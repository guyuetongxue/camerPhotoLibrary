//
//  ZMKHUserUploadPictureTool.m
//  zmPurse
//
//  Created by 胡庭 on 2019/4/28.
//  Copyright © 2019 胡庭. All rights reserved.
//

#import "ZMKHUserUploadPictureTool.h"
#import "WYImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define ORIGINAL_MAX_WIDTH 640.0f

static ZMKHUserUploadPictureTool *_zmkhUserPictureTool;

@interface ZMKHUserUploadPictureTool ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,WYImageCropperDelegate>

@end

@implementation ZMKHUserUploadPictureTool

+ (instancetype)zmkhUserUplaodPictureManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_zmkhUserPictureTool == nil){
            _zmkhUserPictureTool = [[self alloc] init];
        }
    });
    return _zmkhUserPictureTool;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _zmkhUserPictureTool = [super allocWithZone:zone];
    });
    return _zmkhUserPictureTool;
}

-(id)copyWithZone:(NSZone *)zone
{
    return _zmkhUserPictureTool;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _zmkhUserPictureTool;
}

#pragma mark -uploadCamer

- (void)uploadCamer
{
    UIAlertController *alertCtl =[[UIAlertController alloc]init];
       UIAlertAction *cancel =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       }];
       UIAlertAction *xiangji =[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           //=====
           UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                      controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                      
                      //采用照相机的前镜头
                      if ([self isFrontCameraAvailable]) {
                          controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                      }
                      
                      NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                      [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                      controller.mediaTypes = mediaTypes;
                      controller.delegate = self;
                   controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
                      [[self zmkhJumpRooVc:self] presentViewController:controller
                                         animated:YES
                                       completion:^(void){
                                           NSLog(@"Picker View Controller is presented");
                                       }];
           //=====
       }];
       UIAlertAction *xiangce =[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
           //=====
           // 从相册中选取
                  if ([self isPhotoLibraryAvailable]) {
                      UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                      controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                      NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                      [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                      controller.mediaTypes = mediaTypes;
                      controller.delegate = self;
                      controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
                      [[self zmkhJumpRooVc:self] presentViewController:controller
                                         animated:YES
                                       completion:^(void){
                                           NSLog(@"Picker View Controller is presented");
                                       }];
                  }
           //=====
       }];
       
       if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
       {
           [alertCtl addAction:cancel];
           [alertCtl addAction:xiangji];
           [alertCtl addAction:xiangce];
       }else{
           [alertCtl addAction:cancel];
           [alertCtl addAction:xiangce];
       }
       
       [[self zmkhJumpRooVc:self] presentViewController:alertCtl animated:YES completion:nil];
}

#pragma mark WYImageCropperDelegate
- (void)imageCropper:(WYImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage{
    
    if (self.uplaodBlock) {
           self.uplaodBlock(editedImage);
       }
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(WYImageCropperViewController *)cropperViewCrotroller {
    [cropperViewCrotroller dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        WYImageCropperViewController *imgEditorVC = [[WYImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        imgEditorVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [[self zmkhJumpRooVc:self] presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated{
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
}


#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}




#pragma mark - 跳转相机-相册


- (void)popCamerOrPhotoLibraary:(NSUInteger )sourceType
{
    // 跳转到相机或相册页面
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    imagePickerController.delegate = self;
    
    imagePickerController.allowsEditing = YES;
    
    imagePickerController.sourceType = sourceType;
    
    //跳转动画效果
//    imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [[self zmkhJumpRooVc:self] presentViewController:imagePickerController animated:YES completion:^{}];
}



#pragma mark - image picker delegte



#pragma mark - 获取当前vc

/*
 当前类vc
 */
- (UIViewController *)zmkhJumpRooVc:(id)responder
{
    return [self fetchViewController:responder];
}

#pragma mark --- private

- (UIViewController *)fetchViewController:(id)responder
{
    UIViewController *vc;
    if ([responder isKindOfClass:[UIView class]]) {
        vc = [self fetchViewControllerFromView:responder];
    }else if ([responder isKindOfClass:[UIViewController class]]){
        vc = responder;
    }
    if (!vc) {
        vc = [self fetchViewControllerFromRootViewController];
    }
    return vc;
}

- (UIViewController *)fetchViewControllerFromView:(UIView *)view
{
    UIResponder *responder = view.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            break;
        }
        responder = responder.nextResponder;
    }
    return (UIViewController *)responder;
}

- (UIViewController *)fetchViewControllerFromRootViewController
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (vc) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}




#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}






/*
 
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<UIImagePickerControllerInfoKey, id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0);
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info;
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
 
 */




@end
