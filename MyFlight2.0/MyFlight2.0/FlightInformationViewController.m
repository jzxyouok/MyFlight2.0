//
//  FlightInformationViewController.m
//  MyFlight2.0
//
//  Created by apple on 12-12-26.
//  Copyright (c) 2012年 LIAN YOU. All rights reserved.
//

#import "FlightInformationViewController.h"

@interface FlightInformationViewController ()

@end

@implementation FlightInformationViewController

@synthesize org;
@synthesize passName;
@synthesize idNo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) requestForData
{
    NSURL *url = [[NSURL alloc] initWithString:GET_RIGHT_URL_WITH_Index(@"/web/phone/prod/flight/huet/getCussQueryHandler.jsp")];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    [request setPostValue:self.org forKey:@"org"];
    [request setPostValue:@"HUAIRNEW" forKey:@"orgId"];
    [request setPostValue:self.passName forKey:@"passName"];
    [request setPostValue:self.idNo forKey:@"idNo"];
    [request setPostValue:@"1" forKey:@"currentPageNo"];
    
    [request setPostValue:HWID_VALUE forKey:KEY_hwId];
    [request setPostValue:SOURCE_VALUE forKey:KEY_source];
    [request setPostValue:SERVICECode_VALUE forKey:KEY_serviceCode];
    [request setPostValue:EDITION_VALUE forKey:KEY_edition];
    
    [request setCompletionBlock:^(void){
        
        NSData *response = [request responseData];
        
        NSError *error = nil;
        
        [responseDictionary release];
        
        responseDictionary = [[response objectFromJSONDataWithParseOptions:JKSerializeOptionNone error:&error] retain];
        
        if(error != nil)
        {
            NSLog(@"JSON Parse Failed\n");
        }
        else
        {
            NSLog(@"JSON Parse Succeeded\n");
            
            NSDictionary *result = [responseDictionary objectForKey:@"result"];
            
            if([[result objectForKey:@"resultCode"] isEqualToString:@""])
            {
                [detailedInfoTable reloadData];
                [flightInfoTable reloadData];
                
                for(NSString *string in [responseDictionary allKeys])
                {
                    NSLog(@"%@\n",string);
                }
                for(NSString *string in [responseDictionary allValues])
                {
                    NSLog(@"%@\n",string);
                }
            }
            else
            {
                alertMessage = [[UIAlertView alloc] initWithTitle:[result objectForKey:@"resultCode"] message:[result objectForKey:@"message"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertMessage show];
                [alertMessage release];
            }
        }
    }];
    
    [request setFailedBlock:^(void){
        NSLog(@"JSON Request Failed\n");
    }];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"查询进度详情";
    
    [self requestForData];
    
    detailedTitleArray = [[NSArray alloc] initWithObjects:@"票        号", @"值机状态", @"航  班  号", @"座  位  号", @"乘  机  人", nil];
    
    detailedInfoTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 10, 300, 220)];
    
    detailedInfoTable.rowHeight = 44.0f;
    detailedInfoTable.backgroundColor = FOREGROUND_COLOR;
    detailedInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    detailedInfoTable.layer.borderColor = [BORDER_COLOR CGColor];
    detailedInfoTable.layer.borderWidth = 1.0f;
    detailedInfoTable.layer.cornerRadius = CORNER_RADIUS;
    
    detailedInfoTable.delegate = self;
    detailedInfoTable.dataSource = self;
    detailedInfoTable.scrollEnabled = NO;
    detailedInfoTable.allowsSelection = NO;
    
    flightInfoTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 250, 300, 88)];
    
    flightInfoTable.rowHeight = 44.0f;
    flightInfoTable.backgroundColor = FOREGROUND_COLOR;
    flightInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    flightInfoTable.layer.borderColor = [BORDER_COLOR CGColor];
    flightInfoTable.layer.borderWidth = 1.0f;
    flightInfoTable.layer.cornerRadius = CORNER_RADIUS;
    
    flightInfoTable.delegate = self;
    flightInfoTable.dataSource = self;
    flightInfoTable.scrollEnabled = NO;
    flightInfoTable.allowsSelection = NO;
    
    [self.view addSubview:detailedInfoTable];
    [detailedInfoTable release];
    
    [self.view addSubview:flightInfoTable];
    [flightInfoTable release];
    
    UIButton *cancelCheckInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    cancelCheckInButton.frame = CGRectMake(10, [UIScreen mainScreen].bounds.size.height < 500 ? 370:450, 300, 40);
    
    [cancelCheckInButton setBackgroundImage:[UIImage imageNamed:@"orange_btn.png"] forState:UIControlStateNormal];
    [cancelCheckInButton setBackgroundImage:[UIImage imageNamed:@"orange_btn_click.png"] forState:UIControlStateHighlighted];
    
    [cancelCheckInButton setTitle:@"取消值机" forState:UIControlStateNormal];
    [cancelCheckInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    cancelCheckInButton.titleLabel.font = [UIFont systemFontOfSize:20];
    cancelCheckInButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    [cancelCheckInButton addTarget:self action:@selector(cancelCheckIn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cancelCheckInButton];
    
    self.view.backgroundColor = BACKGROUND_COLOR;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == detailedInfoTable)
    {
        return 5;
    }
    else
    {
        return 2;
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    else
    {
        for(UIView *view in [cell subviews])
        {
            [view removeFromSuperview];
        }
    }
    
    NSDictionary *cussInfo = [[responseDictionary objectForKey:@"cussInfo"] objectAtIndex:0];
    
    UIView *line;
    
    if(indexPath.row != 0)
    {
        line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 1)];
        
        line.backgroundColor = [UIColor whiteColor];
        
        [cell addSubview:line];
        [line release];
    }
    
    if(indexPath.row != [tableView numberOfRowsInSection:indexPath.section] - 1)
    {
        line = [[UIView alloc] initWithFrame:CGRectMake(0, tableView.rowHeight - 1, tableView.frame.size.width, 1)];
        
        line.backgroundColor = LINE_COLOR;
        
        [cell addSubview:line];
        [line release];
    }
    
    if(responseDictionary == nil)
    {
        return cell;
    }
    
    if(tableView == detailedInfoTable)
    {
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 13.5, 80, 17)];
        
        title.text = [detailedTitleArray objectAtIndex:indexPath.row];
        title.font = [UIFont systemFontOfSize:17.0f];
        title.textAlignment = UITextAlignmentLeft;
        title.textColor = FONT_COLOR_LIGHT_GRAY;
        title.backgroundColor = [UIColor clearColor];
        
        [cell addSubview:title];
        [title release];
        
        UILabel *value = [[UILabel alloc] initWithFrame:CGRectMake(90, 13.5, 200, 17)];
        
        switch (indexPath.row) {
            case 0:
                value.text = [responseDictionary objectForKey:@"tktNo"];
                break;
            case 1:
                if([[cussInfo objectForKey:@"result"] isEqualToString:@"1"])
                {
                    value.text = @"已值机";
                    value.textColor = FONT_COLOR_GREEN;
                }
                break;
            case 2:
                value.text = [NSString stringWithFormat:@"%@%@", [cussInfo objectForKey:@"airlinecode"], [cussInfo objectForKey:@"airlineNo"]];
                break;
            case 3:
                value.text = [cussInfo objectForKey:@"seatNo"];
                break;
            case 4:
                value.text = [cussInfo objectForKey:@"name_ch"];
                break;
            default:
                break;
        }
        
        value.font = [UIFont systemFontOfSize:17.0f];
        value.textAlignment = UITextAlignmentRight;
        value.textColor = FONT_COLOR_DEEP_GRAY;
        value.backgroundColor = [UIColor clearColor];
        
        [cell addSubview:value];
        [value release];
    }
    else
    {
        if(indexPath.row == 0)
        {
            UILabel *label;
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 120, 16)];
            
            label.text = [NSString stringWithFormat:@"%@ - %@", [cussInfo objectForKey:@"departure_cn"], [cussInfo objectForKey:@"arrival_cn"]];
            label.font = [UIFont systemFontOfSize:16.0f];
            label.textAlignment = UITextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            
            [cell addSubview:label];
            [label release];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(130, 14, 120, 16)];
            
            label.text = [NSString stringWithFormat:@"%@%@", [cussInfo objectForKey:@"airlinecode"], [cussInfo objectForKey:@"airlineNo"]];
            label.font = [UIFont systemFontOfSize:16.0f];
            label.textAlignment = UITextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.backgroundColor = [UIColor clearColor];
            
            [cell addSubview:label];
            [label release];
        }
        else
        {
            UILabel *label;
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(100, 8, 80, 12)];
            
            label.text = @"起飞时间";
            label.font = [UIFont systemFontOfSize:12.0f];
            label.textAlignment = UITextAlignmentLeft;
            label.textColor = FONT_COLOR_LIGHT_GRAY;
            label.backgroundColor = [UIColor clearColor];
            
            [cell addSubview:label];
            [label release];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(100, 22, 80, 14)];
            
            label.text = [[cussInfo objectForKey:@"takeoffDateTime"] stringByReplacingCharactersInRange:NSMakeRange(10, 14) withString:@""];
            label.font = [UIFont systemFontOfSize:14.0f];
            label.textAlignment = UITextAlignmentLeft;
            label.textColor = FONT_COLOR_DEEP_GRAY;
            label.backgroundColor = [UIColor clearColor];
            
            [cell addSubview:label];
            [label release];
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 80, 28)];
            
            label.text = [NSString stringWithFormat:@"%@:%@", [[cussInfo objectForKey:@"deptime"] stringByReplacingCharactersInRange:NSMakeRange(2, 2) withString:@""], [[cussInfo objectForKey:@"deptime"] stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""]];
            
            label.font = [UIFont systemFontOfSize:28.0f];
            label.textAlignment = UITextAlignmentLeft;
            label.textColor = FONT_COLOR_DEEP_GRAY;
            label.backgroundColor = [UIColor clearColor];
            
            [cell addSubview:label];
            [label release];
        }
    }
    
    cell.backgroundColor = FOREGROUND_COLOR;
    
    return cell;
}

- (void) cancelCheckIn
{
    NSURL *url = [NSURL URLWithString:GET_RIGHT_URL_WITH_Index(@"/web/phone/prod/flight/huet/getPwHandler.jsp")];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request setRequestMethod:@"POST"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    NSDictionary *cussInfo = [[responseDictionary objectForKey:@"cussInfo"] objectAtIndex:0];
    
    [request setPostValue:[cussInfo objectForKey:@"recNo"] forKey:@"recNo"];
    [request setPostValue:[cussInfo objectForKey:@"pwId"] forKey:@"pwId"];
    [request setPostValue:[cussInfo objectForKey:@"org"] forKey:@"org"];
    [request setPostValue:[cussInfo objectForKey:@"orgId"] forKey:@"orgId"];
    [request setPostValue:[responseDictionary objectForKey:@"passName"] forKey:@"passName"];
    [request setPostValue:[responseDictionary objectForKey:@"idNo"] forKey:@"idNo"];
    [request setPostValue:[cussInfo objectForKey:@"etNo"] forKey:@"etNo"];
    
    [request setCompletionBlock:^(void){
        
        NSData *response = [request responseData];
        
        NSError *error = nil;
        
        NSDictionary *responseDict = [response objectFromJSONDataWithParseOptions:JKSerializeOptionNone error:&error];
        
        if(error != nil)
        {
            NSLog(@"JSON Parse Failed\n");
        }
        else
        {
            NSLog(@"JSON Parse Succeeded\n");
            
            NSDictionary *result = [responseDict objectForKey:@"result"];
            
            if([[result objectForKey:@"resultCode"] isEqualToString:@""])
            {
                for(NSString *string in [responseDict allKeys])
                {
                    NSLog(@"%@\n",string);
                }
                for(NSString *string in [responseDict allValues])
                {
                    NSLog(@"%@\n",string);
                }
                
                [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:2] animated:YES];
            }
            else
            {
                alertMessage = [[UIAlertView alloc] initWithTitle:[result objectForKey:@"resultCode"] message:[result objectForKey:@"message"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertMessage show];
                [alertMessage release];
            }
        }
    }];
    
    [request setFailedBlock:^(void){
        alertMessage = [[UIAlertView alloc] initWithTitle:@"" message:@"网络无响应，请稍后再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertMessage show];
        [alertMessage release];
    }];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) dealloc
{
    [detailedTitleArray release];
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

@end
