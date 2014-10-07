//
//  DPFileHelper.h
//  ITReader
//
//  Created by haowenliang on 14-10-3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPFileHelper : NSObject

//文档缓存路劲
+ (NSString*)readerCachePath;
+ (NSString*)readerDestinationPath;

//数据库存储路径
+ (NSString*)dbCachePathWithName:(NSString*)name;

//helper
+ (BOOL)createPathIfNecessary:(NSString*)path;
+ (BOOL)isFileExistAtPath:(NSString*)filePath;
+ (void)removePath:(NSString *)path;
@end
