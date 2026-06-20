# ``BEWebData``

NSData subclass that supports loading from data URLs with metadata preservation.

```objc
#import <BEFoundation/BEWebData.h>
```

## Overview

[BEWebData](doc:BEWebData) extends `NSData` to handle RFC 2397 data URLs, automatically decoding them and preserving metadata such as MIME type, charset, and encoding method.

## Usage

### Creating from Data URLs

```objc
// Create from a data URL
NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8;base64,SGVsbG8="];
BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];

// Access the data
NSData *data = [webData subdataWithRange:NSMakeRange(0, webData.length)];
NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
```

### Accessing Metadata

```objc
BEWebData *webData = [BEWebData dataWithContentsOfURL:dataURL];

// Check MIME type
NSString *mimeType = webData.MIMEType;  // e.g., @"text/plain"

// Check charset
NSString *charset = webData.charset;  // e.g., @"utf-8"

// Check encoding
NSStringEncoding encoding = webData.stringEncoding;  // e.g., NSUTF8StringEncoding

// Check if base64 encoded
BOOL isBase64 = webData.isBase64;
```

### Decoding Data URLs

```objc
// Static method to decode a data URL without creating an instance
NSString *mimeType = nil;
NSString *charset = nil;
NSStringEncoding encoding = 0;
BOOL isBase64 = NO;

NSData *decoded = [BEWebData decodeDataURL:dataURL
                                  MIMEType:&mimeType
                                   charset:&charset
                                  encoding:&encoding
                                    base64:&isBase64];
```

### Asynchronous Downloads

```objc
// Using the completion handler
BEWebData *webData = [[BEWebData alloc] initWithContentsOfURL:webURL
                                                       options:BEDataReadingAsynchronous
                                                         error:&error];

webData.dataTaskCompletionHandler = ^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
        NSLog(@"Download failed: %@", error);
    } else {
        NSLog(@"Download complete: %lu bytes", (unsigned long)data.length);
    }
};
```

## See Also

- [NSURL+Data](doc:NSURL_Data)
- [NSData+URLDownload](doc:NSData_URLDownload)
