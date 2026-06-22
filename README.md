# my_llama_plugin

A Flutter plugin that runs local `.gguf` language models on Android and iOS via
llama.cpp.

The current implementation is CPU-only on both platforms. It supports loading a
model from a real device file path, generating a synchronous text completion,
and releasing native memory.

## Usage

```dart
final llama = MyLlamaPlugin();

final loaded = await llama.loadModel(
  '/absolute/path/to/model.gguf',
  contextSize: 2048,
);

if (loaded) {
  final text = await llama.generate(
    'Hello, my name is',
    maxTokens: 128,
    temperature: 0.8,
  );
  print(text);
}

await llama.disposeModel();
```

## Model files

Pass a real filesystem path to `loadModel`. Flutter asset keys are not enough;
copy or download the `.gguf` file into app-accessible storage first, then pass
that absolute path.

## Example

The example app provides a small manual test screen:

```sh
cd example
flutter run
```

Enter the `.gguf` model path, load it, then enter a prompt and generate.

## Native Android usage

The Android implementation also exposes a small Kotlin/Java-friendly API for
native apps. Add the Android library or generated AAR to your native Android
project, then call `MyLlamaNative` from a background thread because model loading
and generation are synchronous.

```kotlin
import com.example.my_llama_plugin.MyLlamaNative
import java.util.concurrent.Executors

private val llamaExecutor = Executors.newSingleThreadExecutor()

fun runLocalModel(modelPath: String) {
  llamaExecutor.execute {
    val loaded = MyLlamaNative.loadModel(
      path = modelPath,
      contextSize = 2048,
      gpuLayers = 0,
      threads = 0,
    )

    if (loaded) {
      val text = MyLlamaNative.generate(
        prompt = "Hello, my name is",
        maxTokens = 128,
        temperature = 0.8f,
        topK = 40,
        topP = 0.95f,
      )
      println(text)
    }

    MyLlamaNative.disposeModel()
  }
}
```

For Java callers, the same class exposes static overloads:

```java
boolean loaded = MyLlamaNative.loadModel(modelPath, 2048, 0, 0);
String text = MyLlamaNative.generate("Hello", 128, 0.8f, 40, 0.95f);
MyLlamaNative.disposeModel();
```
