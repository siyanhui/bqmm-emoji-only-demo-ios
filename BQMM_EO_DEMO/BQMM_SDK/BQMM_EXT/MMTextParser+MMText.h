//
//  MMTextParser+CodeText.h
//  BQMM_EO_Demo
//
//  Created xiaoqing Teng on 16/5/23.
//  Copyright © 2016 xiaoqing Teng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BQMM/BQMM.h>

@interface MMTextParser (MMText)

/**
 *  将textImageArray转换成MMText
 *
 *  @param textImageArray MMEmoji和text的集合
 *
 *  @return 返回字符串 如 你好[.emojiCode],你快乐吗[~emojiCode]
 */
+ (NSString *)MMTextWithTextImageArray:(NSArray *)textImageArray;

/**
 *  计算展示图文混排所需size
 *
 *  @param mmText       你好[.emojiCode],你快乐吗[~emojiCode]
 *  @param font             字体
 *  @param maximumTextWidth 最大显示宽度
 *
 *  @return 展示所需的size
 */
+ (CGSize)sizeForMMText:(NSString *)mmText
                   font:(UIFont *)font
       maximumTextWidth:(CGFloat)maximumTextWidth;

+ (CGSize)sizeForTextWithText:(NSString *)text
                         font:(UIFont *)font
             maximumTextWidth:(CGFloat)maximumTextWidth;

@end
