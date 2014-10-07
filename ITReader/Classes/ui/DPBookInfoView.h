//
//  DPBookInfoView.h
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPBookModel.h"
#import "DPBookDetailModel.h"

@interface DPBookInfoView : UIView
{
    UIImageView* _bookImage;
    UILabel* _bookTitle;
    UILabel* _bookSubtitle;
    UILabel* _bookDescription;
}
@property (nonatomic, strong) DPBookModel* model;

@property (nonatomic, strong) UIImageView* bookImage;
@property (nonatomic, strong) UILabel* bookTitle;
@property (nonatomic, strong) UILabel* bookSubtitle;
@property (nonatomic, strong) UILabel* bookDescription;

- (void)setModelWithObject:(id)object;

@end

@class ProgressIndicator;
@interface DPLocalBookInfoView : DPBookInfoView
@property (nonatomic, strong) DPBookDetailModel* datasource;
@property (nonatomic, strong) ProgressIndicator* indicator;
@end
