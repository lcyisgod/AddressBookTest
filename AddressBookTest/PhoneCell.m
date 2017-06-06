//
//  PhoneCell.m
//  AddressBookTest
//
//  Created by 小龙虾 on 2017/6/5.
//  Copyright © 2017年 杭州迪火科技有限公司. All rights reserved.
//

#import "PhoneCell.h"
#import "PersonPhone.h"

@interface PhoneCell ()

@end
@implementation PhoneCell


-(void)upDataWithModel:(PersonPhone *)model
{
    [self.textLabel setText:model.name];
    [self.detailTextLabel setText:model.phoneNum];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
