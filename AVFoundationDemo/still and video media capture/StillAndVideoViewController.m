//
//  StillAndVideoViewController.m
//  AVFoundationDemo
//
//  Created by lotus on 2018/1/23.
//  Copyright © 2018年 lotus. All rights reserved.
//

#import "StillAndVideoViewController.h"

static NSInteger toolBarHeight = 60;

@interface StillAndVideoViewController ()

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;//deprecated after 10.0
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation StillAndVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureCamera];
}

- (void)configureCamera{
    //device
    AVCaptureDevice *tempDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    _device = tempDevice;
    
    //device input
    NSError *error;
    AVCaptureDeviceInput *tempInput = [AVCaptureDeviceInput deviceInputWithDevice:tempDevice error:&error];
    if (error) {
        NSLog(@"init device input fail.");
        return;
    }
    _deviceInput = tempInput;
    
    //image output
    AVCaptureStillImageOutput *tempStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    _imageOutput =  tempStillImageOutput;
    
    //session
    AVCaptureSession *tempSession = [[AVCaptureSession alloc] init];
    tempSession.sessionPreset = AVCaptureSessionPresetPhoto;
    if ([tempSession canAddInput:tempInput]) {
        [tempSession addInput:tempInput];
    }
    
    if ([tempSession canAddOutput:tempStillImageOutput]) {
        [tempSession addOutput:tempStillImageOutput];
    }
    
    _captureSession = tempSession;
    
    //preview layer
    AVCaptureVideoPreviewLayer *tempLayer = [AVCaptureVideoPreviewLayer layerWithSession:tempSession];
    tempLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - toolBarHeight);
    tempLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer = tempLayer;
    [self.view.layer insertSublayer:tempLayer atIndex:0];
    
    //start session
    [tempSession startRunning];
}

#pragma mark - event methods

- (IBAction)takePhoto:(id)sender {
    
    if (![_imageOutput isCapturingStillImage]) {
        AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
            
        }];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
