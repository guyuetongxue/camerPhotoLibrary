//
//  ZMKHUserUploadPictureTool.h
//  zmPurse
//
//  Created by 胡庭 on 2019/4/28.
//  Copyright © 2019 胡庭. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZMKHUserUploadPictureTool : NSObject

+ (instancetype)zmkhUserUplaodPictureManager;

- (void)uploadCamer;

typedef void (^uploadBlock)(id saveImage);

@property (nonatomic,strong) uploadBlock uplaodBlock;



@end

NS_ASSUME_NONNULL_END
