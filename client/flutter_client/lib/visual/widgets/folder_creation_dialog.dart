import 'package:flutter/material.dart';
import 'package:noodle/visual/widgets/text_input.dart';

class CreateFolderDialog extends StatefulWidget {
  const CreateFolderDialog({super.key});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  String folderName = "";

  @override
  void dispose() {
    super.dispose();
  }

  void updateFolderName(String s){
    setState((){
      folderName = s;
      debugPrint(folderName);
    });
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Create a folder',
              style: TextStyle(
                color: const Color(0xFF484135),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Geological',
              ),
            ),
            const SizedBox(height: 20),
            TextInput.yellow(
              hintText: 'Enter folder name',
              onTextChanged: updateFolderName,
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
                  onPressed: () {
                    if (folderName.trim().isNotEmpty) {
                      Navigator.pop(context, folderName.trim());
                    }
                  },
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      color: Color(0xFF484135),
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
    );
  }
}