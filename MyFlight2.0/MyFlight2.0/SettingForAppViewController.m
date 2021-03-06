//
//  SettingForAppViewController.m
//  MyFlight2.0
//
//  Created by Davidsph on 1/4/13.
//  Copyright (c) 2013 LIAN YOU. All rights reserved.
//

#import "SettingForAppViewController.h"
#import "SettingCell.h"
#import "SettingSecondCell.h"
#import "ShowLableDetailCell.h"
@interface SettingForAppViewController ()
{
    
    NSArray *nameArray;
    
}
@end

@implementation SettingForAppViewController

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
    [super viewDidLoad];
    nameArray =[[NSArray alloc] initWithObjects:@"默认出发机场",@"默认到达机场", nil];
    
    self.view.backgroundColor =BACKGROUND_COLOR;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==4) {
        return 1;
    } else{
        
        return 2;
    }

    // Return the number of rows in the section.
    return 0;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==1) {
        if (indexPath.row==1) {
            
            return 80;
        }
    }
    
    
return  44;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        
        static NSString *CellIdentifier = @"Cell";
        
        SettingCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell==nil) {
            
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:nil options:nil];
            cell = [array objectAtIndex:0];
            
        }
        
        cell.nameLabel.text =[nameArray objectAtIndex:indexPath.row];
 
        return cell;
        
        
    } else if(indexPath.section==4){
        
        
        static NSString *CellIdentifier = @"Cell1";
        
        SettingCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell==nil) {
            
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"SettingCell" owner:nil options:nil];
            cell = [array objectAtIndex:0];
            
            
        }
        
        cell.nameLabel.text =@"清楚缓冲数据及隐私";
        return cell;

    } else{
        
        
        static NSString *CellIdentifier = @"cell1";
        SettingSecondCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell==nil){
            NSArray *array =[[NSBundle mainBundle] loadNibNamed:@"SettingSecondCell" owner:nil options:nil];
            cell =[array objectAtIndex:0];
            
        }
        
        
        
        static NSString *CellIdentifier1 = @"cell11";
        ShowLableDetailCell *cell11 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell11==nil){
            NSArray *array =[[NSBundle mainBundle] loadNibNamed:@"ShowLableDetailCell" owner:nil options:nil];
            cell11 =[array objectAtIndex:0];
            
        }

        
        
        if(indexPath.section==1){
            if (indexPath.row==0) {
                cell.nameLabel.text = @"接收推送通知";
                
                return cell;
            } else{
            
                cell11.noticeLabel.text = @"用于接收预订通知和航班变动通知等重要信息，建议开启。如手机设置未开启，请在手机设置-通知里开启.";
                return cell11;
            }
            
            
        } else if(indexPath.section==2){
            if (indexPath.row==0) {
                cell.nameLabel.text = @"接收短信通知";
                return cell;
                
            } else {
                
                cell11.noticeLabel.text = @"重要航班信息会给您发送短信，建议开启。使用完全免费。";
                return cell11;
            }
             
            
        } else{
            
            if (indexPath.row==0) {
               cell.nameLabel.text = @"将信息加入Passbook";
                return  cell;
            } else{
                cell11.noticeLabel.text = @"关注航班信息和机票预订订单信息会加入PASSBOOK，用户需要手动触发添加。";
                return cell11;
                
            }
            
            
        }
        
        
       return  cell;

        
        
        
    }
    
        
      
    // Configure the cell...
    
    return nil;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}




@end
