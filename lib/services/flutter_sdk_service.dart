import 'dart:io';
import 'package:path/path.dart' as path;

class FlutterSdkService {
  static Future<String?> detectSystemFlutter() async {
    try {
      final command = Platform.isWindows ? 'where' : 'which';
      final result = await Process.run(command, ['flutter'], runInShell: true);

      if (result.exitCode == 0) {
        String flutterPath = result.stdout.toString().trim();
        if (Platform.isWindows) {
          // On Windows, 'where' returns the full path to flutter.bat
          // We need the SDK root directory
          final batFile = File(flutterPath);
          if (await batFile.exists()) {
            final sdkRoot = path.dirname(path.dirname(flutterPath));
            return sdkRoot;
          }
        } else {
          // On Unix systems, get the SDK root
          final flutterFile = File(flutterPath);
          if (await flutterFile.exists()) {
            final sdkRoot = path.dirname(path.dirname(flutterPath));
            return sdkRoot;
          }
        }
      }
    } catch (e) {
      // Flutter not found in PATH
    }
    return null;
  }

  static Future<bool> isValidFlutterSdk(String sdkPath) async {
    final flutterBin = Platform.isWindows
        ? path.join(sdkPath, 'bin', 'flutter.bat')
        : path.join(sdkPath, 'bin', 'flutter');

    return await File(flutterBin).exists();
  }

  static Future<String?> getFlutterVersion(String sdkPath) async {
    try {
      final flutterBin = Platform.isWindows
          ? path.join(sdkPath, 'bin', 'flutter.bat')
          : path.join(sdkPath, 'bin', 'flutter');

      final result = await Process.run(flutterBin, [
        '--version',
      ], runInShell: true);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final versionMatch = RegExp(r'Flutter ([\d\.\w-]+)').firstMatch(output);
        return versionMatch?.group(1);
      }
    } catch (e) {
      // Error getting version
    }
    return null;
  }

  static Future<Map<String, String>> getFlutterInfo(String sdkPath) async {
    try {
      final flutterBin = Platform.isWindows
          ? path.join(sdkPath, 'bin', 'flutter.bat')
          : path.join(sdkPath, 'bin', 'flutter');

      final result = await Process.run(flutterBin, [
        '--version',
      ], runInShell: true);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();

        final versionMatch = RegExp(r'Flutter ([\d\.\w-]+)').firstMatch(output);
        final channelMatch = RegExp(r'channel (\w+)').firstMatch(output);
        final dartMatch = RegExp(r'Dart ([\d\.\w-]+)').firstMatch(output);

        return {
          'version': versionMatch?.group(1) ?? 'Unknown',
          'channel': channelMatch?.group(1) ?? 'Unknown',
          'dart': dartMatch?.group(1) ?? 'Unknown',
        };
      }
    } catch (e) {
      // Error getting info
    }
    return {'version': 'Unknown', 'channel': 'Unknown', 'dart': 'Unknown'};
  }
}
