//
//  PhoneCell.h
//  AddressBookTest
//
//  Created by 小龙虾 on 2017/6/5.
//  Copyright © 2017年 杭州迪火科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PersonPhone;

@interface PhoneCell : UITableViewCell
-(void)upDataWithModel:(PersonPhone *)model;
@end
