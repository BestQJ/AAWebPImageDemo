//
//  AAWebpImage+WebP.h
//  AAWebPImageDemo
//
//  Created by 乔杰 on 2018/11/6.
//  Copyright © 2018年 乔杰. All rights reserved.
//

#import "AAWebpImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface AAWebpImage (WebP)

+ (nullable AAWebpImage*)aa_imageWithWebPData:(nullable NSData *)data;

@end

NS_ASSUME_NONNULL_END
