//
//  DPViewController.m
//  ITReader
//
//  Created by haowenliang on 14-10-5.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPViewController.h"
#import "DPITReaderDef.h"
#import "DPBookDetailModel.h"
#import "ReaderViewController.h"


@interface DPViewController ()<ReaderViewControllerDelegate>

@end

@implementation DPViewController
#pragma mark ---- rotation ---
- (BOOL)shouldAutorotate {
    return YES;
}

//ios 6 +
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//ios 5 and below
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark ---- super actions ------
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPdfReaderNotification:) name:DPITReader_OpenPdf_Notify object:nil];
    
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
#endif // DEMO_VIEW_CONTROLLER_PUSH
}

- (void)orientationChanged:(NSNotification *)notification
{
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
#endif // DEMO_VIEW_CONTROLLER_PUSH
}

#pragma mark - goto reader methods
- (void)openPdfReaderNotification:(NSNotification *)notification
{
    id object = notification.object;
    if (object && [object isKindOfClass:[DPBookDetailModel class]]) {
        DPBookDetailModel* detail = (DPBookDetailModel*)object;
        [self openPdfReader:[detail savePath]];
    }
}

- (void)openPdfReader:(NSString*)filePath
{
    NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)

    ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:phrase];
    
    if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
    {
        ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        
        readerViewController.delegate = self; // Set the ReaderViewController delegate to self
        
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
        
        [self.navigationController pushViewController:readerViewController animated:YES];
        
#else // present in a modal view controller
        
        readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [self presentViewController:readerViewController animated:YES completion:NULL];
        
#endif // DEMO_VIEW_CONTROLLER_PUSH
    }
    else // Log the error so that we know that something went wrong
    {
        NSLog(@"%s [ReaderDocument withDocumentFilePath:'%@' password:'%@'] failed.", __FUNCTION__, filePath, phrase);
    }
}

- (void)operationsAfterReaderViewDismiss
{
#if (DEMO_VIEW_CONTROLLER_PUSH == TRUE)
    
    [self.navigationController popViewControllerAnimated:YES];
    
#else // dismiss the modal view controller
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
#endif // DEMO_VIEW_CONTROLLER_PUSH
}

#pragma mark - ReaderViewControllerDelegate methods

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [self operationsAfterReaderViewDismiss];
}

#pragma mark ---- base abilities ------
// 下一个界面的返回按钮
- (void)resetBackBarButton:(SEL)selector
{
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"返回";
    temporaryBarButtonItem.target = self;
    temporaryBarButtonItem.action = @selector(selector);
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
}
/**统一的返回按钮*/
- (void)resetBackBarButtonWithImage
{
    NSString* backString = @"";//返回
    UIImage* tImage = nil;
    UIImage* pImage = nil;
    tImage = LOAD_ICON_USE_POOL_CACHE(@"header_leftbtn_nor.png");
    pImage = LOAD_ICON_USE_POOL_CACHE(@"header_leftbtn_press.png");
    //    tImage = [tImage stretchableImageWithLeftCapWidth:25 topCapHeight:1];
    //    pImage = [pImage stretchableImageWithLeftCapWidth:25 topCapHeight:1];
    
    // Custom initialization
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5.0, 0.0, tImage.size.width,tImage.size.height);
    backButton.contentMode = UIViewContentModeScaleAspectFit;
    [backButton setBackgroundImage:tImage forState:UIControlStateNormal];
    [backButton setBackgroundImage:pImage forState:UIControlStateHighlighted];
    
    UIEdgeInsets  insets = UIEdgeInsetsMake(1, 15, 1, 10);
    [backButton setTitleEdgeInsets:insets];
    
    [backButton setTitle:backString forState:UIControlStateNormal];
    [backButton setTitle:backString forState:UIControlStateHighlighted];
    [backButton setImage:nil forState:UIControlStateNormal];
    [backButton setImage:nil forState:UIControlStateHighlighted];
    
    backButton.titleLabel.textColor		= RGBACOLOR(0x00,0x79,0xff,1);
    //    backButton.titleLabel.shadowColor	= [UIColor clearColor];
    //    backButton.titleLabel.shadowOffset    = CGSizeMake(0, -1) ;
    [backButton setTitleColor:RGBACOLOR(0x00,0x79,0xff,1) forState:UIControlStateNormal];
    [backButton setTitleColor:RGBACOLOR(0x00,0x79,0xff,0.4f) forState:UIControlStateHighlighted];
    
    backButton.titleLabel.font = [UIFont systemFontOfSize:18];
    backButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    //    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    //    [backButton setImage:[UIImage imageNamed:@"back-white.png"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.leftBarButtonItem=temporaryBarButtonItem;
}

//返回操作
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*设置文字标题*/
- (void)setTitle:(NSString *) title
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if(!titleView){
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.textColor = RGBACOLOR(0x00, 0x00, 0x00, 1);
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    [titleView sizeToFit];
}

/*设置自定义TitleView*/
- (void)setCustomTitleView:(UIView*)titleView
{
    if (titleView != nil) {
        CGRect frame = titleView.frame;
        frame.origin.x = (SCREEN_WIDTH -frame.size.width)/2.0f;
        titleView.frame = frame;
        self.navigationItem.titleView = nil;
        self.navigationItem.titleView = titleView;
    }
}

- (void)setDisplayCustomTitleText:(NSString*)text
{
    // Init views with rects with height and y pos
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    // Use autoresizing to restrict the bounds to the area that the titleview allows
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    titleView.autoresizesSubviews = YES;
    titleView.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    //    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    titleLabel.font = [UIFont systemFontOfSize:22];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    titleLabel.textColor = RGBACOLOR(0x00, 0x00, 0x00, 1);
    titleLabel.lineBreakMode = NSLineBreakByClipping;
    titleLabel.autoresizingMask = titleView.autoresizingMask;
    
    CGRect leftViewbounds = self.navigationItem.leftBarButtonItem.customView.bounds;
    CGRect rightViewbounds = self.navigationItem.rightBarButtonItem.customView.bounds;
    
    CGRect frame;
    CGFloat maxWidth = leftViewbounds.size.width > rightViewbounds.size.width ? leftViewbounds.size.width : rightViewbounds.size.width;
    maxWidth += 15;//leftview 左右都有间隙，左边是5像素，右边是8像素，加2个像素的阀值 5 ＋ 8 ＋ 2
    CGFloat usedWidth = maxWidth * 2;
    
    //    CGFloat usedWidth = leftViewbounds.size.width + rightViewbounds.size.width + 30;
    
    frame = titleLabel.frame;
    
    frame.size.width = SCREEN_WIDTH - usedWidth;
    titleLabel.frame = frame;
    
    frame = titleView.frame;
    frame.size.width = SCREEN_WIDTH - usedWidth;
    titleView.frame = frame;
    
    //    titleView.center = CGPointMake(SCREEN_WIDTH/2.0f, titleView.center.y);
    
    // Set the text
    titleLabel.text = text;
    // Add as the nav bar's titleview
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
}

- (void)resetTextRightButtonWithTitle:(NSString*)title andSel:(SEL)selector
{
    UIButton *rightButtonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 30)];
    [rightButtonItem addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    rightButtonItem.titleLabel.font = [UIFont systemFontOfSize:17.f];
    rightButtonItem.titleLabel.textColor		= RGBACOLOR(0x00,0x00,0x00,1);
    [rightButtonItem setTitleColor:RGBACOLOR(0x00,0x00,0x00,1) forState:UIControlStateNormal];
    [rightButtonItem setTitleColor:RGBACOLOR(0x00,0x00,0x00,0.4f) forState:UIControlStateHighlighted];
    
    [rightButtonItem setTitle:title forState:UIControlStateNormal];
    [rightButtonItem sizeToFit];
    UIBarButtonItem *rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightButtonItem];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)resetTextLeftButtonWithTitle:(NSString*)title andSel:(SEL)selector
{
    UIButton *rightButtonItem=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 46, 30)];
    [rightButtonItem addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    rightButtonItem.titleLabel.font = [UIFont systemFontOfSize:17.f];
    rightButtonItem.titleLabel.textColor		= RGBACOLOR(0xff,0xff,0xff,1);
    [rightButtonItem setTitleColor:RGBACOLOR(0xff,0xff,0xff,1) forState:UIControlStateNormal];
    [rightButtonItem setTitleColor:RGBACOLOR(0xff,0xff,0xff,0.4f) forState:UIControlStateHighlighted];
    
    [rightButtonItem setTitle:title forState:UIControlStateNormal];
    UIBarButtonItem *rightBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:rightButtonItem];
    self.navigationItem.leftBarButtonItem = rightBarButtonItem;
}

- (void)removeLeftNavigationBarButton
{
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.backBarButtonItem = nil;
}

- (void)removeRightNavigationBarButton
{
    self.navigationItem.rightBarButtonItem = nil;
}

@end
