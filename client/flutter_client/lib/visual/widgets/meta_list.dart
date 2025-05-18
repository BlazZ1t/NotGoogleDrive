import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:noodle/structs/meta_data_structs.dart';

class MetaListWidget extends StatelessWidget {
  final List<AbstractMeta> items;
  final Function(FolderMetadata)? onFolderTap;
  final Function(FileMetadata)? onDownload;
  final Function(AbstractMeta)? onDelete;
  final Function(FileMetadata)? rename;
  final String folderIconPath;
  final String textFileIconPath;
  final String otherFileIconPath;
  final Color iconColor;

  const MetaListWidget({
    super.key,
    required this.items,
    this.onFolderTap,
    this.onDownload,
    this.onDelete,
    this.rename,
    required this.folderIconPath,
    required this.textFileIconPath,
    required this.otherFileIconPath,
    this.iconColor = const Color(0xFFE7E7E7),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildListItem(item);
      },
    );
  }

  Widget _buildListItem(AbstractMeta item) {
    if (item is FolderMetadata) {
      return _buildFolderItem(item);
    } else if (item is FileMetadata) {
      return _buildFileItem(item);
    }
    return const SizedBox.shrink();
  }

  Widget _buildFolderItem(FolderMetadata folder) {
    return InkWell(
      onTap: () => onFolderTap?.call(folder),
      child: _MetaCard(
        iconPath: folderIconPath,
        title: folder.name,
        isFolder: true,
        onDelete: onDelete != null ? () => onDelete!(folder) : null,
      ),
    );
  }

  Widget _buildFileItem(FileMetadata file) {
    return _MetaCard(
      iconPath: file.isTextFile ? textFileIconPath : otherFileIconPath,
      title: file.name,
      subtitle: file.formattedDate,
      trailing: '${(file.size / 1024).toStringAsFixed(1)} KB',
      onDownload: onDownload != null ? () => onDownload!(file) : null,
      onDelete: onDelete != null ? () => onDelete!(file) : null,
      rename: rename != null ? () => rename!(file) : null,
    );
  }
}

class _MetaCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String? subtitle;
  final String? trailing;
  final bool isFolder;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? rename;

  const _MetaCard({
    required this.iconPath,
    required this.title,
    this.subtitle,
    this.trailing,
    this.isFolder = false,
    this.onDownload,
    this.onDelete,
    this.rename
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "Geologica",
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFE7E7E7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isFolder && subtitle != null && trailing != null)
                    Text(
                      "${trailing!} • ${subtitle!}",
                      style: TextStyle(
                        letterSpacing: -0.05,
                        fontFamily: "Geologica",
                        fontSize: 14,
                        fontWeight: FontWeight.w100,
                        color: Color(0xFFE7E7E7),
                      ),
                    ),
                ],
              ),
            ),
            _buildFileMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFileMenu(BuildContext context) {
    return PopupMenuButton(
      icon: SvgPicture.asset(
        "assets/images/Menu.svg",
        width: 28,
      ),
      itemBuilder: (context) => [
        if (!isFolder)
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.download, color: Color(0xFFE7B35F)),
              title: Text(
                'Download',
                style: TextStyle(
                  fontFamily: "Geologica",
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFE7E7E7),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onDownload?.call();
              },
            ),
          ), 
        if (!isFolder)
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.edit , color: Color(0xFFE7B35F)),
              title: Text(
                'Rename',
                style: TextStyle(
                  fontFamily: "Geologica",
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFE7E7E7),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                rename?.call();
              },
            ),
          ), 
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.delete, color: Color(0xFFE7B35F)),
            title: Text(
              'Delete',
              style: TextStyle(
                fontFamily: "Geologica",
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFFE7E7E7),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete?.call();
            },
          ),
        ),
      ],
      offset: Offset(0, -100), // Смещение меню вверх
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Color(0xFFE7B35F).withOpacity(0.2)),
      ),
      color: Color(0xFF484135), // Цвет фона меню
    );
  }
}