//
//  LTSAssetManager.h
//  AVFoundationDemo
//
//  Created by lotus on 2018/1/24.
//  Copyright © 2018年 lotus. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LTSAsset    [LTSAssetManager shareManager]

typedef void(^LTSAssetManagerBlock)(BOOL reslut);

@interface LTSAssetManager : NSObject

+ (instancetype)shareManager;

- (void)checkAuthorise:(void(^)(NSInteger authorizationStatus))handler;

/**
 添加图片到指定相册

 @param image 图片
 @param album 相册，如果为nil则添加到系统相册
 @param block 完成回调
 */
- (void)saveImage:(UIImage *)image toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block;
@end
