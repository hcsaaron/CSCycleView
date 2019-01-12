//
//  CSCycleView.h
//  CSCycleView-Demo
//
//  Created by iMacHCS on 15/6/4.
//  Copyright (c) 2015年 CS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CSCycleView;
@protocol CSCycleViewDataSource <NSObject>
@required
- (NSInteger)numberOfPagesInCycleView:(CSCycleView *)cycleView;
- (UIView *)cycleView:(CSCycleView *)cycleView viewForPageAtIndex:(NSInteger)index;

@end

@protocol CSCycleViewDelegate <NSObject>

-(void)cycleView:(CSCycleView *)cycleView didSelectPageAtIndex:(NSInteger)index;

@end

@interface CSCycleView : UIView
@property (nonatomic, weak) id<CSCycleViewDataSource> dataSource;
@property (nonatomic, weak) id<CSCycleViewDelegate> delegate;
@property (nonatomic, strong, readonly) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSInteger currentPage;
@property (nonatomic, assign) BOOL hidePageControl;
@property (nonatomic, assign) BOOL scrollEnable;
- (void)reloadData;

//暂停滚动
- (void)pauseAnimation;
//继续滚动
- (void)resumeAnimation;
//数秒后继续滚动
- (void)resumeAnimationAfterTimeInterval:(NSTimeInterval)interval;
//完全停止定时器
- (void)stopRepeatingTimer;
@end
