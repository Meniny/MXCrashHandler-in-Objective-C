# MXCrashHandler-in-Objective-C

`MXCrashHandler` is an easy-to-use class to handle crash on iOS.

## Installation with CocoaPods

```
pod 'MXCrashHandler'
```

## Usage

```
#import "MXCrashHandler.h"
```

```
@interface MXClass: UIViewController <MXCrashHandlerDelegate>
```

```
[MXCrashHandler install];
[MXCrashHandler setDelegate:self];
```

```
- (void)crashHandler:(MXCrashHandler *)handler didReceiveException:(NSException *)exception {
  NSLog(@"%@", exception);
}
```
