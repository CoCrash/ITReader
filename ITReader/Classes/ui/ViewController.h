//
//  ViewController.h
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//
// Home view controller
#import <UIKit/UIKit.h>
#import "DPViewController.h"

@interface ViewController : DPViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    UISearchBar* _searchBar;
    UISearchDisplayController* _searchResultDisplay;
    UITableView *_tableView;
}

@end
