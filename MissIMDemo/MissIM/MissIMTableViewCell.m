//
//  MissIMTableViewCell.m
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import "MissIMTableViewCell.h"
#import "MissIMShowImageBrowser.h"
#import "MissIMFrame.h"
#import "MissIMContentView.h"
#import "MissIMData.h"

static NSString *identifier = @"IMCELL.MISS";

@interface MissIMTableViewCell()

@property(nonatomic,retain) UILabel *labelName; //人名
@property(nonatomic,retain) UILabel *labelTime; //时间
@property(nonatomic,retain) UIButton *iconImage; //头像
@property(nonatomic,retain) MissIMContentView *missContentView; //内容区域
@property(nonatomic,retain) UIView *viewHead; //头像区域

@end

@implementation MissIMTableViewCell

+(instancetype)missimWithTableViewCell:(UITableView *)tableView
{
    MissIMTableViewCell *IMCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!IMCell) {
        IMCell = [[MissIMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return IMCell;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //创建时间视图
        self.labelTime = [[UILabel alloc] init];
        self.labelTime.textAlignment = NSTextAlignmentCenter; //文字居中
        self.labelTime.textColor = [UIColor grayColor]; //文字颜色
        self.labelTime.font = ChatTimeFont; //字体大小
        [self.contentView addSubview:self.labelTime];
        
        //创建头像
        self.viewHead = [[UIView alloc] init];
        self.viewHead.layer.cornerRadius = 22;
        self.viewHead.layer.masksToBounds = YES;
        self.viewHead.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        [self.contentView addSubview:self.viewHead];
        self.iconImage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.iconImage.layer.cornerRadius = 20;
        self.iconImage.layer.masksToBounds = YES;
        [self.iconImage addTarget:self action:@selector(buttonHeadImageClick:)  forControlEvents:UIControlEventTouchUpInside];
        [self.viewHead addSubview:self.iconImage];
        
        //创建名称
        self.labelName = [[UILabel alloc] init];
        self.labelName.textAlignment = NSTextAlignmentCenter; //名称居中
        self.labelName.textColor = [UIColor grayColor];
        self.labelName.font = ChatTimeFont;
        [self.contentView addSubview:self.labelName];
        
        //创建内容区域
        self.missContentView = [MissIMContentView buttonWithType:UIButtonTypeCustom];
        [self.missContentView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.missContentView.titleLabel.font = ChatContentFont;
        self.missContentView.titleLabel.numberOfLines = 0;
        [self.missContentView addTarget:self action:@selector(buttonContentClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.missContentView];

        
    }
    return self;
}

#pragma mark 点击头像区域
-(void)buttonHeadImageClick:(UIButton *)sender
{
    
}

#pragma mark 点击内容区域
-(void)buttonContentClick:(UIButton *)sender
{
    MissIMData *data = self.missIMFrame.data;
    if (data.type == kMISSIMTYPEIMAGE) {
        [MissIMShowImageBrowser showImage:self.missContentView.showImageView];
    }
}

#pragma mark 设置内容以及视图的Frame

-(void)setMissIMFrame:(MissIMFrame *)missIMFrame
{
    _missIMFrame = missIMFrame;
    MissIMData *data = missIMFrame.data;
    
    //设置时间的数据与坐标
    self.labelTime.text = data.sendTime;
    self.labelTime.frame = missIMFrame.timeFrame;
    
    //设置用户头像
    
    //把父视图的frame设置好
    self.viewHead.frame = missIMFrame.iconFrame;
    self.iconImage.frame = CGRectMake(2, 2, MissIconWidthAndHeight-5, MissIconWidthAndHeight - 5);
    [self.iconImage setBackgroundImage:data.iconImage forState:UIControlStateNormal];

    
    
    //设置用户名数据与坐标
    self.labelName.text = data.name;
    self.labelName.frame = missIMFrame.nameFrame;
    
    //设置内容区域
    
    //默认情况下把文本，image view hidde
    [self.missContentView setTitle:@"" forState:UIControlStateNormal];
    self.missContentView.showImageView.hidden = YES;
    
    self.missContentView.frame = missIMFrame.conFrame;
    
    //判断是自己发送还是接收
    if (data.from == kMISSIMFROMME) {
        [self.missContentView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }else{
        [self.missContentView setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    //调节一下文字的居左的间距
    self.missContentView.contentEdgeInsets = UIEdgeInsetsMake(MissContentTop, MissContentLeft, MissContentBottom, MissContentRight);
    switch (data.type) {
        case kMISSIMTYPETEXT:
            [self.missContentView setTitle:data.text forState:UIControlStateNormal];
            break;
        default:
            self.missContentView.showImageView.hidden = NO;
            self.missContentView.showImageView.image = data.pickerImage;
            self.missContentView.showImageView.frame = CGRectMake(0, 0, self.missContentView.frame.size.width, self.missContentView.frame.size.height);
            break;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc
{
    NSLog(@"MissIMTableViewCell 内存释放");
}

@end
