//
//  CrashHandler.m
//  Meniny
//
//  Created by Meniny on 16/2/23.
//  Copyright © 2016年 Meniny. All rights reserved.
//
//  Powerd by Meniny.
//  See http://www.meniny.cn/ for more informations.
//

#import "MXCrashHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

//#define atCANCEL NSLocalizedString(@"Cancel", nil)
//#define atTERMINATE NSLocalizedString(@"Terminate", nil)
//#define atIGNORE NSLocalizedString(@"Ignore", nil)
//#define atFEEDBACK NSLocalizedString(@"Feedback", nil)

NSString * const CrashHandlerSignalExceptionName =      @"MXCrashHandlerSignalExceptionName";
NSString * const CrashHandlerSignalKey =                @"MXCrashHandlerSignalKey";
NSString * const CrashHandlerAddressesKey =             @"MXCrashHandlerAddressesKey";

NSString * const CrashHandlerAssertLanguageKey =        @"MXCrashHandlerAssertLanguageKey";

NSString * const CrashHandlerAssertOCMethodKey =        @"MXCrashHandlerAssertOCMethodKey";
NSString * const CrashHandlerAssertOCFileKey =          @"MXCrashHandlerAssertOCFileKey";
NSString * const CrashHandlerAssertOCObjectKey =        @"MXCrashHandlerAssertOCObjectKey";
NSString * const CrashHandlerAssertOCLineKey =          @"MXCrashHandlerAssertOCLineKey";

NSString * const CrashHandlerAssertCFunctionKey =       @"MXCrashHandlerAssertCFunctionKey";
NSString * const CrashHandlerAssertCFileKey =           @"MXCrashHandlerAssertCFileKey";
NSString * const CrashHandlerAssertCLineKey =           @"MXCrashHandlerAssertCLineKey";

/**
 * @brief 语言类型
 */
typedef NS_OPTIONS(NSInteger, MXAssertLanguageType) {
    /**
     * @brief OC
     */
    MXAssertLanguageTypeObjectiveC = 1 << 0,
    /**
     * @brief C
     */
    MXAssertLanguageTypeC = 1 << 1
};

volatile int32_t UncaughtExceptionCount = 0;
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger CrashHandlerSkipAddressCount = 4;
const NSInteger CrashHandlerReportAddressCount = 5;

void HandleException(NSException *exception);
void SignalHandler(int signal);

@interface MXCrashHandler ()

@end

@implementation MXCrashHandler

+ (void)install {
    [MXCrashHandler installWithThread:[NSThread currentThread]];
}

+ (void)installWithThread:(NSThread *)thread {
    if (thread == nil) {
        thread = [NSThread currentThread];
    }
    [[thread threadDictionary] setValue:[MXAssertHandler sharedHandler] forKey:NSAssertionHandlerKey];
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

+ (instancetype)sharedHandler {
    static MXCrashHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MXCrashHandler new];
    });
    return instance;
}

/**
 * @method
 * @brief 已经废弃
 */
- (instancetype)init {
//    NSAssert(@"User + (instancetype)sharedHandler or other class method", nil);
    self = [super init];
    return self;
}

/**
 * @method
 * @brief 反向追踪
 */
+ (NSArray *)backtrace {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = CrashHandlerSkipAddressCount;
         i < CrashHandlerSkipAddressCount + CrashHandlerReportAddressCount;
         i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

//- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
//    NSString *title = [anAlertView buttonTitleAtIndex:anIndex];
//    if ([title isEqualToString:atTERMINATE]) {
//        dismissed = YES;
//    }
//}

- (void)validateAndSaveCriticalApplicationData {
    
}

/**
 * @method
 * @brief 调用代理，处理异常
 */
- (void)handleException:(NSException *)exception {
    [self validateAndSaveCriticalApplicationData];
    
    if (self.delegate != nil &&
        [self.delegate respondsToSelector:@selector(crashHandler:didReceiveException:)]) {
        [self.delegate crashHandler:self didReceiveException:exception];
    }
//    else {
//        NSArray *symbols = [exception callStackSymbols];
//        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@\n%@%@", nil), [exception reason], (symbols.count ? [[symbols componentsJoinedByString:@"\n"] stringByAppendingString:@"\n"] : @""), [[exception userInfo] objectForKey:CrashHandlerAddressesKey]];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", nil)
//                                                        message:message
//                                                       delegate:self
//                                              cancelButtonTitle:atIGNORE
//                                              otherButtonTitles:atTERMINATE, (self.delegate != nil) ? atFEEDBACK : nil, nil];
//        [alert show];
//    }
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:CrashHandlerSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:CrashHandlerSignalKey] intValue]);
    } else {
        [exception raise];
    }
}

@end

#pragma mark - MXAssertHandler

@interface MXAssertHandler ()

@end

@implementation MXAssertHandler

+ (instancetype)sharedHandler {
    static MXAssertHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MXAssertHandler new];
    });
    return instance;
}

// 处理Objective-C的断言
- (void)handleFailureInMethod:(SEL)selector
                       object:(id)object
                         file:(NSString *)fileName
                   lineNumber:(NSInteger)line
                  description:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [self handleFailureInLanguage:MXAssertLanguageTypeObjectiveC
                         OCMethod:selector
                        CFunction:nil
                         OCObject:object
                             file:fileName
                       lineNumber:line
                      description:format
                           valist:args];
    va_end(args);
}

// 处理C的断言
- (void)handleFailureInFunction:(NSString *)functionName
                           file:(NSString *)fileName
                     lineNumber:(NSInteger)line
                    description:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    [self handleFailureInLanguage:MXAssertLanguageTypeC
                         OCMethod:NULL
                        CFunction:functionName
                         OCObject:nil
                             file:fileName
                       lineNumber:line
                      description:format
                           valist:args];
    va_end(args);
}

- (void)handleFailureInLanguage:(MXAssertLanguageType)language
                       OCMethod:(SEL)selector
                      CFunction:(NSString *)functionName
                       OCObject:(id)object
                           file:(NSString *)fileName
                     lineNumber:(NSInteger)line
                    description:(NSString *)format
                         valist:(va_list)valist {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    [userInfo setObject:NSStringFromAnyRawValue(MXAssertLanguageTypeObjectiveC) forKey:CrashHandlerAssertLanguageKey];
    if (language == MXAssertLanguageTypeObjectiveC) {
        [userInfo setObject:NSStringFromSelector(selector) forKey:CrashHandlerAssertOCMethodKey];
        [userInfo setObject:[NSString stringWithFormat:@"%@", object] forKey:CrashHandlerAssertOCObjectKey];
        [userInfo setObject:[NSString stringWithFormat:@"%@", fileName] forKey:CrashHandlerAssertOCFileKey];
        [userInfo setObject:[NSString stringWithFormat:@"%zd", line] forKey:CrashHandlerAssertOCLineKey];
    } else {
        [userInfo setObject:NSStringFromSelector(selector) forKey:CrashHandlerAssertCFunctionKey];
        [userInfo setObject:[NSString stringWithFormat:@"%@", fileName] forKey:CrashHandlerAssertCFileKey];
        [userInfo setObject:[NSString stringWithFormat:@"%zd", line] forKey:CrashHandlerAssertCLineKey];
    }
    
    NSString *string = [[NSString alloc] initWithFormat:format arguments:valist];
    
    if (string == nil) {
        string = @"NSAssert";
    }
    
    NSException *exception = [NSException exceptionWithName:@"NSAssert" reason:string userInfo:userInfo];
    [[MXCrashHandler sharedHandler] performSelectorOnMainThread:@selector(handleException:) withObject:exception waitUntilDone:YES];
}

@end

#pragma mark - C

/**
 * @method
 * @brief 处理异常
 *
 * @param exception 异常信息
 */
void HandleException(NSException *exception) {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSArray *callStack = [MXCrashHandler backtrace];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:callStack forKey:CrashHandlerAddressesKey];
    
    [[MXCrashHandler sharedHandler] performSelectorOnMainThread:@selector(handleException:) withObject:[NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo] waitUntilDone:YES];
}

/**
 * @method
 * @brief 信号处理
 *
 * @param signal 信号值
 */
void SignalHandler(int signal) {
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:CrashHandlerSignalKey];
    
    NSArray *callStack = [MXCrashHandler backtrace];
    [userInfo setObject:callStack forKey:CrashHandlerAddressesKey];
    
    [[MXCrashHandler sharedHandler] performSelectorOnMainThread:@selector(handleException:) withObject:[NSException exceptionWithName:CrashHandlerSignalExceptionName reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %zd was raised.", nil), signal] userInfo:@{CrashHandlerSignalKey: @(signal)}] waitUntilDone:YES];
}
