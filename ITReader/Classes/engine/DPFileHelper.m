//
//  DPFileHelper.m
//  ITReader
//
//  Created by haowenliang on 14-10-3.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPFileHelper.h"

@implementation DPFileHelper

+ (NSString*)readerCachePath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    [DPFileHelper createPathIfNecessary:path];
    [path stringByAppendingString:@"DownloadCache"];
    [DPFileHelper createPathIfNecessary:path];
    return path;
}

+ (NSString*)readerDestinationPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths lastObject];
    [DPFileHelper createPathIfNecessary:path];
    [path stringByAppendingString:@"BookStore"];
    [DPFileHelper createPathIfNecessary:path];
    return path;
}

+ (NSString*)dbCachePathWithName:(NSString*)name
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [paths objectAtIndex:0];
    NSString* cachePath = [cachesPath stringByAppendingPathComponent:name];
    
    [DPFileHelper createPathIfNecessary:cachesPath];
    [DPFileHelper createPathIfNecessary:cachePath];
    return cachePath;
}

+ (void)removePath:(NSString *)path
{
    if (nil != path)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        @try
        {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
        }
        @catch (NSException *e)
        {
        }
        @finally
        {
        }
    }
}

+ (BOOL)isFileExistAtPath:(NSString*)filePath
{
    if (!filePath)
    {
        return NO;
    }
    
    NSFileManager* fileManger = [NSFileManager defaultManager];
    
    BOOL fileExist = NO;
    @try
    {
        fileExist = [fileManger fileExistsAtPath:filePath];
    }
    @catch (NSException * e)
    {
    }
    @finally
    {
    }
    return fileExist;
}


+ (BOOL)createPathIfNecessary:(NSString*)path
{
    BOOL succeeded = YES;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path])
    {
        succeeded = [fm createDirectoryAtPath: path
                  withIntermediateDirectories: YES
                                   attributes: nil
                                        error: nil];
    }
    
    return succeeded;
}

@end
