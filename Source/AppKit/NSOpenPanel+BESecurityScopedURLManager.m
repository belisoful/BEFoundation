#import <TargetConditionals.h>
#if TARGET_OS_OSX
//
//  NSOpenPanel+BESecurityScopedURLManager.m
//  BESecurityScopedURLManager
//
//  Optional AppKit convenience category implementation for NSOpenPanel integration.
//  Include this file only in projects that use macOS AppKit.
//

#import "NSOpenPanel+BESecurityScopedURLManager.h"
#import <objc/runtime.h>

// Associated object keys (defined in main implementation)
static const void * const kBEURLManagerKey = &kBEURLManagerKey;
static const void * const kBEBookmarkLifetimeKey = &kBEBookmarkLifetimeKey;

#pragma mark - NSOpenPanel Convenience Category Implementation

@implementation NSOpenPanel (BESecurityScopedURLManager)

#pragma mark - Associated Object Properties

- (BESecurityScopedURLManager *)ss_urlManager {
	return objc_getAssociatedObject(self, kBEURLManagerKey);
}

- (void)setSs_urlManager:(BESecurityScopedURLManager *)manager {
	objc_setAssociatedObject(self, kBEURLManagerKey, manager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BESecurityScopedURLBookmarkLifetime)ss_bookmarkLifetime {
	NSNumber *lifetimeNum = objc_getAssociatedObject(self, kBEBookmarkLifetimeKey);
	return lifetimeNum ? (BESecurityScopedURLBookmarkLifetime)[lifetimeNum unsignedIntegerValue]
					   : BESecurityScopedURLBookmarkLifetimeLongLived;
}

- (void)setSs_bookmarkLifetime:(BESecurityScopedURLBookmarkLifetime)lifetime {
	objc_setAssociatedObject(self, kBEBookmarkLifetimeKey, @(lifetime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Convenience Initializers

+ (instancetype)ss_openPanel {
	return [self ss_openPanelWithManager:[BESecurityScopedURLManager sharedManager]];
}

+ (instancetype)ss_openPanelWithManager:(nullable BESecurityScopedURLManager *)manager {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.ss_urlManager = manager;
	return panel;
}

#pragma mark - Completion Handler

- (NSArray<NSURL *> *)ss_addURLsToCatalog:(NSArray<NSURL *> *)urls {
	BESecurityScopedURLManager *manager = self.ss_urlManager;
	NSMutableArray<NSURL *> *failed = [NSMutableArray array];
	if (manager) {
		BESecurityScopedURLBookmarkLifetime lifetime = self.ss_bookmarkLifetime;
		for (NSURL *selectedURL in urls) {
			// Collect failures rather than discarding the BOOL result.
			if (![manager addURLToCatalog:selectedURL lifetime:lifetime]) {
				[failed addObject:selectedURL];
			}
		}
	}
	return failed;
}

- (void)ss_beginWithCompletionHandler:(nullable void (^)(NSModalResponse result))handler {
	// Avoid the temporary panel→block→panel retain cycle by capturing self weakly.
	__weak typeof(self) weakSelf = self;
	[self beginWithCompletionHandler:^(NSModalResponse result) {
		typeof(self) strongSelf = weakSelf;
		if (result == NSModalResponseOK && strongSelf) {
			NSArray<NSURL *> *failed = [strongSelf ss_addURLsToCatalog:strongSelf.URLs];
			if (failed.count > 0) {
				NSLog(@"[NSOpenPanel+BESecurityScopedURLManager] Failed to bookmark %lu of %lu selected URL(s).",
					  (unsigned long)failed.count, (unsigned long)strongSelf.URLs.count);
			}
		}

		if (handler) {
			handler(result);
		}
	}];
}

@end

#pragma mark - NSOpenPanel Helper Category Implementation

@implementation NSOpenPanel (BEPanelHelper)

- (void)ss_presetDirectoryAtURL:(nullable NSURL *)url {
	if (!url || !url.isFileURL) {
		return;
	}
	
	NSNumber *isDirectory = nil;
	NSError *error = nil;
	BOOL success = [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error];
	
	if (!success || error) {
		// Assume it's a file and use parent directory
		self.directoryURL = [url URLByDeletingLastPathComponent];
		return;
	}
	
	if ([isDirectory boolValue]) {
		self.directoryURL = url;
	} else {
		self.directoryURL = [url URLByDeletingLastPathComponent];
	}
}

@end
#endif // TARGET_OS_OSX
