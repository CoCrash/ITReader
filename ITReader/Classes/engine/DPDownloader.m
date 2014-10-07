//
//  DPDownloader.m
//  ITReader
//
//  Created by haowenliang on 14-10-3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPDownloader.h"
#import "DPFileHelper.h"
#import "DPBookDetailModel.h"

@implementation DPDownloader

-(id)init
{
    if (self = [super init]){
        _dowloadState = DPDownloadState_Waiting;
        _request = nil;
    }
    return self;
}

- (instancetype)initWithDatasource:(DPBookDetailModel*)model
{
    if (self = [self init]) {
        self.datasource = model;
        if (_datasource) {
            _url = _datasource.Download;
            _fileType = [_datasource fileType];
            _name = [_datasource fileName];
            _progress = [[ProgressIndicator alloc] initWithFrame:CGRectMake(0, 0, 100, 33)];
        }
    }
    return self;
}

- (void)resetProgressIndicatorFrame:(CGRect)frame
{
    if (_progress) {
        _progress.frame = frame;
    }
}

- (ASIHTTPRequest *)request
{
    if (nil == _request) {
        [self generateHttpRequest];
    }
    return _request;
}

-(void)generateHttpRequest
{
    if (![_url length]) {
        _request = nil;
        return;
    }
    NSURL *url = [NSURL URLWithString:_url];
    _request = [ASIHTTPRequest requestWithURL:url];
    _request.delegate = self;
    _request.temporaryFileDownloadPath = [self cachesPath];
    _request.downloadDestinationPath = [self actualSavePath];
    _request.downloadProgressDelegate = _progress;
    _request.allowResumeForFileDownloads = YES;
    _request.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:_name, @"Name", nil];
    
    [_request addRequestHeader:@"Host" value:@"filepi.com"];
    [_request addRequestHeader:@"Referer" value:@"http://it-ebooks.info/"];
}

- (NSString *)actualSavePath
{
    if (_datasource && [[_datasource savePath] length]) {
        return [_datasource savePath];
    }
    if (![_savePath length]) {
        _savePath = [DPFileHelper readerDestinationPath];
    }
    return [_savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", _name, _fileType]];
}

- (NSString *)cachesPath
{
    if (_datasource && [[_datasource cachePath] length]) {
        
        return [_datasource cachePath];
    }
    
    NSString *path = [DPFileHelper readerCachePath];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", _name, _fileType]];
    return path;
}

- (NSString*)unzipPath
{
    if (_datasource && [[_datasource unzipPath] length]) {
        
        return [_datasource unzipPath];
    }
    
    if (![_savePath length]) {
        _savePath = [DPFileHelper readerDestinationPath];
    }
    return [_savePath stringByAppendingPathComponent:_name];
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"total size: %lld", request.contentLength);
    _progress.totalSize = request.contentLength/1024.0/1024.0;
}

-(void)requestStarted:(ASIHTTPRequest *)request
{
    _dowloadState = DPDownloadState_Downloading;
    if (_delegate && [_delegate respondsToSelector:@selector(dpDownloader:currentStart:)]) {
        [_delegate dpDownloader:self currentStart:_dowloadState];
    }
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    _dowloadState = DPDownloadState_Succeed;
    if (_delegate && [_delegate respondsToSelector:@selector(dpDownloader:currentStart:)]) {
        [_delegate dpDownloader:self currentStart:_dowloadState];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"download failed, error: %@", error);
    _dowloadState = DPDownloadState_Failed;
    if (_delegate && [_delegate respondsToSelector:@selector(dpDownloader:currentStart:)]) {
        [_delegate dpDownloader:self currentStart:_dowloadState];
    }
}

@end
