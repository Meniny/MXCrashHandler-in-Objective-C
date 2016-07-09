//
//  CrashHandler.h
//  Meniny
//
//  Created by Meniny on 16/2/23.
//  Copyright © 2016年 Meniny. All rights reserved.
//
//  Powerd by Meniny.
//  See http://www.meniny.cn/ for more informations.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MXCrashHandler;
@protocol CrashHandlerDelegate <NSObject>
@required
//- (void)crashHandler:(CrashHandler *)handler sendEmail:(NSString *)body;
/**
 * @method
 * @brief 代理，拦截到异常和信号都代理方法中处理
 */
- (void)crashHandler:(MXCrashHandler *)handler didReceiveException:(NSException *)exception;
@end

@interface MXCrashHandler : NSObject <UIAlertViewDelegate> {
    BOOL dismissed;
}
/**
 * @property
 * @brief 代理，拦截到异常和信号都代理方法中处理
 */
@property (nonatomic, strong) id<CrashHandlerDelegate> delegate;
/**
 * @method
 * @brief 单利
 */
+ (instancetype)sharedHandler;
/**
 * @method
 * @brief 通过调用此方法来启动异常拦截
 */
+ (void)install;
+ (void)installWithThread:(NSThread *)thread;
- (instancetype)init NS_DEPRECATED_IOS(1_0,1_0, "Use + (instancetype)sharedHandler or other class methods");
@end

#pragma mark - MXAssertHandler

@interface MXAssertHandler : NSAssertionHandler
+ (instancetype)sharedHandler;
@end
