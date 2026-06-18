#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LlamaBridge : NSObject
- (BOOL)loadModelAtPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END