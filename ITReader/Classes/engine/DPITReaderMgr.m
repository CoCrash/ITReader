//
//  DPITReaderMgr.m
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPITReaderMgr.h"
#import "DPITReaderDef.h"
#import "DPFileHelper.h"
#import "DPBookDetailModel.h"
#import "DPBookSearchResponseModel.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
static DPITReaderMgr *sInstance = nil;
static dispatch_once_t onceToken;
static FMDatabase *itReaderDB = nil;

//本地数据表
#define TableLocalBookDetailInfo "(ID integer primary key, BookId integer, BookDetail blob)"
//下载列表
#define TableTempBookDetailInfo "(ID integer primary key, BookId integer, BookDetail blob)"

#define DBTableCheck(DataBase, TableName) \
if (![DataBase tableExists:@#TableName]) \
{ \
[DataBase executeUpdate:@("CREATE TABLE IF NOT EXISTS " #TableName " " Table##TableName)]; \
}

#define ArchivedDataOrNil(Obj) ((nil != (Obj)) ? [NSKeyedArchiver archivedDataWithRootObject:(Obj)] : nil)

#define READER_CACHE_DIR            @"ReaderDb"
#define READER_DATABASE_NAME   @"itreader.db"

@interface DPITReaderMgr()
{
    BOOL tempNeedToSyncDatabase;
    BOOL localNeedToSyncDatabase;
}

@property (nonatomic, strong) NSMutableArray* localBookList;
@property (nonatomic, strong) NSMutableArray* tempBookList;

@end

@implementation DPITReaderMgr

+ (DPITReaderMgr *)shareInstance
{
    dispatch_once(&onceToken, ^{
        sInstance = [[DPITReaderMgr alloc] init];
    });
    return sInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        localNeedToSyncDatabase = YES;
        tempNeedToSyncDatabase = YES;
        _localBookList = [[NSMutableArray alloc] init];
        _tempBookList = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(operationForDownloadingABook:) name:DPITReader_Download_Book_Request_Notify object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(operationForDownloadFailed:) name:DPITReader_Download_Book_Failed_Notify object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(operationForDownloadSucceed:) name:DPITReader_Download_Book_Succeed_Notify object:nil];
    }
    return self;
}

#pragma mark ---- notification ----
- (void)operationForDownloadingABook:(NSNotification*)notification
{
    DPBookDetailModel* book = (DPBookDetailModel*)notification.object;
    [self AddBookDetailItemToTemp:book];
    [self AsyncGetTempBookInfo];
}

- (void)operationForDownloadFailed:(NSNotification*)notification
{
//    DPBookDetailModel* book = (DPBookDetailModel*)notification.object;
//    [self DeleteBookDownloadItem:[book.ID unsignedIntegerValue]];
//    [self AsyncGetTempBookInfo];
}

- (void)operationForDownloadSucceed:(NSNotification*)notification
{
    DPBookDetailModel* book = (DPBookDetailModel*)notification.object;
    [self DeleteBookDownloadItem:[book.ID unsignedIntegerValue]];
    [self AddBookDetailItemToLocal:book];
    [self AsyncGetTempBookInfo];
    [self AsyncGetLocalBookInfo];
}

#pragma mark ---- 网络请求 ----
- (void)searchBooksForKeyword:(NSString*)keyword atPage:(NSInteger)page comparator:(void (^)(NSString *, NSInteger, DPBookSearchResponseModel *))callback
{
    if (![keyword length]) {
        return;
    }
    NSMutableString* urlStr = [NSMutableString stringWithFormat:Resource_URL];
    [urlStr appendString:Request_Book_Search];
    [urlStr appendString:keyword];
    if (-1 != page) {
        [urlStr appendString:Request_Book_Page];
        [urlStr appendString:[NSString stringWithFormat:@"%ld",(long)page]];
    }
    NSString* encodeStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* ghData = [NSData dataWithContentsOfURL:[NSURL URLWithString:encodeStr]];
        NSDictionary* json = nil;
        if (ghData) {
            json = [NSJSONSerialization
                    JSONObjectWithData:ghData
                    options:kNilOptions
                    error:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            DPBookSearchResponseModel* model = [[DPBookSearchResponseModel alloc] initWithDictionary:json error:NULL];
            callback(keyword, page, model);
        });
    });
}

- (void)detailsOfBookWithId:(NSNumber*)bookId comparator:(void (^)(DPBookDetailModel *))callback
{
    if (![bookId integerValue]) {
        return;
    }
    DPBookDetailModel* cacheData = [self cacheDetailInfoOfBookWithId:bookId];
    if (cacheData) {
        callback(cacheData);
        return;
    }
    NSString* urlStr = [NSString stringWithFormat:@"%@%@%@",Resource_URL,Request_Book_Detail,bookId];
    NSString* encodeStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData* ghData = [NSData dataWithContentsOfURL:[NSURL URLWithString:encodeStr]];
        NSDictionary* json = nil;
        if (ghData) {
            json = [NSJSONSerialization
                    JSONObjectWithData:ghData
                    options:kNilOptions
                    error:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            DPBookDetailModel* model = [[DPBookDetailModel alloc] initWithDictionary:json error:NULL];
            callback(model);
        });
    });
}
#pragma mark ---- 本地数据操作 ----
- (DPBOOK_STATE)checkBookDownloadState:(DPBookDetailModel*)model
{
    //已经下载过+ 正在下载
    for (DPBookDetailModel* obj in _localBookList)
    {
        if ([[obj fileName] isEqualToString:[model fileName]] || [obj.ISBN isEqualToString:model.ISBN]) {
            return DPBOOK_STATE_Downloaded;
        }
    }
    for (DPBookDetailModel* obj in _tempBookList) {
        if ([[obj fileName] isEqualToString:[model fileName]] || [obj.ISBN isEqualToString:model.ISBN]) {
            return DPBOOK_STATE_Downloading;
        }
    }
    return DPBOOK_STATE_UNDownload;
}

- (NSArray*)GetLocalBookInfo
{
    NSLog(@"%s",__FUNCTION__);
    if (![_localBookList count] && localNeedToSyncDatabase) {
        dispatch_async(kBgQueue, ^{
            [self AsyncGetLocalBookInfo];
        });
    }
    NSLog(@"async get local book info?");
    return _localBookList;
}

- (void)AsyncGetLocalBookInfo
{
    localNeedToSyncDatabase = NO;
    NSString *DatabasePath = [DPITReaderMgr GetDatabasePath:NO];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DatabasePath];
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"select BookDetail,BookId from LocalBookDetailInfo"];
        @synchronized(_localBookList){
            [_localBookList removeAllObjects];
            while ([rs next]) {
                DPBookDetailModel* model = (DPBookDetailModel*)[NSKeyedUnarchiver unarchiveObjectWithData:[rs dataForColumnIndex:0]];
                NSNumber* bookid = [NSNumber numberWithUnsignedInteger:[rs intForColumnIndex:1]];
                model.ID = bookid;
                model.Time = nil;
                [_localBookList addObject:model];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DPITRader_LocalBook_Async object:nil];
            NSLog(@"notification: %@",DPITRader_LocalBook_Async);
        }
    }];
}

- (NSArray*)GetTempBookInfo
{
    if (![_tempBookList count] && tempNeedToSyncDatabase) {
        dispatch_async(kBgQueue, ^{
            [self AsyncGetTempBookInfo];
        });
    }
    return _tempBookList;
}

- (void)AsyncGetTempBookInfo
{
    tempNeedToSyncDatabase = NO;
    NSString *DatabasePath = [DPITReaderMgr GetDatabasePath:NO];
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DatabasePath];
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"select BookDetail,BookId from TempBookDetailInfo"];
        @synchronized(_tempBookList){
            [_tempBookList removeAllObjects];
            while ([rs next]) {
                DPBookDetailModel* model = (DPBookDetailModel*)[NSKeyedUnarchiver unarchiveObjectWithData:[rs dataForColumnIndex:0]];
                NSNumber* bookid = [NSNumber numberWithUnsignedInteger:[rs intForColumnIndex:1]];
                model.ID = bookid;
                model.Time = nil;
                [_tempBookList addObject:model];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DPITRader_TempBook_Async object:nil];
        }
    }];
}

- (DPBookDetailModel*)cacheDetailInfoOfBookWithId:(NSNumber*)bookId
{
    if (bookId == nil || [bookId isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return nil;
    }
    for(DPBookDetailModel* model in _localBookList)
    {
        if ([model.ID isEqualToNumber:bookId]) {
            return model;
        }
    }
    for (DPBookDetailModel* cache in _tempBookList) {
        if ([cache.ID isEqualToNumber:bookId]) {
            return cache;
        }
    }
    return nil;
}
#pragma mark ---- 增加书本信息 ----
- (void)AddBookDetailItemToTemp:(DPBookDetailModel* ) model
{
    NSNumber* bookId = model.ID;
    if (!bookId) {
        return;
    }
    //更新本地数据
    FMDatabase *db = nil;
    db = [DPITReaderMgr OpenReaderDatabase:NO];
    if (nil == db)
    {
        return;
    }
    NSData *data = ArchivedDataOrNil(model);
    if ([db beginTransaction])
    {
        [db executeUpdate:@"INSERT OR IGNORE INTO TempBookDetailInfo(BookId) VALUES(?)", bookId];
        [db executeUpdate:@"UPDATE TempBookDetailInfo SET BookDetail = ? WHERE BookId = ? AND BookDetail IS NULL", data, bookId];
        [db commit];
    }
}

- (void)AddBookDetailItemToLocal:(DPBookDetailModel* ) model
{
    NSNumber* bookId = model.ID;
    if (!bookId) {
        return;
    }
    //更新本地数据
    FMDatabase *db = nil;
    db = [DPITReaderMgr OpenReaderDatabase:NO];
    if (nil == db)
    {
        return;
    }
    NSData *data = ArchivedDataOrNil(model);
    if ([db beginTransaction])
    {
        [db executeUpdate:@"INSERT OR IGNORE INTO LocalBookDetailInfo(BookId) VALUES(?)", bookId];
        [db executeUpdate:@"UPDATE LocalBookDetailInfo SET BookDetail = ? WHERE BookId = ? AND BookDetail IS NULL", data, bookId];
        [db commit];
    }
}

#pragma mark ---- 删除书本信息 ----
//删除下载item
- (BOOL)DeleteBookDownloadItem:(NSUInteger)bookId
{
    FMDatabase *db = nil;
    db = [DPITReaderMgr OpenReaderDatabase:NO];
    if (nil == db)
    {
        return NO;
    }
    [db beginTransaction];
    BOOL result = [db executeUpdate:@"DELETE FROM TempBookDetailInfo WHERE BookId = ?", [NSNumber numberWithUnsignedInteger:bookId]];
    [db commit];
    
    return result;
}

//删除本地数据item
- (BOOL)DeleteBookLocalItem:(NSUInteger)bookId
{
    FMDatabase *db = nil;
    db = [DPITReaderMgr OpenReaderDatabase:NO];
    if (nil == db)
    {
        return NO;
    }
    [db beginTransaction];
    BOOL result = [db executeUpdate:@"DELETE FROM LocalBookDetailInfo WHERE BookId = ?", [NSNumber numberWithUnsignedInteger:bookId]];
    [db commit];
    
    return result;
}
//删除表
- (BOOL)DeleteTable:(FMDatabase*)db Table:(NSString*)TableName
{
    if (nil == db)
    {
        return NO;
    }
    [db beginTransaction];
    BOOL result = [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE %@", TableName]];
    [db commit];
    
    return result;
}

#pragma mark -----Database Operation-----

+ (FMDatabase*)OpenReaderDatabase:(BOOL)isCareLoginId
{
    return [DPITReaderMgr PrepareReaderDB];
}

+ (void)CheckBookReaderDB:(FMDatabase *)db
{
    DBTableCheck(db, LocalBookDetailInfo)
    DBTableCheck(db, TempBookDetailInfo)
}

+ (FMDatabase *)PrepareReaderDB
{
    @synchronized (self)
    {
        if (nil == itReaderDB)
        {
            NSString *DatabasePath = [self GetDatabasePath:NO];
            itReaderDB = [self CreateDatabaseWithPath:DatabasePath];
            
            if (itReaderDB)      // 这里建表
            {
                [DPITReaderMgr CheckBookReaderDB:itReaderDB];
            }
        }
    }
    
    return itReaderDB;
}

+ (FMDatabase *)CreateDatabaseWithPath:(NSString *)dbPath
{
    if (nil == dbPath)
    {
        return nil;
    }
    //创建数据库实例,如果是路径中不存在db的文件,会自动创建一个db文件
    FMDatabase *db= [FMDatabase databaseWithPath:dbPath];
    if (![db open] || ![db goodConnection])
    {
        NSLog(@"Open PADB(%s) 1st try failed", [[dbPath lastPathComponent] UTF8String]);
        [db close];
        [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
        if (![db open] || ![db goodConnection])
        {
            return nil;
        }
    }
    [db setShouldCacheStatements:YES];
    
    return db;
}

+ (NSString *)GetDatabasePath:(BOOL)IsCareLoginId
{
    NSString *CacheName = nil;
    NSString *DatabaseName = nil;
    
    if (IsCareLoginId)
    {
        NSString *CacheDir = [DPITReaderMgr GetCurrentLoginId];
        
        if (nil == CacheDir)
        {
            return nil;
        }
        
        CacheName = [NSString stringWithFormat:@"%@/%@", READER_CACHE_DIR, CacheDir];
        DatabaseName = READER_DATABASE_NAME;
    }
    else
    {
        CacheName = READER_CACHE_DIR;
        DatabaseName = READER_DATABASE_NAME;
    }
    
    NSString *DatabaseDir = [DPITReaderMgr cachePathWithName:CacheName];
    NSString *DatabasePath = [DatabaseDir stringByAppendingPathComponent:DatabaseName];
    return DatabasePath;
}

+ (NSString*)GetCurrentLoginId
{
    return nil;
}

#pragma mark - Dir Tools
+ (NSString*)cachePathWithName:(NSString*)name
{
    return [DPFileHelper dbCachePathWithName:name];
}

@end
