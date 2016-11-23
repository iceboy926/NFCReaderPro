//
//  ViewController.m
//  NFCReaderPro
//
//  Created by 金玉衡 on 16/11/21.
//
//

#import "MainViewController.h"
#import "ScanDeviceListViewController.h"
#import "WebViewController.h"
#import "KSWaitingView.h"
#import "NFCCard.h"
#import "NSData+Hex.h"

@interface MainViewController ()

@property (nonatomic, strong)UIButton *bleManagerBtn;
@property (nonatomic, strong) DKDeviceManager  *deviceManager;
@property (nonatomic, strong) NSMutableString  *msgBuffer;
@property (nonatomic, strong) UITextField *inputTextView;
@property (nonatomic, strong) UIButton *readerCardBtn;
@property (nonatomic, strong) KSWaitingView *waitingView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [self.view addSubview:self.bleManagerBtn];
    [self.view addSubview:self.readerCardBtn];
    
    [self.view addSubview:self.inputTextView];

    [self setupNavigationView];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchView:)];
    
    [self.view addGestureRecognizer:gesture];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addUIConstraints];
}


- (void)setupNavigationView
{
    self.view.backgroundColor = backGroundColor;
    [self setTitle:@"NFCReader"];
}

- (void)touchView:(UITapGestureRecognizer *)gesture
{
    [self resignAllResponse];
}

- (void)resignAllResponse
{
    [self.inputTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ui layout

- (void)addUIConstraints
{
    [self.bleManagerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 50));
        
    }];
    
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_bleManagerBtn.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(280, 50));
    }];


    [self.readerCardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(_inputTextView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 50));
        
    }];
    
 }

#pragma mark lazy load

- (UIButton *)bleManagerBtn
{
    if(_bleManagerBtn == nil)
    {
        _bleManagerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_bleManagerBtn setTitle:@"查找蓝牙设备" forState:UIControlStateNormal];
        [_bleManagerBtn setTitleColor:navigaterBarColor forState:UIControlStateNormal];
        [_bleManagerBtn setBackgroundColor:[UIColor clearColor]];
        
        [_bleManagerBtn addTarget:self action:@selector(bleManangerClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _bleManagerBtn;
}


- (UITextField *)inputTextView
{
    if(_inputTextView == nil)
    {
        _inputTextView = [[UITextField alloc] init];
        _inputTextView.textAlignment = NSTextAlignmentCenter;
        _inputTextView.text = @"http://www.baidu.com";
         //[[ UIApplication sharedApplication] openURL:[ NSURL urlWithString:urlText];
    }
    
    return _inputTextView;
}

- (UIButton *)readerCardBtn
{
    if(_readerCardBtn == nil)
    {
        _readerCardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_readerCardBtn setTitle:@"读卡操作" forState:UIControlStateNormal];
        [_readerCardBtn setTitleColor:navigaterBarColor forState:UIControlStateNormal];
        [_readerCardBtn setBackgroundColor:[UIColor clearColor]];
        [_readerCardBtn addTarget:self action:@selector(readerCardBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _readerCardBtn;
}

- (DKDeviceManager *)deviceManager
{
    if(_deviceManager == nil)
    {
        _deviceManager = [[DKDeviceManager alloc] init];
        
    }
    
    return _deviceManager;
}

- (NSMutableString *)msgBuffer
{
    if(_msgBuffer == nil)
    {
        _msgBuffer = [[NSMutableString alloc] init];
    }
    
    return _msgBuffer;
}

- (KSWaitingView *)waitingView
{
    if(_waitingView == nil)
    {
        _waitingView = [[KSWaitingView alloc] init];
    }
    return _waitingView;
}


#pragma mark 

- (void)bleManangerClicked:(UIButton *)sender
{
    
    ScanDeviceListViewController *scanDeviceVC = [[ScanDeviceListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    scanDeviceVC.title = @"蓝牙设备";
    
    scanDeviceVC.DidCheckBLEDevice = ^(BOOL blConnect){
    
        [self showWait:@"正在连接设备"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
            [self hideWait];
        
            if(blConnect)
            {
                [self showAlert:@"连接设备成功"];
                //[self getDeviceMsg];
            }
            else
            {
                [self showAlert:@"连接设备失败"];
            }

        });
       };
    
    [self.navigationController pushViewController:scanDeviceVC animated:YES];
}


- (void)readerCardBtnClicked:(UIButton *)sender
{
    //WebViewController *webVC = [[WebViewController alloc] init];
    //webVC.title = @"";
    
    //[self.navigationController pushViewController:webVC animated:YES];
    
    if([DKBleManager sharedInstance].isConnect)
    {
        self.waitingView.strInputData = self.inputTextView.text;
    
        [self.waitingView show];
    }
    else
    {
        [self showAlert:@"请先连接蓝牙读卡器"];
    }
}


-(void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
    
}

-(void)showWait:(NSString *)mas
{
    [SVProgressHUD showWithStatus:mas];
}

-(void)hideWait
{
    [SVProgressHUD dismiss];
}


//获取设备信息
-(void)getDeviceMsg {
    
    [self.msgBuffer setString:@""];
    [self.deviceManager requestDeviceVersionWithCallbackBlock:^(NSUInteger versionNum) {
        [self.msgBuffer appendString:@"SDK版本v1.4.0 20161026\r\n"];
        [self.msgBuffer appendString:[NSString stringWithFormat:@"设备版本：%02lx\r\n", (unsigned long)versionNum]];

        [self.deviceManager requestDeviceBtValueWithCallbackBlock:^(float btVlueMv) {
            [self.msgBuffer appendString:[NSString stringWithFormat:@"设备电池电压：%.2fV\r\n", btVlueMv]];
            if (btVlueMv < 3.4) {
                [self.msgBuffer appendString:@"设备电池电量低，请及时充电！\r\n"];
            }
            else {
                [self.msgBuffer appendString:@"设备电池电量充足！\r\n"];
            }
            
        }];
    }];
}



@end
