//
//  AAWebpImage+WebP.m
//  AAWebPImageDemo
//
//  Created by 乔杰 on 2018/11/6.
//  Copyright © 2018年 乔杰. All rights reserved.
//

#import "AAWebpImage+WebP.h"
#import "webp/decode.h"
#import "webp/mux_types.h"
#import "webp/demux.h"

static void FreeImageData(void *info, const void *data, size_t size) {
    free((void *)data);
}

@implementation AAWebpImage (WebP)

+ (nullable AAWebpImage*)aa_imageWithWebPData:(nullable NSData *)data {
   
    if (!data) return nil;
    WebPData webpData;
    WebPDataInit(&webpData);
    webpData.bytes = data.bytes;
    webpData.size = data.length;
    WebPDemuxer *demuxer = WebPDemux(&webpData);
    if (!demuxer) return nil;

    uint32_t flags = WebPDemuxGetI(demuxer, WEBP_FF_FORMAT_FLAGS);
    if (!(flags & ANIMATION_FLAG)) {
        AAWebpImage *staticImage = [self aa_rawWepImageWithData:webpData];
        WebPDemuxDelete(demuxer);
        return staticImage;
    }
    
    WebPIterator iter;
    if (!WebPDemuxGetFrame(demuxer, 1, &iter)) {
        WebPDemuxReleaseIterator(&iter);
        WebPDemuxDelete(demuxer);
        return nil;
    }
    
    NSMutableArray *images = [NSMutableArray array];
    NSTimeInterval duration = 0;
    do {
        AAWebpImage *image;
        if (iter.blend_method == WEBP_MUX_BLEND) {
            image = [self aa_blendWebpImageWithOriginImage:[images lastObject] iterator:iter];
        } else {
            image = [self aa_rawWepImageWithData:iter.fragment];
        }
        if (!image) continue;
        [images addObject:image];
        duration += iter.duration / 1000.0f;
    } while (WebPDemuxNextFrame(&iter));
    
    WebPDemuxReleaseIterator(&iter);
    WebPDemuxDelete(demuxer);
    
    AAWebpImage *finalImage = (AAWebpImage *)[AAWebpImage animatedImageWithImages: images duration: duration];
    return finalImage;
}


+ (nullable AAWebpImage*)aa_blendWebpImageWithOriginImage:(nullable UIImage *)originImage iterator:(WebPIterator)iter {
    if (!originImage) return nil;
    
    CGSize size = originImage.size;
    CGFloat tmpX = iter.x_offset;
    CGFloat tmpY = size.height - iter.height - iter.y_offset;
    CGRect imageRect = CGRectMake(tmpX, tmpY, iter.width, iter.height);
    
    AAWebpImage *image = [self aa_rawWepImageWithData:iter.fragment];
    if (!image) return nil;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    uint32_t bitmapInfo = iter.has_alpha ? kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast : 0;
    CGContextRef blendCanvas = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpaceRef, bitmapInfo);
    CGContextDrawImage(blendCanvas, CGRectMake(0, 0, size.width, size.height), originImage.CGImage);
    CGContextDrawImage(blendCanvas, imageRect, image.CGImage);
    CGImageRef newImageRef = CGBitmapContextCreateImage(blendCanvas);
    
    image = [[AAWebpImage alloc] initWithCGImage: newImageRef];
    CGImageRelease(newImageRef);
    CGContextRelease(blendCanvas);
    CGColorSpaceRelease(colorSpaceRef);
    return image;
}

+ (nullable AAWebpImage *)aa_rawWepImageWithData:(WebPData)webpData {
    WebPDecoderConfig config;
    if (!WebPInitDecoderConfig(&config)) return nil;
    if (WebPGetFeatures(webpData.bytes, webpData.size, &config.input) != VP8_STATUS_OK) return nil;
    
    config.output.colorspace = config.input.has_alpha ? MODE_rgbA : MODE_RGB;
    config.options.use_threads = 1;
    
    if (WebPDecode(webpData.bytes, webpData.size, &config) != VP8_STATUS_OK) return nil;
    
    int width = config.input.width;
    int height = config.input.height;
    if (config.options.use_scaling) {
        width = config.options.scaled_width;
        height = config.options.scaled_height;
    }
    
    CGDataProviderRef provider =
    CGDataProviderCreateWithData(NULL, config.output.u.RGBA.rgba, config.output.u.RGBA.size, FreeImageData);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = config.input.has_alpha ? kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast : 0;
    size_t components = config.input.has_alpha ? 4 : 3;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, 8, components * 8, components * width, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    
    AAWebpImage *image = [[AAWebpImage alloc] initWithCGImage:imageRef];

    CGImageRelease(imageRef);
    
    return image;
}

@end
