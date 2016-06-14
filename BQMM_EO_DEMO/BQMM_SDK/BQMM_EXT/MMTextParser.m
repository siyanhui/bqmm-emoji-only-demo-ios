//
//  MMTextParser.m
//  BQMM_EO_Demo
//
//  Created by xiaoqing Teng on 16/5/23.
//  Copyright © 2016年 xiaoqing Teng. All rights reserved.
//

#import "MMTextParser.h"
#import "MMTextAttachment.h"

static MMEmoji *s_placeholderEmoji = nil;

@implementation MMTextParser

#pragma mark public

+ (NSString *)pureTextFromAttributeText:(NSAttributedString *)aStr {
    NSMutableString *mStr = [[NSMutableString alloc] init];
    __block NSInteger pointer = 0;
    [aStr enumerateAttribute:NSAttachmentAttributeName
                     inRange:NSMakeRange(0, [aStr length])
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL * stop) {
                      if ([value isKindOfClass:[MMTextAttachment class]]) {
                          MMTextAttachment *attachment = (MMTextAttachment *)value;
                          NSString *preStr = [[aStr attributedSubstringFromRange:NSMakeRange(pointer, range.location - pointer)] string];
                          [mStr appendString:preStr];
                          pointer = range.location + range.length;
                          NSString *wrappedCode = @"";
                          if (attachment.emoji) {
                              wrappedCode = [self wrappedEmoji:attachment.emoji];
                          }
                          [mStr appendString:wrappedCode];
                      }
                  }];
    NSString *lastStr = [[aStr attributedSubstringFromRange:NSMakeRange(pointer, aStr.length - pointer)] string];
    [mStr appendString:lastStr];
    return [[NSString alloc] initWithString:mStr];
}

+ (void)parseMMTextModel:(MMTextParserModel *)model
       completionHandler:(void(^)(NSArray *textImgArray))completionHandler {
    NSMutableArray *codes = [NSMutableArray array];

    [model.originalData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            NSString *emojiCode = [model.codeData objectAtIndex:idx];
            if (![codes containsObject:emojiCode]) {
                [codes addObject:emojiCode];
            }
        }
    }];
    if (codes.count == 0) {
        completionHandler(@[model.mmText]);
    }else {
        void(^fetchAction)(NSArray *) = ^(NSArray *smEmojis) {
            NSArray *ret = [self generateTextImageArrayFromMMTextModel:model withEmojis:smEmojis];
            completionHandler(ret);
        };
        [[MMEmotionCentre defaultCentre] fetchEmojisByType:MMFetchTypeAll codes:codes completionHandler:^(NSArray *emojis) {
            fetchAction(emojis);
        }];
    }
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

#pragma mark -private

+ (NSString *)wrappedEmoji:(MMEmoji *)emoji {
    if (emoji.isEmoji) {
        return [NSString stringWithFormat:@"[.%@]",emoji.emojiCode];
    }else {
        return [NSString stringWithFormat:@"[~%@]",emoji.emojiCode];
    }
}

+ (void)enumerateMatchesInMMText:(NSString *)mmText textUseBlock:(void(^)(NSRange range))textBlock emojiUserBlock:(void(^)(NSRange emojiRange, NSRange emojiCodeRange))emojiBlock {
    NSRegularExpression *expression = [[NSRegularExpression alloc] initWithPattern:@"\\[[\\.~]([^\\[\\]]+)\\]"
                                                                           options:0
                                                                             error:NULL];
    __block NSUInteger startLocation = 0;
    [expression enumerateMatchesInString:mmText options:0 range:NSMakeRange(0, [mmText length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSRange emojiRange = [result rangeAtIndex:0];
        NSRange emojiCodeRange = [result rangeAtIndex:1];
        if (emojiRange.location > startLocation) {
            NSRange capRange = NSMakeRange(startLocation, emojiRange.location - startLocation);
            textBlock(capRange);
        }
        emojiBlock(emojiRange, emojiCodeRange);
        startLocation = emojiRange.location + emojiRange.length;
    }];
    if (startLocation < mmText.length) {
        NSRange capRange = NSMakeRange(startLocation, mmText.length - startLocation);
        textBlock(capRange);
    }

}

+ (MMEmoji *)findEmojiWithEmojiCode:(NSString *)code fromEmojis:(NSArray *)emojis {
    MMEmoji *ret = nil;
    for (MMEmoji *emoji in emojis) {
        if ([emoji.emojiCode isEqualToString:code]) {
            ret = emoji;
            break;
        }
    }
    return ret;
}

+ (NSArray *)generateTextImageArrayFromMMTextModel:(MMTextParserModel *)mmTextModel withEmojis:(NSArray *)emojis {
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:mmTextModel.originalData.count];
    [mmTextModel.originalData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            NSString *emojiCode = [mmTextModel.codeData objectAtIndex:idx];
            MMEmoji *emoji = [self findEmojiWithEmojiCode:emojiCode fromEmojis:emojis];
            if (emoji == nil) {
                [ret addObject:[NSNull null]];
            } else {
                [ret addObject:emoji];
            }
        } else {
            NSString *text = [mmTextModel.originalData objectAtIndex:idx];
            [ret addObject:text];
        }
    }];
    return [NSArray arrayWithArray:ret];
}




@end

@implementation MMTextParserModel

- (instancetype)initWithMMText:(NSString *)mmText {
    self = [super init];
    if (self && mmText) {
        self.mmText = mmText;
        NSMutableArray *originalData = [NSMutableArray array];
        NSMutableArray *wrapperCodeData = [NSMutableArray array];
        NSMutableArray *codeData = [NSMutableArray array];

        [MMTextParser enumerateMatchesInMMText:mmText textUseBlock:^(NSRange range) {
            NSString *text = [mmText substringWithRange:range];
            [originalData addObject:text];
            [wrapperCodeData addObject:@""];
            [codeData addObject:@""];
        } emojiUserBlock:^(NSRange emojiRange, NSRange emojiCodeRange) {
            NSString *emojiWrapperCode = [mmText substringWithRange:emojiRange];
            NSString *emojiCode = [mmText substringWithRange:emojiCodeRange];
            [originalData addObject:[NSNull null]];
            [wrapperCodeData addObject:emojiWrapperCode];
            [codeData addObject:emojiCode];
        }];
        self.originalData = originalData;
        self.wrapperCodeData = wrapperCodeData;
        self.codeData = codeData;
    }
    return self;
}

@end
