import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class CollageScreen extends StatefulWidget {
  final List<String> imagePaths;

  const CollageScreen({super.key, required this.imagePaths});

  @override
  State<CollageScreen> createState() => _CollageScreenState();
}

class _CollageScreenState extends State<CollageScreen> {
  List<img.Image> _images = [];
  img.Image? _collageImage;
  bool _isLoading = true;
  String _currentLayout = 'Grid';

  final List<String> _layouts = ['Grid', 'Horizontal', 'Vertical', 'Mosaic'];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    try {
      List<img.Image> loadedImages = [];
      
      for (String path in widget.imagePaths) {
        final bytes = await File(path).readAsBytes();
        final image = img.decodeImage(bytes);
        if (image != null) {
          // Resize for better performance
          loadedImages.add(img.copyResize(image, width: 400));
        }
      }
      
      setState(() {
        _images = loadedImages;
        _isLoading = false;
      });
      
      _createCollage(_currentLayout);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading images: $e')),
        );
      }
    }
  }

  Future<void> _createCollage(String layout) async {
    if (_images.isEmpty) return;

    setState(() {
      _isLoading = true;
      _currentLayout = layout;
    });

    img.Image? collage;

    switch (layout) {
      case 'Grid':
        collage = _createGridCollage();
        break;
      case 'Horizontal':
        collage = _createHorizontalCollage();
        break;
      case 'Vertical':
        collage = _createVerticalCollage();
        break;
      case 'Mosaic':
        collage = _createMosaicCollage();
        break;
    }

    setState(() {
      _collageImage = collage;
      _isLoading = false;
    });
  }

  img.Image _createGridCollage() {
    final int cols = (_images.length <= 4) ? 2 : 3;
    final int rows = (_images.length / cols).ceil();
    const int cellWidth = 200;
    const int cellHeight = 200;
    
    final collage = img.Image(
      width: cols * cellWidth,
      height: rows * cellHeight,
    );
    img.fill(collage, color: img.ColorRgb8(255, 255, 255));

    for (int i = 0; i < _images.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      final resized = img.copyResize(_images[i], width: cellWidth, height: cellHeight);
      
      img.compositeImage(
        collage,
        resized,
        dstX: col * cellWidth,
        dstY: row * cellHeight,
      );
    }

    return collage;
  }

  img.Image _createHorizontalCollage() {
    final int totalWidth = _images.length * 200;
    const int height = 300;
    
    final collage = img.Image(width: totalWidth, height: height);
    img.fill(collage, color: img.ColorRgb8(255, 255, 255));

    for (int i = 0; i < _images.length; i++) {
      final resized = img.copyResize(_images[i], width: 200, height: height);
      img.compositeImage(collage, resized, dstX: i * 200, dstY: 0);
    }

    return collage;
  }

  img.Image _createVerticalCollage() {
    const int width = 300;
    final int totalHeight = _images.length * 200;
    
    final collage = img.Image(width: width, height: totalHeight);
    img.fill(collage, color: img.ColorRgb8(255, 255, 255));

    for (int i = 0; i < _images.length; i++) {
      final resized = img.copyResize(_images[i], width: width, height: 200);
      img.compositeImage(collage, resized, dstX: 0, dstY: i * 200);
    }

    return collage;
  }

  img.Image _createMosaicCollage() {
    // Create a more complex mosaic layout
    final collage = img.Image(width: 600, height: 600);
    img.fill(collage, color: img.ColorRgb8(255, 255, 255));

    if (_images.isEmpty) return collage;

    // Define different sized rectangles for mosaic effect
    final List<Map<String, int>> positions = [
      {'x': 0, 'y': 0, 'w': 300, 'h': 300},
      {'x': 300, 'y': 0, 'w': 300, 'h': 150},
      {'x': 300, 'y': 150, 'w': 150, 'h': 150},
      {'x': 450, 'y': 150, 'w': 150, 'h': 150},
      {'x': 0, 'y': 300, 'w': 200, 'h': 200},
      {'x': 200, 'y': 300, 'w': 200, 'h': 200},
      {'x': 400, 'y': 300, 'w': 200, 'h': 200},
    ];

    for (int i = 0; i < _images.length && i < positions.length; i++) {
      final pos = positions[i];
      final resized = img.copyResize(
        _images[i],
        width: pos['w']!,
        height: pos['h']!,
      );
      
      img.compositeImage(
        collage,
        resized,
        dstX: pos['x']!,
        dstY: pos['y']!,
      );
    }

    return collage;
  }

  Future<void> _saveCollage() async {
    if (_collageImage == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'collage_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${directory.path}/$fileName');
      
      final bytes = img.encodeJpg(_collageImage!);
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
          const SnackBar(content: Text('Collage saved to gallery!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving collage: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Collage'),
        actions: [
          IconButton(
            onPressed: _collageImage != null ? _saveCollage : null,
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
                  : _collageImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            Uint8List.fromList(img.encodeJpg(_collageImage!)),
                            fit: BoxFit.contain,
                          ),
                        )
                      : const Center(child: Text('No collage created')),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Layout: $_currentLayout (${_images.length} images)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _layouts.length,
                    itemBuilder: (context, index) {
                      final layout = _layouts[index];
                      final isSelected = layout == _currentLayout;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(layout),
                          selected: isSelected,
                          onSelected: (_) => _createCollage(layout),
                          selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
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
