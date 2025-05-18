import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noodle/structs/meta_data_structs.dart';

import 'package:noodle/visual/widgets/buble_buttons.dart';
import 'package:noodle/visual/widgets/media_picker.dart';
import 'package:noodle/visual/widgets/file_picker.dart';
import 'package:noodle/visual/widgets/profile_dialog.dart';
import 'package:noodle/visual/widgets/meta_list.dart';
import 'package:noodle/visual/widgets/folder_creation_dialog.dart';
import 'package:noodle/visual/widgets/rename_dialog.dart';

import 'package:noodle/services/storage.dart';
import 'dart:io';

class MainPage extends StatefulWidget {
  static const routeName = 'main';
  final Function(File f, String name) uploadFile;
  final Function(String path) toList;
  final Function(String path) createFolder;
  final Function() logout;
  final Function(String path) downloadFile;
  final Function(String path) deleteFile;
  final Function(String path) deleteFolder;
  final Function(String path, String newName) rename;

  MainPage({
    super.key,
    required this.uploadFile,
    required this.downloadFile,
    required this.toList,
    required this.createFolder,
    required this.logout,
    required this.deleteFile,
    required this.deleteFolder,
    required this.rename,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  String currentPath ="";
  late List<AbstractMeta> L = [];

  @override
  void initState(){
    super.initState();
    getList();
  }

  Future<void> getList() async{
    L = await widget.toList(currentPath);
    setState((){});
  }

  void MediaPickerCall() async {
    final result = await showDialog(
      context: context,
      builder: (context) => MediaPickerDialog(),
    );

    if (result != null) {
      File receivedFile = result['file'];
      String fileName = result['fileName'];


      await widget.uploadFile(receivedFile, currentPath + fileName );
      getList();
    }
  }

  void FilePickerCall() async {
    final result = await showDialog(
      context: context,
      builder: (context) => FileUploadDialog(),
    );

    if (result != null) {
      File receivedFile = result['file'];
      String fileName = result['fileName'];


      await widget.uploadFile(receivedFile, currentPath + fileName );
      getList();
    }
  }

  void FolderCreationCall()async{
    final result = await showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(),
    );

    await widget.createFolder("${currentPath}${result}/");
    
    getList();
  }


  void folderTap(FolderMetadata f){
    
    currentPath = "${currentPath}${f.name}/";
    print("File name: ${currentPath}");
    getList();
  }

  void back() {
    if (currentPath.isEmpty || currentPath == '/') {
      return; // Уже в корне, дальше некуда идти
    }

    // Удаляем trailing slash если есть
    String normalizedPath = currentPath.endsWith('/') 
        ? currentPath.substring(0, currentPath.length - 1)
        : currentPath;

    // Находим последний слеш
    final lastSlashIndex = normalizedPath.lastIndexOf('/');
    
    if (lastSlashIndex == -1) {
      // Нет слешей - переходим в корень
      currentPath = '';
    } else if (lastSlashIndex == 0) {
      // Это последний слеш в пути (первый символ)
      currentPath = '';
    } else {
      // Обрезаем до предыдущего уровня
      currentPath = normalizedPath.substring(0, lastSlashIndex+1);
    }
    print(currentPath);
    getList(); // Обновляем список файлов
  }

  void onDownload(FileMetadata f){
    widget.downloadFile("${currentPath}${f.name}");
  }

  void onDelete(AbstractMeta f) async {
    if(f is FileMetadata){
      await widget.deleteFile("${currentPath}${f.name}");
    }else if(f is FolderMetadata){
      await widget.deleteFolder("${currentPath}${f.name}");
    }
    getList();
  }

  void rename(FileMetadata file) async {
    String fileName = await showDialog<String>(
      context: context,
      builder: (context) => RenameDialog(currentName: file.name),
    ) ?? file.name;
    String serverPath = "${currentPath}${file.name}";
  
    // Проверяем наличие расширения в serverPath
    if (!fileName.contains('.')) {
      // Если расширения нет, добавляем из оригинального файла
      final originalName = file.name;
      final extension = originalName.contains('.') 
          ? '.${originalName.split('.').last}'
          : '';
      fileName = '$fileName$extension';
      
    }
    print(fileName);
    print(serverPath);
    if (fileName != null && fileName != file.name) {
      await widget.rename(serverPath, fileName);
      getList(); // Обновляем список
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFF484135),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            
                            width: 330,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24) 
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        GestureDetector(
                          onTap: () async { 
                            final username = await NoodleStorage.getUsername();
                            showDialog(
                              context: context,
                              builder: (context) => ProfileDialog(
                                imageUrl: "assets/images/Profile_photo.png", 
                                username:username ?? 'NONE',
                                logout: widget.logout), 
                            );
                          },
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C1C1C),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: SvgPicture.asset(
                              'assets/images/Account.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  currentPath == "" ? const SizedBox(height: 20) :
                  SizedBox(
                    height: 34,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/images/arrow_right.svg",
                          width: 24,
                          height: 24,
                        ),
                        Text(
                          currentPath.substring(0, currentPath.length - 1),
                          style: TextStyle(
                            fontFamily: "Geologica",
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFFFFFFF),
                          ),
                        )
                      ],
                    ),
                  ),

                  Expanded(
                    child: MetaListWidget(
                      items: L,
                      folderIconPath: "assets/images/folder_filled.svg",
                      textFileIconPath: "assets/images/File_text.svg",
                      otherFileIconPath: "assets/images/File_yellow.svg",
                      onFolderTap: folderTap,
                      onDelete: onDelete,
                      onDownload: onDownload,
                      rename: rename
                    )
                  ),
                  const SizedBox(height: 30),
                ],
              ),
              BubleButtons(
                f1: MediaPickerCall,
                f2: FilePickerCall,
                f3: FolderCreationCall,
                ret: currentPath == "" ? null : back
              )
            ],
          ),
        ),
      ),
    );
  }
}