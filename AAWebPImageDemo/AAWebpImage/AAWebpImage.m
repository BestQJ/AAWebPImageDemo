//
//  AAWebpImage.m
//  AAWebPImageDemo
//
//  Created by 乔杰 on 2018/11/6.
//  Copyright © 2018年 乔杰. All rights reserved.
//

#import "AAWebpImage.h"
#import "AAWebpImage+WebP.h"

@interface AAWebpImage ()

@property (nonatomic, strong) NSString *imageName;

@end

@implementation AAWebpImage

+ (AAWebpImage *)imageNamed:(NSString *)name {
    
    if ([name containsString: @".jpg"] || [name containsString: @".webp"]) {
        //图片名称带jpg、webp后缀
        name = [name componentsSeparatedByString: @"."][0];
        if ([self getCurrentFile: name]) {
            //name a.jpg a.webp 能在ImagesResource中找到并生成webpImage
            return [self getCurrentFile: name];
        }
    }else {
        //图片名称带png后缀
        if ([name containsString: @".png"]) {
            name = [name componentsSeparatedByString: @"."][0];
        }
        if (![name containsString: @"@2x"] && ![name containsString: @"@3x"]) {
            NSString *name2x = [name stringByAppendingString: @"@2x"];
            NSString *name3x = [name stringByAppendingString: @"@3x"];
            if ([UIScreen mainScreen].scale == 3) {
                //设备分辨率为3x时 优先选用3x图片
                if ([self getCurrentFile: name3x]) {
                    //name a.png 转换名称后追加@3x能在ImagesResource中找到并生成webpImage
                    return [self getCurrentFile: name3x];
                }else if ([self getCurrentFile: name2x]) {
                    //name a.png 转换名称后追加@2x能在ImagesResource中找到并生成webpImage
                    return [self getCurrentFile: name2x];
                }else if ([self getCurrentFile: name]) {
                    //name a.png 能在ImagesResource中找到并生成webpImage
                    return [self getCurrentFile: name];
                }
            }else {
                //设备分辨率为2x时 优先选用2x图片
                if ([self getCurrentFile: name2x]) {
                    //name a.png 转换名称后追加@2x能在ImagesResource中找到并生成webpImage
                    return [self getCurrentFile: name2x];
                }else if ([self getCurrentFile: name]) {
                    //name a.png 能在ImagesResource中找到并生成webpImage
                    return [self getCurrentFile: name];
                }else if ([self getCurrentFile: name3x]) {
                    //name a.png 转换名称后追加@3x能在ImagesResource中找到并生成webpImage
                    return [self getCurrentFile: name3x];
                }
            }
        }else {
            if ([self getCurrentFile: name]) {
                //name a@2x.png a@3x.png 能在ImagesResource中找到并生成webpImage
                return [self getCurrentFile: name];
            }
        }
    }
    return nil;
}

- (CGSize)size {
    
    CGFloat fixelW = CGImageGetWidth(self.CGImage);
    
    CGFloat fixelH = CGImageGetHeight(self.CGImage);
    
    CGSize size = CGSizeMake(fixelW, fixelH);
    
    if (self.isHighlighted) return size;
    
    if ([self.imageName containsString: @"@2x"]) {
        
        return CGSizeMake(size.width/2.0, size.height/2.0);
        
    }else if ([self.imageName containsString: @"@3x"]) {
        
        return CGSizeMake(size.width/3.0, size.height/3.0);
    }
    return size;
}


+ (AAWebpImage *)getCurrentFile:(NSString *)name {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource: name ofType:@"webp"];

    NSData *data = [[NSData alloc] initWithContentsOfFile: filePath];
    
    AAWebpImage *img = [AAWebpImage aa_imageWithWebPData: data];

    img.imageName = name;
    
    return img;
}



@end
