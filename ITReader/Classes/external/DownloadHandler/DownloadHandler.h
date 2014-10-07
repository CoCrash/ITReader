//
//  DownloadHandler.h
//  DownloadHandler
//
//  Created by 阿 朱 on 12-4-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ProgressIndicator.h"
@interface DownloadHandler : NSObject<ASIHTTPRequestDelegate, ASIProgressDelegate>
@property(nonatomic,copy)NSString *url;
//下载资源的名称
@property(nonatomic,copy)NSString *name;
//下载资源的类型，即后缀
@property(nonatomic,copy)NSString *fileType;
@property(nonatomic,copy)NSString *savePath;
@property(nonatomic,retain)ProgressIndicator *progress;
+(DownloadHandler *)sharedInstance;
-(void)start;
@end
