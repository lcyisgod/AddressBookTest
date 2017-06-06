//
//  ConnectController.m
//  AddressBookTest
//
//  Created by 小龙虾 on 2017/6/3.
//  Copyright © 2017年 杭州迪火科技有限公司. All rights reserved.
//

#import "ConnectController.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import "PinYin4Objc.h"
#import "PersonPhone.h"
#import "PhoneController.h"

@interface ConnectController ()<CNContactPickerDelegate>
@property(nonatomic, strong)NSMutableArray *dataAry;
@property(nonatomic, strong)NSMutableArray *keyAry;
@end

@implementation ConnectController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationItem setTitle:@"iOS8.0之后"];
    self.dataAry = [NSMutableArray array];
    self.keyAry = [NSMutableArray array];
    // Do any additional setup after loading the view.
    //打开通讯录
    UIButton *openAddressBook = [UIButton buttonWithType:UIButtonTypeCustom];
    openAddressBook.frame = CGRectMake(100, 100, 100, 50);
    [openAddressBook setTitle:@"打开通讯录" forState:UIControlStateNormal];
    openAddressBook.backgroundColor = [UIColor greenColor];
    [openAddressBook setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [openAddressBook addTarget:self action:@selector(gotoAddressBook) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:openAddressBook];
    
    //读取通讯录
    UIButton *readeAddressBook = [UIButton buttonWithType:UIButtonTypeCustom];
    readeAddressBook.frame = CGRectMake(100, 200, 100, 50);
    [readeAddressBook setTitle:@"读取通讯录" forState:UIControlStateNormal];
    readeAddressBook.backgroundColor = [UIColor greenColor];
    [readeAddressBook setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [readeAddressBook addTarget:self action:@selector(readeAddressBook) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readeAddressBook];


}

-(void)gotoAddressBook
{
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (authorizationStatus == CNAuthorizationStatusNotDetermined) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                CNContactPickerViewController *contactPickerVC = [[CNContactPickerViewController alloc] init];
                contactPickerVC.delegate = self;
                [self presentViewController:contactPickerVC animated:YES completion:nil];
            } else {
                NSLog(@"授权失败, error=%@", error);
            }
        }];
    }else if (authorizationStatus == CNAuthorizationStatusAuthorized) {
        CNContactPickerViewController *contactPickerVC = [[CNContactPickerViewController alloc] init];
        contactPickerVC.delegate = self;
        [self presentViewController:contactPickerVC animated:YES completion:nil];
    }
}

-(void)readeAddressBook
{
    __weak typeof(self) wakeSelf = self;
    CNAuthorizationStatus authorizationStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (authorizationStatus == CNAuthorizationStatusNotDetermined) {
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                [wakeSelf readeBookAddress1];
            } else {
                NSLog(@"授权失败, error=%@", error);
            }
        }];
    }else if (authorizationStatus == CNAuthorizationStatusAuthorized){
        [self readeBookAddress1];
    }else if (authorizationStatus == CNAuthorizationStatusDenied){
        NSLog(@"已经拒绝");
    }else
        NSLog(@"受保护的");
}

-(void)readeBookAddress1
{
    [self.dataAry removeAllObjects];
    //获取指定的字段,并不是要获取所有字段，需要指定具体的字段
    NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        PersonPhone *phonePerson = [[PersonPhone alloc] init];
        phonePerson.name = @"#";
        NSString *givenName = contact.givenName;
        NSString *familyName = contact.familyName;
        if (givenName.length != 0 && familyName.length != 0) {
            phonePerson.name = [NSString stringWithFormat:@"%@%@",familyName,givenName];
        }else if (givenName.length != 0){
            phonePerson.name = givenName;
        }else if (familyName.length != 0){
            phonePerson.name = familyName;
        }
        
        //取名称的首字母
        HanyuPinyinOutputFormat *outputFormat = [[HanyuPinyinOutputFormat alloc] init];
        [outputFormat setToneType:ToneTypeWithoutTone];
        [outputFormat setVCharType:VCharTypeWithV];
        [outputFormat setCaseType:CaseTypeUppercase];
        NSString *nameChares = [PinyinHelper toHanyuPinyinStringWithNSString:phonePerson.name withHanyuPinyinOutputFormat:outputFormat withNSString:@""];
        for (int i = 0; i < nameChares.length; i++) {
            char chares = [nameChares characterAtIndex:i];
            if (chares >='A' || chares <= 'Z') {
                phonePerson.chares = chares;
                break;
            }else if (chares == '#'){
                phonePerson.chares = '#';
                break;
            }
        }
        
        
        NSArray *phoneNumbers = contact.phoneNumbers;
        for (CNLabeledValue *labelValue in phoneNumbers) {
            NSString *label = labelValue.label;
            CNPhoneNumber *phoneNumber = labelValue.value;
            phonePerson.phoneNum = phoneNumber.stringValue;
            phonePerson.type = label;
        }
        
        [self.dataAry addObject:phonePerson];
    }];
    
    //按首字母排序
    for (int i = 0; i < self.dataAry.count; i++) {
        for (int j = i+1; j < self.dataAry.count; j++) {
            PersonPhone *phone1 = [self.dataAry objectAtIndex:i];
            PersonPhone *phone2 = [self.dataAry objectAtIndex:j];
            if (phone1.chares > phone2.chares) {
                id obj = phone1;
                self.dataAry[i]=phone2;
                self.dataAry[j]=obj;
            }
        }
    }
    
    //封装数据，在下个界面使用
    [self returnKeyCount:self.dataAry];
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *str in self.keyAry) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSMutableArray *personArray = [NSMutableArray array];
        [dic setObject:str forKey:@"key"];
        for (PersonPhone *person in self.dataAry) {
            if ([str isEqualToString:[NSString stringWithFormat:@"%c",person.chares]]) {
                [personArray addObject:person];
            }
        }
        [dic setObject:personArray forKey:@"person"];
        [array addObject:dic];
    }
    
    PhoneController *phoneVC = [[PhoneController alloc] init];
    phoneVC.phonePersonAry = array;
    [self.navigationController pushViewController:phoneVC animated:YES];
}

-(void)returnKeyCount:(NSArray *)array
{
    char chares = ((PersonPhone *)[array objectAtIndex:0]).chares;
    [self.keyAry addObject:[NSString stringWithFormat:@"%c",chares]];
    for (PersonPhone *person in array) {
        if (chares != person.chares) {
            chares = person.chares;
            [self.keyAry addObject:[NSString stringWithFormat:@"%c",chares]];
        }
    }
}


#pragma mark - CNContactPickerDelegate
// 如果实现该方法当选中联系人时就不会再出现联系人详情界面， 如果需要看到联系人详情界面只能不实现这个方法，
-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact
{
    NSLog(@"选中某一个联系人时调用---------------------------------");
    [self printContactInfo:contact];
}

// 同时选中多个联系人
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts {
    for (CNContact *contact in contacts) {
        NSLog(@"================================================");
        [self printContactInfo:contact];
    }
}

- (void)printContactInfo:(CNContact *)contact {
    NSString *givenName = contact.givenName;
    NSString *familyName = contact.familyName;
    NSLog(@"givenName=%@, familyName=%@", givenName, familyName);
    NSArray * phoneNumbers = contact.phoneNumbers;
    for (CNLabeledValue<CNPhoneNumber*>*phone in phoneNumbers) {
        NSString *label = phone.label;
        CNPhoneNumber *phonNumber = (CNPhoneNumber *)phone.value;
        NSLog(@"label=%@, value=%@", label, phonNumber.stringValue);
    }
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
