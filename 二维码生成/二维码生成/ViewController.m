//
//  ViewController.m
//  二维码生成
//
//  Created by 王朝阳 on 2016/11/16.
//  Copyright © 2016年 wangzhaoyang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UITextField *text;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)generate:(UIButton *)btn {
    
    [self.text resignFirstResponder];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [self.text.text dataUsingEncoding:NSUTF8StringEncoding];
   
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *image = [filter outputImage];
//    UIImage *image1 = [UIImage imageWithCIImage:image];
//    self.imageView.image = image1;
    self.imageView.image = [self createNonInterpolatedUIImageFormCIImage:image withSize:100.0];
    
}
- (IBAction)scanBtn:(UIButton *)sender {
}
#pragma mark - 生成高清的二维码
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    //设置比例
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap（位图）;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
- (void)setupUI {
    
    _text = [[UITextField alloc] initWithFrame:CGRectMake(60, 100, 250, 40)];
    _text.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:_text];
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [moreBtn setTitle:@"生成" forState:UIControlStateNormal];
    moreBtn.tintColor = [UIColor  greenColor];
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:20];
    
    [moreBtn addTarget:self action:@selector(generate:) forControlEvents:UIControlEventTouchUpInside];
    moreBtn.frame = CGRectMake(150, 150, 50, 50);
    [self.view addSubview:moreBtn];
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(60, 200, 250, 250)];
    _imageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_imageView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
