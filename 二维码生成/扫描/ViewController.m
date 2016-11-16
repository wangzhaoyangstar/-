//
//  ViewController.m
//  扫描
//
//  Created by 王朝阳 on 2016/11/16.
//  Copyright © 2016年 wangzhaoyang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface ViewController () <AVCaptureMetadataOutputObjectsDelegate>
///捕获会话
@property (nonatomic, strong) AVCaptureSession *session;
///预览图层,可以通过输出设备展示被捕获的数据流
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    //1.扫描完成停止会话
    [self.session stopRunning];
    //2.删除预览图层
    [self.previewLayer removeFromSuperlayer];
    //3.设置显示界面
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        self.textLabel.text = obj.stringValue;
    }
    //4.结束扫描
    [self dismissViewControllerAnimated:YES completion:^{
       
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:self.textLabel.text preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}
- (IBAction)scanBtn:(UIButton *)sender {
    //1.实例化拍摄设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //2.设置输入设备
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"没有摄像头设备");
        return;
    }
    //3.设置元数据输出
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    //设置输出数据的代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置扫描区域的比例
    CGFloat width = 300 / CGRectGetHeight(self.view.frame);
    CGFloat height = 300 / CGRectGetWidth(self.view.frame);
    output.rectOfInterest = CGRectMake((1 - width) / 2, (1- height) / 2, width, height);

    //4.添加摄像会话
    AVCaptureSession *session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    [session addInput:input];
    [session addOutput:output];
    //添加会话输出条码类型
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,
                                     AVMetadataObjectTypeEAN13Code,
                                     AVMetadataObjectTypeEAN8Code,
                                     AVMetadataObjectTypeCode128Code
                                     ]];
    self.session = session;
    
    //5.视频预览图层
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    preview.frame = self.view.bounds;
    //将图层插入当前视图
    [self.view.layer insertSublayer:preview atIndex:100];
    self.previewLayer = preview;
    //6.启动会话
    [_session startRunning];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
