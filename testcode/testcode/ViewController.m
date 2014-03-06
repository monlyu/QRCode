//
//  ViewController.m
//  testcode
//
//  Created by mk on 14-2-24.
//  Copyright (c) 2014年 vi. All rights reserved.
//

#import "ViewController.h"
#import <QRCode/QRCode.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];
    
    QRCfg *c = [QRCfg newCfg];
    c.forecolorHex = @"#000000";
    c.bgColorHex = @"#FFFF11";
    c.endColorHex = @"#4398AE";
    c.gradType = Center_Out;
    c.embedImg = [UIImage imageNamed:@"birdview.png"];
    
    UIImage *img = [QRUtil qrImageForString:@"韩梅梅来自大家庭" size:300 cfg:c];
    
    UIImageView *v = [[UIImageView alloc] initWithFrame:CGRectMake(10, 100, 300, 300)];
    v.image = img;
    [self.view addSubview:v];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
