import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noodle/visual/widgets/buble_buttons.dart';

import 'package:noodle/visual/widgets/media_picker.dart';
import 'package:noodle/visual/widgets/file_picker.dart';

import 'dart:io';

class MainPage extends StatefulWidget {
  static const routeName = 'main';
  final Function(File f, String name) uploadFile;
  final Function(String path) toList;

  MainPage({
    super.key,
    required this.uploadFile,
    required this.toList,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  String currentPath ="";

  @override
  void initState(){
    super.initState();
    getList();
  }

  Future<void> getList() async{
    final L = await widget.toList(currentPath=='' ? '/' : currentPath);
    debugPrint("heh:");
    for(var x in L){
      debugPrint("heh: ${x.name}");
    }
  } 

  void MediaPickerCall() async {
    final result = await showDialog(
      context: context,
      builder: (context) => MediaPickerDialog(),
    );

    if (result != null) {
      File receivedFile = result['file'];
      String fileName = result['fileName'];


      widget.uploadFile(receivedFile, currentPath + fileName );
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


      widget.uploadFile(receivedFile, currentPath + fileName );
    }
  }

  void FolderCreationCall(){

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
                          onTap: () {},
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
                  const SizedBox(height: 30),
                  const Spacer(),
                  
                  const SizedBox(height: 30),
                ],
              ),
              BubleButtons(
                f1: MediaPickerCall,
                f2: FilePickerCall,
                f3: FolderCreationCall,
              )
            ],
          ),
        ),
      ),
    );
  }
}