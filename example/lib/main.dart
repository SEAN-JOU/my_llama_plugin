import 'package:flutter/material.dart';
import 'package:my_llama_plugin/my_llama_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = MyLlamaPlugin();
  final _modelPathController = TextEditingController();
  final _promptController = TextEditingController(text: 'Hello, my name is');

  bool _isBusy = false;
  bool _isLoaded = false;
  String _output = '';

  @override
  void dispose() {
    _modelPathController.dispose();
    _promptController.dispose();
    _plugin.disposeModel();
    super.dispose();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isBusy = true;
      _output = 'Loading model...';
    });

    final loaded = await _plugin.loadModel(_modelPathController.text.trim());
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      _isLoaded = loaded;
      _output = loaded ? 'Model loaded.' : 'Model failed to load.';
    });
  }

  Future<void> _generate() async {
    setState(() {
      _isBusy = true;
      _output = 'Generating...';
    });

    final response = await _plugin.generate(
      _promptController.text,
      maxTokens: 128,
    );
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      _output = response?.isNotEmpty == true ? response! : 'No response.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Llama GGUF plugin')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _modelPathController,
              decoration: const InputDecoration(
                labelText: 'GGUF model path',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isBusy ? null : _loadModel,
              child: const Text('Load model'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _promptController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Prompt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _isBusy || !_isLoaded ? null : _generate,
              child: const Text('Generate'),
            ),
            const SizedBox(height: 24),
            SelectableText(_output),
          ],
        ),
      ),
    );
  }
}
