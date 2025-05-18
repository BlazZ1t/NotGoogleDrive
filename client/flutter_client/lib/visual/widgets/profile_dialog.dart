import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  final String imageUrl;
  final String username;

  final VoidCallback logout;

  const ProfileDialog({
    super.key,
    required this.imageUrl,
    required this.username,
    required this.logout
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(23),
            width: 310,
            decoration: BoxDecoration(
              color: const Color(0xFFE7E7E7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 141,
                  height: 141,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF484135),
                      width: 3,
                    ),
                    image: DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 310,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 23,
                            child: Text(
                              'Username:\n',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: "Geological",
                                fontSize: 18,
                                color: Color(0xFF484135)
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          SizedBox(
                            height: 23,
                            child: Text(
                              username,
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontFamily: "Geological",
                                fontSize: 18,
                                color: Color(0xFF484135)
                              ),
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: logout, 
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFE7B35F)
                          ),                          
                          child: Text(
                            "Log out",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: "Geological",
                              fontSize: 18,
                              color: Color(0xFF484135)
                            ),
                          ),
                        ),
                        
                      )

                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -5,
            left: -5,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black,
                size: 32,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}