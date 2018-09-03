//
//  ViewController.m
//  WKWebView-JS
//
//  Created by CCX on 2018/9/3.
//  Copyright © 2018年 xyq. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "Masonry.h"

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *loginWebView;

@property (nonatomic, strong) UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.loginWebView];
    [self.view addSubview:self.btn];
    [self.loginWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).with.offset(20);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loginWebView.mas_bottom).with.offset(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 50));
    }];
    
    NSURL *htmlPath = [[NSBundle mainBundle] URLForResource:@"login" withExtension:@"html"];
    [self.loginWebView loadRequest:[NSURLRequest requestWithURL:htmlPath]];
    
}

- (WKWebView*) loginWebView {
    if (!_loginWebView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [config.userContentController addScriptMessageHandler:self name:@"loginApp"];
        [config.userContentController addScriptMessageHandler:self name:@"logintest"];
        _loginWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _loginWebView.UIDelegate = self;
        _loginWebView.navigationDelegate = self;
     }
    return _loginWebView;
}

- (UIButton*) btn {
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn setTitle:@"test" forState:UIControlStateNormal];
        _btn.backgroundColor = [UIColor blueColor];
        [_btn addTarget:self action:@selector(testAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//test Action
//showName('%@','%@')里面要加单引号，否则js不能识别
- (void) testAction {
    NSString *jsStr = [NSString stringWithFormat:@"showName('%@','%@')",@"test",@"123"];
    [self.loginWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"error ==== %@", error.description);
    }];
}

//js向oc传值
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *dic = message.body;
    if ([message.name isEqualToString:@"loginApp"]) {
        NSLog(@"name == %@", dic[@"name"]);
    }else if ([message.name isEqualToString:@"logintest"]){
        NSLog(@"name and password === %@ , %@",dic[@"name"], dic[@"password"] );
    }
}

// 在JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:@"JS调用alert" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:@"JS调用confirm" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    
    NSLog(@"%@", prompt);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}
@end
