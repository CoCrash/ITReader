//
//  DPITReaderEventHandler.h
//  ITReader
//
//  Created by haowenliang on 14-10-5.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DPBookDetailModel;
@class ProgressIndicator;
@interface DPITReaderEventHandler : NSObject

+ (DPITReaderEventHandler*)shareInstance;
/*下载图书*/
- (void)downloadBook:(DPBookDetailModel*)datamodel;
/*获取图书下载进度条*/
- (ProgressIndicator *)getDownloadProgressView:(NSString*)fileName;

/*打开书本详细页面*/
- (void)OpenBookDetailViewController:(id)dataModel;
/*拉取下一页数据*/
- (void)requestForNextPage:(NSInteger)page withWord:(NSString*)word;
/*打开阅读器*/
- (void)OpenBookReader:(id)dataModel;
@end
