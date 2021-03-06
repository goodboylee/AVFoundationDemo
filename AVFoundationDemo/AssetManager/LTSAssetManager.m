//
//  LTSAssetManager.m
//  AVFoundationDemo
//
//  Created by lotus on 2018/1/24.
//  Copyright © 2018年 lotus. All rights reserved.
//

#import "LTSAssetManager.h"

static LTSAssetManager *shareObj = nil;

typedef void(^SearchGroupBlock)(ALAssetsGroup *group);

@interface LTSAssetManager()
{
    ALAssetsLibrary     *_library;
}

@property (nonatomic, copy) LTSAssetManagerBlock privateBlock;

@end

@implementation LTSAssetManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObj = [[super allocWithZone:NULL] init];
    });
    return shareObj;
}
- (id)init{
    self = [super init];
    if (self) {
        _library = [[ALAssetsLibrary alloc] init];
    }
    return self;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [LTSAssetManager shareManager];
}

- (id)copy{
    return [LTSAssetManager shareManager];
}

#pragma mark - save image to album
#pragma mark - ios8 methods
#ifdef __IPHONE_8_0
- (void)saveImage:(UIImage *)image toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block{
    NSParameterAssert(image);
    self.privateBlock = block;

    if (album) {
        //操作photoLibrary
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

            //检查指定的相册是否存在
            PHAssetCollection *collection = [self checkAlbumWithName:album];

            //创建相册变动请求
            PHAssetCollectionChangeRequest *collectionChangeReq;
            if (collection) {
                collectionChangeReq = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            }else{
                collectionChangeReq = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:album];
            }

            //创建相片变动请求，其实这一步是添加相片到系统相册
            PHAssetChangeRequest *assetChangeReq = [PHAssetChangeRequest creationRequestForAssetFromImage:image];

            //该对象可直接添加进相册
            PHObjectPlaceholder *placehoder = assetChangeReq.placeholderForCreatedAsset;

            //添加相片到指定相册,该api说明添加的是元素是PHAsset对象的数组，但是也可以添加元素是PHObjectPlaceholder对象的数组，文档也有演示示例
            [collectionChangeReq addAssets:@[placehoder]];

        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success && error == nil) {
                [self callBackWithResult:YES];
            }else{
                [self callBackWithResult:NO];
            }
        }];
    }else{
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success && error == nil) {
                [self callBackWithResult:YES];
            }else{
                [self callBackWithResult:NO];
            }
        }];
    }
}

- (void)saveImageAtPath:(NSURL *)fileURL toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block{
    [self saveAssets:@[fileURL] type:LTSAssetTypeImage toAlbum:album completeHandler:block];
}

- (void)saveVideoAtPath:(NSURL *)fileURL toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block{
    [self saveAssets:@[fileURL] type:LTSAssetTypeVideo toAlbum:album completeHandler:block];
}

- (void)saveImages:(NSArray <UIImage *>*)images toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block{
    if (images.count == 0) {
        return;
    }

    self.privateBlock = block;

    if (album) {
        //操作photoLibrary
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

            //检查指定的相册是否存在
            PHAssetCollection *collection = [self checkAlbumWithName:album];

            //创建相册变动请求
            PHAssetCollectionChangeRequest *collectionChangeReq;
            if (collection) {
                collectionChangeReq = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            }else{
                collectionChangeReq = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:album];
            }

            //创建相片资源
            NSArray *placehoders = [self getAssetsWithImages:images];

            //添加相片到指定相册,该api说明添加的是元素是PHAsset对象的数组，但是也可以添加元素是PHObjectPlaceholder对象的数组，文档也有演示示例
            [collectionChangeReq addAssets:placehoders];

        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success && error == nil) {
                [self callBackWithResult:YES];
            }else{
                [self callBackWithResult:NO];
            }
        }];
    }else{
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            for (NSInteger i = 0; i < images.count; i++) {
                [PHAssetChangeRequest creationRequestForAssetFromImage:images[i]];
            }
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success && error == nil) {
                [self callBackWithResult:YES];
            }else{
                [self callBackWithResult:NO];
            }
        }];
    }
}

- (void)saveAssets:(NSArray <NSURL *>*)assets type:(LTSAssetType)assetType toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block{
    if (assets.count == 0) {
        return;
    }
    self.privateBlock = block;

    if (album) {
        //操作photoLibrary
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

            //检查指定的相册是否存在
            PHAssetCollection *collection = [self checkAlbumWithName:album];

            //创建相册变动请求
            PHAssetCollectionChangeRequest *collectionChangeReq;
            if (collection) {
                collectionChangeReq = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            }else{
                collectionChangeReq = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:album];
            }

            //创建相片资源
            NSArray *placehoders = [self getAssetsWithURL:assets type:assetType];

            //添加相片到指定相册,该api说明添加的是元素是PHAsset对象的数组，但是也可以添加元素是PHObjectPlaceholder对象的数组，文档也有演示示例
            [collectionChangeReq addAssets:placehoders];

        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success && error == nil) {
                [self callBackWithResult:YES];
            }else{
                [self callBackWithResult:NO];
            }
        }];
    }else{
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            if (assetType == LTSAssetTypeImage) {
                for (NSInteger i = 0; i < assets.count; i++) {
                    [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:assets[i]];
                }
            }else{
                //video
                for (NSInteger i = 0; i < assets.count; i++) {
                    [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:assets[i]];
                }
            }
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success && error == nil) {
                [self callBackWithResult:YES];
            }else{
                [self callBackWithResult:NO];
            }
        }];
    }
}

- (NSArray *)getAssetsWithURL:(NSArray <NSURL *>*)urls type:(LTSAssetType)assetType{
    NSMutableArray *tempArr = [NSMutableArray array];

    if (assetType == LTSAssetTypeImage) {
        for (NSInteger i = 0; i < urls.count; i++) {
            PHAssetChangeRequest *assetChangeReq = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:urls[i]];
            [tempArr addObject:assetChangeReq.placeholderForCreatedAsset];
        }
    }else{
        //video
        for (NSInteger i = 0; i < urls.count; i++) {
            PHAssetChangeRequest *assetChangeReq = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:urls[i]];
            [tempArr addObject:assetChangeReq.placeholderForCreatedAsset];
        }
    }
    return [tempArr copy];
}

- (NSArray *)getAssetsWithImages:(NSArray <UIImage *>*)imagas{
    NSMutableArray *tempArr = [NSMutableArray array];

    for (NSInteger i = 0; i < imagas.count; i++) {
        PHAssetChangeRequest *assetChangeReq = [PHAssetChangeRequest creationRequestForAssetFromImage:imagas[i]];
        [tempArr addObject:assetChangeReq.placeholderForCreatedAsset];
    }

    return [tempArr  copy];
}
#else

#pragma mark - before ios8 methods
- (void)saveImage:(UIImage *)image toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block{
    NSParameterAssert(image);
    self.privateBlock = block;
    
    if (album) {
        
        [self checkAlbumWithName:album completion:^(ALAssetsGroup *group) {
            if (group) {
                [self saveImg:image toGroup:group];
            }else{
                NSLog(@"the group album isn't exist, create a new group album.");
                __weak typeof(self) weakSelf = self;
                [_library addAssetsGroupAlbumWithName:album resultBlock:^(ALAssetsGroup *group) {
                    [weakSelf saveImg:image toGroup:group];
                } failureBlock:^(NSError *error) {
                    NSLog(@"create new group album fail.");
                    [weakSelf callBackWithResult:NO];
                }];
            }

        }];
        
    }
    //just write to system album "camera roll"
    else{
        [_library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            
            if (error == nil) {
                [self callBackWithResult:YES];
            }else{
                [self callBackWithResult:NO];
            }
        }];
    }
    
}

- (void)saveVideoAtPath:(NSURL *)fileURL toAlbum:(NSString *)album completeHandler:(LTSAssetManagerBlock)block{
    NSParameterAssert(fileURL);
    self.privateBlock = block;
    UITableView
    if (album) {
        
        [self checkAlbumWithName:album completion:^(ALAssetsGroup *group) {
            if (group) {
                [self saveVideo:fileURL toGroup:group];
            }else{
                NSLog(@"the group album isn't exist, create a new group album.");
                __weak typeof(self) weakSelf = self;
                [_library addAssetsGroupAlbumWithName:album resultBlock:^(ALAssetsGroup *group) {
                    [weakSelf saveVideo:fileURL toGroup:group];
                } failureBlock:^(NSError *error) {
                    NSLog(@"create new group album fail.");
                    [weakSelf callBackWithResult:NO];
                }];
            }
            
        }];
        
    }
    //just write to system album "camera roll"
    else{
        [_library writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error == nil) {
                [self callBackWithResult:YES];
            }else{
                [self callBackWithResult:NO];
            }
        }];
    }
}

- (void)saveImg:(UIImage *)image toGroup:(ALAssetsGroup *)group{
    //保存相片到系统相册
    [_library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
        
        if (error == nil) {
            //保存相片到指定相册
            [_library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                
                if ([group addAsset:asset]) {
                    [self callBackWithResult:YES];
                }else{
                    [self callBackWithResult:NO];
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"get the image asset url from library fail.");
                [self callBackWithResult:NO];
            }];
        }else{
            NSLog(@"the first step:save iamge to system album failure.");
            [self callBackWithResult:NO];
        }
    }];
}

- (void)saveVideo:(NSURL *)videoURL toGroup:(ALAssetsGroup *)group{
    [_library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error == nil) {
            //保存视频到指定相册
            [_library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                if ([group addAsset:asset]) {
                    [self callBackWithResult:YES];
                }else{
                    [self callBackWithResult:NO];
                }
            } failureBlock:^(NSError *error) {
                NSLog(@"get the video asset url from libray fail.");
                [self callBackWithResult:NO];
            }];
        }else{
            NSLog(@"the first step:save video to system album failure.");
            [self callBackWithResult:NO];
        }
    }];
}

//检查相册是否存在
- (void)checkAlbumWithName:(NSString *)album completion:(SearchGroupBlock)block{
    
    __block BOOL founded = NO;
    [_library enumerateGroupsWithTypes:ALAssetsGroupAlbum | ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
        if ([groupName isEqualToString:album]) {
            founded = YES;
            block(group);
        }
        
        if (group == nil && founded == NO) {
            block(nil);
        }
        
    } failureBlock:^(NSError *error) {
        NSLog(@"something wrong occure when enumerate group.");
        block(nil);
    }];
}

#endif


- (void)callBackWithResult:(BOOL)result{
    if (self.privateBlock) {
        self.privateBlock(result);
    }
}


//检查相册是否存在
- (PHAssetCollection *)checkAlbumWithName:(NSString *)album{
    PHFetchResult *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:album]) {
            return collection;
        }
    }
    
    return nil;
}

#pragma mark - cheack authorization
//检查授权
- (void)checkAuthorise:(void (^)(NSInteger))handler{
    
#ifdef __IPHONE_9_0
    handler([PHPhotoLibrary authorizationStatus]);
#else
    handler([ALAssetsLibrary authorizationStatus]);
#endif
}

@end



















