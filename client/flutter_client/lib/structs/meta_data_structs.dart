import 'package:intl/intl.dart';

abstract class AbstractMeta {
  final String name;
  
  AbstractMeta({required this.name});
}

class FileMetadata extends AbstractMeta {
  final String type;
  final int size;
  final DateTime modified;

  FileMetadata({
    required super.name,
    required this.type,
    required this.size,
    required this.modified,
  });

  String get formattedDate => DateFormat('MMMM d, y').format(modified);

  factory FileMetadata.fromJson(Map<String, dynamic> json) {
    return FileMetadata(
      name: json['name'],
      type: json['type'],
      size: json['size'],
      modified: DateTime.parse(json['last_modified']),
    );
  }

  bool get isTextFile => ['txt', 'pdf', 'doc', 'docx'].contains(type.toLowerCase());
}

class FolderMetadata extends AbstractMeta {
  final bool isFolder;

  FolderMetadata({
    required super.name,
    this.isFolder = true,
  });

  factory FolderMetadata.fromJson(Map<String, dynamic> json) {
    return FolderMetadata(
      name: json['name'],
      isFolder: json['is_folder'] ?? true,
    );
  }
}