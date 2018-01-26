//
//  CameraPreview.m
//  AVFoundationDemo
//
//  Created by lotus on 2018/1/26.
//  Copyright © 2018年 lotus. All rights reserved.
//

#import "CameraPreview.h"

@implementation CameraPreview

+ (Class)layerClass{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureVideoPreviewLayer *)previewLayer{
    return (AVCaptureVideoPreviewLayer *)self.layer;
}

- (void)setSession:(AVCaptureSession *)session{
    self.previewLayer.session = session;
}

- (AVCaptureSession *)session{
    return self.previewLayer.session;
}
@end
