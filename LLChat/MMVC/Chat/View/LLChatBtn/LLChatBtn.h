//
//  LLChatBtn.h
//  LLChat
//
//  Created by WangZhaomeng on 2018/9/4.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LLChatButtonTypeNormal = 0,   //系统默认类型
    LLChatButtonTypeRetry,        //重发消息按钮
    LLChatButtonTypeInput,        //聊天输入按钮
    LLChatButtonTypeMoreKeyboard, //聊天加号键盘
}LLChatButtonType;
@interface LLChatBtn : UIButton

+ (instancetype)chatButtonWithType:(LLChatButtonType)type;

@end
