
//效果图

![Image text](https://github.com/wangzhaomeng/LLPhotoBrowser/blob/master/exampleImgs/IMG_0244.PNG?raw=true)

![Image text](https://github.com/wangzhaomeng/LLPhotoBrowser/blob/master/exampleImgs/IMG_0245.PNG?raw=true)

![Image text](https://github.com/wangzhaomeng/LLPhotoBrowser/blob/master/exampleImgs/IMG_0246.PNG?raw=true)


//代码示例
```
- (IBAction)btnClick:(UIButton *)sender {
    LLPhotoBrowser *photoBrowser = [[LLPhotoBrowser alloc] initWithImages:_images currentIndex:1];
    photoBrowser.delegate = self;
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

- (void)photoBrowser:(LLPhotoBrowser *)photoBrowser didSelectImage:(UIImage *)image {
    NSLog(@"选中的图片为:%@",image);
}
```

