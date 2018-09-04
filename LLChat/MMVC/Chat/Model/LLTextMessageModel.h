//
//  LLTextMessageModel.h
//  LLChat
//
//  Created by WangZhaomeng on 2018/9/3.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import "LLBaseMessageModel.h"

#define LL_TEXT_CONTENT_W (LL_SCREEN_WIDTH-200)
#define LL_TEXT_CONTENT_F [UIFont systemFontOfSize:15]
@interface LLTextMessageModel : LLBaseMessageModel

- (NSDictionary<NSAttributedStringKey,id> *)contentAttributes;

@end