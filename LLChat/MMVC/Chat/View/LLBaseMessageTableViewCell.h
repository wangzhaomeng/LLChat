//
//  LLBaseMessageTableViewCell.h
//  LLChat
//
//  Created by WangZhaomeng on 2018/9/4.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLBaseMessageTableViewCell : UITableViewCell {
    UILabel *_nickLabel;
    UIImageView *_avatarImageView;
    UIImageView *_bubbleImageView;
    UIActivityIndicatorView *_activityView;
    
    CGRect _contentRect;
}

- (void)setConfig:(LLBaseMessageModel *)model;

@end
