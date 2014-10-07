//
//  DPViewController.h
//  ITReader
//
//  Created by haowenliang on 14-10-5.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPViewController : UIViewController

- (void)openPdfReader:(NSString*)filePath;
- (void)orientationChanged:(NSNotification *)notification;
- (void)titleDoubleTapOperation;
- (void)operationsAfterReaderViewDismiss;

//返回按钮
- (void)resetBackBarButton:(SEL)selector;
- (void)backAction;
- (void)resetBackBarButtonWithImage;
- (void)removeLeftNavigationBarButton;
- (void)removeRightNavigationBarButton;
- (void)resetTextLeftButtonWithTitle:(NSString*)title andSel:(SEL)selector;
//右上角按钮
- (void)resetTextRightButtonWithTitle:(NSString*)title andSel:(SEL)selector;

//标题
- (void)setTitle:(NSString *) title;
- (void)setCustomTitleView:(UIView*)titleView;
- (void)setDisplayCustomTitleText:(NSString*)text;

@end
