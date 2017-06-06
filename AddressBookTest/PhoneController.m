//
//  PhoneController.m
//  AddressBookTest
//
//  Created by 小龙虾 on 2017/6/5.
//  Copyright © 2017年 杭州迪火科技有限公司. All rights reserved.
//

#import "PhoneController.h"
#import "PersonPhone.h"
#import "PhoneCell.h"

@interface PhoneController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)NSMutableArray *keyAry;
@property(nonatomic, strong)UITableView *baseTab;
@end

@implementation PhoneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setTitle:@"通讯录"];
    self.keyAry = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createViews];
}

-(void)createViews
{
    self.baseTab = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.baseTab.dataSource = self;
    self.baseTab.delegate = self;
    [self.view addSubview:self.baseTab];
}

#pragma mark-
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellFinds = @"cell";
    PhoneCell *cell = [tableView dequeueReusableCellWithIdentifier:cellFinds];
    if (!cell) {
        cell = [[PhoneCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellFinds];
    }
    NSDictionary *dic = [self.phonePersonAry objectAtIndex:indexPath.section];
    NSArray *array = [dic objectForKey:@"person"];
    PersonPhone *phone = [array objectAtIndex:indexPath.row];
    [cell upDataWithModel:phone];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic = [self.phonePersonAry objectAtIndex:section];
    NSArray *array = [dic objectForKey:@"person"];
    return array.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.phonePersonAry.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dic = [self.phonePersonAry objectAtIndex:section];
    return [dic objectForKey:@"key"];
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

@end
