//
//  CSCycleView.m
//  CSCycleView-Demo
//
//  Created by iMacHCS on 15/6/4.
//  Copyright (c) 2015年 CS. All rights reserved.
//

#import "CSCycleView.h"
#import "NSTimer+Addition.h"

@interface CSCycleView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;


@end

@implementation CSCycleView
{
    NSInteger _totalPages;
    NSMutableArray *_currentViews;
}
- (void)dealloc
{
    _scrollView.delegate = nil; //不写这个可能会崩溃
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeSubViews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSubViews];
    }
    return self;
}
//初始化子视图
- (void)initializeSubViews
{
    _duration = 2;
    
    _currentPage = 0;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    
    [self addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 15, CGRectGetWidth(self.frame), 15)];
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 15, CGRectGetWidth(self.frame), 15);
    _scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
    _scrollView.contentOffset = CGPointMake(CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
    [self reloadData];
}

#pragma mark - public
//暂停滚动
- (void)pauseAnimation
{
    [_timer pauseTimer];
}
//继续滚动
- (void)resumeAnimation
{
    [_timer resumeTimer];
}
//数秒后继续滚动
- (void)resumeAnimationAfterTimeInterval:(NSTimeInterval)interval
{
    [_timer resumeTimerAfterTimeInterval:interval];
}
#pragma mark --- setter
-(void)setDataSource:(id<CSCycleViewDataSource>)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        
        [self reloadData];
    }
}
-(void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:_duration target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}
-(void)setHidePageControl:(BOOL)hidePageControl
{
    _hidePageControl = hidePageControl;
    _pageControl.hidden = hidePageControl;
}
-(void)setScrollEnable:(BOOL)scrollEnable
{
    _scrollEnable = scrollEnable;
    _scrollView.scrollEnabled = scrollEnable;
}
#pragma mark - private
- (void)stopRepeatingTimer
{
    if (_timer.isValid) {
        [_timer invalidate];
    }
}
//根据实际的page转化为有效地下一页
- (NSInteger)validNextPageWithCurrentPage:(NSInteger)index;
{
    if(index == -1)
    {
        //滑到负一页时应该显示最后一页
        index = _totalPages - 1;
    }
    
    if(index == _totalPages)
    {
        //滑到最后一页+1时，应该显示第一页
        index = 0;
    }
    
    return index;
}
//获取展现的个view
- (void)getDisplayViewsWithCurrentPage:(NSInteger)page {
    
    if (self.dataSource) {
        NSInteger pre = [self validNextPageWithCurrentPage:_currentPage - 1];
        NSInteger last = [self validNextPageWithCurrentPage:_currentPage + 1];
        
        if (!_currentViews) {
            _currentViews = [[NSMutableArray alloc] init];
        }
        
        [_currentViews removeAllObjects];
        
        [_currentViews addObject:[self.dataSource cycleView:self viewForPageAtIndex:pre]];
        [_currentViews addObject:[self.dataSource cycleView:self viewForPageAtIndex:page]];
        [_currentViews addObject:[self.dataSource cycleView:self viewForPageAtIndex:last]];
    }
}
- (void)reloadData
{
    _totalPages = [self.dataSource numberOfPagesInCycleView:self];
    if (_totalPages == 0) {
        return;
    }
    
    _pageControl.hidden = _totalPages > 1 ? NO : YES;
    _pageControl.numberOfPages = _totalPages;
    
    _pageControl.currentPage = _currentPage;
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayViewsWithCurrentPage:_currentPage];
    
    for (int i = 0; i < _currentViews.count; i++) {
        UIView *v = [_currentViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [v addGestureRecognizer:singleTap];
        v.frame = CGRectOffset(v.frame, v.frame.size.width * i, 0);
        [_scrollView addSubview:v];
    }
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
}
#pragma mark --- action
- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(cycleView:didSelectPageAtIndex:)]) {
        [self.delegate cycleView:self didSelectPageAtIndex:_currentPage];
    }
}
//定时器被触发
- (void)timerFired:(NSTimer *)timer
{
    if (timer.isValid) {
        CGPoint newOffset = CGPointMake( 2 * CGRectGetWidth(_scrollView.frame), _scrollView.contentOffset.y);
        [_scrollView setContentOffset:newOffset animated:YES];
    }
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //暂停
    [_timer pauseTimer];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //继续
    [_timer resumeTimerAfterTimeInterval:_duration];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_totalPages) {
        CGFloat x = scrollView.contentOffset.x;
        //往下翻一张
        if(x >= (2*self.frame.size.width)) {
            _currentPage = [self validNextPageWithCurrentPage:_currentPage+1];
            [self reloadData];
        }
        
        //往上翻
        if(x <= 0) {
            _currentPage = [self validNextPageWithCurrentPage:_currentPage-1];
            [self reloadData];
        }
    }
}
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:NO];
}
//完了让它回到中间
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:NO];
}



@end
