//
//  CameraPreview.h
//  AVFoundationDemo
//
//  Created by lotus on 2018/1/26.
//  Copyright © 2018年 lotus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraPreview : UIView

@property (nonatomic, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic) AVCaptureSession *session;
@end
