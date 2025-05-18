import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:noodle/visual/widgets/shrinking_icon_button.dart';
import 'package:noodle/visual/widgets/text_input.dart';

class MediaPickerDialog extends StatefulWidget {
  @override
  _MediaPickerDialogState createState() => _MediaPickerDialogState();
}

class _MediaPickerDialogState extends State<MediaPickerDialog> {
  File? _selectedFile;
  String _fileName = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);

      if (file != null) {
        setState(() {
          _selectedFile = File(file.path);
          _fileName = file.name;
        });
      }
    } catch (e) {
      print('Error picking media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFCBBF7A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select media',
                style: TextStyle(
                  color: const Color(0xFF484135),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Geological',
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedFile != null) ...[
                isVideoFile(_selectedFile!.path)
                    ? Icon(Icons.videocam, size: 60, color: const Color(0xFF484135))
                    : Image.file(_selectedFile!, height: 100),
                const SizedBox(height: 16),
                Text(
                  'Selected file:',
                  style: TextStyle(
                    color: const Color(0xFF484135),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Geological',
                  ),
                ),
                Text(
                  _fileName,
                  style: TextStyle(
                    color: const Color(0xFF484135),
                    fontSize: 18,
                    fontFamily: 'Geological',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                TextInput.yellow(
                  hintText: 'File name',
                  onTextChanged: (value) => _fileName = value,
                ),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMediaButton(
                    icon: Icons.photo_library,
                    label: 'Photo',
                    onPressed: () => _pickMedia(ImageSource.gallery, false),
                  ),
                  _buildMediaButton(
                    icon: Icons.video_library,
                    label: 'Video',
                    onPressed: () => _pickMedia(ImageSource.gallery, true),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: const Color(0xFF484135),
                        fontSize: 18,
                        fontFamily: 'Geological',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7B35F),
                    ),
                    onPressed: _selectedFile == null
                        ? null
                        : () {
                            Navigator.pop(context, {
                              'file': _selectedFile,
                              'fileName': _fileName,
                            });
                          },
                    child: const Text(
                      'Download',
                      style:TextStyle(
                        color: const Color(0xFF484135),
                        fontSize: 18,
                        fontFamily: 'Geological',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 32, color: const Color(0xFF484135)),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF484135),
            fontSize: 18,
            fontFamily: 'Geological',
            fontWeight: FontWeight.w400,
            
          ),
        ),
      ],
    );
  }

  bool isVideoFile(String path) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    return videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
}