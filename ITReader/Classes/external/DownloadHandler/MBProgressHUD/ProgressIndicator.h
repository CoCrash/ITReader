//
//  ProgressIndicator.h
//  DownloadHandler
//
//  Created by 阿 朱 on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressIndicator : UIView
@property (nonatomic, strong) UILabel* label;
//下载资源的总大小
@property CGFloat totalSize;
@end
