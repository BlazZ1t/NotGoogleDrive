

class FileMetadata {
  final String name;
  final String path;
  final int size;
  final DateTime modified;

  FileMetadata({
    required this.name,
    required this.path,
    required this.size,
    required this.modified,
  });

  factory FileMetadata.fromJson(Map<String, dynamic> json) {
    return FileMetadata(
      name: json['name'],
      path: json['path'],
      size: json['size'],
      modified: DateTime.parse(json['modified']),
    );
  }
}

class FolderMetadata {
  final String name;
  final String path;

  FolderMetadata({
    required this.name,
    required this.path,
  });

  factory FolderMetadata.fromJson(Map<String, dynamic> json) {
    return FolderMetadata(
      name: json['name'],
      path: json['path'],
    );
  }
}