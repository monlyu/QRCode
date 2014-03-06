//
//  QRValue.h
//  QRCode
//
//  Created by mk on 14-2-24.
//  Copyright (c) 2014年 vi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//容错率
typedef NS_ENUM(NSInteger, FTA) {
    LOW,    /* 7% */
    MID,    /* 15% */
    HIGH,   /* 25% */
    HIGHER  /* 30% */
};

//渐变的方式
typedef NS_ENUM(NSInteger, GRADType) {
    NONE,
    LeftRight,
    RightLeft,
    TopButtom,
    LeftTop_RightButtom,
    RightButtom_LeftTop,
    Center_Out
};


@interface QRCfg : NSObject

+(QRCfg *)newCfg;

@property(nonatomic,assign) FTA fta;  //容错率

@property(nonatomic,strong) NSString *forecolorHex;  //前景色 （方块颜色） #xxxxxx
@property(nonatomic,strong) NSString *bgColorHex;  //背景颜色   #xxxxxx

@property(nonatomic,strong) NSString *endColorHex;  //渐变的最终色   #xxxxxx
@property(nonatomic,assign) GRADType gradType; //渐变的类型

@property(nonatomic,strong) UIImage *embedImg;      //嵌入的图片信息

//只读的内容
@property(nonatomic,readonly) UIColor *forecolor;
@property(nonatomic,readonly) UIColor *bgColor;
@property(nonatomic,readonly) UIColor *endColor;

@end
