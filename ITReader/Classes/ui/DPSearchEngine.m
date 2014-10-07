//
//  DPSearchEngine.m
//  ITReader
//
//  Created by haowenliang on 14-10-5.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPSearchEngine.h"
#import "DPITReaderDef.h"
#import "DPITReaderEventHandler.h"
#import "DPBookSearchResponseModel.h"

#import "DPBookDetailViewController.h"
#import "DPBookInfoView.h"
#import "RTLabel.h"

#define BOOK_INFO_VIEW_TAG (0x1234)
#define BOOK_GUIDE_LABEL_TAG (0x1024)
#define BOOK_GUIDE_LABEL_WIDTH (260)
#define BOOK_GUIDE_LABEL_Y_OFFSET (48)
#define BOOK_GUIDE_TEXT (@"<font face='HelveticaNeue-CondensedBold' size=22><p align=center>Ensure that complete the search keyword, <br>such as <font color=#20b23b>'ios kernel'</font></p></font>")
#define BOOK_GUIDE_LOADING_TEXT (@"<font face='HelveticaNeue-CondensedBold' size=22><p align=center>Searching books from it-ebook.info</p></font>")
#define BOOK_LOADIN_ACTIVITY_TAG (0x1025)
@interface DPSearchEngine()
{
    NSString* _currentSearchText;
}
@end

@implementation DPSearchEngine

- (instancetype)init
{
    if (self = [super init]) {
        _isUpPullRefreshing = NO;
        _currentSearchText = nil;
        _searchResults = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchResponseCallback:) name:kEH_Search_Response_Notification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setCurState:(CurrentState)curState
{
    _curState = curState;
    if (_delegate && [_delegate respondsToSelector:@selector(searchEngine:stateChanged:)]) {
        [_delegate searchEngine:self stateChanged:_curState];
    }
}

- (void)reloadData
{
    if (_delegate && [_delegate respondsToSelector:@selector(searchEngineDatasourceRefleshed:)]) {
        [_delegate searchEngineDatasourceRefleshed:self];
    }
}

- (CGFloat)getHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return TABLE_VIEW_BOOK_INFO_CELL_HEIGHT;
}

#pragma UISearchDisplayDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_searchResults removeAllObjects];
    self.curState = CurrentState_Guide;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.text.length>0) {
        _currentSearchText = searchBar.text;
        _currentPage = -1;
        _totalSearchResult = 0;
        self.curState = CurrentState_Loading;
        [[DPITReaderEventHandler shareInstance] requestForNextPage:_currentPage withWord:_currentSearchText];
    }
}

#pragma UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (CurrentState_Search == _curState) {
        return [self getHeightForRowAtIndexPath:indexPath];
    }
    return tableView.bounds.size.height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;//后续可以增加本地文件搜索
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (CurrentState_Search == _curState) {
        return _searchResults.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (CurrentState_Search == _curState) {
        static NSString *CellIdentifier = @"Result_Cell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        DPBookInfoView* contentView = (DPBookInfoView*)[cell viewWithTag:BOOK_INFO_VIEW_TAG];
        if (!contentView) {
            contentView = [[DPBookInfoView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self getHeightForRowAtIndexPath:indexPath])];
            contentView.tag = BOOK_INFO_VIEW_TAG;
            [cell addSubview:contentView];
        }
        [contentView setModelWithObject:_searchResults[indexPath.row]];
        return cell;
    } else{
        static NSString *CellIdentifier = @"Guide_Cell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        UIActivityIndicatorView* activityView = (UIActivityIndicatorView*)[cell viewWithTag:BOOK_LOADIN_ACTIVITY_TAG];
        if (!activityView) {
            activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityView.tag = BOOK_LOADIN_ACTIVITY_TAG;
            [cell addSubview:activityView];
        }
        if (CurrentState_Loading == _curState) {
            activityView.hidden = NO;
            [activityView startAnimating];
        }else{
            activityView.hidden = YES;
        }
        
        RTLabel* guide = (RTLabel*)[cell viewWithTag:BOOK_GUIDE_LABEL_TAG];
        if (!guide) {
            guide = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, BOOK_GUIDE_LABEL_WIDTH, 0)];
            guide.backgroundColor = [UIColor clearColor];
            guide.tag = BOOK_GUIDE_LABEL_TAG;
            [guide setParagraphReplacement:@""];
            [cell addSubview:guide];
        }
        guide.frame = CGRectMake(0, 0, BOOK_GUIDE_LABEL_WIDTH, 0);
        if (CurrentState_Loading == _curState) {
            [guide setText:BOOK_GUIDE_LOADING_TEXT];
        }else{
            [guide setText:BOOK_GUIDE_TEXT];
        }
        CGSize optimumSize = [guide optimumSize];
        guide.frame = CGRectMake(0, 0, optimumSize.width, optimumSize.height);
        activityView.center = CGPointMake(cell.bounds.size.width/2.0f,BOOK_GUIDE_LABEL_Y_OFFSET/2.0);
        guide.center = CGPointMake(cell.bounds.size.width/2.0f, BOOK_GUIDE_LABEL_Y_OFFSET + optimumSize.height/2.0f);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (CurrentState_Search == _curState) {
        id book = _searchResults[indexPath.row];
        [[DPITReaderEventHandler shareInstance] OpenBookDetailViewController:book];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (CurrentState_Search == _curState && NO == _isUpPullRefreshing){
//            cell.frame = CGRectMake(-320, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
//            [UIView animateWithDuration:0.3 animations:^{
//                    cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
//            } completion:^(BOOL finished) {
//                ;
//            }];
//    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //判断是否拉到底部，触发加载更多
    if (scrollView.contentOffset.y +scrollView.bounds.size.height >= scrollView.contentSize.height) {
        if (!_isUpPullRefreshing)
        {
            [self getNextPageOfSearchResult];
        }
    }
}

- (void)getNextPageOfSearchResult
{
    if ([_searchResults count] >= _totalSearchResult || ![_currentSearchText length]) return;

    if (_currentPage > 0) {
        _currentPage++;
    }else{
        _currentPage = -1;
    }
    _isUpPullRefreshing = YES;
    [[DPITReaderEventHandler shareInstance] requestForNextPage:_currentPage withWord:_currentSearchText];
}

#pragma mark ---- notification handlers -----
- (void)searchResponseCallback:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSString* keyWord = [userInfo objectForKey:kEH_Request_Word];
    DPBookSearchResponseModel *response = [userInfo objectForKey:kEH_Response_Model];
    if (([keyWord length] && NO == [keyWord isEqualToString:_currentSearchText]) || nil == response) {
        return;
    }
    
    _totalSearchResult = [response.Total integerValue];
    NSArray* books = [response Books];
    _currentPage = [[response Page] integerValue];
    if (_currentPage == 1) {
        [_searchResults removeAllObjects];
    }
    if ([books count]) {
        for (id subItem in books){
            [_searchResults addObject:subItem];
        }
    }
    self.curState = CurrentState_Search;
    [self reloadData];
    _isUpPullRefreshing = NO;
}


@end
