//
//  LLSettingController.m
//  test
//
//  Created by fqb on 2017/12/15.
//  Copyright © 2017年 kevliule. All rights reserved.
//

#import "LLSettingController.h"
#import "WCRedEnvelopesHelper.h"
#import "LLRedEnvelopesMgr.h"
#import <objc/runtime.h>

static NSString * const kSettingControllerKey = @"SettingControllerKey";

@interface LLSettingController ()

@property (nonatomic, strong) LLSettingParam *settingParam; //设置参数

@property (nonatomic, strong) ContactsDataLogic *contactsDataLogic;

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation LLSettingParam

@end

@implementation LLSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
    [self setNavigationBar];
    [self setTableView];
    [self reloadTableData];
}

- (void)commonInit{
    _settingParam = [[LLSettingParam alloc] init];
    _settingParam.isOpenRedEnvelopesHelper = [LLRedEnvelopesMgr shared].isOpenRedEnvelopesHelper;
    _settingParam.isOpenSportHelper = [LLRedEnvelopesMgr shared].isOpenSportHelper;
    _settingParam.isOpenBackgroundMode = [LLRedEnvelopesMgr shared].isOpenBackgroundMode;
    _settingParam.isOpenRedEnvelopesAlert = [LLRedEnvelopesMgr shared].isOpenRedEnvelopesAlert;
    _settingParam.openRedEnvelopesDelaySecond = [LLRedEnvelopesMgr shared].openRedEnvelopesDelaySecond;
    _settingParam.wantSportStepCount = [LLRedEnvelopesMgr shared].wantSportStepCount;
    _settingParam.filterRoomDic = [LLRedEnvelopesMgr shared].filterRoomDic;

    _contactsDataLogic = [[NSClassFromString(@"ContactsDataLogic") alloc] initWithScene:0x0 delegate:nil sort:0x1 extendChatRoom:0x0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConfirmFilterChatRoom:) name:@"kConfirmFilterChatRoomNotification" object:nil];
}

- (void)setNavigationBar{
    self.title = @"微信助手设置";
    
    UIBarButtonItem *saveItem = [NSClassFromString(@"MMUICommonUtil") getBarButtonWithTitle:@"保存" target:self action:@selector(clickSaveItem) style:0 color:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)exchangeMethod{
    method_exchangeImplementations(class_getInstanceMethod(NSClassFromString(@"MMTableViewCellInfo"), @selector(actionEditorCell:)), class_getInstanceMethod([LLSettingController class], @selector(onTextFieldEditChanged:)));
}

- (void)setTableView{
    _tableViewInfo = [[NSClassFromString(@"MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:0];
    [self.view addSubview:[_tableViewInfo getTableView]];
    [_tableViewInfo setDelegate:self];
    if (@available(iOS 11, *)) {         
        [_tableViewInfo getTableView].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;             
    }else{
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
}

- (void)reloadTableData{
    MMTableViewCellInfo *openRedEnvelopesCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openRedEnvelopesSwitchHandler:) target:self title:@"是否开启红包助手" on:_settingParam.isOpenRedEnvelopesHelper];
    MMTableViewCellInfo *backgroundModeCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openBackgroundMode:) target:self title:@"是否开启后台模式" on:_settingParam.isOpenBackgroundMode];
    MMTableViewCellInfo *openAlertCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openRedEnvelopesAlertHandler:) target:self title:@"是否开启红包提醒" on:_settingParam.isOpenRedEnvelopesAlert];
    MMTableViewCellInfo *delayTimeCell = [NSClassFromString(@"MMTableViewCellInfo") editorCellForSel:nil target:nil title:@"延迟秒数" margin:120 tip:@"请输入延迟抢红包秒数" focus:NO autoCorrect:NO text:[NSString stringWithFormat:@"%.2f",_settingParam.openRedEnvelopesDelaySecond] isFitIpadClassic:YES];
    MMTableViewCellInfo *filterRoomCell = [NSClassFromString(@"MMTableViewCellInfo") normalCellForSel:@selector(onfilterRoomCellClicked) target:self title:@"过滤群聊" rightValue:self.settingParam.filterRoomDic.count?[NSString stringWithFormat:@"已选%ld个群聊",(long)self.settingParam.filterRoomDic.count]:@"暂未选择" accessoryType:1];
    [delayTimeCell addUserInfoValue:@(UIKeyboardTypeDecimalPad) forKey:@"keyboardType"];
    [delayTimeCell addUserInfoValue:@"delayTimeCell" forKey:@"cellType"];
    objc_setAssociatedObject(delayTimeCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);

    MMTableViewSectionInfo *redEnvelopesSection = [NSClassFromString(@"MMTableViewSectionInfo") sectionInfoDefaut];
    [redEnvelopesSection setHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,20)]];
    [redEnvelopesSection addCell:openRedEnvelopesCell];
    [redEnvelopesSection addCell:backgroundModeCell];
    [redEnvelopesSection addCell:openAlertCell];
    [redEnvelopesSection addCell:delayTimeCell];
    [redEnvelopesSection addCell:filterRoomCell];
    
    MMTableViewCellInfo *openStepCountCell = [NSClassFromString(@"MMTableViewCellInfo") switchCellForSel:@selector(openStepCountSwitchHandler:) target:self title:@"是否开启运动助手" on:_settingParam.isOpenSportHelper];
    MMTableViewCellInfo *stepCell = [NSClassFromString(@"MMTableViewCellInfo") editorCellForSel:@selector(stepCountHandler:) target:self title:@"运动步数" margin:120 tip:@"请输入想要的运动步数" focus:NO autoCorrect:NO text:[NSString stringWithFormat:@"%ld",(long)_settingParam.wantSportStepCount] isFitIpadClassic:YES];
    [stepCell addUserInfoValue:@(UIKeyboardTypeNumberPad) forKey:@"keyboardType"];
    [stepCell addUserInfoValue:@"stepCell" forKey:@"cellType"];
    objc_setAssociatedObject(stepCell, &kSettingControllerKey, self, OBJC_ASSOCIATION_ASSIGN);

    MMTableViewSectionInfo *stepCountSection = [NSClassFromString(@"MMTableViewSectionInfo") sectionInfoDefaut];
    [stepCountSection setHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0,0,0,20)]];
    [stepCountSection addCell:openStepCountCell];
    [stepCountSection addCell:stepCell];

    MMTableViewCellInfo *githubCell = [NSClassFromString(@"MMTableViewCellInfo") normalCellForSel:@selector(onGithubCellClicked) target:self title:@"我的Github" rightValue:@"欢迎Star" accessoryType:1];

    MMTableViewSectionInfo *aboutMeSection = [NSClassFromString(@"MMTableViewSectionInfo") sectionInfoDefaut];
    [aboutMeSection addCell:githubCell];
    
    [_tableViewInfo clearAllSection];

    [_tableViewInfo addSection:redEnvelopesSection];
    [_tableViewInfo addSection:stepCountSection];
    [_tableViewInfo addSection:aboutMeSection];
    
    [[_tableViewInfo getTableView] reloadData];
}

//点击保存
- (void)clickSaveItem{
    [LLRedEnvelopesMgr shared].isOpenRedEnvelopesHelper = _settingParam.isOpenRedEnvelopesHelper;
    [LLRedEnvelopesMgr shared].isOpenSportHelper = _settingParam.isOpenSportHelper;
    [LLRedEnvelopesMgr shared].isOpenBackgroundMode = _settingParam.isOpenBackgroundMode;
    [LLRedEnvelopesMgr shared].isOpenRedEnvelopesAlert = _settingParam.isOpenRedEnvelopesAlert;
    [LLRedEnvelopesMgr shared].openRedEnvelopesDelaySecond = _settingParam.openRedEnvelopesDelaySecond;
    [LLRedEnvelopesMgr shared].wantSportStepCount = _settingParam.wantSportStepCount;
    [LLRedEnvelopesMgr shared].filterRoomDic = _settingParam.filterRoomDic;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openRedEnvelopesSwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenRedEnvelopesHelper = openSwitch.on;
}

- (void)openBackgroundMode:(UISwitch *)backgroundMode{
    _settingParam.isOpenBackgroundMode = backgroundMode.on;
}

- (void)openRedEnvelopesAlertHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenRedEnvelopesAlert = openSwitch.on;
}

- (void)onTextFieldEditChanged:(UITextField *)textField{
    LLSettingController *settingController = objc_getAssociatedObject(self, &kSettingControllerKey);
    MMTableViewCellInfo *cellInfo = (MMTableViewCellInfo *)self;
    NSString *cellType = [cellInfo getUserInfoValueForKey:@"cellType"];
    if([cellType isEqualToString:@"delayTimeCell"]){
        settingController.settingParam.openRedEnvelopesDelaySecond = [textField.text floatValue];
    } else if ([cellType isEqualToString:@"stepCell"]){
        settingController.settingParam.wantSportStepCount = [textField.text integerValue];
    }
}

- (void)openStepCountSwitchHandler:(UISwitch *)openSwitch{
    _settingParam.isOpenSportHelper = openSwitch.on;
}

- (void)onfilterRoomCellClicked{
    LLFilterChatRoomController *chatRoomVC = [[NSClassFromString(@"LLFilterChatRoomController") alloc] init];
    MemberDataLogic *dataLogic = [[NSClassFromString(@"MemberDataLogic") alloc] initWithMemberList:[_contactsDataLogic getChatRoomContacts] admin:0x0];
    [chatRoomVC setMemberLogic:dataLogic];
    chatRoomVC.filterRoomDic = _settingParam.filterRoomDic;
    [self.navigationController PushViewController:chatRoomVC animated:YES];
}

- (void)onGithubCellClicked{
    NSURL *myGithubURL = [NSURL URLWithString:@"https://github.com/kevll/WeChatRedEnvelopesHelper"];
    MMWebViewController *githubWebVC = [[NSClassFromString(@"MMWebViewController") alloc] initWithURL:myGithubURL presentModal:NO extraInfo:nil delegate:nil];
    [self.navigationController PushViewController:githubWebVC animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)onConfirmFilterChatRoom:(NSNotification *)notify{
    _settingParam.filterRoomDic = notify.object;
    [self reloadTableData]; //刷新页面
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self exchangeMethod];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self exchangeMethod]; //reset
}

- (void)dealloc{
    [super dealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
