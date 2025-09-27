import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

// Import custom services and widgets
import 'services/storage_service.dart';
import 'services/flutter_sdk_service.dart';
import 'theme/desktop_theme.dart';
import 'widgets/desktop_sidebar.dart';
import 'widgets/sdk_info_card.dart';
import 'screens/json_to_dart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.instance.initialize();

  runApp(const FlutterProjectGeneratorApp());
}

class FlutterProjectGeneratorApp extends StatefulWidget {
  const FlutterProjectGeneratorApp({super.key});

  @override
  State<FlutterProjectGeneratorApp> createState() =>
      _FlutterProjectGeneratorAppState();
}

class _FlutterProjectGeneratorAppState
    extends State<FlutterProjectGeneratorApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final isDark = await StorageService.instance.isDarkMode();
    setState(() {
      _isDarkMode = isDark;
    });
  }

  Future<void> _toggleTheme(bool isDark) async {
    setState(() {
      _isDarkMode = isDark;
    });
    await StorageService.instance.setDarkMode(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Project Generator',
      theme: DesktopTheme.lightTheme,
      darkTheme: DesktopTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(isDarkMode: _isDarkMode, onThemeChanged: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const MainScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<String> _flutterSdkPaths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedSdkPaths();
  }

  Future<void> _loadSavedSdkPaths() async {
    // Load saved SDK paths from storage
    final savedPaths = await StorageService.instance.getSdkPaths();

    // Auto-detect system Flutter if no saved paths
    if (savedPaths.isEmpty) {
      final systemFlutter = await FlutterSdkService.detectSystemFlutter();
      if (systemFlutter != null) {
        await StorageService.instance.addSdkPath(systemFlutter);
        savedPaths.add(systemFlutter);
      }
    }

    setState(() {
      _flutterSdkPaths.clear();
      _flutterSdkPaths.addAll(savedPaths);
      _isLoading = false;
    });
  }

  Future<void> _addFlutterSdkPath() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      // Verify it's a valid Flutter SDK path
      final isValid = await FlutterSdkService.isValidFlutterSdk(
        selectedDirectory,
      );

      if (isValid) {
        await StorageService.instance.addSdkPath(selectedDirectory);
        setState(() {
          if (!_flutterSdkPaths.contains(selectedDirectory)) {
            _flutterSdkPaths.add(selectedDirectory);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Flutter SDK path added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Invalid Flutter SDK path. Please select a valid Flutter installation.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _removeFlutterSdkPath(int index) async {
    final pathToRemove = _flutterSdkPaths[index];
    await StorageService.instance.removeSdkPath(pathToRemove);
    setState(() {
      _flutterSdkPaths.removeAt(index);
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return ProjectGeneratorScreen(flutterSdkPaths: _flutterSdkPaths);
      case 1:
        return _buildSdkManagementPage();
      case 2:
        return _buildRecentProjectsPage();
      case 3:
        return const JsonToDartScreen();
      default:
        return ProjectGeneratorScreen(flutterSdkPaths: _flutterSdkPaths);
    }
  }

  Widget _buildSdkManagementPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.settings,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                'Flutter SDK Management',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addFlutterSdkPath,
                icon: const Icon(Icons.add),
                label: const Text('Add SDK Path'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your Flutter SDK installations',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _flutterSdkPaths.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: _flutterSdkPaths.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final sdkPath = _flutterSdkPaths[index];
                      return SdkInfoCard(
                        sdkPath: sdkPath,
                        onRemove: () => _removeFlutterSdkPath(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Flutter SDK Configured',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a Flutter SDK path to get started with project generation.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addFlutterSdkPath,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First SDK'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjectsPage() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                'Recent Projects',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your recently generated Flutter projects',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Recent Projects',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Projects you create will appear here for quick access.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          DesktopSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            isDarkMode: widget.isDarkMode,
            onThemeChanged: widget.onThemeChanged,
          ),
          // Main content
          Expanded(child: _getSelectedPage()),
        ],
      ),
    );
  }
}

// Continue with the ProjectGeneratorScreen from the existing code
class ProjectGeneratorScreen extends StatefulWidget {
  final List<String> flutterSdkPaths;

  const ProjectGeneratorScreen({super.key, required this.flutterSdkPaths});

  @override
  State<ProjectGeneratorScreen> createState() => _ProjectGeneratorScreenState();
}

class _ProjectGeneratorScreenState extends State<ProjectGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameController = TextEditingController();
  final _namespaceController = TextEditingController();
  String? _selectedLocation;
  String? _selectedSDK;
  String _selectedTemplate = 'app';
  bool _isGenerating = false;

  final Map<String, bool> _platforms = {
    'android': true,
    'ios': true,
    'windows': false,
    'macos': false,
    'linux': false,
    'web': false,
  };

  final Map<String, String> _templates = {
    'app': 'Basic Flutter App',
    'module': 'Flutter Module',
    'package': 'Flutter Package',
    'plugin': 'Flutter Plugin',
    'plugin_ffi': 'Flutter FFI Plugin',
    'skeleton': 'Flutter Skeleton',
  };

  @override
  void initState() {
    super.initState();
    if (widget.flutterSdkPaths.isNotEmpty) {
      _selectedSDK = widget.flutterSdkPaths.first;
    }
    _loadLastUsedLocation();
  }

  Future<void> _loadLastUsedLocation() async {
    final lastLocation = await StorageService.instance.getLastUsedLocation();
    if (lastLocation != null) {
      setState(() {
        _selectedLocation = lastLocation;
      });
    }
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _namespaceController.dispose();
    super.dispose();
  }

  Future<void> _selectProjectLocation() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        _selectedLocation = selectedDirectory;
      });
      await StorageService.instance.saveLastUsedLocation(selectedDirectory);
    }
  }

  void _generateProject() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a project location'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final selectedPlatforms = _platforms.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedPlatforms.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one platform'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _showGenerationDialog();
    }
  }

  void _showGenerationDialog() {
    final selectedPlatforms = _platforms.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Project Configuration'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Project Name: ${_projectNameController.text}'),
                const SizedBox(height: 8),
                Text('Location: $_selectedLocation'),
                const SizedBox(height: 8),
                Text('SDK: $_selectedSDK'),
                const SizedBox(height: 8),
                Text('Platforms: ${selectedPlatforms.join(', ')}'),
                const SizedBox(height: 8),
                Text(
                  'Namespace: ${_namespaceController.text.isEmpty ? 'Default' : _namespaceController.text}',
                ),
                const SizedBox(height: 8),
                Text('Template: ${_templates[_selectedTemplate]}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isGenerating
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      _executeProjectGeneration();
                    },
              child: _isGenerating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generate Project'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _executeProjectGeneration() async {
    if (_selectedSDK == null || _selectedLocation == null) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      final projectPath = path.join(
        _selectedLocation!,
        _projectNameController.text,
      );

      // Check if directory already exists
      if (await Directory(projectPath).exists()) {
        throw Exception('Project directory already exists');
      }

      final flutterBin = Platform.isWindows
          ? path.join(_selectedSDK!, 'bin', 'flutter.bat')
          : path.join(_selectedSDK!, 'bin', 'flutter');

      // Build flutter create command
      final List<String> args = ['create'];

      // Add platforms
      final selectedPlatforms = _platforms.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedPlatforms.isNotEmpty) {
        args.addAll(['--platforms', selectedPlatforms.join(',')]);
      }

      // Add template
      args.addAll(['--template', _selectedTemplate]);

      // Add organization if namespace is provided
      if (_namespaceController.text.isNotEmpty) {
        args.addAll(['--org', _namespaceController.text]);
      }

      // Add project name
      args.add(_projectNameController.text);

      // Execute flutter create command
      final result = await Process.run(
        flutterBin,
        args,
        workingDirectory: _selectedLocation,
        runInShell: true,
      );

      if (result.exitCode == 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Project "${_projectNameController.text}" created successfully!\nLocation: $projectPath',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Open Folder',
                onPressed: () {
                  if (Platform.isWindows) {
                    Process.run('explorer', [projectPath], runInShell: true);
                  } else if (Platform.isMacOS) {
                    Process.run('open', [projectPath], runInShell: true);
                  } else if (Platform.isLinux) {
                    Process.run('xdg-open', [projectPath], runInShell: true);
                  }
                },
              ),
            ),
          );
        }
      } else {
        throw Exception('Flutter create failed: ${result.stderr}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating project: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
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
                Icons.create_new_folder,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                'Create New Project',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Configure and generate your Flutter project',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Main Form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Project Name Input
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Project Details',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _projectNameController,
                              decoration: const InputDecoration(
                                labelText: 'Project Name',
                                hintText: 'my_flutter_app',
                                prefixIcon: Icon(
                                  Icons.drive_file_rename_outline,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a project name';
                                }
                                if (!RegExp(
                                  r'^[a-z][a-z0-9_]*$',
                                ).hasMatch(value)) {
                                  return 'Project name must be lowercase with underscores';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _namespaceController,
                              decoration: const InputDecoration(
                                labelText: 'Package Namespace (Optional)',
                                hintText: 'com.example.myapp',
                                prefixIcon: Icon(Icons.business),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (!RegExp(
                                    r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$',
                                  ).hasMatch(value)) {
                                    return 'Invalid namespace format';
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location and SDK Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Project Configuration',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // Location Selector
                            Row(
                              children: [
                                const Icon(Icons.folder),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Project Location',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedLocation ??
                                            'No location selected',
                                        style: TextStyle(
                                          color: _selectedLocation == null
                                              ? Colors.grey
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _selectProjectLocation,
                                  child: const Text('Browse'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // SDK Selection
                            widget.flutterSdkPaths.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.orange.shade200,
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'No Flutter SDK Configured',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Please add a Flutter SDK path in SDK Management to create projects.',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : DropdownButtonFormField<String>(
                                    value: _selectedSDK,
                                    decoration: const InputDecoration(
                                      labelText: 'Flutter SDK',
                                      prefixIcon: Icon(Icons.flutter_dash),
                                    ),
                                    items: widget.flutterSdkPaths.map((
                                      String sdkPath,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: sdkPath,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Text(
                                            //   path.basename(sdkPath),
                                            //   style: const TextStyle(
                                            //     fontWeight: FontWeight.bold,
                                            //   ),
                                            // ),
                                            Text(
                                              sdkPath,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedSDK = newValue;
                                      });
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select a Flutter SDK';
                                      }
                                      return null;
                                    },
                                  ),
                            const SizedBox(height: 16),

                            // Template Selection
                            DropdownButtonFormField<String>(
                              value: _selectedTemplate,
                              decoration: const InputDecoration(
                                labelText: 'Project Template',
                                prefixIcon: Icon(Icons.web_stories),
                              ),
                              items: _templates.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedTemplate = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Platform Selection
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Platforms',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _platforms.entries.map((entry) {
                                final displayName =
                                    entry.key.substring(0, 1).toUpperCase() +
                                    entry.key.substring(1);
                                return FilterChip(
                                  label: Text(displayName),
                                  selected: entry.value,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _platforms[entry.key] = selected;
                                    });
                                  },
                                  avatar: entry.value
                                      ? const Icon(Icons.check, size: 16)
                                      : null,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed:
                            (_isGenerating || widget.flutterSdkPaths.isEmpty)
                            ? null
                            : _generateProject,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.build),
                        label: Text(
                          _isGenerating ? 'Generating...' : 'Generate Project',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
