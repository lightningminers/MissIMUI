//
//  MissIMViewController.m
//  MissIMDemo
//
//  Created by xiangwenwen on 15/4/4.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//



#import <AVOSCloudIM/AVOSCloudIM.h>

#import "MissIMViewController.h"
#import "MissIMUIView.h"
#import "MissIMModelManager.h"
#import "MissIMTableViewCell.h"
#import "MissIMFrame.h"
#import "MissIMData.h"



static NSString *kMissIMServiceClientId = @"missFServiceClient"; //客服Id

@interface MissIMViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate,AVIMClientDelegate,UITextFieldDelegate,UIActionSheetDelegate>

@property(nonatomic,strong) MissIMUIView *mainUI; //创建自定义视图
@property(nonatomic,strong) MissIMModelManager *modelManager; //创建模型管理类
@property(nonatomic,strong) AVIMClient *avimClient; //AVIM 客户端类
@property(nonatomic,strong) AVIMConversation *avimConversation; //AVIM 对话连接类
@property(nonatomic,strong) UIApplication *application; //全局APP控制单例


//查询历史纪录用的Id
@property(nonatomic,copy) NSString *messageId;
@property(nonatomic,assign) int64_t timeId;
@property(nonatomic,copy) NSString *conversationId;
@property(nonatomic,assign) NSInteger messageNumber; //记录聊天总数

@property(nonatomic,assign) BOOL isConnectionStatus; //连接状态


@property(nonatomic,assign) BOOL isScroll; //滚动的开关
@property(nonatomic,assign) int64_t historyTimeId; //历史消息，每一次滚动间隔的时间
@property(nonatomic,assign) NSInteger scrollNumber; //滚动的次数

@end

@implementation MissIMViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MissIMUIView *mainUI = [MissIMUIView missWithUI];
    [mainUI.MissIMBackForWebView addTarget:self action:@selector(backForWebView) forControlEvents:UIControlEventTouchUpInside];
    [mainUI.MissIMOptions addTarget:self action:@selector(openPhotoAndCamera) forControlEvents:UIControlEventTouchUpInside];
    self.view = mainUI;
    _mainUI = mainUI;
    
    //委托
    mainUI.MissIMTextField.delegate = self;
    mainUI.MissIMTableView.dataSource = self;
    mainUI.MissIMTableView.delegate = self;
    
    //注册处理键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    
    [self connectionToAVIMClient];
}

-(void)addInfoDataSource:(NSDictionary *)info
{
    //状态，统计
    _messageNumber = 0;
    _isScroll = YES;
    _scrollNumber = 0;
    
    
    //创建模型管理类
    _modelManager = [[MissIMModelManager alloc] initWithdataSource:info];
    //创建AVIM客户端类
    _avimClient = [[AVIMClient alloc] init];
    _avimClient.delegate = self;
    //创建APP全局控制
    _application = [UIApplication sharedApplication];
}

-(void)backForWebView
{
    //计算发送消息的总条数
    self.messageNumber = self.modelManager.messageNumber + self.messageNumber;
    if (self.messageId) {
        //写入本地plist文件
        [self.modelManager writeToMissIMPlistFile:self.messageId conversationId:self.conversationId timeId:self.timeId messageNumber:self.messageNumber];
    }
    [self.avimClient closeWithCallback:^(BOOL succeeded, NSError *error) {
        NSLog(@"----关闭客户端对话");
    }];
    self.application.networkActivityIndicatorVisible = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 处理Table表格

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelManager.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MissIMTableViewCell *cell = [MissIMTableViewCell missimWithTableViewCell:tableView];
    cell.missIMFrame = [self.modelManager.dataSource objectAtIndex:indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MissIMFrame *missIMFrame = [self.modelManager.dataSource objectAtIndex:indexPath.row];
    return missIMFrame.cellHeight;
}

#pragma mark 调起摄像头或系统相册

-(void)openPhotoAndCamera
{
    [self.mainUI.MissIMTextField resignFirstResponder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"访问相册", @"摄像头",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if (buttonIndex == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }else if (buttonIndex == 1){
        BOOL isCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        if (isCamera) {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }else{
        NSLog(@"点击的取消");
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [self sendMessageTypeImage:image];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 处理上拉刷新历史消息


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //手指触摸屏幕，准备滚动的那一刻
    NSLog(@"手指滑动开始－－－－－的那一瞬间");
    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //手指离开屏幕，放下的那一刻
    NSLog(@"刷动到顶部，放下的时候");
    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
    if (scrollView.contentOffset.y < 0 && self.historyTimeId > 0) {
        if (self.isScroll) {
            self.application.networkActivityIndicatorVisible = YES;
            [self.mainUI.MissIMActivity startAnimating];
            self.isScroll = NO;
            [self fetchHistoryMessage:self.conversationId timeId:self.historyTimeId];
        }
    }
}

-(void)fetchHistoryMessage:(NSString *)conversationId timeId:(int64_t)timeId
{
    __weak MissIMViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVHistoryMessageQuery *query = [AVHistoryMessageQuery queryWithConversationId:conversationId timestamp:timeId limit:4];
        NSArray *historyMessage = [query find];
        /*
            第一条记录是最新发送的一条消息，时间越久的，UI要放在最上面
            
            就是更新模型的时候，先把历史消息，降序，然后添加到模型的最前端
         
            最后更新UI，把indexPath scroll到模型的最后端
         
            起始的时间点，用从plist文件中读取的那个为顶点

         */
        
        if (historyMessage.count) {
            weakSelf.scrollNumber ++;
//            NSArray *descend = [historyMessage sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                return NSOrderedDescending;
//            }];
             //删除掉最后一个
            NSMutableArray *handleHistory = [NSMutableArray arrayWithArray:historyMessage];
            [handleHistory removeObjectAtIndex:0];
            [weakSelf.modelManager parseHistoryMessage:handleHistory ordered:NO];
            AVHistoryMessage *lastMessage = [handleHistory lastObject];
            weakSelf.historyTimeId = lastMessage.timestamp;
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新模型，倒序
                [weakSelf.mainUI.MissIMTableView reloadData];
                NSInteger index;
                if (weakSelf.scrollNumber == 1) {
                    index = 1;
                }else{
                    index = (weakSelf.scrollNumber * handleHistory.count) + 2;
                }
                
                NSInteger row = self.modelManager.dataSource.count - index;
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
                [weakSelf.mainUI.MissIMTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                //更新UI成功
                weakSelf.isScroll = YES;
                weakSelf.application.networkActivityIndicatorVisible = NO;
                weakSelf.mainUI.MissIMActivity.hidden = YES;
                [weakSelf.mainUI.MissIMActivity stopAnimating];
            });
        }
    });
}

#pragma mark 处理键盘或者文本框

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0) {
        [self.mainUI.MissIMTextField resignFirstResponder];
        [self sendMessageTypeText:textField.text];
        return YES;
    }else{
        return NO;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.mainUI.MissIMTextField.returnKeyType = UIReturnKeySend;
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *value = [info objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    CGSize keyboardSize = [value CGRectValue].size;//获取键盘的size值
    //获取键盘出现的动画时间
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    CGFloat height = 0 - keyboardSize.height;
    NSTimeInterval animation = animationDuration;
    //视图移动的动画开始
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration: animation];
    CGRect IMSubViewFrame = self.mainUI.MissIMSubView.frame;
    CGRect frame =CGRectMake(IMSubViewFrame.origin.x, height, IMSubViewFrame.size.width,IMSubViewFrame.size.height);
    self.mainUI.MissIMSubView.frame = frame;
    [UIView commitAnimations];
    
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    NSTimeInterval animation = animationDuration;
    [UIView beginAnimations:@"animal"context:nil];
    [UIView setAnimationDuration:animation];
    self.mainUI.MissIMSubView.frame = [[UIScreen mainScreen] bounds];
    [UIView commitAnimations];
}

#pragma mark 开启AVIM的对话连接

-(void)connectionToAVIMClient
{
    self.application.networkActivityIndicatorVisible = YES;
    __weak MissIMViewController *weakSelf = self;
    NSArray *clientId = @[kMissIMServiceClientId];
    [self.avimClient openWithClientId:self.modelManager.userId callback:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            AVIMConversationQuery *query = [weakSelf.avimClient conversationQuery];
            [query whereKey:kAVIMKeyMember containsAllObjectsInArray:clientId];
            [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
                if (objects.count && !error) {
                    NSLog(@"与%@建立连接",kMissIMServiceClientId);
                    weakSelf.avimConversation = objects[0];
                    weakSelf.conversationId = weakSelf.avimConversation.conversationId;
                    if (!weakSelf.modelManager.dataSource.count > 0 && weakSelf.modelManager.isHistory) {
                        AVHistoryMessageQuery *historyQuery = [AVHistoryMessageQuery queryWithConversationId:weakSelf.avimConversation.conversationId timestamp:weakSelf.modelManager.timeId limit:1];
                        NSArray *historyMessage = [historyQuery find];
                        NSLog(@"history message ---- %@",historyMessage);
                        if (historyMessage.count > 0) {
                            AVHistoryMessage *lastMessage = historyMessage[0];
                            weakSelf.historyTimeId = lastMessage.timestamp;
                            [weakSelf.mainUI.MissIMActivity startAnimating];
                            [weakSelf.modelManager parseHistoryMessage:historyMessage ordered:NO];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf.mainUI.MissIMActivity stopAnimating];
                                [weakSelf.mainUI.MissIMTableView reloadData];
                            });
                        }
                    }
                }else{
                    if (error) {
                        NSLog(@"网络错误，无法建立链接");
                    }else{
                        [weakSelf.avimClient createConversationWithName:@"MissIM" clientIds:clientId callback:^(AVIMConversation *conversation, NSError *error) {
                            if (error) {
                                NSLog(@"创建聊天出错");
                            }else{
                                NSLog(@"创建一个新的聊天");
                                weakSelf.avimConversation = conversation;
                            }
                        }];
                    }
                }
                weakSelf.application.networkActivityIndicatorVisible = NO;
            }];
        }
    }];
}

#pragma mark 处理发送文本消息

-(void)sendMessageTypeText:(NSString *)text
{
    self.mainUI.MissIMTextField.text = @"";
    AVIMMessage *message = [AVIMMessage messageWithContent:text];
    __weak MissIMViewController *weakSelf = self;
    __weak AVIMMessage *weakMessage = message;
    [self.avimConversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            NSLog(@"发送文本成功");
            NSMutableDictionary *dataMessage = [[NSMutableDictionary alloc] init];
            dataMessage[@"text"] = text;
            dataMessage[@"from"] = @(kMISSIMFROMME);
            dataMessage[@"type"] = @(kMISSIMTYPETEXT);
            weakSelf.messageId = weakMessage.messageId;
            weakSelf.timeId = weakMessage.sendTimestamp;
            weakSelf.conversationId = weakMessage.conversationId;
            weakSelf.messageNumber ++;
            [weakSelf.modelManager addMissIMDataSource:dataMessage ordered:YES];
            //注册通知
            [weakSelf postMessageCenter:weakSelf.messageId conversationId:weakSelf.conversationId timeId:weakSelf.timeId messageNumber:weakSelf.messageNumber MissIMPlistPath:weakSelf.modelManager.MissIMPlistPath];
            NSInteger row = weakSelf.modelManager.dataSource.count - 1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
            [weakSelf.mainUI.MissIMTableView reloadData];
            [weakSelf.mainUI.MissIMTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }else{
            NSLog(@"发送失败");
        }
    }];
}

#pragma mark 处理发送图片消息

-(void)sendMessageTypeImage:(UIImage *)image
{
        NSData *data = UIImageJPEGRepresentation(image, 0.4);
        __weak MissIMViewController *weakSelf = self;
        self.application.networkActivityIndicatorVisible = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imagePath = [weakSelf.modelManager createImageFilePath];
            NSFileManager *manager = [[NSFileManager alloc] init];
            [manager createFileAtPath:imagePath contents:data attributes:nil];
            AVIMImageMessage *imageMessage = [AVIMImageMessage messageWithText:@"" attachedFilePath:imagePath attributes:nil];
            [weakSelf.avimConversation sendMessage:imageMessage callback:^(BOOL succeeded, NSError *error) {
                if (succeeded && !error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.application.networkActivityIndicatorVisible = NO;
                        NSLog(@"发送图片成功");
                        NSMutableDictionary *dataMessage = [[NSMutableDictionary alloc] init];
                        UIImage *pickerImage = [UIImage imageWithData:data];
                        dataMessage[@"from"] = @(kMISSIMFROMME);
                        dataMessage[@"type"] = @(kMISSIMTYPEIMAGE);
                        dataMessage[@"pickerImage"] = pickerImage;
                        self.messageId = imageMessage.messageId;
                        self.timeId = imageMessage.sendTimestamp;
                        self.messageNumber ++;
                        [self.modelManager addMissIMDataSource:dataMessage ordered:YES];
                        //注册通知
                        [self postMessageCenter:self.messageId conversationId:self.conversationId timeId:self.timeId messageNumber:self.messageNumber MissIMPlistPath:self.modelManager.MissIMPlistPath];
                        NSInteger row = self.modelManager.dataSource.count - 1;
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
                        [self.mainUI.MissIMTableView reloadData];
                        [self.mainUI.MissIMTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    });
                }else{
                    NSLog(@"发送出错");
                }
            }];
        });
    
}

#pragma mark 接收文本消息
-(void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message
{
        if (!conversation || !message) {
            NSLog(@"----出现异常");
        }else{
            NSLog(@"----接收文本成功");
            self.avimConversation = conversation;
            NSMutableDictionary *dataMessage = [[NSMutableDictionary alloc] init];
            dataMessage[@"name"] = @"service";
            dataMessage[@"text"] = message.content;
            dataMessage[@"from"] = @(kMISSIMFROMOTHER);
            dataMessage[@"type"] = @(kMISSIMTYPETEXT);
            self.messageId = message.messageId;
            self.timeId = message.sendTimestamp;
            self.messageNumber ++;
            [self.modelManager addMissIMDataSource:dataMessage ordered:YES];
            //注册通知
            [self postMessageCenter:self.messageId conversationId:self.conversationId timeId:self.timeId messageNumber:self.messageNumber MissIMPlistPath:self.modelManager.MissIMPlistPath];
            NSInteger row = self.modelManager.dataSource.count - 1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
            [self.mainUI.MissIMTableView reloadData];
            [self.mainUI.MissIMTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
}

#pragma mark 接收媒体消息
-(void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message
{
        if (!conversation || !message) {
            NSLog(@"---出现异常");
        }else{
            NSLog(@"---接收图片成功");
            AVIMMessageMediaType messageTpe = message.mediaType;
            if (messageTpe == kAVIMMessageMediaTypeImage) {
                self.avimConversation = conversation;
                NSData *data = [message.file getData];
                UIImage *pickerImage = [UIImage imageWithData:data];
                NSMutableDictionary *dataMessage = [[NSMutableDictionary alloc] init];
                dataMessage[@"name"] = @"service";
                dataMessage[@"from"] = @(kMISSIMFROMOTHER);
                dataMessage[@"type"] = @(kMISSIMTYPEIMAGE);
                dataMessage[@"pickerImage"] = pickerImage;
                self.messageId = message.messageId;
                self.timeId = message.sendTimestamp;
                self.messageNumber ++;
                [self.modelManager addMissIMDataSource:dataMessage ordered:YES];
                //注册通知
                [self postMessageCenter:self.messageId conversationId:self.conversationId timeId:self.timeId messageNumber:self.messageNumber MissIMPlistPath:self.modelManager.MissIMPlistPath];
                NSInteger row = self.modelManager.dataSource.count - 1;
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:row inSection:0];
                [self.mainUI.MissIMTableView reloadData];
                [self.mainUI.MissIMTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
}


-(void)postMessageCenter:(NSString *)messageId conversationId:(NSString *)conversationId timeId:(int64_t)timestamp messageNumber:(NSInteger)messageNumber MissIMPlistPath:(NSString *)MissIMPlistPath
{
    NSNumber *timeId = [NSNumber numberWithLongLong:timestamp];
    NSNumber *messageCount = [NSNumber numberWithLong:messageNumber];
    NSDictionary *dataSource = @{@"messageId":messageId,@"timeId":timeId,@"messageNumber":messageCount,@"conversationId":conversationId,@"MissIMPlistPath":MissIMPlistPath};
    //处理App运行期的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"saveMissIMPlist" object:nil userInfo:dataSource];
}

#pragma mark 处理网络状态

/*!
 当前聊天状态被暂停，常见于网络断开时触发。
 */
- (void)imClientPaused:(AVIMClient *)imClient
{
    self.isConnectionStatus = NO;
}
/*!
 当前聊天状态开始恢复，常见于网络断开后开始重新连接。
 */
- (void)imClientResuming:(AVIMClient *)imClient
{
    
}
/*!
 当前聊天状态已经恢复，常见于网络断开后重新连接上。
 */
- (void)imClientResumed:(AVIMClient *)imClient
{
    self.isConnectionStatus = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    NSLog(@"MissIMUIViewController 内存释放");
}

@end