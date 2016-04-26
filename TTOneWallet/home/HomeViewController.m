//
//  HomeViewController.m
//  JFT
//
//  Created by ebeijia on 15/4/28.
//  Copyright (c) 2015年 ebeijia. All rights reserved.
//

#import "HomeViewController.h"


#import "FirstVC.h"
#import "SecondVC.h"
#import "ThreedVC.h"
#import "FourVC.h"
#import "FiveVC.h"



/**
 *    设备宽度和高度
 *
 */
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//--------------获取控件的fram属性--------------------------
/**
 *  获取控件的fram属性
 *
 *  @param obj 试图
 *
 */
#define W(obj)   (!obj?0:(obj).frame.size.width)
#define H(obj)   (!obj?0:(obj).frame.size.height)
#define X(obj)   (!obj?0:(obj).frame.origin.x)
#define Y(obj)   (!obj?0:(obj).frame.origin.y)
#define XW(obj) (X(obj))+(W(obj))
#define YH(obj) (Y(obj))+(H(obj))


#define  viewH   (kScreenHeight-64)/5   //每一个view的高度.


#define kHeadIconH 45 //头像
#define kNaviH 64
#define kAjustValue 20

@interface HomeViewController ()<UIGestureRecognizerDelegate>
{
    NSArray* _StoryIDarray;//storyboardID 名称数组
}
@end

@implementation HomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //基础设置
   self.title=@"壹钱包效果";
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    _StoryIDarray=@[@"FirstVC",@"SecondVC",@"ThreedVC",@"FourVC",@"FiveVC"];
 
    
  [self addChildView];
}

- (void)addChildView
{
    for (int i=0; i<_StoryIDarray.count; i++) {
        NSString* StoryID=_StoryIDarray[i];
       UIViewController* VC=[[self storyboard]instantiateViewControllerWithIdentifier:StoryID];
        VC.view.tag=i+1;
        VC.view.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight);
        UITapGestureRecognizer *payTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        payTap.delegate = self;
        [VC.view addGestureRecognizer:payTap];
        [VC.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)]];
        [self.view addSubview:VC.view];
        [self addChildViewController:VC];
    }
    
    [self imageBackOriginNotAnimate];
}




#pragma mark-《Tap手势》
- (void)handleTap:(UITapGestureRecognizer *)tap{
    
    UIView *childView = (UIView *)tap.view;
    if (CGRectGetMinY(tap.view.frame) <= kNaviH){
        [self imageBackOrigin];
    }else{
        [self imagePanToShow:childView];
    }
}




#pragma mark-《Pan手势》
- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    CGPoint translation = [pan translationInView:self.view];
    
//    第一页不能滑
    if (pan.view.tag == 1){
        return;
    }
   
    //到顶部了不能滑动
    if (Y(pan.view)<=64&&translation.y<=0&&pan.view.tag!=5) {
        return;
    }
    
    //这里让pan跟着手移动的速度移动
    pan.view.center = CGPointMake(kScreenWidth/2, pan.view.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:self.view];
    [self adujestPosition:pan offsety:translation.y];
}


//移动设置
- (void)adujestPosition:(UIPanGestureRecognizer *)pan offsety:(CGFloat)offset{
 
    UIView *imagePan =pan.view;
    CGFloat imagePanY = kNaviH+((pan.view.tag-1)*viewH);
    
    //这样判断当前是否在上升和下降
    if (Y(imagePan) < imagePanY){
        //上上
        if (offset<0) {
            NSLog(@"上上上上上上上");
            for (UIViewController *VC in self.childViewControllers) {
                UIView *childView=VC.view;
                //上部
                if (imagePan.tag > childView.tag) {
                    CGFloat k1 =Y(childView) - kNaviH;
                    CGFloat k2 = Y(imagePan) - kNaviH;
                    double k = k1/k2;
                    [self ChangeFramWithView:childView offsety:offset*k];
                }
                //下部
                if (childView.tag > imagePan.tag) {
                    CGFloat k1 =kScreenHeight - Y(childView);
                    CGFloat k2 = Y(imagePan) - kNaviH;
                    double k = k1/k2;
                    [self ChangeFramWithView:childView offsety:-offset*k];
                }
            }
        }
        
        //上下
        if (offset>0)
        {
            NSLog(@"上上上上上上上下下下下下下下下下下");
            for (UIViewController *VC in self.childViewControllers) {
                UIView *childView=VC.view;
                //上部
                if (imagePan.tag > childView.tag) {
                    CGFloat k1 =  kNaviH+((childView.tag-1)*viewH) - childView.frame.origin.y ;
                    CGFloat k2 = kNaviH+((imagePan.tag-1)*viewH) - imagePan.frame.origin.y;
                    float k = k1/k2;
                    [self ChangeCenterWithView:childView offsety:offset * k];
                    
                }
                //下部
                if (childView.tag > imagePan.tag) {
                    CGFloat k1 = CGRectGetMinY(childView.frame) - (kNaviH+((childView.tag-1)*viewH));
                    CGFloat k2 = kNaviH+((imagePan.tag-1)*viewH) - imagePan.frame.origin.y;
                    double k = k1/k2;
                    [self ChangeFramWithView:childView offsety:-offset*k];
                }
            }
        }
    }
    
    
    else  if (CGRectGetMinY(imagePan.frame) > imagePanY){
        
        NSLog(@"下下下下下下下下下");
        //下下
        if (offset>0) {
            for (int i = 0; i<self.childViewControllers.count; i++) {
                UIViewController* VC=self.childViewControllers[i];
                UIView *childView = VC.view;
                //上部
                if (imagePan.tag > childView.tag) {
                    CGFloat k1 = CGRectGetMinY(childView.frame) - kNaviH;
                    CGFloat k2 =CGRectGetHeight(self.view.bounds) - CGRectGetMinY(imagePan.frame);
                    double k = k1/k2;                    
                    [self ChangeFramWithView:childView offsety:-offset*k];
                }
                //下部
                if (childView.tag > imagePan.tag) {
                    CGFloat k1 =CGRectGetHeight(self.view.bounds) - CGRectGetMinY(childView.frame);
                    CGFloat k2 =CGRectGetHeight(self.view.bounds) - CGRectGetMinY(imagePan.frame);
                    double k = k1/k2;
                    [self ChangeFramWithView:childView offsety:offset*k];
                }
            }
        }
        //下上
        if (offset<0)
        {
            NSLog(@"下下下下下下下下上上上上上上上上上");
            for (int i = 0; i<self.childViewControllers.count; i++) {
                UIViewController* VC=self.childViewControllers[i];
                UIView *childView =VC.view;
                //上部
                if (imagePan.tag > childView.tag) {
                    CGFloat k1 = (kNaviH+((childView.tag-1)*viewH))-Y(childView) ;
                    CGFloat k2 =Y(imagePan) - (kNaviH+((imagePan.tag-1)*viewH));
                    double k = k1/k2;
                    
                    [self ChangeFramWithView:childView offsety:-offset*k];
                }
                //下部
                if (childView.tag > imagePan.tag) {
                    CGFloat k1 = Y(childView) - (kNaviH+((childView.tag-1)*viewH));
                    CGFloat k2 = Y(imagePan) - (kNaviH+((imagePan.tag-1)*viewH));
                    double k = k1/k2;
                    
                    [self ChangeFramWithView:childView offsety:offset*k];
                }
            }
        }
    }
    else{
        //归位
        [self imageBackOrigin];
    }
    //手势结束
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self imageBackOrigin];
    }
}


//showImagePan
- (void)imagePanToShow:(UIView *)imagePan
{
    for (UIViewController *VC in self.childViewControllers) {
        UIView *childView=VC.view;
        [UIView animateWithDuration:.5 animations:^{
            imagePan.frame = CGRectMake(0, kNaviH, kScreenWidth, kScreenHeight);
            //
            if (imagePan.tag>childView.tag) {
                childView.frame =  CGRectMake(0, kNaviH, kScreenWidth, kScreenHeight);
            }else if(imagePan.tag<childView.tag){
                childView.frame =  CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
            }
        }];
    }
}

//第五个页面
-(void)tagFiveAction:(UIView *)imagePan{
   [UIView animateWithDuration:.2 animations:^{
        imagePan.frame = CGRectMake(0, kAjustValue,kScreenWidth, kScreenHeight+64);
    }];
}

//showImagePan.tag-1
- (void)imagePanLastToShow:(UIView *)imagePan{
    for (UIViewController *VC in self.childViewControllers) {
        UIView *childView =VC.view;
        [UIView animateWithDuration:.5 animations:^{
            if (imagePan.tag>childView.tag) {
                childView.frame =  CGRectMake(0, kNaviH, kScreenWidth, kScreenHeight);
            }else{
                childView.frame =  CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
            }
        }];
    }
    
}


//归位,有动画
- (void)imageBackOrigin{
    for (UIViewController* VC  in self.childViewControllers) {
        [UIView animateWithDuration:.5 animations:^{
            VC.view.frame =  CGRectMake(0,  kNaviH+((VC.view.tag - 1)*viewH), kScreenWidth, kScreenHeight);
        }];
    }
}


//归位,无动画
- (void)imageBackOriginNotAnimate{
    for (UIViewController *VC in self.childViewControllers) {
        VC.view.frame =  CGRectMake(0,  kNaviH+((VC.view.tag - 1)*viewH), kScreenWidth, kScreenHeight);
    }
}


/**
 *  改变位置
 *
 *  @param view
 *  @param offsety  改变量
 */
-(void)ChangeFramWithView:(UIView*)view   offsety:(CGFloat)offsety;
{
    CGRect rect = view.frame;
    rect.origin.y = rect.origin.y + offsety;
    view.frame = rect;
}

/**
 *  改变位置
 *
 *  @param view
 *  @param offsety  改变量
 */
-(void)ChangeCenterWithView:(UIView*)view   offsety:(CGFloat)offsety;
{
    CGPoint point = view.center;
    point.y = point.y + offsety;
    view.center = point;
}

@end
