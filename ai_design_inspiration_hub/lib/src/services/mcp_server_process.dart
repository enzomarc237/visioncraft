import 'dart:io';

class McpServerProcess {
  Process? _process;

  Future<void> start({int port = 8765, String? apiKey}) async {
    if (_process != null) return;
    final String script = 'tools/mcp_server.py';
    final Map<String, String> env = Map<String, String>.from(Platform.environment);
    if (apiKey != null) env['MCP_API_KEY'] = apiKey;
    _process = await Process.start('python3', [script, '--port', '$port'], environment: env);
    _process!.stdout.transform(SystemEncoding().decoder).listen((e) => stdout.write(e));
    _process!.stderr.transform(SystemEncoding().decoder).listen((e) => stderr.write(e));
  }

  Future<void> stop() async {
    final Process? p = _process;
    if (p == null) return;
    p.kill(ProcessSignal.sigint);
    _process = null;
  }
}

