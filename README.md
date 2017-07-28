# MXCrashHandler-in-Objective-C

`MXCrashHandler` is an easy-to-use class to handle crash on iOS.

## Installation with CocoaPods

```
pod 'MXCrashHandler'
```

## Usage

Add the code blew to `AppDelegate.m`:

```
#import "MXCrashHandler.h"
```

```
@interface AppDelegate () <MXCrashHandlerDelegate>
```

```
[MXCrashHandler installWithThread:[NSThread currentThread]];
[[MXCrashHandler sharedHandler] setDelegate:self];
```

```
- (void)crashHandler:(MXCrashHandler *)handler didReceiveException:(NSException *)exception {
  NSLog(@"%@", exception);
}
```
