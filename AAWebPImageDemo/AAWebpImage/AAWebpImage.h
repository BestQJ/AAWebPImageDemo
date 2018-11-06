//
//  AAWebpImage.h
//  AAWebPImageDemo
//
//  Created by 乔杰 on 2018/11/6.
//  Copyright © 2018年 乔杰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AAWebpImage : UIImage

//isHighlighted = YES 获取图片实际大小 默认返回屏幕适配大小图片（即实际大小/[UIScreen mainScreen].scale）
@property (nonatomic, assign) BOOL isHighlighted;

@end

NS_ASSUME_NONNULL_END
