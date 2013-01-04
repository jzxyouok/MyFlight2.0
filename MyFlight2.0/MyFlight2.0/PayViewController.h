//
//  PayViewController.h
//  MyFlight2.0
//
//  Created by WangJian on 13-1-3.
//  Copyright (c) 2013年 LIAN YOU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderDetaile.h"
#import "Umpay.h"


@interface PayViewController : UIViewController<UmpayDelegate>

@property (nonatomic, retain) OrderDetaile * orderDetaile;

@property (nonatomic, retain) NSString * searchType;

@end