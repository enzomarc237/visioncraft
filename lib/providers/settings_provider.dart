import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _mcpPortKey = 'mcp_server_port';
  static const String _mcpEnabledKey = 'mcp_server_enabled';
  static const String _apiKeysKey = 'mcp_api_keys';

  int _mcpPort = 8080;
  bool _mcpEnabled = false;
  List<String> _apiKeys = [];

  int get mcpPort => _mcpPort;
  bool get mcpEnabled => _mcpEnabled;
  List<String> get apiKeys => _apiKeys;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _mcpPort = prefs.getInt(_mcpPortKey) ?? 8080;
    _mcpEnabled = prefs.getBool(_mcpEnabledKey) ?? false;
    _apiKeys = prefs.getStringList(_apiKeysKey) ?? [];
    notifyListeners();
  }

  Future<void> setMcpPort(int port) async {
    _mcpPort = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_mcpPortKey, port);
    notifyListeners();
  }

  Future<void> setMcpEnabled(bool enabled) async {
    _mcpEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_mcpEnabledKey, enabled);
    notifyListeners();
  }

  Future<String> generateApiKey() async {
    final apiKey = const Uuid().v4();
    _apiKeys.add(apiKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_apiKeysKey, _apiKeys);
    notifyListeners();
    return apiKey;
  }

  Future<void> removeApiKey(String apiKey) async {
    _apiKeys.remove(apiKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_apiKeysKey, _apiKeys);
    notifyListeners();
  }

  bool isValidApiKey(String apiKey) {
    return _apiKeys.contains(apiKey);
  }
}