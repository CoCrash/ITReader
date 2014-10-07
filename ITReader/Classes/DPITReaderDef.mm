//
//  DPITReaderDef.mm
//  Longan
//
//  Created by haowenliang on 14-5-10.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPITReaderDef.h"
////////////////////////
///////

double hw_getSystemVersion()
{
    static double s_SystemVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
    return s_SystemVersion;
}

bool hw_isDeviceJailBroken()
{
    NSURL* url = [NSURL URLWithString:@"cydia://package/com.example.package"];
    return [[UIApplication sharedApplication] canOpenURL:url];
}

static int static_statusbarHeight = 0;

int getScreenWidth()
{
    static int s_scrWidth = 0;
    if (s_scrWidth == 0){
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        s_scrWidth = screenFrame.size.width;
    }
    return s_scrWidth;
}

int getScreenHeight()
{
    static int s_scrHeight = 0;
    if (s_scrHeight == 0){
        CGRect screenFrame = [UIScreen mainScreen].bounds;
        s_scrHeight = screenFrame.size.height;
    }
    return s_scrHeight;
}

int getStatusBarHeight()
{
    if (static_statusbarHeight == 0) {
        CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
        static_statusbarHeight = MIN(statusBarFrame.size.width, statusBarFrame.size.height);
    }
    return static_statusbarHeight;
}

void setStatusBarHeight(int newH)
{
    static_statusbarHeight = newH;
}
