import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:noodle/visual/widgets/text_input.dart';
import 'dart:math';

class FileUploadDialog extends StatefulWidget {
  @override
  _FileUploadDialogState createState() => _FileUploadDialogState();
}

class _FileUploadDialogState extends State<FileUploadDialog> {
  File? _selectedFile;
  String _fileName = '';
  String _fileSize = '';

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        setState(() {
          _selectedFile = File(file.path!);
          _fileName = file.name;
          _fileSize = _formatFileSize(file.size);
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
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
                'Выберите файл',
                style: TextStyle(
                  color: const Color(0xFF484135),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Geological',
                ),
              ),
              const SizedBox(height: 20),
              if (_selectedFile != null) ...[
                Icon(
                  Icons.insert_drive_file,
                  size: 60,
                  color: const Color(0xFF484135),
                ),
                const SizedBox(height: 16),
                Text(
                  'Выбранный файл:',
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
                const SizedBox(height: 4),
                Text(
                  'Размер: $_fileSize',
                  style: TextStyle(
                    color: const Color(0xFF484135).withOpacity(0.7),
                    fontSize: 16,
                    fontFamily: 'Geological',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 16),
                TextInput.yellow(
                  hintText: 'Название файла',
                  onTextChanged: (value) => _fileName = value,
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF484135),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _pickFile,
                child: Text(
                  _selectedFile == null ? 'Выбрать файл' : 'Заменить файл',
                  style: TextStyle(
                    color: const Color(0xFFCBBF7A),
                    fontSize: 18,
                    fontFamily: 'Geological',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Отмена',
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _selectedFile == null
                        ? null
                        : () {
                            Navigator.pop(context, {
                              'file': _selectedFile,
                              'fileName': _fileName,
                            });
                          },
                    child: Text(
                      'Загрузить',
                      style: TextStyle(
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
}