//
//  MMLabel.m
//  StampMeSDK
//
//  Created by ceo on 11/9/15.
//  Copyright © 2015 siyanhui. All rights reserved.
//

#import "MMTextView.h"
#import <BQMM/BQMM.h>
#import "MMTextParser.h"
#import "MMTextAttachment.h"

@interface MMTextView ()

@property (nonatomic, strong) NSMutableArray *attachmentRanges;
@property (nonatomic, strong) NSMutableArray *attachments;
@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) MMTextParserModel *model;

@end

@implementation MMTextView

#pragma mark - setter/getter

- (void)setMmFont:(UIFont *)mmFont {
    _mmFont = mmFont;
    [self setFont:mmFont];
}

- (void)setMmTextColor:(UIColor *)mmTextColor {
    _mmTextColor = mmTextColor;
    [self setTextColor:mmTextColor];
}

- (void)setPlaceholderTextWithMmTextModel:(MMTextParserModel *)model {

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    [model.originalData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            NSString *emojiString = [model.wrapperCodeData objectAtIndex:idx];
            MMTextAttachment *placeholderAttachment = [[MMTextAttachment alloc] init];
            if ([emojiString hasPrefix:@"[."]) {
                placeholderAttachment.bounds = CGRectMake(0, 0, 20, 20);//固定20X20
            }else {
                placeholderAttachment.bounds = CGRectMake(0, 0, 60, 60);//固定20X20
            }
            [attrStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:placeholderAttachment]];
        }else if ([obj isKindOfClass:[NSString class]]){
            NSString *capString = (NSString *)obj;
            [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:capString]];
        }
    }];

    //字体
    if (self.mmFont) {
        [attrStr addAttribute:NSFontAttributeName value:self.mmFont range:NSMakeRange(0, attrStr.length)];
    }
    if (self.mmTextColor) {
        [attrStr addAttribute:NSForegroundColorAttributeName value:self.mmTextColor range:NSMakeRange(0, attrStr.length)];
    }
    self.attributedText = attrStr;
}

- (void)setMMText:(NSString *)mmText {
    NSString *mT = mmText;
    if (mT == nil) {
        mT = @"";
    }
    [self setMMText:mT completionHandler:nil];
}

- (void)setMMText:(NSString*)mmText completionHandler:(void(^)(void))completionHandler {
    MMTextParserModel *model = [[MMTextParserModel alloc] initWithMMText:mmText];
    self.model = model;
    [self clearImageViewsCover];
    [self setPlaceholderTextWithMmTextModel:model];
    [self updateAttributeTextWithMmTextModel:model completionHandler:completionHandler];
}

- (void)updateAttributeTextWithMmTextModel:(MMTextParserModel *)model completionHandler:(void(^)(void))completionHandler {

    __weak MMTextView *weakSelf = self;

    [MMTextParser parseMMTextModel:model completionHandler:^(NSArray *textImgArray) {
        __strong MMTextView *tempSelf = weakSelf;
        if (tempSelf && [tempSelf.model.mmText isEqualToString:model.mmText]) {
            tempSelf.attributedText = [tempSelf transTextImageArrayToAttributedText:textImgArray];
            [tempSelf transAttachmentToImageViews];
        }
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (NSAttributedString *)transTextImageArrayToAttributedText:(NSArray *)textImgArray {
    NSMutableAttributedString *attachmentStr = [[NSMutableAttributedString alloc] init];
    for (id obj in textImgArray) {
        if ([obj isKindOfClass:[MMEmoji class]]) {
            MMTextAttachment *attachment = [[MMTextAttachment alloc] init];
            attachment.emoji = obj;
            attachment.image = attachment.emoji.emojiImage;
            [attachmentStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        } else if ([obj isKindOfClass:[NSString class]]) {
            [attachmentStr appendAttributedString:[[NSAttributedString alloc] initWithString:obj]];
        } else if ([obj isKindOfClass:[NSNull class]]){
            MMTextAttachment *attachment = [[MMTextAttachment alloc] init];
            attachment.image = [MMTextAttachment errorImage];
            attachment.bounds = CGRectMake(0, 0, 20, 20);
            [attachmentStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
        }
    }
    if (self.mmFont) {
        [attachmentStr addAttribute:NSFontAttributeName value:self.mmFont range:NSMakeRange(0, attachmentStr.length)];
    }
    if (self.mmTextColor) {
        [attachmentStr addAttribute:NSForegroundColorAttributeName value:self.mmTextColor range:NSMakeRange(0, attachmentStr.length)];
    }
    return attachmentStr;
}

- (void)transAttachmentToImageViews {
    [self clearImageViewsCover];
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, [self.attributedText length])
                                        options:0
                                     usingBlock:^(id value, NSRange range, BOOL * stop) {
                                         if ([value isKindOfClass:[MMTextAttachment class]]) {
                                             MMTextAttachment *attachment = (MMTextAttachment *)value;
                                             UIImage *emojiImg = attachment.image;
                                             attachment.image = nil;
                                             [self.attachmentRanges addObject:[NSValue valueWithRange:range]];
                                             [self.attachments addObject:value];
                                             UIImageView *imgView = [[UIImageView alloc] initWithImage:emojiImg];
                                             [self.imageViews addObject:imgView];
                                         }
                                     }];
}

- (NSMutableArray *)attachments {
    if (_attachments == nil) {
        _attachments = [[NSMutableArray alloc] init];
    }
    return _attachments;
}

- (NSMutableArray *)attachmentRanges {
    if (_attachmentRanges == nil) {
        _attachmentRanges = [[NSMutableArray alloc] init];
    }
    return _attachmentRanges;
}

- (NSMutableArray *)imageViews {
    if (_imageViews == nil) {
        _imageViews = [[NSMutableArray alloc] init];
    }
    return _imageViews;
}

#pragma mark - private

- (void)clearImageViewsCover {
    [self.attachmentRanges removeAllObjects];
    [self.attachments removeAllObjects];

    for (UIImageView *imgView in self.imageViews) {
        [imgView removeFromSuperview];
    }
    [self.imageViews removeAllObjects];
}


#pragma mark - Layout

- (void)layoutAttachments {
    NSInteger attachmentCount = [self.attachments count];
    for (NSInteger i = 0; i < attachmentCount; i++) {
        NSRange range = [self.attachmentRanges[i] rangeValue];
        MMTextAttachment *attachment = self.attachments[i];
        UIImageView *imgView = self.imageViews[i];

        NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:nil];
        CGRect rect = [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:self.textContainer];
        rect.origin.x += self.textContainerInset.left;
        rect.origin.y += self.textContainerInset.top;

        CGFloat originalY = CGRectGetMaxY(rect) - attachment.bounds.size.height;
        if(attachment.bounds.size.width == 20) {
            CGFloat lineHeight = self.mmFont.lineHeight;
            originalY = CGRectGetMaxY(rect) - lineHeight / 2 - attachment.bounds.size.height / 2;
        }
        imgView.frame = CGRectMake(rect.origin.x, originalY, attachment.bounds.size.width, attachment.bounds.size.height);
        if ([imgView superview] == nil) {
            [self addSubview:imgView];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutAttachments];
}

- (NSString *)mmTextWithRange:(NSRange)range {
    return [MMTextParser pureTextFromAttributeText:[self.attributedText attributedSubstringFromRange:range]];
}

- (void)copy:(id)sender {
    [UIPasteboard generalPasteboard].string = [self mmTextWithRange:self.selectedRange];
}



@end
