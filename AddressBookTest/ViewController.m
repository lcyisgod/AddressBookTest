//
//  ViewController.m
//  AddressBookTest
//
//  Created by 小龙虾 on 2017/6/3.
//  Copyright © 2017年 杭州迪火科技有限公司. All rights reserved.
//

#import "ViewController.h"
#import "ConnectController.h"
#import "PhoneController.h"
#import "PersonPhone.h"


#import <AddressBookUI/AddressBookUI.h>
#import <AddressBook/AddressBook.h>

#import "PinYin4Objc.h"

@interface ViewController ()<ABPeoplePickerNavigationControllerDelegate>
@property(nonatomic, strong)ABPeoplePickerNavigationController *abPeoplePicker;
@property(nonatomic, strong)NSMutableArray *dataAry;
@property(nonatomic, strong)NSMutableArray *keyAry;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationItem setTitle:@"IOS8.0之前"];
    
    self.dataAry = [[NSMutableArray alloc] init];
    self.keyAry = [[NSMutableArray alloc] init];
    
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
    
    UIBarButtonItem *rigthBtn = [[UIBarButtonItem alloc] initWithTitle:@"下一个" style:UIBarButtonItemStyleDone target:self action:@selector(nextMethod:)];
    [self.navigationItem setRightBarButtonItem:rigthBtn];
}

-(void)nextMethod:(UIBarButtonItem *)sender
{
    ConnectController *conVC = [[ConnectController alloc] init];
    [self.navigationController pushViewController:conVC animated:YES];
}

-(void)gotoAddressBook
{
    ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
    //判断是否授权
    if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
        //请求授权
        ABAddressBookRef addressBookRef = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self gotoAddressBook1];
                });
            }else
                NSLog(@"授权失败");
        });
    }else if (authorizationStatus == kABAuthorizationStatusDenied){
        NSLog(@"已经拒绝");
    }else if (authorizationStatus == kABAuthorizationStatusAuthorized){
        NSLog(@"已经授权");
        [self gotoAddressBook1];
    }else{
        NSLog(@"不允许访问");
    }
}

-(void)gotoAddressBook1
{
    _abPeoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    _abPeoplePicker.peoplePickerDelegate = self;
    [self presentViewController:_abPeoplePicker animated:YES completion:nil];
}

-(void)readeAddressBook
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            if (granted) {
                ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(addressBookRef, &error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self copyAddressBook:addressBook];
                });
            }else{
                NSLog(@"拒绝");
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [self copyAddressBook:addressBook];
    }
    else {
        NSLog(@"授权失败");
    }

}


- (void)copyAddressBook:(ABAddressBookRef)addressBook
{
    [self.dataAry removeAllObjects];
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    for ( int i = 0; i < numberOfPeople; i++){
        PersonPhone *phonePerson = [[PersonPhone alloc] init];
        phonePerson.name = @"#";
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        if (firstName.length != 0 && lastName.length != 0) {
            phonePerson.name = [NSString stringWithFormat:@"%@%@",lastName,firstName];
        }else if (firstName.length != 0){
            phonePerson.name = firstName;
        }else if (lastName.length != 0){
            phonePerson.name = lastName;
        }

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
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取电话Label
            NSString * personPhoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phone, k));
            if (k == 0) {
                phonePerson.type = personPhoneLabel;
            }
            //获取該Label下的电话值
            NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            if (k == 0) {
                phonePerson.phoneNum = personPhone;
            }
        }
        [self.dataAry addObject:phonePerson];
        /*
        //获取URL多值
        ABMultiValueRef url = ABRecordCopyValue(person, kABPersonURLProperty);
        for (int m = 0; m < ABMultiValueGetCount(url); m++)
        {
            //获取电话Label
            NSString * urlLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(url, m));
            //获取該Label下的电话值
            NSString * urlContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(url,m);
        }
        
        //读取照片
        NSData *image = (__bridge NSData*)ABPersonCopyImageData(person);
        
        //读取middlename
        NSString *middlename = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        NSLog(@"middlename:%@",middlename);
        //读取prefix前缀
        NSString *prefix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonPrefixProperty);
        NSLog(@"prefix前缀:%@",prefix);
        //读取suffix后缀
        NSString *suffix = (__bridge NSString*)ABRecordCopyValue(person, kABPersonSuffixProperty);
        NSLog(@"suffix后缀:%@",suffix);
        //读取nickname呢称
        NSString *nickname = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNicknameProperty);
        NSLog(@"nickname昵称:%@",nickname);
        //读取firstname拼音音标
        NSString *firstnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty);
        NSLog(@"firsname拼音音标:%@",firstnamePhonetic);
        //读取lastname拼音音标
        NSString *lastnamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty);
        NSLog(@"lastname拼音音标:%@",lastnamePhonetic);
        //读取middlename拼音音标
        NSString *middlenamePhonetic = (__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNamePhoneticProperty);
        NSLog(@"middlename拼音音标:%@",middlenamePhonetic);
        //读取organization公司
        NSString *organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        NSLog(@"organization拼音音标:%@",organization);
        //读取jobtitle工作
        NSString *jobtitle = (__bridge NSString*)ABRecordCopyValue(person, kABPersonJobTitleProperty);
        NSLog(@"jobtitle工作:%@",jobtitle);
        //读取department部门
        NSString *department = (__bridge NSString*)ABRecordCopyValue(person, kABPersonDepartmentProperty);
        NSLog(@"department部门:%@",department);
        //读取birthday生日
        NSDate *birthday = (__bridge NSDate*)ABRecordCopyValue(person, kABPersonBirthdayProperty);
        NSLog(@"birthday生日:%@",birthday);
        //读取note备忘录
        NSString *note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
        NSLog(@"note备忘录:%@",note);
        //第一次添加该条记录的时间
        NSString *firstknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonCreationDateProperty);
        NSLog(@"第一次添加该条记录的时间%@\n",firstknow);
        //最后一次修改該条记录的时间
        NSString *lastknow = (__bridge NSString*)ABRecordCopyValue(person, kABPersonModificationDateProperty);
        NSLog(@"最后一次修改該条记录的时间%@\n",lastknow);
        
        //获取email多值
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        int emailcount = (int)ABMultiValueGetCount(email);
        for (int x = 0; x < emailcount; x++)
            {
                //获取email Label
                NSString* emailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, x));
                NSLog(@"email Label:%@",emailLabel);
                //获取email值
                NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, x);
                NSLog(@"email:%@",emailContent);
            }
        //读取地址多值
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        int count = (int)ABMultiValueGetCount(address);
        for(int j = 0; j < count; j++)
        {
            //获取地址Label
            NSString* addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, j);
            NSLog(@"addressLabel:%@",addressLabel);
            //获取該label下的地址6属性
            NSDictionary* personaddress =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(address, j);
            NSLog(@"personaddress:%@",personaddress);
            NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
            NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];
            NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            NSString* zip = [personaddress valueForKey:(NSString *)kABPersonAddressZIPKey];
           NSString* coutntrycode = [personaddress valueForKey:(NSString *)kABPersonAddressCountryCodeKey];
        }
        
        //获取dates多值
        ABMultiValueRef dates = ABRecordCopyValue(person, kABPersonDateProperty);
        int datescount = (int)ABMultiValueGetCount(dates);
        for (int y = 0; y < datescount; y++)
        {
            //获取dates Label
            NSString* datesLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(dates, y));
            //获取dates值
            NSString* datesContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(dates, y);
        }
        //获取kind值
        CFNumberRef recordType = ABRecordCopyValue(person, kABPersonKindProperty);
        if (recordType == kABPersonKindOrganization) {
            // it's a company
            NSLog(@"it's a company\n");
            }
        else {
            // it's a person, resource, or room
            NSLog(@"it's a person, resource, or room\n");
        }
        
        
        //获取IM多值
        ABMultiValueRef instantMessage = ABRecordCopyValue(person, kABPersonInstantMessageProperty);
        for (int l = 1; l < ABMultiValueGetCount(instantMessage); l++)
        {
            //获取IM Label
            NSString* instantMessageLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(instantMessage, l);
            //获取該label下的2属性
            NSDictionary* instantMessageContent =(__bridge NSDictionary*) ABMultiValueCopyValueAtIndex(instantMessage, l);
            NSString* username = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageUsernameKey];
                    
            NSString* service = [instantMessageContent valueForKey:(NSString *)kABPersonInstantMessageServiceKey];
        }*/
    }
    
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

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSLog(@"电话号码:%@",phoneNO);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
