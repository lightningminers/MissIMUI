//
//  ViewController.m
//  MissIMDemo
//
//  Created by xiangwenwen on 15/4/4.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//


#import <AVOSCloudIM/AVOSCloudIM.h>

#import "ViewController.h"
#import "MissIMViewController.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)gotoMissIMController:(UIButton *)sender {
    
    MissIMViewController *im = [[MissIMViewController alloc] init];
    [im addInfoDataSource:@{@"nickname":@"wenwen",@"userId":@"icepygodmanDEFTGTG",@"iconUrl":@"http://www.battlenet.com.cn/static-render/cn/hearthglen/173/58685869-avatar.jpg?alt=wow/static/images/2d/avatar/7-0.jpg"}];
    [self presentViewController:im animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
