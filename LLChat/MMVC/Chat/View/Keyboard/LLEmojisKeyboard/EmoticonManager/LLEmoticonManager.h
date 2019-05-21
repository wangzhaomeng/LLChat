//
//  LLEmoticonManager.h
//  LLChat
//
//  Created by WangZhaomeng on 2019/5/17.
//  Copyright © 2019 WangZhaomeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLEmoticonManager : NSObject

///所有简体表情, 如: [爱你]
@property (nonatomic, strong) NSArray *chs;
@property (nonatomic, strong) NSDictionary *chsDic;
///所有繁体表情, 如: [愛你]
@property (nonatomic, strong) NSArray *cht;
@property (nonatomic, strong) NSDictionary *chtDic;
///所有表情 <默认, 浪小花, emoji>
@property (nonatomic, strong) NSArray *emoticons;

+ (instancetype)manager;

///匹配文本中的所有表情
- (NSArray *)matchEmoticons:(NSString *)subString;
///匹配输入框将要删除的表情
- (NSString *)willDeleteEmoticon:(NSString *)subString;
///文本转富文本
- (NSMutableAttributedString *)attributedString:(NSString *)subString;

@end
