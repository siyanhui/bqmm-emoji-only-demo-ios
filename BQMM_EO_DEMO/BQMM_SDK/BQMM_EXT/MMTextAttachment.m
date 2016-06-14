//
//  MMTextAttachment.m
//  StampMeSDK
//
//  Created by ceo on 11/9/15.
//  Copyright © 2015 siyanhui. All rights reserved.
//

#import "MMTextAttachment.h"
#import <BQMM/BQMM.h>

@implementation MMTextAttachment

- (void)setEmoji:(MMEmoji *)emoji {
    if (_emoji != emoji) {
        _emoji = emoji;
        if (_emoji.isEmoji) {
            self.bounds = CGRectMake(0, 0, 20, 20);
        }else {
            self.bounds = CGRectMake(0, 0, 60, 60);
        }
    }
}

- (UIImage *)placeHolderImage {
    static UIImage *clearImage = nil;
    if (clearImage == nil) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), NO, 0);
        clearImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return clearImage;
}

+ (UIImage *)errorImage {
    static UIImage *_errorImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _errorImage = [UIImage imageNamed:@"emoji_error"];
    });
    return _errorImage;
}

@end
