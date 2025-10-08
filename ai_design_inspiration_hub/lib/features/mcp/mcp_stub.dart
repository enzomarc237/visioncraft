class McpServerStub {
  bool _running = false;
  String? _apiKey;

  bool get isRunning => _running;
  String? get apiKey => _apiKey;

  Future<void> start({required String apiKey}) async {
    _apiKey = apiKey;
    _running = true;
    // In a real implementation, bind to a local port and expose MCP tools.
  }

  Future<void> stop() async {
    _running = false;
  }

  bool validateKey(String? key) => key != null && key.isNotEmpty && key == _apiKey;
}
