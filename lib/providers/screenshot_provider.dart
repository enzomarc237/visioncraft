import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/screenshot.dart';
import '../models/design_specification.dart';
import '../services/database_service.dart';
import '../services/file_storage_service.dart';
import '../services/image_analysis_service.dart';
import '../services/export_service.dart';
import '../repositories/screenshot_repository.dart';
import 'package:uuid/uuid.dart';

class ScreenshotProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  final FileStorageService _fileStorageService = FileStorageService();
  final ImageAnalysisService _analysisService = ImageAnalysisService();
  late final ScreenshotRepository _repository;

  List<Screenshot> _screenshots = [];
  bool _isLoading = false;
  String? _searchQuery;
  List<String> _selectedTags = [];
  List<String> _selectedCategories = [];

  ScreenshotProvider({required DatabaseService databaseService})
      : _databaseService = databaseService {
    _repository = ScreenshotRepository(_databaseService);
    loadScreenshots();
  }

  List<Screenshot> get screenshots => _screenshots;
  bool get isLoading => _isLoading;
  String? get searchQuery => _searchQuery;
  List<String> get selectedTags => _selectedTags;
  List<String> get selectedCategories => _selectedCategories;

  Future<void> loadScreenshots() async {
    _isLoading = true;
    notifyListeners();

    try {
      _screenshots = await _repository.getAllScreenshots(
        tags: _selectedTags.isEmpty ? null : _selectedTags,
        categories: _selectedCategories.isEmpty ? null : _selectedCategories,
        titleQuery: _searchQuery,
      );
    } catch (e) {
      debugPrint('Error loading screenshots: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadScreenshot(
    File imageFile, {
    String? title,
    String? description,
    List<String>? tags,
    List<String>? categories,
    String? sourceUrl,
  }) async {
    try {
      // Save image file
      final imagePath = await _fileStorageService.saveImage(imageFile);

      // Create screenshot object
      final screenshot = Screenshot(
        id: const Uuid().v4(),
        title: title,
        description: description,
        imagePath: imagePath,
        creationDate: DateTime.now(),
        sourceUrl: sourceUrl,
        uploadTimestamp: DateTime.now(),
        tags: tags ?? [],
        categories: categories ?? [],
      );

      // Save to database
      await _repository.insertScreenshot(screenshot);

      // Generate thumbnail
      final thumbnailPath = await _fileStorageService.getThumbnailPath(imagePath);
      await _analysisService.generateThumbnail(imagePath, thumbnailPath);

      // Start image analysis in background
      _analyzeScreenshotInBackground(screenshot);

      // Reload screenshots
      await loadScreenshots();
    } catch (e) {
      debugPrint('Error uploading screenshot: $e');
      rethrow;
    }
  }

  Future<void> _analyzeScreenshotInBackground(Screenshot screenshot) async {
    try {
      final designSpec = await _analysisService.analyzeImage(
        screenshot.imagePath,
        screenshot.id,
      );
      await _repository.insertDesignSpecification(designSpec);
    } catch (e) {
      debugPrint('Error analyzing screenshot: $e');
    }
  }

  Future<void> updateScreenshot(Screenshot screenshot) async {
    try {
      await _repository.updateScreenshot(screenshot);
      await loadScreenshots();
    } catch (e) {
      debugPrint('Error updating screenshot: $e');
      rethrow;
    }
  }

  Future<void> deleteScreenshot(String id) async {
    try {
      final screenshot = _screenshots.firstWhere((s) => s.id == id);
      await _fileStorageService.deleteImage(screenshot.imagePath);
      await _repository.deleteScreenshot(id);
      await loadScreenshots();
    } catch (e) {
      debugPrint('Error deleting screenshot: $e');
      rethrow;
    }
  }

  Future<Screenshot?> getScreenshotById(String id) async {
    return await _repository.getScreenshotById(id);
  }

  Future<DesignSpecification?> getDesignSpecification(String screenshotId) async {
    return await _repository.getDesignSpecification(screenshotId);
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    loadScreenshots();
  }

  void setSelectedTags(List<String> tags) {
    _selectedTags = tags;
    loadScreenshots();
  }

  void setSelectedCategories(List<String> categories) {
    _selectedCategories = categories;
    loadScreenshots();
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedTags = [];
    _selectedCategories = [];
    loadScreenshots();
  }

  ExportService createExportService() {
    return ExportService(_repository);
  }
}