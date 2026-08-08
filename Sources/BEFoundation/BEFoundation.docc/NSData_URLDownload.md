# NSData+URLDownload

NSData category for convenient asynchronous downloading from URLs.

```objc
#import <BEFoundation/NSData+URLDownload.h>
```

## Overview

This category provides class methods for initiating asynchronous network data and file downloads using `NSURLSession`. All methods return a `BEDataDownloadHandler` for controlling the download process.

## Usage

### Data Download

```objc
// Download as NSData
[NSData dataDownloadWithContentsOfURL:webURL
                          completion:^(NSData *data, NSURLResponse *response) {
    NSLog(@"Downloaded %lu bytes", (unsigned long)data.length);
} error:^(NSError *error, BOOL auxiliary) {
    NSLog(@"Error: %@", error);
} progress:^(int64_t received, int64_t total) {
    NSLog(@"Progress: %lld / %lld", received, total);
}];
```

### File Download

```objc
// Download to temporary file
[NSData downloadFileWithURL:webURL
                  completion:^(NSURL *tempFile, NSURLResponse *response) {
    NSLog(@"Downloaded to: %@", tempFile.path);
    // Move or process the file
} error:^(NSError *error, BOOL auxiliary) {
    NSLog(@"Error: %@", error);
} progress:^(int64_t received, int64_t total) {
    float progress = (float)received / (float)total;
    NSLog(@"Progress: %.1f%%", progress * 100);
}];
```

### Using the Download Handler

```objc
BEDataDownloadHandler *handler = [NSData dataDownloadWithContentsOfURL:webURL
                                                     completion:^(NSData *data, NSURLResponse *response) {
    // Handle completion
} error:^(NSError *error, BOOL auxiliary) {
    // Handle error
}];

// Control the download
[handler pause];    // Pause
[handler resume];  // Resume
[handler cancel];  // Cancel

// Check status
BOOL isComplete = handler.isComplete;
BOOL isDataTask = handler.isDataTask;
```

### Configuring the Session

By default, downloads use `[NSURLSessionConfiguration defaultSessionConfiguration]`. To control timeouts, headers, caching policy, or protocol classes, supply your own configuration — either per download or process-wide.

For a single download, set `sessionConfiguration` on a handler and pass it to one of the `…handler:` methods:

```objc
NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
config.timeoutIntervalForRequest = 30;

BEDataDownloadHandler *handler = [[BEDataDownloadHandler alloc] init];
handler.sessionConfiguration = config;
handler.dataCompletionBlock = ^(NSData *data, NSURLResponse *response) {
    // Handle completion
};
[NSData dataDownloadWithContentsOfURL:webURL handler:handler];
```

To apply a configuration to every download — including the convenience methods that build their handler internally — set the process-wide default once, for example at app launch:

```objc
NSData.defaultSessionConfiguration = config;
```

The configuration used for a given download resolves in order: the handler's `sessionConfiguration`, then `NSData.defaultSessionConfiguration`, then `[NSURLSessionConfiguration defaultSessionConfiguration]`.

### Delegate-Based Downloads

```objc
@interface MyClass () <BEDataDownloadDelegate>
@end

@implementation MyClass

- (void)downloadWithDelegate {
    [NSData dataDownloadWithContentsOfURL:webURL delegate:self];
}

- (void)downloadReceived:(int64_t)totalBytesReceived totalBytes:(int64_t)totalBytesExpected {
    float progress = (float)totalBytesReceived / (float)totalBytesExpected;
    NSLog(@"Progress: %.1f%%", progress * 100);
}

- (void)downloadDataComplete:(NSData *)data urlResponse:(NSURLResponse *)response {
    NSLog(@"Download complete");
}

- (void)downloadError:(NSError *)error auxiliary:(BOOL)auxiliary {
    NSLog(@"Error: %@", error);
}

@end
```

## See Also

- [BEWebData](doc:BEWebData)
- [NSURL+Data](doc:NSURL_Data)
