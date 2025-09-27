# Flutter Project Generator

A Flutter desktop application that generates Flutter project templates with customizable configurations, similar to an IDE project wizard.

## Features

### Core Functionality

- **Project Name Input**: Text field with validation for proper Flutter project naming conventions
- **Location Selector**: Directory picker for selecting where to create the project  
- **SDK Selection**: Dropdown menu to choose from different Flutter SDK versions
- **Platform Selection**: Multi-select checkboxes for target platforms:
  - Android
  - iOS  
  - Windows
  - macOS
  - Linux
  - Web
- **Namespace Configuration**: Custom package identifier input with validation
- **Template Selection**: Choose from different project templates:
  - Basic Flutter App
  - Flutter App with State Management
  - Flutter Desktop App
  - Flutter Web App
  - Flutter Plugin
  - Flutter Package

### JSON to Dart Model Generator

- **JSON Input**: Paste JSON data to automatically generate Dart model classes
- **Customizable Options**:
  - **Null Safety**: Enable/disable null safety features
  - **Generate Equatable**: Extends Equatable class for value equality
  - **Generate copyWith**: Add copyWith method for immutable updates
  - **Use num for numbers**: Use num type instead of int/double
  - **Generate toJson**: Add toJson method for serialization
  - **Generate fromJson**: Add fromJson factory constructor
  - **Use JsonAnnotation**: Use json_annotation package annotations
  - **Generate toString**: Override toString method
- **Real-time Generation**: Instant Dart code generation with copy-to-clipboard functionality
- **Sample Data**: Load sample JSON for testing and learning

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version recommended)
- Dart SDK (included with Flutter)
- Platform-specific requirements for desktop development:
  - **Windows**: Visual Studio 2022 or Visual Studio Build Tools 2022
  - **macOS**: Xcode
  - **Linux**: Clang, CMake, GTK development headers

### Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd flutter_project_generator
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Enable desktop support (if not already enabled):
   ```bash
   flutter config --enable-windows-desktop
   flutter config --enable-macos-desktop
   flutter config --enable-linux-desktop
   ```

### Running the Application

#### Windows
```bash
flutter run -d windows
```

#### macOS
```bash
flutter run -d macos
```

#### Linux
```bash
flutter run -d linux
```

## Usage

1. **Project Name**: Enter a valid Flutter project name (lowercase with underscores)
2. **Location**: Click "Browse" to select where your new project will be created
3. **SDK Version**: Choose your preferred Flutter SDK version from the dropdown
4. **Platforms**: Select target platforms by clicking the platform chips
5. **Namespace**: (Optional) Enter a custom package namespace in reverse domain format
6. **Template**: Select the type of Flutter project template you want to generate
7. **Generate**: Click "Generate Project" to create your Flutter project

## Project Structure

```
lib/
├── main.dart                 # Main application entry point
│
test/
├── widget_test.dart         # Widget tests for the application
│
windows/                     # Windows-specific files
macos/                      # macOS-specific files  
linux/                      # Linux-specific files
```

## Development

### Dependencies

- `file_picker: ^8.0.6` - For directory selection functionality
- `path: ^1.9.0` - For path manipulation utilities

### Building for Release

#### Windows
```bash
flutter build windows
```

#### macOS  
```bash
flutter build macos
```

#### Linux
```bash
flutter build linux
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Check the [Flutter documentation](https://docs.flutter.dev/)
- File issues on the project's GitHub repository
- Join the Flutter community on [Discord](https://discordapp.com/invite/N7Yshp4)
