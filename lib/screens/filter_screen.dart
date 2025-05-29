import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class FilterScreen extends StatefulWidget {
  final String imagePath;

  const FilterScreen({super.key, required this.imagePath});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  img.Image? _originalImage;
  img.Image? _filteredImage;
  String _currentFilter = 'None';
  bool _isLoading = true;

  final List<String> _filters = [
    'None',
    'Grayscale',
    'Sepia',
    'Blur',
    'Brighten',
    'Darken',
    'Contrast',
    'Vintage',
  ];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      _originalImage = img.decodeImage(bytes);
      _filteredImage = img.copyResize(_originalImage!, width: 800);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading image: $e')),
        );
      }
    }
  }

  Future<void> _applyFilter(String filterType) async {
    if (_originalImage == null) return;

    setState(() {
      _isLoading = true;
      _currentFilter = filterType;
    });

    img.Image filtered = img.copyResize(_originalImage!, width: 800);

    switch (filterType) {
      case 'Grayscale':
        filtered = img.grayscale(filtered);
        break;
      case 'Sepia':
        filtered = img.sepia(filtered);
        break;
      case 'Blur':
        filtered = img.gaussianBlur(filtered, radius: 2);
        break;
      case 'Brighten':
        // Apply brightness adjustment manually
        for (int y = 0; y < filtered.height; y++) {
          for (int x = 0; x < filtered.width; x++) {
            final pixel = filtered.getPixel(x, y);
            final r = (pixel.r + 30).clamp(0, 255);
            final g = (pixel.g + 30).clamp(0, 255);
            final b = (pixel.b + 30).clamp(0, 255);
            filtered.setPixel(
                x, y, img.ColorRgb8(r.toInt(), g.toInt(), b.toInt()));
          }
        }
        break;
      case 'Darken':
        // Apply darkness adjustment manually
        for (int y = 0; y < filtered.height; y++) {
          for (int x = 0; x < filtered.width; x++) {
            final pixel = filtered.getPixel(x, y);
            final r = (pixel.r - 30).clamp(0, 255);
            final g = (pixel.g - 30).clamp(0, 255);
            final b = (pixel.b - 30).clamp(0, 255);
            filtered.setPixel(
                x, y, img.ColorRgb8(r.toInt(), g.toInt(), b.toInt()));
          }
        }
        break;
      case 'Contrast':
        // Apply contrast adjustment manually
        final factor = 1.5; // contrast factor
        for (int y = 0; y < filtered.height; y++) {
          for (int x = 0; x < filtered.width; x++) {
            final pixel = filtered.getPixel(x, y);
            final r = ((pixel.r - 128) * factor + 128).clamp(0, 255);
            final g = ((pixel.g - 128) * factor + 128).clamp(0, 255);
            final b = ((pixel.b - 128) * factor + 128).clamp(0, 255);
            filtered.setPixel(
                x, y, img.ColorRgb8(r.toInt(), g.toInt(), b.toInt()));
          }
        }
        break;
      case 'Vintage':
        // Apply sepia first
        filtered = img.sepia(filtered);
        // Then apply slight darkening
        for (int y = 0; y < filtered.height; y++) {
          for (int x = 0; x < filtered.width; x++) {
            final pixel = filtered.getPixel(x, y);
            final r = (pixel.r - 10).clamp(0, 255);
            final g = (pixel.g - 10).clamp(0, 255);
            final b = (pixel.b - 10).clamp(0, 255);
            filtered.setPixel(
                x, y, img.ColorRgb8(r.toInt(), g.toInt(), b.toInt()));
          }
        }
        break;
      default:
        // No filter
        break;
    }

    setState(() {
      _filteredImage = filtered;
      _isLoading = false;
    });
  }

  Future<void> _saveImage() async {
    if (_filteredImage == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'filtered_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');

      final bytes = img.encodeJpg(_filteredImage!);
      await file.writeAsBytes(bytes);

      // Save to gallery
      final File imageFile = File(file.path);
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final result = await ImageGallerySaverPlus.saveImage(
      imageBytes,
      quality: 100,
      name: 'my_image_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Filters'),
        actions: [
          IconButton(
            onPressed: _filteredImage != null ? _saveImage : null,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            Uint8List.fromList(img.encodeJpg(_filteredImage!)),
                            fit: BoxFit.contain,
                          ),
                        )
                      : const Center(child: Text('No image loaded')),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Current Filter: $_currentFilter',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _currentFilter;

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => _applyFilter(filter),
                          selectedColor:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
