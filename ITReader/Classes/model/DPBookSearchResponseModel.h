//
//  DPBookSearchResponseModel.h
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBaseModel.h"
#import "DPBookModel.h"

@interface DPBookSearchResponseModel : DPBaseModel

@property (nonatomic, strong) NSString<Optional>* Error; //Error code / description (Note: request success code = 0)
@property (nonatomic, assign) NSNumber<Optional>* Time; //Request query execution time (seconds)
@property (nonatomic, strong) NSString<Optional>* Total; //The total search results
@property (nonatomic, assign) NSNumber<Optional>* Page; //The page number of results (Note: limit = 10 results on page)
@property (nonatomic, strong) NSArray<DPBookModel, ConvertOnDemand, Optional>* Books;//Search results Array: ID, Title, SubTitle (optional), Description, Image

@end
