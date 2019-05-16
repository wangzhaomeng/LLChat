//
//  LLChatUserModel.h
//  LLChat
//
//  Created by WangZhaomeng on 2019/4/24.
//  Copyright © 2019 WangZhaomeng. All rights reserved.
//  聊天用户

#import "LLChatBaseModel.h"

@interface LLChatUserModel : LLChatBaseModel

///用户id
@property (nonatomic, strong) NSString *uid;
///用户昵称
@property (nonatomic, strong) NSString *name;
///用户头像
@property (nonatomic, strong) NSString *avatar;
///聊天界面是否显示用户昵称
@property (nonatomic, assign) BOOL isShowName;

///默认登录用户
+ (instancetype)shareInfo;

@end
