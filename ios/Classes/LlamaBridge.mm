#import "LlamaBridge.h"

#include "LlamaEngine.hpp"

@implementation LlamaBridge {
    LlamaEngine *_engine;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _engine = new LlamaEngine();
    }
    return self;
}

- (BOOL)loadModelAtPath:(NSString *)path
            contextSize:(int)contextSize
              gpuLayers:(int)gpuLayers
                threads:(int)threads {
    if (path.length == 0) {
        return NO;
    }

    return _engine->loadModel(
        std::string(path.UTF8String),
        contextSize,
        gpuLayers,
        threads
    );
}

- (NSString *)generateWithPrompt:(NSString *)prompt
                       maxTokens:(int)maxTokens
                     temperature:(float)temperature
                            topK:(int)topK
                            topP:(float)topP {
    if (prompt.length == 0) {
        return @"";
    }

    std::string response = _engine->generate(
        std::string(prompt.UTF8String),
        maxTokens,
        temperature,
        topK,
        topP
    );

    NSString *result = [[NSString alloc] initWithBytes:response.data()
                                                length:response.size()
                                              encoding:NSUTF8StringEncoding];
    return result ?: @"";
}

- (void)disposeModel {
    _engine->dispose();
}

- (void)dealloc {
    delete _engine;
    _engine = nullptr;
}

@end
