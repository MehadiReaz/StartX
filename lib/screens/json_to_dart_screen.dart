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
      _errorMessage = null;
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

          // Main Content - Responsive Layout
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 1200) {
                  return _buildMobileLayout();
                } else {
                  return _buildDesktopLayout();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - JSON Input
        Expanded(
          flex: 5,
          child: _buildJsonInputPanel(),
        ),
        const SizedBox(width: 16),

        // Middle Panel - Configuration Options
        SizedBox(
          width: 320,
          child: _buildConfigurationPanel(),
        ),
        const SizedBox(width: 16),

        // Right Panel - Generated Dart Code
        Expanded(
          flex: 5,
          child: _buildOutputPanel(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Class Name and Generate Button
          _buildClassNameAndGenerateSection(),
          const SizedBox(height: 16),

          // Configuration Panel
          _buildConfigurationPanel(),
          const SizedBox(height: 16),

          // JSON Input Panel
          SizedBox(
            height: 300,
            child: _buildJsonInputPanel(),
          ),
          const SizedBox(height: 16),

          // Output Panel
          SizedBox(
            height: 400,
            child: _buildOutputPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildClassNameAndGenerateSection() {
    return Row(
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
              if (!RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(value.trim())) {
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
            onPressed: _isGenerating ? null : _generateDartModel,
            icon: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.build),
            label: Text(_isGenerating ? 'Generating...' : 'Generate'),
          ),
        ),
      ],
    );
  }

  Widget _buildJsonInputPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'JSON Input',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // Show class name and generate button for desktop layout
            if (MediaQuery.of(context).size.width >= 1200) ...[
              SizedBox(
                width: 200,
                child: TextFormField(
                  controller: _classNameController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    hintText: 'MyModel',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateDartModel,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.build, size: 16),
                label: Text(_isGenerating ? 'Generating...' : 'Generate'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _errorMessage != null
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _jsonController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Paste your JSON here...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                    onChanged: (value) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationPanel() {
    return Card(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generation Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildSwitchTile(
                'Null Safety',
                'Enable null safety features',
                _nullSafety,
                (value) => setState(() => _nullSafety = value),
              ),
              _buildSwitchTile(
                'Generate Equatable',
                'Extends Equatable class',
                _generateEquatable,
                (value) => setState(() => _generateEquatable = value),
              ),
              _buildSwitchTile(
                'Generate copyWith',
                'Add copyWith method',
                _generateCopyWith,
                (value) => setState(() => _generateCopyWith = value),
              ),
              _buildSwitchTile(
                'Use num for numbers',
                'Use num instead of int/double',
                _useNumForNumbers,
                (value) => setState(() => _useNumForNumbers = value),
              ),
              _buildSwitchTile(
                'Generate toJson',
                'Add toJson method',
                _generateToJson,
                (value) => setState(() => _generateToJson = value),
              ),
              _buildSwitchTile(
                'Generate fromJson',
                'Add fromJson factory',
                _generateFromJson,
                (value) => setState(() => _generateFromJson = value),
              ),
              _buildSwitchTile(
                'Use JsonAnnotation',
                'Use json_annotation package',
                _useJsonAnnotation,
                (value) => setState(() => _useJsonAnnotation = value),
              ),
              _buildSwitchTile(
                'Generate toString',
                'Override toString method',
                _generateToString,
                (value) => setState(() => _generateToString = value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildOutputPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Generated Dart Code',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed:
                  _dartCodeController.text.isEmpty ? null : _copyToClipboard,
              icon: const Icon(Icons.copy),
              label: const Text('Copy'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: TextField(
              controller: _dartCodeController,
              maxLines: null,
              expands: true,
              readOnly: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Generated Dart code will appear here...',
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
    );
  }
}