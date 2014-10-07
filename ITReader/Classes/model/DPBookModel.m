//
//  DPBookModel.m
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBookModel.h"

@implementation DPBookModel

- (NSString *)fileType
{
    return @"pdf";
}

- (NSString *)fileName
{
    if ([_Title length]) {
        return [_Title stringByDeletingPathExtension];
    }
    if ([_ID integerValue]) {
        return [NSString stringWithFormat:@"%@",_ID];
    }
    return [NSString stringWithFormat:@"%lu",(long)self];
}


@end
