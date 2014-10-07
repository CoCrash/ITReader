//
//  DPDownloadHandler.h
//  ITReader
//
//  Created by haowenliang on 14-10-3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DPDownloader;
@interface DPDownloadHandler : NSObject

+ (DPDownloadHandler *)sharedInstance;
- (void)addDownloaderRequest:(DPDownloader*)downloader;
- (DPDownloader*)getDownloaderRequestOfName:(NSString*)name;

- (void)removeRequestFromQueueOfName:(NSString*)name;

@end
