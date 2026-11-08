import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  bool _isAnalyzing = false;

  String? _diseaseName;
  double? _confidence;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
        _diseaseName = null;
        _confidence = null;
      });
    } catch (e) {
      _showMessage('Unable to select image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) {
      _showMessage('Please select a leaf image first.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _diseaseName = null;
      _confidence = null;
    });

    try {
      // TODO: Connect your FastAPI /predict endpoint here.
      // Send _selectedImage to your API and receive the prediction.

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Temporary example result. Replace with your API response.
      setState(() {
        _diseaseName = 'Early Blight';
        _confidence = 0.94;
      });
    } catch (e) {
      _showMessage('Analysis failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _diseaseName = null;
      _confidence = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plant Disease Scanner',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Identify plant diseases using a leaf photograph.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 25),

              // Image preview
              Container(
                width: double.infinity,
                height: 270,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            size: 65,
                            color: colors.primary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No leaf image selected',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Take a photo or choose from gallery',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(19),
                        child: Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 270,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),

              const SizedBox(height: 18),

              // Camera and gallery buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),

              if (_selectedImage != null) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _isAnalyzing ? null : _removeImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove image'),
                  ),
                ),
              ],

              const SizedBox(height: 15),

              // Analyze button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _selectedImage == null || _isAnalyzing
                      ? null
                      : _analyzeImage,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    _isAnalyzing ? 'Analyzing leaf...' : 'Analyze Plant',
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // Result section
              if (_diseaseName != null && _confidence != null)
                _buildResultCard(theme, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme, ColorScheme colors) {
    final isHealthy = _diseaseName!.toLowerCase() == 'healthy';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Analysis Result',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Text('Detected condition', style: theme.textTheme.bodySmall),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  isHealthy ? Icons.check_circle : Icons.warning_amber,
                  color: isHealthy ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _diseaseName!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Model confidence: ${(_confidence! * 100).toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _confidence,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 12),
            Text(
              'This is a model prediction, not a confirmed diagnosis. '
              'Check the leaf and consider expert advice if symptoms persist.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
