//
//  DPBookInfoView.m
//  ITReader
//
//  Created by haowenliang on 14-10-2.
//  Copyright (c) 2014年 dpsoft. All rights reserved.
//

#import "DPBookInfoView.h"
#import "UIImageView+WebCache.h"
#import "DPITReaderMgr.h"
#import "DPDownloadHandler.h"
#import "DPDownloader.h"
#import "ProgressIndicator.h"

#import "ReaderDocument.h"

#define IMAGE_MARGIN (CGPointMake(15,10))
#define IMAGE_SIZE (CGSizeMake(72,84))
#define CONTENT_INSET (CGPointMake(10,8))

@implementation DPBookInfoView

- (void)setModelWithObject:(id)object
{
    self.model = nil;
    if ([object isKindOfClass:[DPBookModel class]]) {
        self.model = object;
    }else if ([object isKindOfClass:[NSDictionary class]]){
        _model = [[DPBookModel alloc] init];
        _model.ID = [object objectForKey:@"ID"];
        _model.Image = [object objectForKey:@"Image"];
        _model.Title = [object objectForKey:@"Title"];
        _model.SubTitle = [object objectForKey:@"SubTitle"];
        _model.Description = [object objectForKey:@"Description"];
        _model.isbn = [object objectForKey:@"isbn"];
    }
    
    [_bookImage sd_setImageWithURL:[NSURL URLWithString:_model.Image]
                      placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                          [self setNeedsLayout];
                      }];
    
    _bookTitle.text = _model.Title;
    //不要subtitle了
    _bookSubtitle.text = [_model.SubTitle length]?_model.SubTitle:_model.isbn;
    _bookSubtitle.text = nil;
    
    _bookDescription.text = _model.Description;
    _bookDescription.textColor = [UIColor colorWithWhite:0.3 alpha:1];
//    [_bookTitle sizeToFit];
//    [_bookSubtitle sizeToFit];
//    [_bookDescription sizeToFit];
    [self setNeedsLayout];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _bookImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        _bookImage.backgroundColor = [UIColor clearColor];
        _bookImage.contentMode = UIViewContentModeScaleAspectFit;
        
        _bookTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _bookTitle.backgroundColor = [UIColor clearColor];
        _bookTitle.textAlignment = NSTextAlignmentLeft;
        _bookTitle.numberOfLines = 1;
        _bookTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        _bookTitle.textColor = [UIColor blackColor];
        _bookTitle.font = [UIFont systemFontOfSize:16];
        
        _bookSubtitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _bookSubtitle.backgroundColor = [UIColor clearColor];
        _bookSubtitle.numberOfLines = 1;
        _bookSubtitle.textAlignment = NSTextAlignmentLeft;
        _bookSubtitle.lineBreakMode = NSLineBreakByTruncatingTail;
        _bookSubtitle.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        _bookSubtitle.font = [UIFont systemFontOfSize:14];
        
        _bookDescription = [[UILabel alloc] initWithFrame:CGRectZero];
        _bookDescription.backgroundColor = [UIColor clearColor];
        _bookDescription.textAlignment = NSTextAlignmentLeft;
        _bookDescription.numberOfLines = 3;
        _bookDescription.lineBreakMode = NSLineBreakByTruncatingTail;
        _bookDescription.textColor = [UIColor colorWithWhite:0.3 alpha:1];
        _bookDescription.font = [UIFont systemFontOfSize:14];
        
        [self addSubview:_bookTitle];
        [self addSubview:_bookSubtitle];
        [self addSubview:_bookImage];
        [self addSubview:_bookDescription];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    _bookImage.frame = CGRectMake(IMAGE_MARGIN.x, IMAGE_MARGIN.y, IMAGE_SIZE.width, IMAGE_SIZE.height);
    CGFloat textWidth = CGRectGetWidth(frame) - CGRectGetMaxX(_bookImage.frame) - CONTENT_INSET.x - IMAGE_MARGIN.x;
    CGFloat textHeight = _bookTitle.font.lineHeight;
    CGRect tframe = _bookTitle.frame;
    _bookTitle.frame = CGRectMake(CGRectGetMaxX(_bookImage.frame)+ CONTENT_INSET.x, CGRectGetMinY(_bookImage.frame),  textWidth, textHeight);
    tframe = _bookTitle.frame;
    
    CGFloat stextHeight = _bookSubtitle.font.lineHeight *_bookSubtitle.numberOfLines;
    textHeight = _bookDescription.font.lineHeight *_bookDescription.numberOfLines;
    CGRect dframe = _bookDescription.frame;
    if ([_bookSubtitle.text length]) {
        CGRect sframe = _bookSubtitle.frame;
        sframe = CGRectMake(tframe.origin.x, CGRectGetMaxY(tframe) + CONTENT_INSET.y, textWidth, stextHeight);
        _bookSubtitle.frame = sframe;
        
        dframe = CGRectMake(tframe.origin.x, CGRectGetMaxY(sframe) + CONTENT_INSET.y, textWidth, textHeight);
    }else{
        dframe = CGRectMake(tframe.origin.x, CGRectGetMaxY(tframe) + CONTENT_INSET.y, textWidth, textHeight);
    }
    _bookDescription.frame = dframe;
}

@end

@interface DPLocalBookInfoView()
@property (nonatomic, assign) DPDownloader* downloader;
@end

@implementation DPLocalBookInfoView

- (void)setDatasource:(DPBookDetailModel *)datasource
{
    _datasource = datasource;

    [_bookImage sd_setImageWithURL:[NSURL URLWithString:_datasource.Image]
                  placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      [self setNeedsLayout];
                  }];
    _bookTitle.text = _datasource.Title;
    _bookSubtitle.text = _datasource.Description;
    _bookDescription.text = nil;
    _indicator.hidden = YES;
    switch ([[DPITReaderMgr shareInstance] checkBookDownloadState:_datasource]) {
        case DPBOOK_STATE_Downloading:{
            DPDownloadHandler* handler = [DPDownloadHandler sharedInstance];
            self.downloader = [handler getDownloaderRequestOfName:[_datasource fileName]];
        }break;
        case DPBOOK_STATE_Downloaded:{
            NSString *phrase = nil; // Document password (for unlocking most encrypted PDF files)
            ReaderDocument *document = [ReaderDocument withDocumentFilePath:[_datasource savePath] password:phrase];
//            if(nil == document.pageNumber || nil == document.pageCount){
//                _bookDescription.text = @"error: pdf get corrupted";
//                _bookDescription.textColor = [UIColor redColor];
//            }else{
                _bookDescription.text = [NSString stringWithFormat:@"read stone : %@/%@",document.pageNumber,document.pageCount];
//                _bookDescription.textColor = [UIColor colorWithWhite:0.3 alpha:1];
//            }
        }
        case DPBOOK_STATE_UNDownload:{
        }break;
        default:
            break;
    }
    [self setNeedsLayout];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _bookSubtitle.numberOfLines = 2;
        _bookDescription.numberOfLines = 1;
        self.indicator = nil;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    CGFloat textWidth = CGRectGetWidth(frame) - CGRectGetMinX(_bookDescription.frame) - IMAGE_MARGIN.x;
    switch ([[DPITReaderMgr shareInstance] checkBookDownloadState:_datasource]) {
        case DPBOOK_STATE_Downloading:{
            if (_downloader) {
                _indicator = _downloader.progress;
                _indicator.frame = CGRectMake(CGRectGetMinX(_bookDescription.frame), CGRectGetMinY(_bookDescription.frame), textWidth, 33);
                _indicator.hidden = NO;
                _indicator.label.hidden = NO;
                [self addSubview:_indicator];
            }
        }break;
        case DPBOOK_STATE_Downloaded:
        case DPBOOK_STATE_UNDownload:{
            _indicator.hidden = YES;
        }break;
        default:
            break;
    }
}
@end