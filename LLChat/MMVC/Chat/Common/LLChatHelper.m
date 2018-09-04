//
//  LLChatHelper.m
//  LLChat
//
//  Created by WangZhaomeng on 2018/9/4.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import "LLChatHelper.h"

@implementation LLChatHelper {
    UIImage *_senderBubbleImage;
    UIImage *_receiverBubbleImage;
}

+ (instancetype)shareInstance {
    static LLChatHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LLChatHelper alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (UIImage *)senderBubbleImage {
    if (_senderBubbleImage == nil) {
        UIImage *image = [UIImage imageNamed:@"ll_chat_bj2"];
        CGSize size = image.size;
        _senderBubbleImage = [image stretchableImageWithLeftCapWidth:size.width/2 topCapHeight:size.height*0.8];
    }
    return _senderBubbleImage;
}

- (UIImage *)receiverBubbleImage {
    if (_receiverBubbleImage == nil) {
        UIImage *image = [UIImage imageNamed:@"ll_chat_bj1"];
        CGSize size = image.size;
        _receiverBubbleImage = [image stretchableImageWithLeftCapWidth:size.width/2 topCapHeight:size.height*0.8];
    }
    return _receiverBubbleImage;
}

@end