//
//  MissIMUIView.m
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import "MissIMUIView.h"

static const NSInteger kMissIMUINavigationBarHeight = 64; //导航栏的高度

@implementation MissIMUIView

-(instancetype)initWithMissIMUI
{
    self = [super init];
    if (self) {
        [self createMissIMUI];
    }
    return self;
}

+(instancetype)missWithUI
{
    MissIMUIView *missUI = [[MissIMUIView alloc] initWithMissIMUI];
    return missUI;
}

-(void)createMissIMUI
{
    CGRect mainScreen = [[UIScreen mainScreen]bounds];
    CGFloat mainWidth = mainScreen.size.width;
    CGFloat mainHeight = mainScreen.size.height;
    self.frame = CGRectMake(0, 0, mainWidth, mainHeight);
    [self setBackgroundColor:[UIColor whiteColor]];
    
    //设置控制视图
    self.MissIMSubView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainWidth, mainHeight)];
    [self.MissIMSubView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:self.MissIMSubView];
    
    //设置导航
    self.MissIMNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, mainWidth, kMissIMUINavigationBarHeight)];
    self.MissIMNavigationBar.contentMode = UIViewContentModeBottomLeft;
    [self addSubview:self.MissIMNavigationBar];
    UINavigationItem *barItems = [[UINavigationItem alloc] init];
    self.MissIMBackForWebView = [[UIButton alloc] initWithFrame:CGRectMake(5, 20, 40, 44)];
    [self.MissIMBackForWebView setTitle:@"返回" forState:UIControlStateNormal];
    [self.MissIMBackForWebView setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:self.MissIMBackForWebView];
    barItems.leftBarButtonItem = backButton;
    [self.MissIMNavigationBar setItems:@[barItems]];
    
    //加载loading  图标
    self.MissIMActivity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, kMissIMUINavigationBarHeight + 5, mainWidth, 20)];
    self.MissIMActivity.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.MissIMSubView addSubview:self.MissIMActivity];
    
    //设置表格视图
    CGFloat tableViewHeight = (mainHeight - kMissIMUINavigationBarHeight) - (44+10);
    self.MissIMTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kMissIMUINavigationBarHeight,mainWidth,tableViewHeight) style:UITableViewStylePlain];
    self.MissIMTableView.backgroundColor = [UIColor clearColor];
    self.MissIMTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.MissIMSubView addSubview:self.MissIMTableView];
    
    //设置文本框
    CGFloat textFieldY = tableViewHeight + kMissIMUINavigationBarHeight + 5;
    self.MissIMTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, textFieldY,(mainWidth-70), 44)];
    self.MissIMTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.MissIMTextField.clearsOnBeginEditing = YES;
    self.MissIMTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.MissIMSubView addSubview:self.MissIMTextField];
    
    //设置选择按钮
    self.MissIMOptions = [[UIButton alloc] initWithFrame:CGRectMake((mainWidth-60), textFieldY, 40, 44)];
    [self.MissIMOptions setTitle:@"选择" forState:UIControlStateNormal];
    [self.MissIMOptions setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.MissIMSubView addSubview:self.MissIMOptions];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)dealloc
{
    NSLog(@"MissIMUIView 内存释放");
}

@end
