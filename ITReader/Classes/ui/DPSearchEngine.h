//
//  DPSearchEngine.h
//  ITReader
//
//  Created by haowenliang on 14-10-5.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CurrentState) {
    CurrentState_Guide = 0,
    CurrentState_Loading = 1,
    CurrentState_Search = 2,
};
@class DPSearchEngine;
@protocol DPSearchEngineProtocol <NSObject>

- (void)searchEngineDatasourceRefleshed:(DPSearchEngine*)engine;

- (void)searchEngine:(DPSearchEngine *)engine stateChanged:(CurrentState)state;

@end

@interface DPSearchEngine : NSObject<UITableViewDataSource, UITableViewDelegate,UISearchDisplayDelegate,UISearchBarDelegate>
{
    NSMutableArray* _searchResults;
    
    BOOL _isUpPullRefreshing;
    CurrentState _curState;
    NSInteger _currentPage;
    NSInteger _totalSearchResult;
}

@property (nonatomic, assign) id<DPSearchEngineProtocol> delegate;
@property (nonatomic, assign) CurrentState curState;

@end
