// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LlamaKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "LlamaKit", targets: ["LlamaKit"]),
    ],
    targets: [
        // C/C++/ObjC++ target: llama.cpp core + CPU backend + ObjC bridge
        .target(
            name: "LlamaCore",
            path: "ios/Classes",
            exclude: [
                // Flutter-specific Swift file — SPM cannot mix Swift and Clang in one target
                "MyLlamaPlugin.swift",
                // Executables / tests (contain main())
                "core/app",
                "core/examples",
                "core/tests",
                "core/tools",
                "core/benches",
                "core/pocs",
                // Helper utilities not needed for core inference
                "core/common",
                // Non-CPU ggml backends
                "core/ggml/src/ggml-blas",
                "core/ggml/src/ggml-cann",
                "core/ggml/src/ggml-cuda",
                "core/ggml/src/ggml-hexagon",
                "core/ggml/src/ggml-hip",
                "core/ggml/src/ggml-metal",
                "core/ggml/src/ggml-musa",
                "core/ggml/src/ggml-opencl",
                "core/ggml/src/ggml-openvino",
                "core/ggml/src/ggml-rpc",
                "core/ggml/src/ggml-sycl",
                "core/ggml/src/ggml-virtgpu",
                "core/ggml/src/ggml-vulkan",
                "core/ggml/src/ggml-webgpu",
                "core/ggml/src/ggml-zdnn",
                "core/ggml/src/ggml-zendnn",
                // Third-party vendor libraries (httplib, miniaudio, etc.) — not needed for inference
                "core/vendor",
                // ggml-cpu: vendor-specific and non-ARM subdirectories
                "core/ggml/src/ggml-cpu/amx",
                "core/ggml/src/ggml-cpu/kleidiai",
                "core/ggml/src/ggml-cpu/llamafile",
                "core/ggml/src/ggml-cpu/spacemit",
                "core/ggml/src/ggml-cpu/arch/loongarch",
                "core/ggml/src/ggml-cpu/arch/powerpc",
                "core/ggml/src/ggml-cpu/arch/riscv",
                "core/ggml/src/ggml-cpu/arch/s390",
                "core/ggml/src/ggml-cpu/arch/wasm",
                "core/ggml/src/ggml-cpu/arch/x86",
            ],
            publicHeadersPath: ".",
            cSettings: [
                .define("GGML_USE_CPU"),
                .define("GGML_VERSION", to: "\"0.15.1\""),
                .define("GGML_COMMIT", to: "\"unknown\""),
                .headerSearchPath("."),
                .headerSearchPath("core/include"),
                .headerSearchPath("core/src"),
                .headerSearchPath("core/ggml/include"),
                .headerSearchPath("core/ggml/src"),
                .headerSearchPath("core/ggml/src/ggml-cpu"),
            ],
            cxxSettings: [
                .define("GGML_USE_CPU"),
                .define("GGML_VERSION", to: "\"0.15.1\""),
                .define("GGML_COMMIT", to: "\"unknown\""),
                .headerSearchPath("."),
                .headerSearchPath("core/include"),
                .headerSearchPath("core/src"),
                .headerSearchPath("core/ggml/include"),
                .headerSearchPath("core/ggml/src"),
                .headerSearchPath("core/ggml/src/ggml-cpu"),
            ],
            linkerSettings: [
                .linkedFramework("Accelerate"),
            ]
        ),
        // Pure Swift API layer — no Flutter dependency
        .target(
            name: "LlamaKit",
            dependencies: ["LlamaCore"],
            path: "Sources/LlamaKit"
        ),
    ],
    cxxLanguageStandard: .cxx17
)
