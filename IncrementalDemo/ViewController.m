//
//  ViewController.m
//  DrawDemo
//
//  Created by 胡聪 on 2017/12/18.
//  Copyright © 2017年 hucong. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

@interface ViewController () <NSURLSessionDataDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableData *haveReceivedData;
@end

@implementation ViewController

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 319, 200)];
    }
    return _imageView;
}

- (NSMutableData *)haveReceivedData {
    if (_haveReceivedData == nil) {
        _haveReceivedData = [NSMutableData data];
    }
    return _haveReceivedData;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.view addSubview:self.imageView];
    self.imageView.center = self.view.center;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSURL *url = [NSURL URLWithString:@"http://c.hiphotos.baidu.com/zhidao/pic/item/7aec54e736d12f2e0bd5528c48c2d5628435680e.jpg"];
    //创建NSURLSession对象，代理方法在self(控制器)执行，代理方法队列传的nil，表示和下载在一个队列里，也就是在子线程中执行。
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    
    //创建一个dataTask任务
    NSURLSessionDataTask *task = [session dataTaskWithURL:url];
    
    //启动任务
    [task resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    //存储已经下载的图片二进制数据。
    [self.haveReceivedData appendData:data];
    
    //总共需要下载的图片数据的大小。
    int64_t totalSize = dataTask.countOfBytesExpectedToReceive;
    
    //创建一个递增的ImageSource，一般传NULL。
    CGImageSourceRef imageSource = CGImageSourceCreateIncremental(NULL);
    
    //使用最新的数据更新递增的ImageSource，第二个参数是已经接收到的Data，第三个参数表示是否已经是最后一个Data了。
    CGImageSourceUpdateData(imageSource, (__bridge CFDataRef)self.haveReceivedData, totalSize == self.haveReceivedData.length);
    
    //通过关联到ImageSource上的Data来创建一个CGImage对象，第一个参数传入更新数据之后的imageSource；第二个参数是图片的索引，一般传0；第三个参数跟创建的时候一样，传NULL就行。
    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    
    //释放创建的CGImageSourceRef对象
    CFRelease(imageSource);
    
    //在主线程中更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        //其实可以直接把CGImageRef对象赋值给layer的contents属性，翻开苹果的头文件看就知道，一个UIView之所以能显示内容，就是因为CALayer的原因，而CALayer显示内容的属性就是contents，而contents通常就是CGImageRef。
        self.imageView.layer.contents = (__bridge id _Nullable)(image);
//        self.imageView.image = [UIImage imageWithCGImage:image];
        
        //释放创建的CGImageRef对象
        CGImageRelease(image);
    });
}

@end
