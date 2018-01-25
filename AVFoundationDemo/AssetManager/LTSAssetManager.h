//
//  LTSAssetManager.h
//  AVFoundationDemo
//
//  Created by lotus on 2018/1/24.
//  Copyright © 2018年 lotus. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LTSAsset    [LTSAssetManager shareManager]

typedef NS_ENUM(NSInteger, LTSAssetType){
    LTSAssetTypeImage = 0,
    LTSAssetTypeVideo
};
typedef void(^LTSAssetManagerBlock)(BOOL reslut);


/**
 系统相册操作类
 */
@interface LTSAssetManager : NSObject

+ (instancetype)shareManager;


/**
 检查用户是否授权操作相册。
 在操作之前建议检查，并且根据结果做相应UI逻辑处理。

 @param handler 返回授权类型
 */
- (void)checkAuthorise:(void(^)(NSInteger authorizationStatus))handler;

/**
 添加一张图片到指定相册

 @param image 图片
 @param album 相册，nil表示添加到系统相册；不为nil，如果指定相册不存在则创建再添加.
 @param block 结果反馈
 */
- (void)saveImage:(UIImage *)image toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block;


/**
 添加指定路径的视频到相册

 @param fileURL 视频路径
 @param album 相册  nil表示添加到系统相册；不为nil，如果指定相册不存在则创建再添加.
 @param block 结果反馈
 */
- (void)saveVideoAtPath:(NSURL *)fileURL toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block;

#pragma mark - 批量添加 only ios9 below
//app支持最低ios8才可以使用以下API，建议使用


/**
 根据图片路径添加单张图片到指定相册

 @param fileURL 图片路径
 @param album 相册  nil表示添加到系统相册；不为nil，如果指定相册不存在则创建再添加.
 @param block 结果反馈
 */
- (void)saveImageAtPath:(NSURL *)fileURL toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block NS_AVAILABLE_IOS(8_0);

/**
 批量添加图片到相册

 @param images 元素是UIImage对象的数组
 @param album 相册名  nil表示添加到系统相册；不为nil，如果指定相册不存在则创建再添加.
 @param block 结果反馈
 */
- (void)saveImages:(NSArray <UIImage *>*)images toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block NS_AVAILABLE_IOS(8_0);


/**
 批量添加图片或者视频到指定相册

 @param assets 元素是NSURL对象的数组，只能是图片或者视频NSURL，两者不可共存
 @param assetType 资源类型，图片或者视频
 @param album 相册名  nil表示添加到系统相册；不为nil，如果指定相册不存在则创建再添加.
 @param block 结果反馈
 */
- (void)saveAssets:(NSArray <NSURL *>*)assets type:(LTSAssetType)assetType toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block NS_AVAILABLE_IOS(8_0);


@end
