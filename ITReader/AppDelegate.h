//
//  AppDelegate.h
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DPNavigationController.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController* viewcontroller;
@property (strong, nonatomic) DPNavigationController* navigator;

@end

