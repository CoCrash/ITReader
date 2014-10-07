//
//  DPBookDetailViewController.h
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPViewController.h"

@class DPBookModel;
@class DPBookDetailModel;
@interface DPBookDetailViewController : DPViewController
{
    DPBookDetailModel* _datasource;
}
@property (nonatomic, strong) DPBookDetailModel* datasource;
@property (nonatomic, strong) NSNumber* bookId;
@property (nonatomic, strong) DPBookModel* baseModel;
- (instancetype)initWithBookId:(NSNumber*)bookId;
- (instancetype)initWithBookModel:(id)model;
@end
