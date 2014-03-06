//
//  QRUtil.m
//  QRUtil
//
//  Created by mk on 14-2-21.
//  Copyright (c) 2014年 vi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QRUtil.h"
#import "qrencode.h"

struct Color {
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
};

@implementation QRUtil

enum {
	qr_margin = 3
};

+ (void)drawQRCode:(QRcode *)code context:(CGContextRef)ctx size:(CGFloat)size cfg:(QRCfg *)cfg
{
	unsigned char	*data = 0;
	int				width;

	data	= code->data;
	width	= code->width;
	float	zoom		= (double)size / (code->width + 2.0 * qr_margin);
	CGRect	rectDraw	= CGRectMake(0, 0, zoom, zoom);

	CGContextSetFillColorWithColor(ctx, cfg.forecolor.CGColor);

	for (int i = 0; i < width; ++i) {
		for (int j = 0; j < width; ++j) {
			if (*data & 1) {
				rectDraw.origin = CGPointMake((j + qr_margin) * zoom, (i + qr_margin) * zoom);
				CGContextAddRect(ctx, rectDraw);
			}

			++data;
		}
	}

	CGContextFillPath(ctx);
}

// 转化为ColorSpaceRef对象
static inline CGColorSpaceRef ToColorSpace(UIColor *color)
{
	return CGColorGetColorSpace(color.CGColor);
}

+ (UIImage *)qrImageForString:(NSString *)string size:(CGFloat)size
{
	return [QRUtil qrImageForString:string size:size cfg:[QRCfg newCfg]];
}

+ (UIImage *)qrImageForString:(NSString *)string size:(CGFloat)size cfg:(QRCfg *)cfg
{
	if (![string length]) {
		return nil;
	}

	// 容错率
	QRecLevel lv = QR_ECLEVEL_L;
	switch (cfg.fta) {
		case LOW:
			lv = QR_ECLEVEL_L; break;

		case MID:
			lv = QR_ECLEVEL_M; break;

		case HIGH:
			lv = QR_ECLEVEL_Q; break;

		case HIGHER:
			lv = QR_ECLEVEL_H; break;

		default:
			break;
	}

	// 如果有图片的话就需要高级别的识别率
	if ((cfg.embedImg != nil) && (lv < QR_ECLEVEL_Q)) {
		lv = QR_ECLEVEL_Q;
	}

	QRcode *code = QRcode_encodeString([string UTF8String], 0, lv, QR_MODE_8, 1);

	if (!code) {
		return nil;
	}

	// create context
	CGColorSpaceRef colorSpace	= CGColorSpaceCreateDeviceRGB();
	CGContextRef	ctx			= CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

	CGAffineTransform	translateTransform	= CGAffineTransformMakeTranslation(0, -size);
	CGAffineTransform	scaleTransform		= CGAffineTransformMakeScale(1, -1);
	CGContextConcatCTM(ctx, CGAffineTransformConcat(translateTransform, scaleTransform));

	// 无渐变的时候，直接用纯色填涂
	if (cfg.gradType == NONE) {
		CGContextSaveGState(ctx);
		CGFloat r, g, b, a;
		[cfg.bgColor getRed:&r green:&g blue:&b alpha:&a];
		CGContextSetRGBFillColor(ctx, r, g, b, a);
		CGContextFillRect(ctx, CGRectMake(0, 0, size, size));
		CGContextRestoreGState(ctx);
	} else if (cfg.gradType == Center_Out) {
		CGFloat			locations[] = {0.0, 1.0};
		NSArray			*colors		= [NSArray arrayWithObjects:(id)cfg.bgColor.CGColor, (id)cfg.endColor.CGColor, nil];	// 渐变颜色数组
		CGGradientRef	gradient	= CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);				// 构造渐变
		CGContextSaveGState(ctx);
        double length = sqrt(2 * pow(size, 2));
		CGContextDrawRadialGradient(ctx, gradient, CGPointMake(size / 2, size / 2), 0, CGPointMake(size / 2, size / 2), length/2, 1);
		CGContextRestoreGState(ctx);											// 恢复状态
		CGGradientRelease(gradient);
	} else {
		CGFloat			locations[] = {0.0, 1.0};
		NSArray			*colors		= [NSArray arrayWithObjects:(id)cfg.bgColor.CGColor, (id)cfg.endColor.CGColor, nil];	// 渐变颜色数组
		CGGradientRef	gradient	= CGGradientCreateWithColors(colorSpace, (CFArrayRef)colors, locations);				// 构造渐变

		CGPoint startPoint	= CGPointZero;
		CGPoint endPoint	= CGPointZero;
		switch (cfg.gradType) {
			case LeftRight:
				startPoint = CGPointMake(0, size / 2), endPoint = CGPointMake(size, size / 2); break;

			case RightLeft:
				endPoint = CGPointMake(0, size / 2), startPoint = CGPointMake(size, size / 2); break;

			case TopButtom:
				startPoint = CGPointMake(size / 2, 0), endPoint = CGPointMake(size / 2, size); break;

			case LeftTop_RightButtom:
				startPoint = CGPointMake(0, 0), endPoint = CGPointMake(size, size); break;

			case RightButtom_LeftTop:
				endPoint = CGPointMake(0, 0), startPoint = CGPointMake(size, size); break;

			default:
				break;
		}

		CGContextSaveGState(ctx);
		CGContextAddRect(ctx, CGRectMake(0, 0, size, size));					// 设置绘图的范围
		CGContextClip(ctx);														// 裁剪
		CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);	// 绘制渐变效果图
		CGContextRestoreGState(ctx);											// 恢复状态

		CGGradientRelease(gradient);
	}

	// draw QR on this context
	[QRUtil drawQRCode:code context:ctx size:size cfg:cfg];

	if (cfg.embedImg != nil) {
		CGContextSaveGState(ctx);
		CGContextTranslateCTM(ctx, 0, size);
		CGContextScaleCTM(ctx, 1.0, -1.0);
		float is = size * 0.21;
		CGContextDrawImage(ctx, CGRectMake((size - is) / 2, (size - is) / 2, is, is), cfg.embedImg.CGImage);
		CGContextRestoreGState(ctx);
	}

	// get image
	CGImageRef	qrCGImage	= CGBitmapContextCreateImage(ctx);
	UIImage		*qrImage	= [UIImage imageWithCGImage:qrCGImage];

	// some releases
	CGContextRelease(ctx);
	CGImageRelease(qrCGImage);
	CGColorSpaceRelease(colorSpace);

	QRcode_free(code);

	return qrImage;
}

@end

