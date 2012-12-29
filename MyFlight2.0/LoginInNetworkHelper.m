//
//  LoginInNetworkHelper.m
//  JOSNAndTableView
//
//  Created by Davidsph on 12/18/12.
//  Copyright (c) 2012 david. All rights reserved.
//

#import "LoginInNetworkHelper.h"
#import "ASIHTTPRequest.h"
#import "DNWrapper.h"
#import "NSData+base64.h"
#import "ASIFormDataRequest.h"
#import "AppConfigure.h"
#import "JSONKit.h"
#import "IsLoginInSingle.h"
#import "UserAccount.h"
#import "CommonContact.h"
#import "CommontContactSingle.h"
@implementation LoginInNetworkHelper

#pragma mark -
#pragma mark 注册操作
//注册操作
+ (BOOL) registerWithUrl:(NSDictionary *) bodyDic delegate:(id<ServiceDelegate>) delegate{
    
    
    NSString *name = [bodyDic objectForKey:KEY_Register_Account];
    
    NSString *pwd = [bodyDic objectForKey:KEY_Register_Pwd];
    
    NSString *yzCode = [bodyDic objectForKey:KEY_Register_YZCode];
    
    
    CCLog(@"用户名为：%@",name);
    
    
    NSString *realUrl = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@",KEY_Register_Account,name,KEY_Register_Pwd,pwd,KEY_Register_YZCode,yzCode,PUBLIC_Parameter];
    
    CCLog(@"realUrl =%@",realUrl);
    
    //base64加密
    NSData *data =[realUrl dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *plain = [data base64Encoding];
    NSString *sign = [DNWrapper md5:realUrl];
    
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    [messageDic setObject:Regist_RequestType_Value forKey:KEY_Request_Type];
    
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:REGISTER_URL]];
    
    [formRequst setPostValue:plain forKey:KEY_PLAIN];
    [formRequst setPostValue:sign forKey:KEY_SIGN];
    [formRequst setPostValue:EDITION_VALUE forKey:KEY_edition];
    [formRequst setPostValue:SOURCE_VALUE forKey:KEY_source];
    [formRequst setRequestMethod:@"POST"];
    
    [formRequst setCompletionBlock:^{
        
        
        NSString *data = [formRequst responseString];
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            
            NSLog(@"服务器返回的信息为：%@",message);
            
            CCLog(@"message 长度为%d",[message length]);
            
            //            CCLog(@"成功注册后返回的数据：%@",dic);
            
            if ([message length]==0) {
                
                NSLog(@"成功注册后返回的数据：%@",data);
                
                
                
                //执行保存用户信息
                
                IsLoginInSingle *single = [IsLoginInSingle shareLoginSingle];
                
                //                single.isLogin = YES; //此时用户刚刚注册 尚未登录
                
                single.token = [dic objectForKey:KEY_Account_token];
                single.userAccount.memberId = [dic objectForKey:KEY_Account_MemberId];
                single.userAccount.email  =[dic objectForKey:KEY_Account_Email];
                single.userAccount.mobile = [dic objectForKey:KEY_Account_Mobile];
                
                
                
                
                NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
                
                //注册成功 保存用户注册时的用户名和密码  方便用户登陆操作
                
                [defaultUser setObject:name forKey:KEY_Default_AccountName];
                [defaultUser setObject:pwd forKey:KEY_Default_Password];
                
                
                
                [defaultUser setBool:NO forKey:KEY_Default_IsUserLogin]; //用户尚未登录
                
                [defaultUser setObject:single.userAccount.memberId forKey:KEY_Default_MemberId];
                
                
                [defaultUser setObject:single.token forKey:KEY_Default_Token];
                
                [defaultUser setObject:single.userAccount.mobile forKey:KEY_Default_UserMobile];
                
                [defaultUser synchronize];
                
                NSString *userName =[[NSUserDefaults standardUserDefaults] objectForKey:KEY_Default_AccountName];
                
                NSString *userPwd = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_Default_Password];
                
                CCLog(@"成功注册后 用户的id为：%@",Default_UserMemberId_Value);
                
                CCLog(@"成功注册后，默认设置的用户名为:%@",userName);
                CCLog(@"成功注册后，默认设置的用户名为：%@",userPwd);
                
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
        //        [delegate requestDidFinishedWithFalseMessage:messageDic];
        
    }];
    
    
    [formRequst setFailedBlock:^{
        
        [delegate requestDidFailed:nil];
        
        NSLog(@"失败");
        NSError *error = [formRequst error];
        NSLog(@"Error downloading image: %@", error.localizedDescription);
    }];
    
    
    [formRequst startSynchronous];
    
    return YES;
    
}

#pragma mark -
#pragma mark 登录操作
//登录操作

+ (BOOL) requestWithUrl:(NSDictionary *) bodyDic delegate:(id<ServiceDelegate>) delegate
{
    
    
    
    NSString *name = [bodyDic objectForKey:KEY_Login_Account];
    
    NSString *pwd = [bodyDic objectForKey:KEY_Login_Pwd];
    
    
    CCLog(@"用户名为：%@",name);
    
    
    NSString *realUrl = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@&%@",KEY_Login_Account,name,KEY_Login_Pwd,pwd,KEY_Login_Type,Login_Type_Value,PUBLIC_Parameter];
    
    CCLog(@"realUrl =%@",realUrl);
    
    //base64加密
    NSData *data =[realUrl dataUsingEncoding:NSUTF8StringEncoding];
    NSString *plain = [data base64Encoding];
    NSString *sign = [DNWrapper md5:realUrl];
    
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:LOGIN_URL]];
    
    
    [formRequst setPostValue:plain forKey:KEY_PLAIN];
    [formRequst setPostValue:sign forKey:KEY_SIGN];
    [formRequst setPostValue:EDITION_VALUE forKey:KEY_edition];
    
    
    //    [formRequst setPostValue:SOURCE_VALUE forKey:KEY_source];
    [formRequst setRequestMethod:@"POST"];
    
    [formRequst setCompletionBlock:^{
        
        NSString *data = [formRequst responseString];
        
        //        CCLog(@"网络返回的数据为：%@",data);
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[[dic objectForKey:KEY_result] objectForKey:KEY_message] retain];
            NSLog(@"服务器返回的信息为：%@",message);
            
            CCLog(@"message 长度为%d",[message length]);
            
            CCLog(@"成功登陆后返回的数据：%@",dic);
            
            if ([message length]==0) {
                
                NSLog(@"成功登陆后返回的数据：%@",data);
                
                
                
                //执行保存用户信息
                
                IsLoginInSingle *single = [IsLoginInSingle shareLoginSingle];
                single.isLogin = YES;
                single.token = [dic objectForKey:KEY_Account_token];
                single.userAccount.memberId = [dic objectForKey:KEY_Account_MemberId];
                single.userAccount.email  =[dic objectForKey:KEY_Account_Email];
                single.userAccount.mobile = [dic objectForKey:KEY_Account_Mobile];
                
                single.userAccount.code = [dic objectForKey:KEY_Account_Code];
                
                
                
                
                NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
                
                //用户登录状态
                [defaultUser setBool:YES forKey:KEY_Default_IsUserLogin];
                //用户ID
                [defaultUser setObject:single.userAccount.memberId forKey:KEY_Default_MemberId];
                //                用户token
                
                [defaultUser setObject:single.token forKey:KEY_Default_Token];
                //                用户手机号码
                [defaultUser setObject:single.userAccount.mobile forKey:KEY_Default_UserMobile];
                
                
                [defaultUser setObject:single.userAccount.code forKey:KEY_Default_Code];
                
                [defaultUser synchronize];
                
                CCLog(@"用户的id为：%@",Default_UserMemberId_Value);
                
                CCLog(@"用户code为%@",single.userAccount.code);
                
                CCLog(@"用户手机号码为：%@", [defaultUser objectForKey:KEY_Default_UserMobile]);
                
                
                if (delegate&&[delegate respondsToSelector:@selector(requestDidFinishedWithRightMessage:)]) {
                    
                    CCLog(@"用户代理不为空");
                    [delegate requestDidFinishedWithRightMessage:messageDic];

                    
                    
                }
                
                                
            } else{
                
                //message 长度不为0 有错误信息
                //                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
        
    }];
    
    
    [formRequst setFailedBlock:^{
        
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        CCLog(@"网络访问失败");
        
    }];
    
    
    [formRequst startAsynchronous];
    
//    [messageDic autorelease];
    
    return true;
    
}
//第三方登陆成功后提交到服务器
+(BOOL) submitOAuthDateToServer:(NSMutableDictionary *) userOAuthInfo delegate:(id<ServiceDelegate>) delegate{
    NSString *usrId = [userOAuthInfo objectForKey:@"usrId"];
    NSString *source = [userOAuthInfo objectForKey:@"source"];
    NSString *token = [userOAuthInfo objectForKey:@"token"];
    
    
    NSString *realUrl = [NSString stringWithFormat:@"usrId=%@&source=%@&token=%@&%@",usrId,source,token,PUBLIC_Parameter];
    CCLog(@"realUrl =%@",realUrl);
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    __block NSString *message = nil;
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:OAUTHINFOCOMIT_URL]];
    
    [formRequst setPostValue:usrId forKey:@"usrId"];
    [formRequst setPostValue:source forKey:@"source"];
    [formRequst setPostValue:token forKey:@"token"];
    [formRequst setPostValue:EDITION_VALUE forKey:KEY_edition];
    
    //    [formRequst setPostValue:SOURCE_VALUE forKey:KEY_source];
    [formRequst setRequestMethod:@"POST"];
    [formRequst setCompletionBlock:^{
        NSString *data = [formRequst responseString];
        //        CCLog(@"网络返回的数据为：%@",data);
        NSError *error = nil;
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        if (!error) {
            CCLog(@"json解析格式正确");
            message = [[[dic objectForKey:KEY_result] objectForKey:KEY_message] retain];
            NSLog(@"服务器返回的信息为：%@",message);
            CCLog(@"message 长度为%d",[message length]);
            CCLog(@"成功登陆后返回的数据：%@",dic);
            if ([message length]==0) {
                NSLog(@"成功登陆后返回的数据：%@",data);
                //执行保存用户信息
                IsLoginInSingle *single = [IsLoginInSingle shareLoginSingle];
                single.isLogin = YES;
                single.token = [dic objectForKey:KEY_Account_token];
                single.userAccount.memberId = [dic objectForKey:KEY_Account_MemberId];
                single.userAccount.email  =[dic objectForKey:KEY_Account_Email];
                single.userAccount.mobile = [dic objectForKey:KEY_Account_Mobile];
                single.userAccount.code = [dic objectForKey:KEY_Account_Code];
                NSUserDefaults *defaultUser = [NSUserDefaults standardUserDefaults];
                //用户登录状态
                [defaultUser setBool:YES forKey:KEY_Default_IsUserLogin];
                //用户ID
                [defaultUser setObject:single.userAccount.memberId forKey:KEY_Default_MemberId];
                //                用户token
                [defaultUser setObject:single.token forKey:KEY_Default_Token];
                //                用户手机号码
                [defaultUser setObject:single.userAccount.mobile forKey:KEY_Default_UserMobile];
                [defaultUser setObject:single.userAccount.code forKey:KEY_Default_Code];
                [defaultUser synchronize];
                CCLog(@"用户的id为：%@",Default_UserMemberId_Value);
                CCLog(@"用户code为%@",single.userAccount.code);
                CCLog(@"用户手机号码为：%@", [defaultUser objectForKey:KEY_Default_UserMobile]);
                if (delegate&&[delegate respondsToSelector:@selector(requestDidFinishedWithRightMessage:)]) {
                    CCLog(@"用户代理不为空");
                    [delegate requestDidFinishedWithRightMessage:messageDic];
                    
                }
            } else{
                //message 长度不为0 有错误信息
                //                [messageDic setObject:message forKey:KEY_message];
                [delegate requestDidFinishedWithFalseMessage:messageDic];
            }
        } else{
            NSLog(@"解析有错误");
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            return ;
        }
    }];
    
    [formRequst setFailedBlock:^{
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        [delegate requestDidFailed:messageDic];
        CCLog(@"网络访问失败");
    }];
    
    [formRequst startAsynchronous];
    
    //    [messageDic autorelease];
    return true;
}


#pragma mark -
#pragma mark 查看账户信息 正确
//查看账户信息

+ (BOOL) getAccountInfo:(NSDictionary *) bodyDic delegate:(id<ServiceDelegate>) delegate{
    
    CCLog(@"function %s line=%d",__FUNCTION__,__LINE__);
    
    NSString *memberId = [bodyDic objectForKey:KEY_Account_MemberId];
    
    //    NSString *memberId =@"693da08649ac4a7a836fa14c93e70abb";
    
    
    NSString *token = Default_Token_Value;
    
    
    //    NSString *token = @"D9CA3670BECA2F720F03BF94BC85CFA5";
    
    CCLog(@"查询用户信息 memberId = %@",memberId);
    
    CCLog(@"查询用户信息 token =%@",token);
    
    NSLog(@"硬件id %@",HWID_VALUE);
    
    
    NSString *signTmp = [NSString stringWithFormat:@"%@%@%@",memberId,SOURCE_VALUE,token];
    
    NSLog(@"signTmp = %@",signTmp);
    
    //    NSString *realUrl = [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@",Account_SearchInfo_URL,KEY_Account_MemberId,memberId,KEY_SIGN,GET_SIGN(signTmp),PUBLIC_Parameter];
    
    
    
    NSString *sign =GET_SIGN(signTmp);
    
    NSLog(@"查询账号详细信息：加密后的为：%@",sign);
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:Account_SearchInfo_URL]];
    
    
    
    [formRequst setPostValue:memberId forKey:KEY_Account_MemberId];
    [formRequst setPostValue:SOURCE_VALUE forKey:KEY_source];
    [formRequst setPostValue:HWID_VALUE forKey:KEY_hwId];
    [formRequst setPostValue:sign forKey:KEY_SIGN];
    
    
    
    [formRequst setPostValue:EDITION_VALUE forKey:KEY_edition];
    //    [formRequst setPostValue:SERVICECode_VALUE forKey:KEY_serviceCode];
    [formRequst setRequestMethod:@"POST"];
    
    
    
    [formRequst setCompletionBlock:^{
        
        NSString *data = [formRequst responseString];
        //        NSString *data =@"";
        
        CCLog(@"网络返回的数据为 这是什么情况啊：%@",data);
        
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            NSLog(@"服务器返回的信息为：%@",message);
            
            if ([message length]==0) {
                
                // NSLog(@"成功登陆后返回的数据：%@",data);
                
                
                
                
                
                
                
                
                
                
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
        
        
    }];
    
    [formRequst setFailedBlock:^{
        
        
        
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        
        
    }];
    
    
    
    
    [formRequst startAsynchronous];
    
    return true;
    
}

#pragma mark -
#pragma mark 编辑账号信息
//编辑账号
+ (BOOL) editAccountInfo:(NSDictionary *) bodyDic delegate:(id<ServiceDelegate>) delegate{
    
    
    
    return true;
    
}





#pragma mark -
#pragma mark 常用乘机人查询 现在是mock 接口
//常用乘机人查询

+(BOOL) getCommonPassenger:(NSDictionary *) bodyDic delegate:(id<ServiceDelegate>) delegate{
    
    
    
    CCLog(@"function %s line=%d",__FUNCTION__,__LINE__);
    
    NSString *memberId = [bodyDic objectForKey:KEY_Account_MemberId];
    
    //    NSString *memberId =@"30f3e771eab046de830fb31ca3eb61dd";
    
    
    NSString *token = Default_Token_Value;
    //    NSString *token = @"14A3C4E3D8DE0FBEA75E00013E4A0D33";
    
    CCLog(@"查询常用联系人信息 memberId = %@",memberId);
    
    CCLog(@"查询常用联系人信息 token =%@",token);
    
    
    
    NSString *signTmp = [NSString stringWithFormat:@"%@%@%@",memberId,SOURCE_VALUE,token];
    
    
    
    
    //    NSString *realUrl = [NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@",Account_SearchInfo_URL,KEY_Account_MemberId,memberId,KEY_SIGN,GET_SIGN(signTmp),PUBLIC_Parameter];
    
    
    
    
    NSString *sign =GET_SIGN(signTmp);
    
    NSLog(@"查询详细信息：加密后的为：%@",sign);
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:SearchCommomPassenger_URL]];
    
    
    
    [formRequst setPostValue:memberId forKey:KEY_Account_MemberId];
    [formRequst setPostValue:SOURCE_VALUE forKey:KEY_source];
    
    [formRequst setPostValue:sign forKey:KEY_SIGN];
    [formRequst setPostValue:SERVICECode_VALUE forKey:KEY_serviceCode];
    [formRequst setPostValue:HWID_VALUE forKey:KEY_hwId];
    
    
    [formRequst setPostValue:EDITION_VALUE forKey:KEY_edition];
    
    [formRequst setRequestMethod:@"POST"];
    
    
    
    [formRequst setCompletionBlock:^{
        
        
        //网络返回的正确信息
        NSString *data = [formRequst responseString];
        
        //     NSString *data =@"{\"result\":{\"resultCode\":\"\",\"message\":\"\"},\"passenger\":[{\"name\":\"李明\",\"type\":\"\",\"certType\":\"\",\"certNo\":\"\",\"id\":\"\"},{\"name\":\"张三\",\"type\":\"\",\"certType\":\"\",\"certNo\":\"\",\"id\":\"\"}]}";
        
        
        CCLog(@"网络返回的数据为 这是什么情况啊：%@",data);
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            NSLog(@"服务器返回的信息为：%@",message);
            
            CCLog(@"信息长度为：%d",[message length]);
            
            if ([message length]==0) {
                
                // NSLog(@"成功登陆后返回的数据：%@",data);
                
                
                NSArray *passengerArray = [dic objectForKey:@"passenger"];
                
                CCLog(@"查询到的常用联系人为%d",[passengerArray count]);
                
                
                CommontContactSingle *passSingle =[ CommontContactSingle shareCommonContact];
                
                
                [passSingle.passengerArray removeAllObjects];
                
                for (NSDictionary *resultDic in passengerArray) {
                    
                    NSString *name = [resultDic objectForKey:KEY_Passenger_Name];
                    NSString *type = [resultDic objectForKey:KEY_Passenger_Type];
                    NSString *certType =[resultDic objectForKey:KEY_Passenger_CertType];
                    NSString *certNo = [resultDic objectForKey:KEY_Passenger_CertNo];
                    NSString *passengerId = [resultDic objectForKey:KEY_Passenger_Id];
                    
                    
                    CCLog(@"联系人Name = %@",name);
                    CommonContact *passenger = [[CommonContact alloc] initWithName:name type:type certType:certType certNo:certNo contactId:passengerId];
                    
                    
                    [passSingle.passengerArray addObject:passenger];
                    [passenger release];
                    
                    
                    
                    
                }
                
                
                
                
                
                
                
                CCLog(@"查询到的联系人数量为%d",[passSingle.passengerArray count]);
                
                
                
                
                
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
        
        
    }];
    
    [formRequst setFailedBlock:^{
        
        
        
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        
        
    }];
    
    
    
    
    [formRequst startAsynchronous];
    
    return true;
    
    
    
}








#pragma mark -
#pragma mark 增加常用联系人
//增加常用联系人
+ (BOOL) addCommonPassenger:(NSDictionary *) bodyDic delegate:(id<ServiceDelegate>) delegate{
    
    
    NSString *name = [bodyDic objectForKey:KEY_Passenger_Name];
    NSString *type = [bodyDic objectForKey:KEY_Passenger_Type];
    NSString *certType = [bodyDic objectForKey:KEY_Passenger_CertType];
    NSString *certNo = [bodyDic objectForKey:KEY_Passenger_CertNo];
    
    
    
    
    CCLog(@"增加常用联系人的姓名：%@ 类型：%@ 证件类型：%@ 证件号码：%@",name,type,certType,certNo);
    
    NSString *memberId = Default_UserMemberId_Value;
    NSString *memberCode = Default_UserMemberCode_Value;
    CCLog(@"memberId = %@ memberCode = %@",memberId,memberCode);
    NSString *personNum = @"1";
    
    
    //    NSString *publicParm = PUBLIC_Parameter;
    NSString *token = Default_Token_Value;
    NSString *signTmp = [NSString stringWithFormat:@"%@%@%@",memberId,SOURCE_VALUE,token];
    
    NSString *sign =GET_SIGN(signTmp);
    
    //    NSString *urlString = [NSString stringWithFormat:@"?mobile=%@&type=%@&%@",mobileNumber,KEY_GETCode_ForRegist,publicParm];
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:AddCommomPassenger_URL]];
    
    
    [formRequst setPostValue:memberId forKey:KEY_Account_MemberId];
    [formRequst setPostValue:memberCode forKey:@"memberCode"];
    [formRequst setPostValue:SOURCE_VALUE forKey:KEY_source];
    [formRequst setPostValue:SERVICECode_VALUE forKey:KEY_serviceCode];
    
    [formRequst setPostValue:HWID_VALUE forKey:KEY_hwId];
    
    [formRequst setPostValue:personNum forKey:@"personNum"];
    
    [formRequst setPostValue:EDITION_VALUE forKey:KEY_edition];
    [formRequst setPostValue:sign forKey:KEY_SIGN];
    
    [formRequst setPostValue:name forKey:@"memberPassengerVoList[0].name"];
    [formRequst setPostValue:type forKey:@"memberPassengerVoList[0].type"];
    [formRequst setPostValue:certType forKey:@"memberPassengerVoList[0].certType"];
    [formRequst setPostValue:certNo forKey:@"memberPassengerVoList[0].certNo"];
    
    
    
    [formRequst setRequestMethod:@"POST"];
    
    
    [formRequst setCompletionBlock:^{
        
        NSString *data = [formRequst responseString];
        
        CCLog(@"网络返回的数据为：%@",data);
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            NSLog(@"服务器返回的信息为：%@",message);
            
            if ([message length]==0) {
                
                // NSLog(@"成功登陆后返回的数据：%@",data);
                
                
                
                
                
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
        
        
    }];
    
    [formRequst setFailedBlock:^{
        
        
        
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        
        
    }];
    
    
    
    
    [formRequst startAsynchronous];
    
    
    return true;
    
}


#pragma mark -
#pragma mark 编辑常用联系人

//编辑常用联系人 新方法

+ (BOOL) editCommonPassengerWithPassengerData:(CommonContact *) passengerData  andDelegate:(id<ServiceDelegate>)delegate{
    
    
    
    
    
    NSString *name = passengerData.name;
    NSString *type = passengerData.type;
    NSString *certType = passengerData.certType;
    NSString *certNo = passengerData.certNo;
    
    NSString *ContactId =passengerData.contactId;
    
    
    CCLog(@"修改常用联系人的姓名：%@ 类型：%@ 证件类型：%@ 证件号码：%@ 乘机人ID:%@",name,type,certType,certNo,ContactId);
    
    
    
    NSString *memberId = Default_UserMemberId_Value;
    NSString *memberCode = Default_UserMemberCode_Value;
    CCLog(@"memberId = %@ memberCode = %@",memberId,memberCode);
    
    NSString *personNum = @"1";
    
    
    //    NSString *publicParm = PUBLIC_Parameter;
    NSString *token = Default_Token_Value;
    
    NSString *signTmp = [NSString stringWithFormat:@"%@%@%@",memberId,SOURCE_VALUE,token];
    
    NSString *sign =GET_SIGN(signTmp);
    
    //    NSString *urlString = [NSString stringWithFormat:@"?mobile=%@&type=%@&%@",mobileNumber,KEY_GETCode_ForRegist,publicParm];
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:UpdateCommomPassenger_URL]];
    
    
    [formRequst setPostValue:memberId forKey:KEY_Account_MemberId];
    [formRequst setPostValue:memberCode forKey:@"memberCode"];
    [formRequst setPostValue:SOURCE_VALUE forKey:KEY_source];
    [formRequst setPostValue:SERVICECode_VALUE forKey:KEY_serviceCode];
    
    [formRequst setPostValue:HWID_VALUE forKey:KEY_hwId];
    
    [formRequst setPostValue:personNum forKey:@"personNum"];
    
    [formRequst setPostValue:EDITION_VALUE forKey:KEY_edition];
    [formRequst setPostValue:sign forKey:KEY_SIGN];
    
    [formRequst setPostValue:ContactId forKey:@"passengerId"];

    [formRequst setPostValue:name forKey:@"memberPassengerVoList[0].name"];
    [formRequst setPostValue:type forKey:@"memberPassengerVoList[0].type"];
    [formRequst setPostValue:certType forKey:@"memberPassengerVoList[0].certType"];
    [formRequst setPostValue:certNo forKey:@"memberPassengerVoList[0].certNo"];
    
    
    
    [formRequst setRequestMethod:@"POST"];
    
    
    [formRequst setCompletionBlock:^{
        
        NSString *data = [formRequst responseString];
        
        CCLog(@"网络返回的数据为：%@",data);
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            NSLog(@"服务器返回的信息为：%@",message);
            
            if ([message length]==0) {
                
                // NSLog(@"成功登陆后返回的数据：%@",data);
                
                
                
                
                
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
        
        
    }];
    
    [formRequst setFailedBlock:^{
        
        
        
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        
        
    }];
    
    
    
    
    [formRequst startAsynchronous];
    
    
    
    return true;
}



//编辑常用联系人
+ (BOOL) editCommonPassenger:(NSDictionary *) bodyDic delegate:(id<ServiceDelegate>) delegate{
    
    
    return true;
}





#pragma mark -
#pragma mark 删除常用联系人
//删除常用联系人

+ (BOOL) deleteCommonPassengerWithPassengerId:(NSString *) passengerId userDic:(NSDictionary *)passengerInfo andDelegate:(id<ServiceDelegate>) delegate{
    
    CCLog(@"function %s line=%d",__FUNCTION__,__LINE__);
    //假数据
    NSString *thisPassageId = @"07cbc7f1efe34f098a7d6fc0731f5ca5";
    
    //    真实的数据
    //    NSString *thisPassageId = passengerId;
    
    CCLog(@"待删除的乘机人ID为：%@",thisPassageId);
    
    
    
    //    NSString *publicParm = PUBLIC_Parameter;
    //    NSString *urlString = [NSString stringWithFormat:@"?mobile=%@&type=%@&%@",mobileNumber,KEY_GETCode_ForRegist,publicParm];
    
    
    NSString *memberId = Default_UserMemberId_Value;
    NSString *memberCode = Default_UserMemberCode_Value;
    
    
    NSString *personNum = @"1";
    CCLog(@"memberId = %@ memberCode = %@",memberId,memberCode);
    
    
    
    NSString *token = Default_Token_Value;
    NSString *signTmp = [NSString stringWithFormat:@"%@%@%@",memberId,SOURCE_VALUE,token];
    
    NSString *sign =GET_SIGN(signTmp);
    
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:DeleteCommomPassenger_URL]];
    
    
    
    [formRequst setPostValue:memberId forKey:KEY_Account_MemberId];
    
    //    [formRequst setPostValue:memberCode forKey:@"memberCode"];
    
    [formRequst setPostValue:SOURCE_VALUE forKey:KEY_source];
    
    [formRequst setPostValue:SERVICECode_VALUE forKey:KEY_serviceCode];
    [formRequst setPostValue:HWID_VALUE forKey:KEY_hwId];
    
    [formRequst setPostValue:personNum forKey:@"personNum"];
    [formRequst setPostValue:EDITION_VALUE forKey:KEY_edition];
    
    [formRequst setPostValue:sign forKey:KEY_SIGN];
    
    [formRequst setPostValue:EDITION_VALUE forKey:KEY_edition];
    
    [formRequst setPostValue:thisPassageId forKey:@"memberPassengerVoList[0].id"];
    
    
    
    [formRequst setRequestMethod:@"POST"];
    
    
    
    [formRequst setCompletionBlock:^{
        
        NSString *data = [formRequst responseString];
        
        CCLog(@"网络返回的数据为：%@",data);
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            NSLog(@"服务器返回的信息为：%@",message);
            
            if ([message length]==0) {
                
                //                NSLog(@"成功登陆后返回的数据：%@",data);
                
                
                
                
                
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
        
        
    }];
    
    [formRequst setFailedBlock:^{
        
        
        
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        
        
    }];
    
    
    
    
    [formRequst startAsynchronous];
    
    
    
    return true;
}

#pragma mark -
#pragma mark 获取验证码
//获取验证码
+ (BOOL) getSecretCode:(NSDictionary *) bodyDic andDelegat:(id<ServiceDelegate>) delegate{
    
    CCLog(@"function %s line=%d",__FUNCTION__,__LINE__);
    
    
    NSString *publicParm = PUBLIC_Parameter;
    
    NSString *mobileNumber = [bodyDic objectForKey:KEY_Account_Mobile];
    NSString *type = [bodyDic objectForKey:KEY_GETCode_RequestType];
    
    
    NSLog(@"用户请求的类型为：%@",type);
    NSLog(@"用户输入的手机号码为：%@",mobileNumber);
    
    NSString *urlString = [NSString stringWithFormat:@"%@?mobile=%@&type=%@&%@",URL_GetSecretCodeUrl,mobileNumber,type,publicParm];
    
    
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    [messageDic setObject:GET_SecretCode_RequestType_Value forKey:KEY_Request_Type];
    
    
    __block NSString *message = nil;
    
    
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    
    [formRequst setCompletionBlock:^{
        
        NSString *data = [formRequst responseString];
        
        CCLog(@"网络返回的数据为：%@",data);
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            NSLog(@"服务器返回的信息为：%@",message);
            
            if ([message length]==0) {
                
                CCLog(@"发送手机验证码后，服务器的响应是：%@",data);
                
                
                
                
                
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
        
        
    }];
    
    [formRequst setFailedBlock:^{
        
        CCLog(@"失败");
        
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        
        
    }];
    
    [formRequst startAsynchronous];
    return  true;
}

#pragma mark -
#pragma mark 找回密码 获取验证码
//找回密码
+ (BOOL) findPasswd_getSecrectCode:(NSString *) mobile andDelegate:(id<ServiceDelegate>) delegate{
    
    
    
//    NSString *publicParm = PUBLIC_Parameter;
    NSString *mobileNumber = mobile;
    
    CCLog(@"用户请求找回密码操作 输入的手机号为：%@",mobile);
    //请求的参数 get方式
    
    NSString *urlString = [NSString stringWithFormat:@"%@?account=%@&source=%@&key=%@",FindPasswd_URL,mobileNumber,SOURCE_VALUE,FindPasswd_Key_Value];
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    
    [formRequst setCompletionBlock:^{
        
        NSString *data = [formRequst responseString];
        
        CCLog(@"网络返回的数据为：%@",data);
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            NSLog(@"服务器返回的信息为：%@",message);
            
            if ([message length]==0) {
                
                // NSLog(@"成功登陆后返回的数据：%@",data);
                
                
                
                
                
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
        
        
    }];
    
    [formRequst setFailedBlock:^{
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        
        
    }];
    
      [formRequst startAsynchronous];
     
    return true;
}



+ (BOOL) findPasswd_VerCodeIsRight:(NSString *) mobile code:(NSString *) code andDelegate:(id<ServiceDelegate>) delegate{
    
    //    NSString *publicParm = PUBLIC_Parameter;
    NSString *mobileNumber = mobile;
    
    CCLog(@"用户请求找回密码操作 输入的手机号为：%@",mobile);
    //请求的参数 get方式
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@?phone=%@&source=%@&code=%@&key=%@",Ver_CodeIsRight_URL,mobileNumber,SOURCE_VALUE,code,FindPasswd_Key_Value];
    
    
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    
    
    [messageDic setObject:VER_CodeISRight_RequestType_Value  forKey:KEY_Request_Type];
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    
    [formRequst setCompletionBlock:^{
        
        NSString *data = [formRequst responseString];
        
        CCLog(@"网络返回的数据为：%@",data);
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            NSLog(@"服务器返回的信息为：%@",message);
            
            if ([message length]==0) {
                
                
                // NSLog(@"成功登陆后返回的数据：%@",data);
                
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
    }];
    
    [formRequst setFailedBlock:^{
        
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        
        
    }];
    
    [formRequst startAsynchronous];
    
    return true;
}


+ (BOOL) findPassWd_ResetPassWdWithNewPwd:(NSString *) newPwd mobile:(NSString *) mobile code:(NSString *) code andDelegate:(id<ServiceDelegate>) delegate{
    
    
    //    NSString *publicParm = PUBLIC_Parameter;
    NSString *mobileNumber = mobile;
    
    CCLog(@"用户请求找回密码操作 输入的手机号为：%@",mobile);
    //请求的参数 get方式
    
    //    http://210.51.165.186:9180/web/phone/member/get_password.jsp?newpassword=123456&confirmpassword=123456&phone=18701081000&code=002345&source=xxxxxxx&key=xxxxx
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@?newpassword=%@&confirmpassword=%@&phone=%@&code=%@&source=%@&key=%@",FindPwd_ResetPwd_URL,newPwd,newPwd,mobileNumber,code,SOURCE_VALUE,FindPasswd_Key_Value];
    
    
    
    __block NSMutableDictionary *messageDic = [[NSMutableDictionary alloc] init];
    
    __block NSString *message = nil;
    
    
    
    //    [messageDic setObject:VER_CodeISRight_RequestType_Value  forKey:KEY_Request_Type];
    __block ASIFormDataRequest *formRequst = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    
    [formRequst setCompletionBlock:^{
        
        NSString *data = [formRequst responseString];
        
        CCLog(@"网络返回的数据为：%@",data);
        
        NSError *error = nil;
        
        
        NSDictionary *dic = [data objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode error:&error];
        
        if (!error) {
            
            CCLog(@"json解析格式正确");
            
            message = [[dic objectForKey:KEY_result] objectForKey:KEY_message];
            NSLog(@"服务器返回的信息为：%@",message);
            
            if ([message length]==0) {
                
                
                // NSLog(@"成功登陆后返回的数据：%@",data);
                [delegate requestDidFinishedWithRightMessage:messageDic];
                
            } else{
                
                //message 长度不为0 有错误信息
                [messageDic setObject:message forKey:KEY_message];
                
                
                [delegate requestDidFinishedWithFalseMessage:messageDic];
                
            }
            
            
            
        } else{
            NSLog(@"解析有错误");
            
            
            [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
            [delegate requestDidFinishedWithFalseMessage:messageDic];
            
            return ;
            
        }
        
    }];
    
    [formRequst setFailedBlock:^{
        
        
        [messageDic setObject:WRONG_Message_NetWork forKey:KEY_message];
        
        [delegate requestDidFailed:messageDic];
        
        
        
    }];
    [formRequst startAsynchronous];
    
    
    return true;
}


//用心愿旅行卡充值 正在做
#pragma mark -
#pragma mark 用心愿旅行卡充值 正在做
+ (BOOL) makeAccountFullWithRechargeCardNo:(NSString *) cardNo cardPasswd:(NSString *) pwd andDelegate:(id<ServiceDelegate>) delegate{
    
    
    
    
    
    return true;
}
@end