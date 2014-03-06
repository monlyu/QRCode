//
//  QRValue.m
//  QRCode
//
//  Created by mk on 14-2-24.
//  Copyright (c) 2014年 vi. All rights reserved.
//

#import "QRCfg.h"

@implementation QRCfg

+(QRCfg *)newCfg
{
    QRCfg *cfg = [[QRCfg alloc] init];
    cfg.fta = LOW;
    cfg.forecolorHex = @"#000000";
    cfg.bgColorHex = nil;
    cfg.endColorHex = nil;
    cfg.gradType = NONE;
    cfg.embedImg = nil;
    return cfg;
}

-(UIColor *)forecolor{
    return _forecolorHex == nil ? nil : [self hexColor:self.forecolorHex];
}

-(UIColor *)bgColor{
    return _bgColorHex == nil ? nil : [self hexColor:self.bgColorHex];
}

-(UIColor *)endColor{
    return _endColorHex == nil ? nil : [self hexColor:self.endColorHex];
}

- (UIColor *)hexColor:(NSString *)input
{
	if ([input characterAtIndex:0] == '#') {
		input = [input substringFromIndex:1];
	}
	NSString	*rs = [input substringWithRange:NSMakeRange(0, 2)];
	long		r	= strtol([rs UTF8String], NULL, 16);
	NSString	*gs = [input substringWithRange:NSMakeRange(2, 2)];
	long		g	= strtol([gs UTF8String], NULL, 16);
	NSString	*bs = [input substringWithRange:NSMakeRange(4, 2)];
	long		b	= strtol([bs UTF8String], NULL, 16);
	return [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1];
}

@end
