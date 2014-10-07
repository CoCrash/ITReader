//
//  DPBookModel.h
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBaseModel.h"
@protocol DPBookModel @end

@interface DPBookModel : DPBaseModel

@property (nonatomic, assign) NSNumber<Optional>* ID; //book id
@property (nonatomic, strong) NSString<Optional>* Title; //book title
@property (nonatomic, strong) NSString<Optional>* SubTitle;//book subtitle
@property (nonatomic, strong) NSString<Optional>* Description; //book info
@property (nonatomic, strong) NSString<Optional>* Image;  //book photo url
@property (nonatomic, strong) NSString<Optional>* isbn; //book isbn

- (NSString*)fileType;
- (NSString*)fileName;

@end
