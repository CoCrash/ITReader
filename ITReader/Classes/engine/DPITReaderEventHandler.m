//
//  DPITReaderEventHandler.m
//  ITReader
//
//  Created by haowenliang on 14-10-5.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPITReaderEventHandler.h"
#import "DPBookDetailViewController.h"
#import "DPITReaderDef.h"
#import "DPITReaderMgr.h"
#import "AppDelegate.h"
#import "DPDownloadHandler.h"
#import "DPDownloader.h"
#import "DPBookDetailModel.h"

static DPITReaderEventHandler *eInstance = nil;
static dispatch_once_t onceToken_EH;

@implementation DPITReaderEventHandler

+ (DPITReaderEventHandler *)shareInstance
{
    dispatch_once(&onceToken_EH, ^{
        eInstance = [[DPITReaderEventHandler alloc] init];
    });
    return eInstance;
}

- (void)downloadBook:(DPBookDetailModel*)datasource
{
    DPDownloadHandler* handler = [DPDownloadHandler sharedInstance];
    DPDownloader* loader = [[DPDownloader alloc] initWithDatasource:datasource];
    [handler addDownloaderRequest:loader];
    
    [[DPITReaderMgr shareInstance] AddBookDetailItemToTemp:datasource];
    [[DPITReaderMgr shareInstance] AsyncGetTempBookInfo];
}

- (ProgressIndicator *)getDownloadProgressView:(NSString*)fileName
{
    DPDownloadHandler* handler = [DPDownloadHandler sharedInstance];
    DPDownloader* loader = nil;
    if ([fileName length]) {
        loader = [handler getDownloaderRequestOfName:fileName];
    }
    if (loader) {
        return loader.progress;
    }
    return nil;
}

- (void)OpenBookDetailViewController:(id)dataModel
{
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    DPBookDetailViewController* viewctr = [[DPBookDetailViewController alloc] initWithBookModel:dataModel];
    [delegate.navigator pushViewController:viewctr animated:YES];
}

- (void)OpenBookReader:(id)dataModel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DPITReader_OpenPdf_Notify object:dataModel];
}

- (void)requestForNextPage:(NSInteger)page withWord:(NSString*)word
{
    if ([word length]) {
        [[DPITReaderMgr shareInstance] searchBooksForKeyword:word atPage:page comparator:^(NSString *keyword, NSInteger page, DPBookSearchResponseModel *response) {
            //page is the request page, but real page should get from the model
            NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
            if (response) {
                [userInfo setObject:response forKey:kEH_Response_Model];
            }
            if ([keyword length]){
                [userInfo setObject:keyword forKey:kEH_Request_Word];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kEH_Search_Response_Notification object:nil userInfo:userInfo];
        }];
    }
}

@end
