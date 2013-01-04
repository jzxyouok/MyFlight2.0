//
//  LowOrderController.m
//  MyFlight2.0
//
//  Created by WangJian on 12-12-15.
//  Copyright (c) 2012年 LIAN YOU. All rights reserved.
//

#import "LowOrderController.h"
#import "LowOrderCell.h"
#import "MonthDayCell.h"
#import "UIButton+BackButton.h"
#import "UIQuickHelp.h"
#import "PublicConstUrls.h"
#import "LowOrderWJ.h"
#import "AppConfigure.h"
@interface LowOrderController ()
{
    int delegataFlag;  // 判断点击的是哪一行
}
@end

@implementation LowOrderController

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
    
    self.navigationItem.title = @"预约该航线";
    
    delegataFlag = 10;
    self.firstLabelArr  = [NSArray arrayWithObjects:@"最早出发日期",@"最晚出发日期",@"折扣(不含税)",@"手机号码", nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    
    self.startAirport.text = self.start;
    self.endAirport.text = self.end;
    
    
    UIButton * backBtn = [UIButton backButtonType:0 andTitle:@""];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBtn1=[[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem=backBtn1;
    [backBtn1 release];

    
    
    
    //获得系统时间
    NSDate *  senddate=[NSDate date];
  //  NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    
    NSCalendar  * cal=[NSCalendar  currentCalendar];
    NSUInteger  unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:senddate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month] ;
    NSInteger day=[conponent day] +2 ;
    
    NSString * strMonth=nil;
    NSString * strDay=nil;
    if (month<10) {
        strMonth = [[NSString alloc] initWithFormat:@"0%d",month];
        
    }
    else{
        strMonth = [NSString stringWithFormat:@"%d",month];
    }
    if (day<10) {
        strDay = [NSString stringWithFormat:@"0%d",day];
        
    }
    else{
        strDay = [NSString stringWithFormat:@"%d",day];
    }
    
    NSString * string = nil;
    if ([strDay intValue]-1 <10) {
        string = [NSString stringWithFormat:@"0%d",[strDay intValue]-1];
    }
    else{
        string = [NSString stringWithFormat:@"%d",[strDay intValue]-1];
    }
    
    NSString * time1 = [NSString stringWithFormat:@"%d-%@-%@",year,strMonth,string];
    NSString * time2 = [NSString stringWithFormat:@"%d-%@-%@",year,strMonth,strDay];
    
    self.seconderLabelArr = [NSMutableArray arrayWithObjects:time1,time2,@"5折以下", nil];

    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_lowOrderCell release];
    [_tableView release];
    [_footView release];
    [_viewPicker release];
    [_btnCancel release];
    [_btnDone release];
    [_pickerSort release];
    [_phoneCEll release];
    [_showTabelView release];
    [_startAirport release];
    [_endAirport release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLowOrderCell:nil];
    [self setTableView:nil];
    [self setFootView:nil];
    [self setViewPicker:nil];
    [self setBtnCancel:nil];
    [self setBtnDone:nil];
    [self setPickerSort:nil];
    [self setPhoneCEll:nil];
    [self setShowTabelView:nil];
    [self setStartAirport:nil];
    [self setEndAirport:nil];
    [super viewDidUnload];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 90  ;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView * myView =[[[UIView alloc] init] autorelease];
    
    self.footView.frame = CGRectMake(10, 30, 300, 44);
    [myView addSubview:self.footView];
    
    return myView;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.firstLabelArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
       
    if (indexPath.row == 3) {
        
        static NSString *CellIdentifier = @"Cell";
        LowTextFiledCell *cell = (LowTextFiledCell *)[self.showTabelView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            [[NSBundle mainBundle] loadNibNamed:@"LowTextFiledCell" owner:self options:nil];
            cell = self.phoneCEll;
        }
        cell.textFiledLabel.delegate = self;
        cell.textFiledLabel.keyboardType = UIKeyboardTypeNumberPad;
        return cell;
  

    }
    
    else{
        static NSString *CellIdentifier = @"Cell";
        LowOrderCell *cell = (LowOrderCell *)[self.showTabelView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            [[NSBundle mainBundle] loadNibNamed:@"LowOrderCell" owner:self options:nil];
            cell = self.lowOrderCell;
        }
        
        cell.firstLabel.text = [self.firstLabelArr objectAtIndex:indexPath.row];

        cell.secondLabel.text = [self.seconderLabelArr objectAtIndex:indexPath.row];
        return cell;
    }
    
    
    
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1) {
        if (indexPath.row == 0) {
            delegataFlag = 0;
        }
        else{
            delegataFlag = 1;
        }
        
        [MonthDayCell selectYear:leaveDate.year month:leaveDate.month day:leaveDate.day];
        SelectCalendarController* controller = [[SelectCalendarController alloc] init];
        [controller setDelegate:self];
        [controller showCalendar];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }

    
    if (indexPath.row == 2) {
        self.contents =[NSArray arrayWithObjects:@"7折以下",@"6折以下",@"5折以下",@"4折以下",@"3折以下", nil];
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:nil
                                         cancelButtonTitle:nil
                                    destructiveButtonTitle:nil
                                         otherButtonTitles:nil];
        actionSheet.tag = 10;
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
        
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        
        [actionSheet addSubview:pickerView];
        [pickerView release];
        
        UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Close"]];  // 对pickerView进行自定义
        closeButton.momentary = YES;
        [closeButton setTitle:@"完成" forSegmentAtIndex:0];
        closeButton.frame = CGRectMake(260, 7.0f, 50.0f, 30.0f);
        closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
        closeButton.tintColor = [UIColor blackColor];
        [closeButton addTarget:self action:@selector(done) forControlEvents:UIControlEventValueChanged];
        [actionSheet addSubview:closeButton];
        [closeButton release];
        
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
        
        [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];

    }
}

-(void) setYear: (int) year month: (int) month day: (int) day {
    [leaveDate setYear:year month:month day:day];
    
    LowOrderCell *cell = (LowOrderCell *)[self.showTabelView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:delegataFlag inSection:0]];
    
    NSString * strMonth;
    NSString * strDay;
    if (month<10) {
        strMonth = [NSString stringWithFormat:@"0%d",month];
    }
    else{
        strMonth = [NSString stringWithFormat:@"%d",month];
    }
    if (day<10) {
        strDay = [NSString stringWithFormat:@"0%d",day];
    }
    else{
        strDay = [NSString stringWithFormat:@"%d",day];
    }

    
    cell.secondLabel.text = [NSString stringWithFormat:@"%d-%@-%@",year,strMonth,strDay];
    
    [self.seconderLabelArr replaceObjectAtIndex:delegataFlag withObject:cell.secondLabel.text];
}

#pragma mark -
#pragma mark UIPickerViewDataSource Protocol Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.contents.count ;   // pickerView  里边元素的个数
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.contents objectAtIndex:row]; // 返回特定某一行的内容
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    LowOrderCell *cell = (LowOrderCell *)[self.showTabelView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
    
    [self.seconderLabelArr replaceObjectAtIndex:2 withObject:[self.contents objectAtIndex:row]];
    
    cell.secondLabel.text = [self.contents objectAtIndex:row];

    [self.tableView reloadData]; // 重新加载tabelView
}
-(void)done   // 点击pickerView上边定义的done按钮的时候触发
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];  // 移除视图
}

- (IBAction)orderNow:(id)sender {
    
    NSString * string = [NSString stringWithFormat:@"%@%@%@",Default_UserMemberId_Value,SOURCE_VALUE,Default_Token_Value];
    
    LowTextFiledCell *cell = (LowTextFiledCell *)[self.showTabelView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
                                                  
    NSString * discount = [[self.seconderLabelArr objectAtIndex:2] substringWithRange:NSMakeRange(0, 1)];
    
    LowOrderWJ * low = [[LowOrderWJ alloc] initWithSource:SOURCE_VALUE
                                                   andDpt:self.startCode
                                                   andArr:self.endCode
                                             andDateSatrt:[self.seconderLabelArr objectAtIndex:0]
                                               andDateEnd:[self.seconderLabelArr objectAtIndex:1]
                                              andDiscount:discount
                                                andMobile:cell.textFiledLabel.text
                                                  andHwId:HWID_VALUE
                                              andMemberId:Default_UserMemberId_Value
                                                  andSign:GET_SIGN(string)
                                              andDelegate:self];
    low.delegate = self;
    [low getLowOrderInfo];
    
    
    
    
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -

//网络错误回调的方法
- (void )requestDidFailed:(NSDictionary *)info{
  
    NSString * meg =[info objectForKey:KEY_message];
    
    [UIQuickHelp showAlertViewWithTitle:@"温馨提醒" message:meg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
}

//网络返回错误信息回调的方法
- (void) requestDidFinishedWithFalseMessage:(NSDictionary *)info{
  
    NSString * meg =[info objectForKey:KEY_message];
    
    [UIQuickHelp showAlertViewWithTitle:@"温馨提醒" message:meg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
    
}


//网络正确回调的方法
- (void) requestDidFinishedWithRightMessage:(NSDictionary *)info{
 
  // [UIQuickHelp showAlertViewWithTitle:@"温馨提醒" message:@"有符合要求的折扣信息时，会提醒您。您可以在我的帐户里查看订阅的航线低价信息。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];

    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"预约成功" message:@"有符合要求的折扣信息时，会提醒您。您可以在我的帐户里查看订阅的航线低价信息。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    
    [alert show];
    [alert release];
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint ce=self.view.center;
    ce.y=self.view.frame.size.height/2;
    if (textField.center.y>20) {
        ce.y=ce.y- textField.center.y-20;
    }
    NSLog(@"%f",textField.center.y);
    [UIView beginAnimations:@"dsdf" context:nil];//动画开始
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    self.view.center=ce;
    [UIView commitAnimations];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGPoint ce=self.view.center;
    ce.y=self.view.frame.size.height/2;
    
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    self.view.center=ce;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES ;
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
     LowTextFiledCell *cell = (LowTextFiledCell *)[self.showTabelView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:0]];
    
    
    CGPoint ce=self.view.center;
    ce.y=self.view.frame.size.height/2;
    
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    self.view.center=ce;
    [UIView commitAnimations];
    

    
    [cell.textFiledLabel resignFirstResponder];
    
}

#pragma mark -- alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
 
}


@end
