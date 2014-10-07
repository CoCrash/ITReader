//
//  DPDownloadHandler.m
//  ITReader
//
//  Created by haowenliang on 14-10-3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPDownloadHandler.h"
#import "DPDownloader.h"
#import "ASINetworkQueue.h"
#import "DPITReaderDef.h"
#import "ZipArchive.h"

static DPDownloadHandler *sharedDownloadhandler = nil;

@interface DPDownloadHandler ()<DPDownloaderProtocol>
{
    ASINetworkQueue *_queue;
    NSMutableSet* _downloaderSet;
}
@end

@implementation DPDownloadHandler

+ (DPDownloadHandler *)sharedInstance
{
    if (!sharedDownloadhandler) {
        sharedDownloadhandler = [[DPDownloadHandler alloc] init];
    }
    return sharedDownloadhandler;
}

- (id)init
{
    if (self = [super init]) {
        _downloaderSet = [[NSMutableSet alloc] init];
        
        if (!_queue) {
            _queue = [[ASINetworkQueue alloc] init];
            _queue.showAccurateProgress = YES;
            _queue.shouldCancelAllRequestsOnFailure = NO;
            [_queue go];
        }
    }
    return self;
}

- (void)addDownloaderRequest:(DPDownloader*)downloader
{
    if (!downloader || !downloader.request) {
        return;
    }
    for (ASIHTTPRequest *r in [_queue operations]) {
        NSString *fileName = [r.userInfo objectForKey:@"Name"];
        if ([fileName isEqualToString:downloader.name]) {
            return;//队列中已存在特定request时，退出
        }
    }
    downloader.delegate = self;
    [_downloaderSet addObject:downloader];
    [_queue addOperation:downloader.request];
}

- (DPDownloader*)getDownloaderRequestOfName:(NSString*)name
{
    if ([name length]) {
        for (ASIHTTPRequest *r in [_queue operations]) {
            NSString *fileName = [r.userInfo objectForKey:@"Name"];
            if ([fileName isEqualToString:name]) {
                return (DPDownloader*)r.delegate;
            }
        }
    }
    return nil;
}

- (void)removeRequestFromQueueOfName:(NSString*)name
{
    if ([name length]) {
        for (ASIHTTPRequest *r in [_queue operations]) {
            NSString *fileName = [r.userInfo objectForKey:@"Name"];
            if ([fileName isEqualToString:name]) {
                [_downloaderSet removeObject:r.delegate];
                [r clearDelegatesAndCancel];
            }
        }
    }
}

- (void)removeRequestFromQueueOfDownloader:(DPDownloader*)downloader
{
    for (ASIHTTPRequest *r in [_queue operations]) {
        NSString *fileName = [r.userInfo objectForKey:@"Name"];
        if ([fileName isEqualToString:downloader.name]) {
            [r clearDelegatesAndCancel];
        }
    }
    downloader.delegate = nil;
    [_downloaderSet removeObject:downloader];
}

- (void)unzipFileOfDownloader:(DPDownloader*)downloader
{
    NSString *unzipPath = [downloader unzipPath];
    ZipArchive *unzip = [[ZipArchive alloc] init];
    if ([unzip UnzipOpenFile:[downloader actualSavePath]]) {
        BOOL result = [unzip UnzipFileTo:unzipPath overWrite:YES];
        if (result) {
            NSLog(@"unzip successfully");
        }
        [unzip UnzipCloseFile];
    }
    unzip = nil;
}

#pragma mark ----Downloader Delegate-----
- (void)dpDownloader:(DPDownloader *)downloader currentStart:(DPDownloadState)state
{
    switch (state) {
        case DPDownloadState_Waiting:
        case DPDownloadState_Downloading:
        {
            
        } break;
        case DPDownloadState_Succeed:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:DPITReader_Download_Book_Succeed_Notify object:downloader.datasource];
            if ([downloader.fileType isEqualToString:@"zip"]) {
                [self unzipFileOfDownloader:downloader];
            }
            [self removeRequestFromQueueOfDownloader:downloader];
        } break;
        case DPDownloadState_Failed:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:DPITReader_Download_Book_Failed_Notify object:downloader.datasource];
            [self removeRequestFromQueueOfDownloader:downloader];
        } break;
        default:
            break;
    }
}


@end
