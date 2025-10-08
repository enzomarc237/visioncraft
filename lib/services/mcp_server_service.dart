import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../services/database_service.dart';
import '../repositories/screenshot_repository.dart';
import '../providers/settings_provider.dart';

class McpServerService {
  final DatabaseService _databaseService;
  final SettingsProvider _settingsProvider;
  late final ScreenshotRepository _repository;
  
  HttpServer? _server;
  bool _isRunning = false;

  McpServerService({
    required DatabaseService databaseService,
    required SettingsProvider settingsProvider,
  })  : _databaseService = databaseService,
        _settingsProvider = settingsProvider {
    _repository = ScreenshotRepository(_databaseService);
  }

  bool get isRunning => _isRunning;

  Future<void> start() async {
    if (_isRunning) return;

    final router = Router();

    // MCP Protocol endpoints
    router.post('/mcp/list-screenshots', _handleListScreenshots);
    router.post('/mcp/get-screenshot-metadata', _handleGetScreenshotMetadata);
    router.post('/mcp/get-design-specifications', _handleGetDesignSpecifications);

    // Health check
    router.get('/health', (Request request) {
      return Response.ok(jsonEncode({'status': 'healthy', 'service': 'AI Design Inspiration Hub MCP Server'}));
    });

    final handler = Pipeline()
        .addMiddleware(_authMiddleware())
        .addMiddleware(logRequests())
        .addHandler(router);

    _server = await shelf_io.serve(
      handler,
      InternetAddress.loopbackIPv4,
      _settingsProvider.mcpPort,
    );

    _isRunning = true;
    print('MCP Server running on http://${_server!.address.host}:${_server!.port}');
  }

  Future<void> stop() async {
    if (!_isRunning || _server == null) return;

    await _server!.close(force: true);
    _server = null;
    _isRunning = false;
    print('MCP Server stopped');
  }

  Middleware _authMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        // Skip auth for health check
        if (request.url.path == 'health') {
          return innerHandler(request);
        }

        final authHeader = request.headers['authorization'];
        if (authHeader == null) {
          return Response.forbidden(
            jsonEncode({'error': {'code': 403, 'message': 'Missing authorization header'}}),
          );
        }

        // Extract API key (assuming "Bearer <key>" format)
        final apiKey = authHeader.startsWith('Bearer ')
            ? authHeader.substring(7)
            : authHeader;

        if (!_settingsProvider.isValidApiKey(apiKey)) {
          return Response.forbidden(
            jsonEncode({'error': {'code': 403, 'message': 'Invalid API key'}}),
          );
        }

        return innerHandler(request);
      };
    };
  }

  Future<Response> _handleListScreenshots(Request request) async {
    try {
      final body = await request.readAsString();
      final params = jsonDecode(body) as Map<String, dynamic>;
      
      final filter = params['filter'] as Map<String, dynamic>?;
      final pagination = params['pagination'] as Map<String, dynamic>?;

      final tags = filter?['tags'] as List<dynamic>?;
      final categories = filter?['categories'] as List<dynamic>?;
      final titleQuery = filter?['title_query'] as String?;
      final dateFromStr = filter?['date_from'] as String?;
      final dateToStr = filter?['date_to'] as String?;

      final limit = pagination?['limit'] as int? ?? 20;
      final offset = pagination?['offset'] as int? ?? 0;

      final screenshots = await _repository.getAllScreenshots(
        tags: tags?.cast<String>(),
        categories: categories?.cast<String>(),
        titleQuery: titleQuery,
        dateFrom: dateFromStr != null ? DateTime.parse(dateFromStr) : null,
        dateTo: dateToStr != null ? DateTime.parse(dateToStr) : null,
        limit: limit > 100 ? 100 : limit,
        offset: offset,
      );

      final totalCount = await _repository.getScreenshotsCount(
        tags: tags?.cast<String>(),
        categories: categories?.cast<String>(),
        titleQuery: titleQuery,
      );

      final response = {
        'screenshots': screenshots.map((s) => {
          'id': s.id,
          'title': s.title,
          'description': s.description,
          'image_path': s.imagePath,
          'creation_date': s.creationDate.toIso8601String(),
          'tags': s.tags,
          'categories': s.categories,
        }).toList(),
        'total_count': totalCount,
      };

      return Response.ok(
        jsonEncode(response),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'error': {'code': 500, 'message': 'Internal server error: $e'}
        }),
      );
    }
  }

  Future<Response> _handleGetScreenshotMetadata(Request request) async {
    try {
      final body = await request.readAsString();
      final params = jsonDecode(body) as Map<String, dynamic>;
      
      final screenshotId = params['screenshot_id'] as String?;
      if (screenshotId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': {'code': 400, 'message': 'Missing required parameter: screenshot_id'}
          }),
        );
      }

      final screenshot = await _repository.getScreenshotById(screenshotId);
      if (screenshot == null) {
        return Response.notFound(
          jsonEncode({
            'error': {'code': 404, 'message': 'Screenshot not found'}
          }),
        );
      }

      final response = {
        'id': screenshot.id,
        'title': screenshot.title,
        'description': screenshot.description,
        'image_path': screenshot.imagePath,
        'creation_date': screenshot.creationDate.toIso8601String(),
        'source_url': screenshot.sourceUrl,
        'upload_timestamp': screenshot.uploadTimestamp.toIso8601String(),
        'tags': screenshot.tags,
        'categories': screenshot.categories,
        'has_design_specs': true, // We could check if specs exist
      };

      return Response.ok(
        jsonEncode(response),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'error': {'code': 500, 'message': 'Internal server error: $e'}
        }),
      );
    }
  }

  Future<Response> _handleGetDesignSpecifications(Request request) async {
    try {
      final body = await request.readAsString();
      final params = jsonDecode(body) as Map<String, dynamic>;
      
      final screenshotId = params['screenshot_id'] as String?;
      if (screenshotId == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error': {'code': 400, 'message': 'Missing required parameter: screenshot_id'}
          }),
        );
      }

      final designSpec = await _repository.getDesignSpecification(screenshotId);
      if (designSpec == null) {
        return Response.notFound(
          jsonEncode({
            'error': {'code': 404, 'message': 'Design specifications not found'}
          }),
        );
      }

      final response = designSpec.toJson();

      return Response.ok(
        jsonEncode(response),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'error': {'code': 500, 'message': 'Internal server error: $e'}
        }),
      );
    }
  }
}