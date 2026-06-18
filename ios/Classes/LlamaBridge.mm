#import "LlamaBridge.h"
#import "core/include/llama.h"

@implementation LlamaBridge {
    // 宣告為實體變數，讓後續的推論(生成對話)也能讀取
    llama_model *model;
    llama_context *ctx;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        llama_backend_init();
    }
    return self;
}

- (BOOL)loadModelAtPath:(NSString *)path {
    // 1. 防呆：如果已經有載入過舊模型，先清空記憶體
    if (model != NULL) {
        llama_free_model(model);
        model = NULL;
    }
    
    NSLog(@"[LlamaBridge] 準備載入模型，路徑為: %@", path);
    // 將 Swift 傳來的 NSString 轉為 C 字串
    const char *cPath = [path UTF8String];
    
    // 2. 配置模型參數
    llama_model_params model_params = llama_model_default_params();
    // 將運算層數開到最大，全部交給 Apple Silicon 的 Metal 引擎處理！
    model_params.n_gpu_layers = 99; 
    
    // 3. 執行載入
    model = llama_load_model_from_file(cPath, model_params);
    
    if (model == NULL) {
        NSLog(@"[LlamaBridge] ❌ 模型載入失敗");
        return NO;
    }
    
    NSLog(@"[LlamaBridge] ✅ 模型載入成功！");
    return YES;
}

- (void)dealloc {
    // 確保物件銷毀時釋放 C++ 記憶體
    if (model != NULL) {
        llama_free_model(model);
    }
    llama_backend_free();
}

@end