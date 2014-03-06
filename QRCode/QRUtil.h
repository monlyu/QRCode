//
//  QRUtil.h
//  QRUtil
//
//  Created by mk on 14-2-21.
//  Copyright (c) 2014年 vi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRCfg.h"

@interface QRUtil : NSObject

+ (UIImage *)qrImageForString:(NSString *)string size:(CGFloat)size;

+ (UIImage *)qrImageForString:(NSString *)string size:(CGFloat)size cfg:(QRCfg *)cfg;


@end
