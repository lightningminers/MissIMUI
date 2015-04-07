//
//  MissIMUIView.h
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import <UIKit/UIKit.h>

@interface MissIMUIView : UIView

@property(nonatomic,strong) UIView *MissIMSubView;  //装载TableView的容器
@property(nonatomic,strong) UITableView *MissIMTableView;  //聊天的容器
@property(nonatomic,strong) UITextField *MissIMTextField;  //发送消息的文本框
@property(nonatomic,strong) UIButton *MissIMOptions; //选择按钮
@property(nonatomic,strong) UIButton *MissIMBackForWebView; //回退
@property(nonatomic,strong) UINavigationBar *MissIMNavigationBar; //导航按钮
@property(nonatomic,strong) UIActivityIndicatorView *MissIMActivity; //加载...

+(instancetype) missWithUI;

@end
