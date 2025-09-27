import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/json_to_dart_service.dart';

class JsonToDartScreen extends StatefulWidget {
  const JsonToDartScreen({super.key});

  @override
  State<JsonToDartScreen> createState() => _JsonToDartScreenState();
}

class _JsonToDartScreenState extends State<JsonToDartScreen> {
  final _jsonController = TextEditingController();
  final _classNameController = TextEditingController(text: 'MyModel');
  final _dartCodeController = TextEditingController();

  bool _nullSafety = true;
  bool _generateEquatable = false;
  bool _generateCopyWith = true;
  bool _useNumForNumbers = false;
  bool _generateToJson = true;
  bool _generateFromJson = true;
  bool _useJsonAnnotation = true;
  bool _generateToString = false;

  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _jsonController.dispose();
    _classNameController.dispose();
    _dartCodeController.dispose();
    super.dispose();
  }

  Future<void> _generateDartModel() async {
    if (_jsonController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter JSON data';
      });
      return;
    }

    if (_classNameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a class name';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final dartCode = JsonToDartService.generateDartModel(
        json: _jsonController.text.trim(),
        className: _classNameController.text.trim(),
        nullSafety: _nullSafety,
        generateEquatable: _generateEquatable,
        generateCopyWith: _generateCopyWith,
        useNumForNumbers: _useNumForNumbers,
        generateToJson: _generateToJson,
        generateFromJson: _generateFromJson,
        useJsonAnnotation: _useJsonAnnotation,
        generateToString: _generateToString,
      );

      setState(() {
        _dartCodeController.text = dartCode;
        _isGenerating = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dart model generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isGenerating = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_dartCodeController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _dartCodeController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dart code copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearAll() {
    setState(() {
      _jsonController.clear();
      _classNameController.text = 'MyModel';
      _dartCodeController.clear();
      _errorMessage = null;
    });
  }

  void _loadSampleJson() {
    const sampleJson = '''{
  "id": 1,
  "name": "John Doe",
  "email": "john.doe@example.com",
  "age": 30,
  "is_active": true,
  "profile": {
    "bio": "Software Developer",
    "website": "https://johndoe.com"
  },
  "skills": ["Flutter", "Dart", "Firebase"],
  "projects": [
    {
      "name": "Project 1",
      "description": "A mobile app"
    }
  ]
}''';

    setState(() {
      _jsonController.text = sampleJson;
      _classNameController.text = 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Row(
            children: [
              Icon(
                Icons.code,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                'JSON to Dart Model',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _loadSampleJson,
                icon: const Icon(Icons.data_object),
                label: const Text('Load Sample'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.clear),
                label: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Convert JSON data to Dart model classes with various configuration options',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Main Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Panel - JSON Input and Options
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Class Name and Generate Button
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _classNameController,
                              decoration: const InputDecoration(
                                labelText: 'Class Name',
                                hintText: 'MyModel',
                                prefixIcon: Icon(Icons.class_),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a class name';
                                }
                                if (!RegExp(
                                  r'^[A-Z][a-zA-Z0-9]*$',
                                ).hasMatch(value.trim())) {
                                  return 'Class name must start with uppercase and contain only letters/numbers';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _isGenerating
                                  ? null
                                  : _generateDartModel,
                              icon: _isGenerating
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.build),
                              label: Text(
                                _isGenerating ? 'Generating...' : 'Generate',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // JSON Input
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'JSON Input',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: TextField(
                                controller: _jsonController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: 'Paste your JSON here...',
                                  border: const OutlineInputBorder(),
                                  errorText: _errorMessage,
                                ),
                                style: const TextStyle(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Middle Panel - Configuration Options
                SizedBox(
                  width: 280,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generation Options',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          // Null Safety
                          SwitchListTile(
                            title: const Text('Null Safety'),
                            subtitle: const Text('Enable null safety features'),
                            value: _nullSafety,
                            onChanged: (value) {
                              setState(() {
                                _nullSafety = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),

                          // Generate Equatable
                          SwitchListTile(
                            title: const Text('Generate Equatable'),
                            subtitle: const Text('Extends Equatable class'),
                            value: _generateEquatable,
                            onChanged: (value) {
                              setState(() {
                                _generateEquatable = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),

                          // Generate copyWith
                          SwitchListTile(
                            title: const Text('Generate copyWith'),
                            subtitle: const Text('Add copyWith method'),
                            value: _generateCopyWith,
                            onChanged: (value) {
                              setState(() {
                                _generateCopyWith = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),

                          // Use num for numbers
                          SwitchListTile(
                            title: const Text('Use num for numbers'),
                            subtitle: const Text(
                              'Use num instead of int/double',
                            ),
                            value: _useNumForNumbers,
                            onChanged: (value) {
                              setState(() {
                                _useNumForNumbers = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),

                          // Generate toJson
                          SwitchListTile(
                            title: const Text('Generate toJson'),
                            subtitle: const Text('Add toJson method'),
                            value: _generateToJson,
                            onChanged: (value) {
                              setState(() {
                                _generateToJson = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),

                          // Generate fromJson
                          SwitchListTile(
                            title: const Text('Generate fromJson'),
                            subtitle: const Text('Add fromJson factory'),
                            value: _generateFromJson,
                            onChanged: (value) {
                              setState(() {
                                _generateFromJson = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),

                          // Use JsonAnnotation
                          SwitchListTile(
                            title: const Text('Use JsonAnnotation'),
                            subtitle: const Text('Use json_annotation package'),
                            value: _useJsonAnnotation,
                            onChanged: (value) {
                              setState(() {
                                _useJsonAnnotation = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),

                          // Generate toString
                          SwitchListTile(
                            title: const Text('Generate toString'),
                            subtitle: const Text('Override toString method'),
                            value: _generateToString,
                            onChanged: (value) {
                              setState(() {
                                _generateToString = value;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Right Panel - Generated Dart Code
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Generated Dart Code',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: _dartCodeController.text.isEmpty
                                ? null
                                : _copyToClipboard,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _dartCodeController,
                            maxLines: null,
                            expands: true,
                            readOnly: true,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: const InputDecoration(
                              hintText:
                                  'Generated Dart code will appear here...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
