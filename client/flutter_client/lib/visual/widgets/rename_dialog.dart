import 'package:flutter/material.dart';
import 'package:noodle/visual/widgets/text_input.dart'; // Предполагается, что TextInput.yellow существует

class RenameDialog extends StatefulWidget {
  final String currentName;

  const RenameDialog({super.key, required this.currentName});

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late String newName;

  @override
  void initState() {
    super.initState();
    newName = widget.currentName;
  }

  void updateName(String s) {
    setState(() {
      newName = s;
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
              'Rename',
              style: TextStyle(
                color: const Color(0xFF484135),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Geological',
              ),
            ),
            const SizedBox(height: 20),
            TextInput.yellow(
              hintText: 'Enter new name',
              onTextChanged: updateName,
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
                    if (newName.trim().isNotEmpty) {
                      Navigator.pop(context, newName.trim());
                    }
                  },
                  child: const Text(
                    'Rename',
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