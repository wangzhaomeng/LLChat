//
//  LLChatViewController.h
//  LLChat
//
//  Created by WangZhaomeng on 2018/9/4.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LLChatUserModel;
@class LLChatGroupModel;
@class LLChatSessionModel;

@interface LLChatViewController : UIViewController

///选择用户进入聊天
- (instancetype)initWithUser:(LLChatUserModel *)userModel;

///选择群进入聊天
- (instancetype)initWithGroup:(LLChatGroupModel *)groupModel;

///选择会话进入聊天
- (instancetype)initWithSession:(LLChatSessionModel *)sessionModel;

@end
