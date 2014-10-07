//
//  DPBookDetailModel.h
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBaseModel.h"

@interface DPBookDetailModel : DPBaseModel

@property (nonatomic, strong) NSString<Optional>* Error;	//Error code / description (Note: request success code = 0)
@property (nonatomic, strong) NSNumber<Optional>* Time;	//Request query execution time (seconds)
@property (nonatomic, strong) NSNumber<Optional>* ID;	//The ID of the book
@property (nonatomic, strong) NSString<Optional>* Title;	//The title of the book
@property (nonatomic, strong) NSString<Optional>* SubTitle;	//The subtitle of the book
@property (nonatomic, strong) NSString<Optional>* Description;	//The description of the book
@property (nonatomic, strong) NSString<Optional>* Author;	//The author(s) name of the book
@property (nonatomic, strong) NSString<Optional>* ISBN;	//The International Standard Book Number (ISBN) of the book
@property (nonatomic, strong) NSString<Optional>* Page;	//The number of pages of the book
@property (nonatomic, strong) NSString<Optional>* Year;	//The publication date (year) of the book
@property (nonatomic, strong) NSString<Optional>* Publisher;	//The publisher of the book
@property (nonatomic, strong) NSString<Optional>* Image;	//The image URL of the book
@property (nonatomic, strong) NSString<Optional>* Download;	//The download URL of the book


@property (nonatomic, strong) NSString<Optional>* LastTime;//本地记录阅读时间
//下载专用
- (NSString*)fileType;
- (NSString*)fileName;
- (NSString*)cachePath;
- (NSString*)savePath;
- (NSString*)unzipPath;
@end
