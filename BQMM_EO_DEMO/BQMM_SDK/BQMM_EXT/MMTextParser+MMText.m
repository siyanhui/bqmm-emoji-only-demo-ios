//
//  MMTextParser+CodeText.m
//  BQMM_EO_Demo
//
//  Created by xiaoqing Teng on 16/5/23.
//  Copyright © 2016年 xiaoqing Teng. All rights reserved.
//

#import "MMTextParser+MMText.h"

static MMEmoji *s_placeholderEmoji = nil;

@implementation MMTextParser (MMText)

+ (NSString*)MMTextWithTextImageArray:(NSArray*)textImageArray {
    NSMutableString *ret = [NSMutableString string];

    for (id obj in textImageArray) {
        if ([obj isKindOfClass:[MMEmoji class]]) {
            MMEmoji *emoji = (MMEmoji*)obj;
            EmojiType type = [MMTextParser emojiTypeWithEmojiCode:emoji.emojiCode];
            switch (type) {
                case EmojiTypeSmall:
                    [ret appendFormat:@"[.%@]", emoji.emojiCode];
                    break;
                case EmojiTypeBig:
                    [ret appendFormat:@"[~%@]", emoji.emojiCode];
                    break;
                default:
                    [ret appendString:emoji.emojiName];
                    break;
            }
        } else if ([obj isKindOfClass:[NSString class]]) {
            [ret appendString:obj];
        } else {
            assert(0);
        }
    }
    return ret;
}

+ (CGSize)sizeForMMText:(NSString*)mmText
                   font:(UIFont *)font
       maximumTextWidth:(CGFloat)maximumTextWidth {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];

    [self enumerateMatchesInMMText:mmText textUseBlock:^(NSRange range) {
        NSString *text = [mmText substringWithRange:range];
        [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:text]];
    } emojiUserBlock:^(NSRange emojiRange, NSRange emojiCodeRange) {
        NSString *emojiString = [mmText substringWithRange:emojiRange];
        NSTextAttachment *placeholderAttachment = [[NSTextAttachment alloc] init];
        if ([emojiString hasPrefix:@"[."]) {
            placeholderAttachment.bounds = CGRectMake(0, 0, 20, 20);//固定20X20
        }else {
            placeholderAttachment.bounds = CGRectMake(0, 0, 60, 60);//固定20X20
        }
        [attrStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:placeholderAttachment]];
    }];

    //字体
    if (font) {
        [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attrStr.length)];
    }
    // 计算文本的大小
    CGSize sizeToFit = [attrStr boundingRectWithSize:CGSizeMake(maximumTextWidth, MAXFLOAT)
                                             options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             context:nil].size;

    return CGRectIntegral(CGRectMake(0, 0, sizeToFit.width + 10, sizeToFit.height + 16)).size;
}

+ (CGSize)sizeForTextWithText:(NSString *)text
                         font:(UIFont *)font
             maximumTextWidth:(CGFloat)maximumTextWidth {
    CGSize size = CGSizeZero;
    size = [text boundingRectWithSize:CGSizeMake(maximumTextWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
    size.width += 10;
    size.height += 16;

    return size;
}

@end
