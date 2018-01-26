//
//  StillAndVideoViewController.m
//  AVFoundationDemo
//
//  Created by lotus on 2018/1/23.
//  Copyright © 2018年 lotus. All rights reserved.
//

#import "StillAndVideoViewController.h"

//view
#import "CameraPreview.h"

#import "LTSAssetManager.h"

static NSInteger toolBarHeight = 60;

@interface StillAndVideoViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, UIGestureRecognizerDelegate, AVCaptureFileOutputRecordingDelegate>

//session
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;//deprecated after 10.0
@property (nonatomic, strong) AVCaptureMovieFileOutput *videoOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureSession *captureSession;

//gesture
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGesture;

//take photo
@property (weak, nonatomic) IBOutlet UIView *takePhotoVideoBtn;





@end

@implementation StillAndVideoViewController


#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //hide nav bar
    self.navigationController.navigationBarHidden = YES;
    
    //set the taking photo btn content
    _takePhotoVideoBtn.layer.contents = (id)[UIImage imageNamed:@"takePhoto"].CGImage;
    
    //configure gesture
    [_tapGesture requireGestureRecognizerToFail:_longPressGesture];
    
    //create session
    self.captureSession = [[AVCaptureSession alloc] init];
    
    //configure preview layer
    AVCaptureVideoPreviewLayer *tempLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    tempLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - toolBarHeight);
    tempLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer = tempLayer;
    [self.view.layer insertSublayer:tempLayer atIndex:0];
    
    //session queue
    self.sessionQueue = dispatch_queue_create("sessionQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(self.sessionQueue, ^{
        [self configureCamera];
    });
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    dispatch_async(self.sessionQueue, ^{
        //start session
        [_captureSession startRunning];
    });
}

- (void)viewWillDisappear:(BOOL)animated{
    dispatch_async(self.sessionQueue, ^{
        //stop session
        [_captureSession stopRunning];
    });
    
    [super viewWillDisappear:animated];
}

- (void)configureCamera{
    //defaut video device
    AVCaptureDevice *tempVideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //default audio device
    AVCaptureDevice *tempAudioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    //video device input
    NSError *error;
    AVCaptureDeviceInput *tempVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:tempVideoDevice error:&error];
    if (error) {
        NSLog(@"init video device input fail.");
        return;
    }
    
    //audio device input
    AVCaptureDeviceInput *tempAudioInput = [AVCaptureDeviceInput deviceInputWithDevice:tempAudioDevice error:&error];
    if (error) {
        NSLog(@"init audio device input fail.");
        return;
    }
    
    //image output
    AVCaptureStillImageOutput *tempStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    _imageOutput =  tempStillImageOutput;
    
    //video output
    AVCaptureMovieFileOutput *tempVideoOutput = [[AVCaptureMovieFileOutput alloc] init];
    _videoOutput = tempVideoOutput;
    
    //session
    if ([_captureSession canAddInput:tempAudioInput]) {
        [_captureSession addInput:tempAudioInput];
    }
    
    if ([_captureSession canAddInput:tempVideoInput]) {
        [_captureSession addInput:tempVideoInput];
    }
    
    if ([_captureSession canAddOutput:tempStillImageOutput]) {
        [_captureSession addOutput:tempStillImageOutput];
    }
    
    if ([_captureSession canAddOutput:tempVideoOutput]) {
        [_captureSession addOutput:tempVideoOutput];
    }
}

#pragma mark - event methods

- (IBAction)takePicture:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        dispatch_async(self.sessionQueue, ^{
            [_captureSession beginConfiguration];
            _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
            [_captureSession commitConfiguration];
            
            if (![_imageOutput isCapturingStillImage]) {
                AVCaptureConnection *connection = [_imageOutput connectionWithMediaType:AVMediaTypeVideo];
                
                [_imageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
                    if (error == nil) {
                        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                        if (imageData) {
                            UIImage *image = [UIImage imageWithData:imageData];
                            [LTSAsset saveImage:image toAlbum:@"我的" completeHandler:^(BOOL reslut) {
                                if (reslut) {
                                    NSLog(@"save image success.");
                                }else{
                                    NSLog(@"save image fail.");
                                }
                            }];
                        }else{
                            NSLog(@"the image data is nil");
                        }
                    }
                }];
            }
            
        });
        
        
        
    }
    
}
- (IBAction)takeVideo:(UILongPressGestureRecognizer *)sender {
    
    dispatch_async(self.sessionQueue, ^{
        if (sender.state == UIGestureRecognizerStateBegan) {
            [_captureSession beginConfiguration];
            _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
            [_captureSession commitConfiguration];
            
            NSString *path = [self videoPath];
            NSLog(@"video path : %@", path);
            NSURL *videoURL = [NSURL fileURLWithPath:path];
            
            if ([_videoOutput isRecording]) {
                [_videoOutput stopRecording];
            }
            [_videoOutput startRecordingToOutputFileURL:videoURL recordingDelegate:self];
        }else if (sender.state == UIGestureRecognizerStateEnded){
            [_videoOutput stopRecording];
        }
    });
    
    
}


#pragma mark - *** delegates ***
#pragma mark  AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(nullable NSError *)error{
    if (error) {
        NSLog(@"record wrong, description: %@", error.localizedDescription);
        [_videoOutput stopRecording];
    }else{
        NSLog(@"record successfully to %@", [outputFileURL absoluteString]);
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections{
    NSLog(@"start video record.");
}


- (NSString *)documentPath{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}
- (NSString *)videoPath{
    NSString *directory = [[self documentPath] stringByAppendingPathComponent:@"video"];
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:directory];
    if (!result) {
        result = [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"mp4"];
    return [directory stringByAppendingPathComponent:fileName];
//    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
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
