//
//  DPDownloader.h
//  ITReader
//
//  Created by haowenliang on 14-10-3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ProgressIndicator.h"

@class DPBookDetailModel;

typedef NS_ENUM(NSUInteger, DPDownloadState) {
    DPDownloadState_Waiting,
    DPDownloadState_Downloading,
    DPDownloadState_Succeed,
    DPDownloadState_Failed,
};

@class DPDownloader;
@protocol DPDownloaderProtocol <NSObject>

- (void)dpDownloader:(DPDownloader*)downloader currentStart:(DPDownloadState)state;

@end

@interface DPDownloader : NSObject<ASIHTTPRequestDelegate, ASIProgressDelegate>
@property (nonatomic, assign) id<DPDownloaderProtocol> delegate;
@property (nonatomic, strong) DPBookDetailModel* datasource;

@property (nonatomic,copy) NSString *url;
//下载资源的名称
@property (nonatomic,copy) NSString *name;
//下载资源的类型，即后缀
@property (nonatomic,copy) NSString *fileType;
@property (nonatomic,copy) NSString *savePath;

@property (nonatomic,retain) ASIHTTPRequest *request;
@property (nonatomic,retain) ProgressIndicator *progress;
@property (nonatomic, assign, readonly) DPDownloadState dowloadState;

- (void)resetProgressIndicatorFrame:(CGRect)frame;

- (instancetype)initWithDatasource:(DPBookDetailModel*)model;
- (NSString *)cachesPath;
- (NSString *)actualSavePath;
- (NSString*)unzipPath;
-(void)generateHttpRequest;
@end
