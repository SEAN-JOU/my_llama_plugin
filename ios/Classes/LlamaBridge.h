#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef BOOL (^LlamaTokenCallback)(NSString * _Nonnull piece);

@interface LlamaBridge : NSObject
- (BOOL)loadModelAtPath:(NSString *)path
            contextSize:(int)contextSize
              gpuLayers:(int)gpuLayers
                threads:(int)threads;
- (NSString *)generateWithPrompt:(NSString *)prompt
                       maxTokens:(int)maxTokens
                     temperature:(float)temperature
                            topK:(int)topK
                            topP:(float)topP;
- (void)generateStreamWithPrompt:(NSString *)prompt
                       maxTokens:(int)maxTokens
                     temperature:(float)temperature
                            topK:(int)topK
                            topP:(float)topP
                   tokenCallback:(LlamaTokenCallback)tokenCallback;
- (void)disposeModel;
@end

NS_ASSUME_NONNULL_END
