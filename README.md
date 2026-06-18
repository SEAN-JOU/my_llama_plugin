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
