//
//  DPBookDetailModel.m
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBookDetailModel.h"
#import "DPFileHelper.h"

@implementation DPBookDetailModel

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
    if ([_ISBN length]) {
        return _ISBN;
    }
    return [NSString stringWithFormat:@"%lu",(long)self];
}

- (NSString *)cachePath
{
    NSString *path = [DPFileHelper readerCachePath];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self fileName], [self fileType]]];
    return path;
}

- (NSString *)savePath
{
    NSString *save = [DPFileHelper readerDestinationPath];
    return [save stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [self fileName], [self fileType]]];
}

//这个基本不会用到
- (NSString *)unzipPath
{
    NSString *save = [DPFileHelper readerDestinationPath];
    return [save stringByAppendingPathComponent:[self fileName]];
}
@end
