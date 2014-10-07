//
//  DPITReaderDef.h
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#ifndef ITReader_DPITReaderDef_h
#define ITReader_DPITReaderDef_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    double hw_getSystemVersion();
    bool hw_isDeviceJailBroken();
    
    int getScreenWidth();
    int getScreenHeight();
    
    // 获取状态栏竖边高度
    int getStatusBarHeight();
    
    void setStatusBarHeight(int newH);
    
#ifdef __cplusplus
}
#endif

#define SCREEN_WIDTH            getScreenWidth()
#define SCREEN_HEIGHT           getScreenHeight()
#define SYSTEM_VERSION hw_getSystemVersion()

#define STATUSBAR_HEIGHT        getStatusBarHeight()
#define APPLICATION_WIDTH       (SCREEN_WIDTH)
#define APPLICATION_HEIGHT      (SCREEN_HEIGHT - STATUSBAR_HEIGHT)




///////Overview////////
#define Resource_URL	@"http://it-ebooks-api.info/v1/"
#define Request_Method	@"GET"
#define Response_Format @"JSON"
#define Response_Encoding	@"UTF-8"

//path
#define Request_Book_Search @"search/"
#define Request_Book_Page @"/page/"
#define Request_Book_Detail @"book/"
///////Book Search////////
/*
Request 
------------------------------------------------------------------
/search/{query}	Search query (Note: 50 characters maximum)
Example: /search/php mysql

/search/{query}/page/{number}
optional	The page number of results (Note: 10 results per page)
Example: /search/php mysql/page/3

 Book Details
 /book/{id}	The ID of the book (Note: returns from /search/)
 Example: /book/2279690981

Limits
------------------------------------------------------------------
1,000 per day	1,000 requests per project (IP / Domain) per day
5 per second	5 requests per project (IP / Domain) per second

 */

#define kEH_Search_Response_Notification @"_kEH_Search_Response_Notification_"
#define kEH_Response_Model @"_event_handler_responsemodel_"
#define kEH_Request_Word @"_event_handler_requestword_"


#define Downloaded_Key @"downloaded_book_list"
#define Downloading_Key @"downloading_book_list"

#define DEMO_VIEW_CONTROLLER_PUSH FALSE
#define Section_Key_Array (@[Downloaded_Key,Downloading_Key])


#define TABLE_VIEW_BOOK_INFO_CELL_HEIGHT (104)

//data mgr

#define DPITRader_LocalBook_Async @"_DPITRader_LocalBook_Async_"
#define DPITRader_TempBook_Async @"_DPITRader_TempBook_Async_"

#define DPITReader_Download_Book_Request_Notify @"_DPITReader_Download_Book_Request_Notify_"
#define DPITReader_Download_Book_Succeed_Notify @"_DPITReader_Download_Book_Succeed_Notify_"
#define DPITReader_Download_Book_Failed_Notify @"_DPITReader_Download_Book_Failed_Notify_"

//打开书本的通知
#define DPITReader_OpenPdf_Notify @"_DPITReader_OpenPdf_Notify_"

#ifndef LOAD_ICON_USE_POOL_CACHE
#define LOAD_ICON_USE_POOL_CACHE(x) [UIImage imageNamed:[NSString stringWithFormat:@"%@",x]]
#endif

#ifndef RGBACOLOR
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#endif


//豆瓣阅读
#define DOUBAN_READ_URL @"http://book.douban.com/isbn/"    //(xxxxxxxxx是图书的ISBN编号)
#endif
