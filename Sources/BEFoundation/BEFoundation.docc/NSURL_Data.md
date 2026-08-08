# NSURL+Data

Convenience methods for creating and parsing data URLs.

```objc
#import <BEFoundation/NSURL+Data.h>
```

## Overview

This category on `NSURL` simplifies working with RFC 2397 data URLs, providing methods to encode binary data or text into data URLs and decode data URLs back into their original content.

## Usage

### Creating Data URLs

```objc
// Create from NSData
NSData *imageData = [NSData dataWithContentsOfFile:@"image.png"];
NSURL *dataURL = [NSURL dataURLWithData:imageData];

// Specify MIME type
dataURL = [NSURL dataURLWithData:imageData mimeType:@"image/png"];

// Specify charset
dataURL = [NSURL dataURLWithData:textData charset:@"utf-8"];

// Control encoding (auto, base64, or percent-encoded)
dataURL = [NSURL dataURLWithData:textData isBase64:NSURLBase64Type_No];

// Full control
dataURL = [NSURL dataURLWithData:imageData 
                         mimeType:@"image/png" 
                         charset:nil 
                        isBase64:NSURLBase64Type_Yes];
```

### Encoding Types

```objc
typedef NS_ENUM(NSInteger, NSURLBase64Type) {
    NSURLBase64Type_Auto = -1,  // Automatically choose based on content type
    NSURLBase64Type_No = 0,     // Force percent-encoding
    NSURLBase64Type_Yes = 1     // Force base64 encoding
};
```

### Parsing Data URLs

```objc
NSURL *dataURL = [NSURL URLWithString:@"data:text/plain;charset=utf-8;base64,SGVsbG8="];

// Check if URL is a data URL
BOOL isData = dataURL.isDataURL;

// Get metadata
NSString *mimeType = dataURL.dataMIMEType;    // @"text/plain"
NSString *charset = dataURL.dataCharset;        // @"utf-8"
NSStringEncoding encoding = dataURL.stringEncoding;  // NSUTF8StringEncoding
BOOL isBase64 = dataURL.isBase64;              // YES

// Get decoded data
NSData *decoded = dataURL.decodedData;
NSString *decodedString = dataURL.decodedString;
```

### Charset Constants

The header defines common charset constants:

```objc
BEURL_DefaultCharset        // @"US-ASCII"
BEURL_UTF8CharSet          // @"utf-8"
BEURL_UTF16CharSet         // @"utf-16"
BEURL_UTF32CharSet         // @"utf-32"
BEURL_LatinCharSet_1       // @"iso-8859-1"
BEURL_LatinCharSet_2       // @"iso-8859-2"
BEURL_Windows1250          // @"windows-1250"
BEURL_Windows1252          // @"windows-1252"
BEURL_EUC_JP               // @"EUC-JP"
BEURL_Shift_JIS            // @"Shift_JIS"
BEURL_ISO_2022_JP          // @"ISO-2022-JP"
```

## See Also

- [BEWebData](doc:BEWebData)
- [NSData+URLDownload](doc:NSData_URLDownload)
