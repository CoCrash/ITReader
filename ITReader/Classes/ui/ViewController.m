//
//  ViewController.m
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

//copy action
//    NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:_dimmingView];
//    UIView* copyview = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];


#import "ViewController.h"
#import "UIImageView+WebCache.h"

#import "DPBookDetailViewController.h"
#import "DPITReaderMgr.h"
#import "DPBookSearchResponseModel.h"
#import "DPBookModel.h"
#import "DPBookDetailModel.h"
#import "DPBookInfoView.h"
#import "DPITReaderDef.h"

#import "DPDownloadHandler.h"
#import "DPDownloader.h"
#import "DPITReaderEventHandler.h"
#import "DPFileHelper.h"
#import "DPSearchEngine.h"

@interface ViewController ()<DPSearchEngineProtocol>
{
    UIView* _dimmingView;
    NSMutableDictionary* _bookfilesInHistory;
    
    DPSearchEngine* _searchEngine;
}

@end

@implementation ViewController

- (void)loadView
{
    [super loadView];
    
    _searchEngine = [[DPSearchEngine alloc] init];
    _searchEngine.delegate = self;
    
    CGRect viewFrame = self.view.bounds;
    _dimmingView = [[UIView alloc] initWithFrame:viewFrame];
    _dimmingView.backgroundColor = [UIColor colorWithRed:0xf0/255.0 green:0xf0/255.0 blue:0xf0/255.0 alpha:1];

    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    _searchBar.delegate = _searchEngine;
    [_searchBar setPlaceholder:@"搜索在线IT电子书"];
    
    _searchResultDisplay = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    _searchResultDisplay.active = NO;
    _searchResultDisplay.delegate = _searchEngine;
    _searchResultDisplay.displaysSearchBarInNavigationBar = NO;
    _searchResultDisplay.searchResultsDataSource = _searchEngine;
    _searchResultDisplay.searchResultsDelegate = _searchEngine;
    [_searchResultDisplay.searchResultsTableView setBackgroundColor:[UIColor whiteColor]];
    
    _tableView.tableHeaderView = _searchBar;
    UIView* footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 0.1)];
    footer.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = footer;
    [_searchResultDisplay.searchResultsTableView setTableFooterView:footer];
    _searchResultDisplay.searchResultsTableView.scrollEnabled = NO;
    
    [self.view addSubview:_tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"IT-eBook";
    
    _bookfilesInHistory = [[NSMutableDictionary alloc] init];
    
    NSArray* datasource = [[[DPITReaderMgr shareInstance] GetLocalBookInfo] copy];
    if ([datasource count]) {
        [_bookfilesInHistory setObject:datasource forKey:Downloaded_Key];
    }else{
        [_bookfilesInHistory setObject:@[] forKey:Downloaded_Key];
    }
    NSArray* downloading = [[[DPITReaderMgr shareInstance] GetTempBookInfo] copy];
    if ([downloading count]) {
        [_bookfilesInHistory setObject:downloading forKey:Downloading_Key];
        [self operationsForDownloadBooks];
    }else{
        [_bookfilesInHistory setObject:@[] forKey:Downloading_Key];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localBookInfoAsyncSucceed:) name:DPITRader_LocalBook_Async object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempBookInfoAsyncSucceed:) name:DPITRader_TempBook_Async object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---- Data Async Notification ----
- (void)localBookInfoAsyncSucceed:(NSNotification *)notification
{
    NSArray* datasource = [[[DPITReaderMgr shareInstance] GetLocalBookInfo] copy];
    if ([datasource count]) {
        [_bookfilesInHistory setObject:datasource forKey:Downloaded_Key];
    }else{
        [_bookfilesInHistory setObject:@[] forKey:Downloaded_Key];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (void)tempBookInfoAsyncSucceed:(NSNotification *)notification
{
    NSArray* downloading = [[[DPITReaderMgr shareInstance] GetTempBookInfo] copy];
    if ([downloading count]) {
        [_bookfilesInHistory setObject:downloading forKey:Downloading_Key];
        [self operationsForDownloadBooks];
    }else{
        [_bookfilesInHistory setObject:@[] forKey:Downloading_Key];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
    });
}

- (void)operationsForDownloadBooks
{
    DPDownloadHandler* handler = [DPDownloadHandler sharedInstance];
    NSArray* downloading = [_bookfilesInHistory objectForKey:Downloading_Key];
    if ([downloading count]) {
        [downloading enumerateObjectsUsingBlock:^(DPBookDetailModel* obj, NSUInteger idx, BOOL *stop) {
            DPDownloader* loader = [[DPDownloader alloc] initWithDatasource:obj];
            [handler addDownloaderRequest:loader];
        }];
    }
}

#pragma UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_bookfilesInHistory count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLE_VIEW_BOOK_INFO_CELL_HEIGHT;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        return @"已下载：";
    }
    return @"下载中：";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < [Section_Key_Array count]) {
        NSArray* secdata = [_bookfilesInHistory objectForKey:Section_Key_Array[section]];
        return [secdata count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    if (indexPath.section < [Section_Key_Array count]) {
        NSArray* secdata = [_bookfilesInHistory objectForKey:Section_Key_Array[indexPath.section]];
        if (indexPath.row < [secdata count]) {
            DPBookDetailModel* model = secdata[indexPath.row];
            DPLocalBookInfoView* infoView = (DPLocalBookInfoView*)[cell viewWithTag:0x1024];
            if (!infoView) {
                infoView = [[DPLocalBookInfoView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TABLE_VIEW_BOOK_INFO_CELL_HEIGHT)];
                infoView.tag = 0x1024;
                [cell addSubview:infoView];
            }
            [infoView setDatasource:model];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section < [Section_Key_Array count]) {
        NSArray* secdata = [_bookfilesInHistory objectForKey:Section_Key_Array[indexPath.section]];
        if (indexPath.row < [secdata count]) {
            DPBookDetailModel* model = secdata[indexPath.row];
            switch ([[DPITReaderMgr shareInstance] checkBookDownloadState:model]) {
                case DPBOOK_STATE_UNDownload:
                case DPBOOK_STATE_Downloading:{
                    DPBookModel* tmpModel = [[DPBookModel alloc] init];
                    tmpModel.ID = model.ID;
                    tmpModel.Title = model.Title;
                    tmpModel.Image = model.Image;
                    [[DPITReaderEventHandler shareInstance] OpenBookDetailViewController:tmpModel];
                }break;
                case DPBOOK_STATE_Downloaded:
                {
                    [self openPdfReader:[model savePath]];
                }break;
                default:
                    break;
            }
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath      //当在Cell上滑动时会调用此函数
{
    return  UITableViewCellEditingStyleDelete;  //返回此值时,Cell会做出响应显示Delete按键,点击Delete后会调用下面的函数,别给传递UITableViewCellEditingStyleDelete参数
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath //对选中的Cell根据editingStyle进行操
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section < [Section_Key_Array count]) {
            NSArray* secdata = [_bookfilesInHistory objectForKey:Section_Key_Array[indexPath.section]];
            if (indexPath.row < [secdata count]) {
                DPBookDetailModel* model = secdata[indexPath.row];
                switch ([[DPITReaderMgr shareInstance] checkBookDownloadState:model]) {
                    case DPBOOK_STATE_UNDownload:
                    case DPBOOK_STATE_Downloading:{
                        //remove database & download request & cache file
                        [[DPDownloadHandler sharedInstance] removeRequestFromQueueOfName:[model fileName]];
                        [DPFileHelper removePath:[model cachePath]];
                        [[DPITReaderMgr shareInstance] DeleteBookDownloadItem:[model.ID  unsignedIntegerValue]];
                        [[DPITReaderMgr shareInstance] AsyncGetTempBookInfo];
                    }break;
                    case DPBOOK_STATE_Downloaded:
                    {
                        //remove database & document file
                        [DPFileHelper removePath:[model savePath]];
                        [[DPITReaderMgr shareInstance] DeleteBookLocalItem:[model.ID  unsignedIntegerValue]];
                        [[DPITReaderMgr shareInstance] AsyncGetLocalBookInfo];
                    }break;
                    default:
                        break;
                }
            }
        }
    }
}

//同步阅读进度
- (void)operationsAfterReaderViewDismiss
{
    [super operationsAfterReaderViewDismiss];
    [_tableView reloadData];
}

#pragma mark ---- search engine protocol -----
- (void)searchEngineDatasourceRefleshed:(DPSearchEngine *)engine
{
//    [_searchResultDisplay.searchResultsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_searchResultDisplay.searchResultsTableView reloadData];
    });
}

- (void)searchEngine:(DPSearchEngine *)engine stateChanged:(CurrentState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_searchResultDisplay.searchResultsTableView reloadData];
        _searchResultDisplay.searchResultsTableView.scrollEnabled = (CurrentState_Search == state);
    });
}

#pragma mark ---- search bar or search display controller hack method ----
- (void)reloadSearchDisplayControllerDimmingView
{
    for (id container in _searchResultDisplay.searchContentsController.view.subviews) {
        if ([container isKindOfClass:NSClassFromString(@"UISearchDisplayControllerContainerView")]) {
            UIView* subContainer = (UIView*)container;
            for(UIView * v in [subContainer subviews])
            {
                if([v isMemberOfClass:[UIView class]])
                {
                    UIView* pv = (UIView*)v;
                    for (UIView* subV in pv.subviews) {
                        if ([subV isKindOfClass:NSClassFromString(@"_UISearchDisplayControllerDimmingView")]) {
                            subV.alpha = 1;
                            [subV.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                            [subV addSubview:_dimmingView];
                        }
                    }
                }else if ([v isKindOfClass:NSClassFromString(@"_UISearchDisplayControllerDimmingView")]) {
                    v.backgroundColor = [UIColor whiteColor];
                    v.alpha = 1;
                }
            }
        }
    }
}

- (void)reloadSearchBarCancelButton:(UISearchBar*)searchBar
{
    for (UIView *searchbuttons in searchBar.subviews)
    {
        if ([searchbuttons isKindOfClass:[UIView class]]) {
            for (UIView* sub in searchbuttons.subviews) {
                if ([sub isKindOfClass:[UIButton class]] || [sub isKindOfClass:NSClassFromString(@"UINavigationButton")])
                {
                    UIButton *cancelButton = (UIButton*)sub;
                    cancelButton.enabled = YES;
                    [cancelButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
                    [cancelButton setTitle:@"搜索"  forState:UIControlStateNormal];//文字
                    break;break;
                }
            }
        }else if ([searchbuttons isKindOfClass:[UIButton class]] || [searchbuttons isKindOfClass:NSClassFromString(@"UINavigationButton")])
        {
            UIButton *cancelButton = (UIButton*)searchbuttons;
            cancelButton.enabled = YES;
            [cancelButton removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
            [cancelButton setTitle:@"搜索"  forState:UIControlStateNormal];//文字
            break;
        }
    }
}

@end
