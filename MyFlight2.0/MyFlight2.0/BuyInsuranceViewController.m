//
//  BuyInsuranceViewController.m
//  MyFlight2.0
//
//  Created by Davidsph on 12/6/12.
//  Copyright (c) 2012 LIAN YOU. All rights reserved.
//

#import "BuyInsuranceViewController.h"

@interface BuyInsuranceViewController ()
{
    
}


@end

@implementation BuyInsuranceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"购买保险";

    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 5, 30, 31);
    backBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    backBtn.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_return_.png"]];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBtn1=[[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem=backBtn1;
    [backBtn1 release];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back
{
    blocks(BuyString);
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)swithOFFOrON:(UISwitch *)sender {
    
  //  mySwitch = (UISwitch *)sender;
    NSLog(@"%s,%d",__FUNCTION__,__LINE__);
    BOOL setting = sender.isOn;//获得开关状态
    if(setting)
    {
        NSLog(@"%s,%d",__FUNCTION__,__LINE__);
        BuyString = @"20元/份*1人";
    }

}


-(void)getDate:(void (^) (NSString * idntity))string{
    [blocks release];
    blocks = [string copy];
}

@end
