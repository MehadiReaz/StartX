import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _sdkPathsKey = 'flutter_sdk_paths';
  static const String _lastUsedLocationKey = 'last_used_location';
  static const String _appSettingsKey = 'app_settings';

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // SDK Paths Management
  Future<List<String>> getSdkPaths() async {
    await initialize();
    final paths = _prefs?.getStringList(_sdkPathsKey) ?? [];
    return paths;
  }

  Future<void> saveSdkPaths(List<String> paths) async {
    await initialize();
    await _prefs?.setStringList(_sdkPathsKey, paths);
  }

  Future<void> addSdkPath(String path) async {
    final paths = await getSdkPaths();
    if (!paths.contains(path)) {
      paths.add(path);
      await saveSdkPaths(paths);
    }
  }

  Future<void> removeSdkPath(String path) async {
    final paths = await getSdkPaths();
    paths.remove(path);
    await saveSdkPaths(paths);
  }

  // Last used location
  Future<String?> getLastUsedLocation() async {
    await initialize();
    return _prefs?.getString(_lastUsedLocationKey);
  }

  Future<void> saveLastUsedLocation(String location) async {
    await initialize();
    await _prefs?.setString(_lastUsedLocationKey, location);
  }

  // App Settings
  Future<Map<String, dynamic>> getAppSettings() async {
    await initialize();
    final settingsJson = _prefs?.getString(_appSettingsKey) ?? '{}';
    return json.decode(settingsJson) as Map<String, dynamic>;
  }

  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await initialize();
    await _prefs?.setString(_appSettingsKey, json.encode(settings));
  }

  // Theme settings
  Future<bool> isDarkMode() async {
    final settings = await getAppSettings();
    return settings['darkMode'] ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    final settings = await getAppSettings();
    settings['darkMode'] = isDark;
    await saveAppSettings(settings);
  }
}
