//
//  DPITReaderMgr.h
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"

typedef NS_ENUM(NSUInteger, DPBOOK_STATE) {
    DPBOOK_STATE_UNDownload,
    DPBOOK_STATE_Downloading,
    DPBOOK_STATE_Downloaded,
};

@class DPBookSearchResponseModel;
@class DPBookDetailModel;

@interface DPITReaderMgr : NSObject
+ (DPITReaderMgr*)shareInstance;

- (DPBOOK_STATE)checkBookDownloadState:(DPBookDetailModel*)model;
- (void)AddBookDetailItemToTemp:(DPBookDetailModel* ) model;
- (BOOL)DeleteBookDownloadItem:(NSUInteger)bookId;
- (BOOL)DeleteBookLocalItem:(NSUInteger)bookId;
- (void)AsyncGetLocalBookInfo;
- (void)AsyncGetTempBookInfo;
/*
 *search books for demended words
 *if page = -1, without page sub path
 */
- (void)searchBooksForKeyword:(NSString*)keyword atPage:(NSInteger)page comparator:(void(^)(NSString* keyword, NSInteger page, DPBookSearchResponseModel* response))callback;

/*
 *search book for demended id
 */
- (void)detailsOfBookWithId:(NSNumber*)bookId comparator:(void(^)(DPBookDetailModel* Book))callback;

- (NSArray*)GetLocalBookInfo;
- (NSArray*)GetTempBookInfo;

@end
