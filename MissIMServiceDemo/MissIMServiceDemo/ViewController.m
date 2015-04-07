//
//  ViewController.m
//  MissIMServiceDemo
//
//  Created by xiangwenwen on 15/4/4.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import <AVOSCloudIM/AVOSCloudIM.h>

#import "ViewController.h"


static const int kMissIMConversationTypeOneOne = 0; //AVIM的单一聊天模式

@interface ViewController ()<AVIMClientDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *field;

@property (weak, nonatomic) IBOutlet UITextField *showField;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property(strong,nonatomic) AVIMClient *avimClient;
@property(strong,nonatomic) AVIMConversation *avimConversation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *serviceId = @"missFServiceClient";
    NSString *userId = @"iOS";
    NSArray *clientId = @[userId];
    
    self.avimClient = [[AVIMClient alloc] init];
    self.avimClient.delegate = self;

//    __weak ViewController *weakSelf = self;
    [self.avimClient openWithClientId:serviceId callback:^(BOOL succeeded, NSError *error) {
        if (succeeded && !error) {
            NSLog(@"%@ ---- 登录成功",serviceId);
            AVIMConversationQuery *query = [self.avimClient conversationQuery];
            [query whereKey:kAVIMKeyMember containsAllObjectsInArray:clientId];
            [query findConversationsWithCallback:^(NSArray *objects, NSError *error) {
                if (objects.count && !error) {
                    self.avimConversation = objects[0];
                }else{
                    if (error) {
                        NSLog(@"查找出错");
                    }else{
//                        [self.avimClient createConversationWithName:@"MissIM" clientIds:clientId callback:^(AVIMConversation *conversation, NSError *error) {
//                            self.avimConversation = conversation;
//                        }];
                    }
                }
            }];
            
//            [self.avimClient createConversationWithName:@"MissIM" clientIds:clientId callback:^(AVIMConversation *conversation, NSError *error) {
//                self.avimConversation = conversation;
//                
//                NSString *messageId = @"o7Rn4qwdS8K3UhLs5_FtGQ";
//                int64_t timeId = 1428226243072;
//                NSUInteger lien = 3;
//                
//                [self.avimConversation queryMessagesBeforeId:messageId timestamp:timeId limit:lien callback:^(NSArray *objects, NSError *error) {
//                    
//                    NSLog(@"%@",objects);
//                    
//                }];
//            }];
        }
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)sendMessage:(UIButton *)sender {
    
    NSString *text = self.field.text;
    NSLog(@"将要发送的文本----%@",text);
    if (text.length > 0) {
        AVIMMessage *message = [AVIMMessage messageWithContent:text];
        [self.avimConversation sendMessage:message callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"发送成功");
                NSLog(@"message id %@",message.messageId);
                NSLog(@"发送的时间搓 time id  %zd",message.sendTimestamp);
            }
        }];
    }
}
- (IBAction)openPhotos:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerCameraCaptureModePhoto;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}
- (IBAction)openCamera:(UIButton *)sender {
    BOOL isCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isCamera) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }else{
         NSLog(@"模拟器没有摄像头");
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    NSData *data = UIImagePNGRepresentation(image);
    
    NSString *doc = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    int64_t rand  = arc4random() * 100;
    NSString *jpg = [NSString stringWithFormat:@"%zd.jpg",rand];
    NSString *filePath = [doc stringByAppendingPathComponent:jpg];
    NSFileManager *manager = [[NSFileManager alloc] init];
    [manager createFileAtPath:filePath contents:data attributes:nil];
    AVIMImageMessage *imageMessage = [AVIMImageMessage messageWithText:@"" attachedFilePath:filePath attributes:nil];
    [self.avimConversation sendMessage:imageMessage callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"图片发送成功");
        }
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)conversation:(AVIMConversation *)conversation didReceiveCommonMessage:(AVIMMessage *)message
{
    NSLog(@"%@",conversation.name);
    NSLog(@"%@",conversation.members);
    NSLog(@"%@",conversation.conversationId);
    NSLog(@"接收到的文本消息是---%@",message.content);
    self.showField.text = message.content;
}



-(void)conversation:(AVIMConversation *)conversation didReceiveTypedMessage:(AVIMTypedMessage *)message
{
    if (message.mediaType == kAVIMMessageMediaTypeImage) {
        NSLog(@"接收到图片");
        NSData *data = [message.file getData];
        UIImage *image = [UIImage imageWithData:data];
        self.imageview.image = image;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
