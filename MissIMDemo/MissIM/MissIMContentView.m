//
//  MissIMContent.m
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import "MissIMContentView.h"

@implementation MissIMContentView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showImageView = [[UIImageView alloc] init];
        self.showImageView.userInteractionEnabled = NO;
        self.showImageView.layer.cornerRadius = 5;
        self.showImageView.layer.masksToBounds = YES;
        self.showImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.showImageView.backgroundColor = [UIColor yellowColor];
        [self addSubview:self.showImageView];
    }
    return self;
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
    NSLog(@"MissIMContentView 内存释放");
}

@end
