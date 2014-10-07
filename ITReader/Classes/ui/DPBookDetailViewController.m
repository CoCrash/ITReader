//
//  DPBookDetailViewController.m
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBookDetailViewController.h"
#import "DPBookDetailModel.h"
#import "UIImageView+WebCache.h"
#import "DPITReaderMgr.h"
#import "RTLabel.h"
#import "DPBookModel.h"
#import "DPITReaderDef.h"
#import "ProgressIndicator.h"

#import "DPITReaderEventHandler.h"

#define DIMAGE_MARGIN (CGPointMake(15,10))
#define DIMAGE_SIZE (CGSizeMake(100,120))
#define DCONTENT_INSET (CGPointMake(10,10))
#define DESC_LINE_SPACE (5)
#define DETL_LINE_SPACE (5)
#define DOWN_LINE_SPACE (5)

@interface DPBookDetailViewController ()
{
    UIScrollView* _scrollView;
    UIImageView* _bookImage;
    RTLabel* _bookDescription;
    RTLabel* _bookDetail;
    RTLabel* _bookDownload;
    ProgressIndicator* _progress;
    
    UIWebView* _doubanView;
    NSString* _doubanUrlStr;
    BOOL _isDoubanShowed;
}
@end

@implementation DPBookDetailViewController

- (instancetype)initWithBookId:(NSNumber *)bookId
{
    if (self = [super init]) {
        self.bookId = bookId;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    if (_progress && _progress.superview == self.navigationController.navigationBar) {
//        [_progress removeFromSuperview];
//    }
    NSArray *gestureRecognizers = [self.navigationController.navigationBar gestureRecognizers];
    for (UIGestureRecognizer* ges in gestureRecognizers){
        if ([ges isKindOfClass:[UITapGestureRecognizer class]]) {
            [self.navigationController.navigationBar removeGestureRecognizer:ges];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadSucceed:) name:DPITReader_Download_Book_Succeed_Notify object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFailed:) name:DPITReader_Download_Book_Failed_Notify object:nil];
    
    
    CGRect barFrame = self.navigationController.navigationBar.bounds;
    _progress = [self getDownloadProgressView];
    if (_progress) {
        [_progress setFrame:CGRectMake(0, 0, barFrame.size.width, 4)];
        _progress.center = CGPointMake(CGRectGetMidX(barFrame),CGRectGetMaxY(barFrame));
        [self.navigationController.navigationBar addSubview:_progress];
    }
    
    [self setTitleViewDoubleTapGesture];
}

- (void)downloadFailed:(NSNotification *)notification
{
    DPBookDetailModel* book = (DPBookDetailModel*)notification.object;
    if ([[book fileName] isEqualToString:[_datasource fileName]]) {
        [self resetTextRightButtonWithTitle:@"下载" andSel:@selector(dowloadThePdf)];
        if (_progress && _progress.superview == self.navigationController.navigationBar) {
            [_progress removeFromSuperview];
        }
    }
}

- (void)downloadSucceed:(NSNotification *)notification
{
    DPBookDetailModel* book = (DPBookDetailModel*)notification.object;
    if ([[book fileName] isEqualToString:[_datasource fileName]]) {
        [self resetTextRightButtonWithTitle:@"打开" andSel:@selector(openThePdf)];
        if (_progress && _progress.superview == self.navigationController.navigationBar) {
            [_progress removeFromSuperview];
        }
    }
}

- (instancetype)initWithBookModel:(id)model
{
    if (self = [super init]) {
        _datasource = nil;
        if ([model isKindOfClass:[DPBookModel class]]) {
            self.baseModel = model;
        }else if ([model isKindOfClass:[NSDictionary class]]){
            _baseModel = [[DPBookModel alloc] init];
            _baseModel.ID = [model objectForKey:@"ID"];
            _baseModel.Image = [model objectForKey:@"Image"];
            _baseModel.Title = [model objectForKey:@"Title"];
            _baseModel.SubTitle = [model objectForKey:@"SubTitle"];
            _baseModel.Description = [model objectForKey:@"Description"];
            _baseModel.isbn = [model objectForKey:@"isbn"];
        }
        self.bookId = _baseModel.ID;
        
        _doubanUrlStr = [NSString stringWithFormat:@"%@%@",DOUBAN_READ_URL, _baseModel.isbn];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _baseModel.Title;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    _bookImage = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bookImage.frame = CGRectMake(DIMAGE_MARGIN.x, DIMAGE_MARGIN.y, DIMAGE_SIZE.width, DIMAGE_SIZE.height);
    _bookImage.backgroundColor = [UIColor clearColor];
    _bookImage.contentMode = UIViewContentModeScaleAspectFit;
    [_bookImage sd_setImageWithURL:[NSURL URLWithString:_baseModel.Image]
                  placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      [self.view setNeedsLayout];
                  }];
    CGFloat textWidth = CGRectGetWidth(self.view.bounds) - CGRectGetMaxY(_bookImage.frame) - DIMAGE_MARGIN.x;
    CGFloat textHeight = CGRectGetHeight(self.view.bounds);
    
    _bookDescription = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, textWidth, textHeight)];
    _bookDescription.backgroundColor = [UIColor clearColor];
    [_bookDescription setLineSpacing:DESC_LINE_SPACE];
    [_bookDescription setParagraphReplacement:@""];
    
    _bookDetail = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, textWidth, textHeight)];
    [_bookDetail setLineSpacing:DETL_LINE_SPACE];
    _bookDetail.backgroundColor = [UIColor clearColor];
    [_bookDetail setParagraphReplacement:@""];
    
    _bookDownload = [[RTLabel alloc] initWithFrame:CGRectMake(0, 0, textWidth, textHeight)];
    _bookDownload.backgroundColor = [UIColor clearColor];
    [_bookDownload setLineSpacing:DOWN_LINE_SPACE];
    [_bookDownload setParagraphReplacement:@""];
    
    [_scrollView addSubview:_bookImage];
    [_scrollView addSubview:_bookDescription];
    [_scrollView addSubview:_bookDetail];
    [_scrollView addSubview:_bookDownload];
    
    [[DPITReaderMgr shareInstance] detailsOfBookWithId:_bookId comparator:^(DPBookDetailModel *Book) {
        self.datasource = Book;
    }];
    CGRect doubanFrame = self.view.bounds;
    doubanFrame.origin.y = (STATUSBAR_HEIGHT + self.navigationController.navigationBar.frame.size.height);
    doubanFrame.size.height -= doubanFrame.origin.y;
    doubanFrame.origin.y += doubanFrame.size.height;
    _doubanView = [[UIWebView alloc] initWithFrame:doubanFrame];
    _doubanView.backgroundColor = [UIColor whiteColor];
    _doubanView.scalesPageToFit = YES;
    [_doubanView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_doubanUrlStr]]];
    _isDoubanShowed = NO;
}

- (void)titleDoubleTapOperation
{
    if (_isDoubanShowed) {
        [self hideDoubanWebView];
    }else{
        [self showDoubanWebView];
    }
}


- (void)titleTapGestureAction:(UITapGestureRecognizer*)recognizer
{
    UIView* view = recognizer.view;
    CGPoint location = [recognizer locationInView:view];
    CGRect titleframe = self.navigationItem.titleView.frame;
    if(CGRectContainsPoint(titleframe, location)){
        [self titleDoubleTapOperation];
    }
}

- (void)setTitleViewDoubleTapGesture
{
    NSArray *gestureRecognizers = [self.navigationController.navigationBar gestureRecognizers];
    for (UIGestureRecognizer* ges in gestureRecognizers){
        if ([ges isKindOfClass:[UITapGestureRecognizer class]]) {
            [self.navigationController.navigationBar removeGestureRecognizer:ges];
        }
    }
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleTapGestureAction:)];
    tapGesture.numberOfTapsRequired=2;
    
    [self.navigationController.navigationBar addGestureRecognizer:tapGesture];
}

- (void)hideDoubanWebView
{
    CGRect frame = _doubanView.frame;
    frame.origin.y += frame.size.height;
    [UIView animateWithDuration:0.7 animations:^{
        _doubanView.frame = frame;
        _doubanView.alpha = 0.5;
    } completion:^(BOOL finished) {
        _doubanView.alpha = 1;
        [_doubanView removeFromSuperview];
        _isDoubanShowed = NO;
    }];
}

- (void)showDoubanWebView
{
    [self.view addSubview:_doubanView];
    [self.view bringSubviewToFront:_doubanView];
    CGRect frame = _doubanView.frame;
    _doubanView.alpha = 0.5;
    frame.origin.y -= frame.size.height;
    [UIView animateWithDuration:0.7 animations:^{
        _doubanView.frame = frame;
        _doubanView.alpha = 1;
    } completion:^(BOOL finished) {
        _isDoubanShowed = YES;
    }];
}

- (void)resetNavigationButton
{
    switch ([[DPITReaderMgr shareInstance] checkBookDownloadState:_datasource]) {
        case DPBOOK_STATE_UNDownload:
        {
            [self resetTextRightButtonWithTitle:@"下载" andSel:@selector(dowloadThePdf)];
        }break;
        case DPBOOK_STATE_Downloading:{
            
        }break;
        case DPBOOK_STATE_Downloaded:
        {
            [self resetTextRightButtonWithTitle:@"打开" andSel:@selector(openThePdf)];
        }break;
        default:
            break;
    }
}

- (void)setDatasource:(DPBookDetailModel *)datasource
{
    _datasource = datasource;
    [self resetNavigationButton];
    //image
    if (![_datasource.Image isEqualToString:_baseModel.Image]) {
        [_bookImage sd_setImageWithURL:[NSURL URLWithString:_datasource.Image]
                      placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                          [self.view setNeedsLayout];
                      }];
    }
    CGRect imgFrame = _bookImage.frame;
    
    // description
    NSMutableString* descString = [[NSMutableString alloc] init];
    [descString appendString:@"<font face='HelveticaNeue-CondensedBold' size=14><p align=justify>"];
    [descString appendString:@"<font color=#20b23b size=16>Book Description<br></font>"];
    NSString* description = _datasource.Description;
    if ([description length]) {
        [descString appendString:description];
    }
    [descString appendString:@"</p></font>"];
    [_bookDescription setText:descString];
    CGSize optimumSize = [_bookDescription optimumSize];
    _bookDescription.frame = CGRectMake(CGRectGetMaxX(imgFrame)+DCONTENT_INSET.x, imgFrame.origin.y + DCONTENT_INSET.y, optimumSize.width, optimumSize.height);
    
    
    NSMutableString* detailString = [[NSMutableString alloc] init];
    [detailString appendString:@"<font face='HelveticaNeue-CondensedBold' size=14><p align=justify>"];
    [detailString appendString:@"<font color=#20b23b size=16>Book Detail<br></font>"];
    NSString* publisher = _datasource.Publisher;
    if ([publisher length]) {
        [detailString appendString:@"<p align=left><font color=#808080>Publisher:\t\t</font>"];
        [detailString appendString:publisher];
        [detailString appendString:@"</p>"];
    }
    NSString* author = _datasource.Author;
    if ([author length]) {
        [detailString appendString:@"<br><p align=left><font color=#808080>Author:\t\t</font>"];
        [detailString appendString:author];
        [detailString appendString:@"</p>"];
    }
    NSString* ISBN = _datasource.ISBN;
    if ([ISBN length]) {
        [detailString appendString:@"<br><p align=left><font color=#808080>ISBN:\t\t</font>"];
        [detailString appendString:ISBN];
        [detailString appendString:@"</p>"];
    }
    NSString* year = _datasource.Year;
    if ([year length]) {
        [detailString appendString:@"<br><p align=left><font color=#808080>Issue:\t\t</font>"];
        [detailString appendString:year];
        [detailString appendString:@"</p>"];
    }
    NSString* pages = _datasource.Page;
    if ([pages length]) {
        [detailString appendString:@"<br><p align=left><font color=#808080>Pages:\t\t</font>"];
        [detailString appendString:pages];
        [detailString appendString:@"</p>"];
    }
    [detailString appendString:@"</p></font>"];
    [_bookDetail setText:detailString];
    optimumSize = [_bookDetail optimumSize];
    _bookDetail.frame = CGRectMake(CGRectGetMaxX(imgFrame)+DCONTENT_INSET.x, CGRectGetMaxY(_bookDescription.frame) + DCONTENT_INSET.y, optimumSize.width, optimumSize.height);
    
    NSMutableString* downloadString = [[NSMutableString alloc] init];
    [downloadString appendString:@"<font face='HelveticaNeue-CondensedBold' size=14><p align=justify>"];
    [downloadString appendString:@"<font color=#20b23b size=16>eBook<br></font>"];
    NSString* download = _datasource.Download;
    if ([download length]) {
        [downloadString appendString:@"<p align=left><font color=#808080>Download:\t\t</font>"];
        [downloadString appendString:@"<a href='"];
        [downloadString appendString:download];
        [downloadString appendString:@"'>"];
        [downloadString appendString:_datasource.Title];
        [downloadString appendString:@"</a></p>"];
    }
    [downloadString appendString:@"</p></font>"];
    [_bookDownload setText:downloadString];
    optimumSize = [_bookDownload optimumSize];
    _bookDownload.frame = CGRectMake(CGRectGetMaxX(imgFrame)+DCONTENT_INSET.x, CGRectGetMaxY(_bookDetail.frame) + DCONTENT_INSET.y, optimumSize.width, optimumSize.height);
    _bookDownload.hidden = YES;
    _scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(_bookDownload.frame) + DCONTENT_INSET.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openThePdf
{
    [self openPdfReader:[_datasource savePath]];
}

- (void)dowloadThePdf
{
    if (_datasource) {
        [self removeRightNavigationBarButton];
        [[DPITReaderEventHandler shareInstance] downloadBook:_datasource];
        
        CGRect barFrame = self.navigationController.navigationBar.bounds;
        _progress = [self getDownloadProgressView];
        if (_progress) {
            [_progress setFrame:CGRectMake(0, 0, barFrame.size.width, 4)];
            _progress.center = CGPointMake(CGRectGetMidX(barFrame),CGRectGetMaxY(barFrame));
            [self.navigationController.navigationBar addSubview:_progress];
        }
    }
}

- (ProgressIndicator *)getDownloadProgressView
{
    NSString* filename = nil;
    if (_datasource) {
        filename = [_datasource fileName];
    }else{
        filename = [_baseModel fileName];
    }
    ProgressIndicator* tmp = [[DPITReaderEventHandler shareInstance] getDownloadProgressView:filename];
    tmp.hidden = NO;
    tmp.label.hidden = YES;
    return tmp;
}

@end
