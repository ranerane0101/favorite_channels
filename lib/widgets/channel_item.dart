import 'package:flutter/material.dart';
import '../models/channel_model.dart';

class ChannelItem extends StatelessWidget {
  final ChannelModel channel;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  ChannelItem({required this.channel, required this.onDelete, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: channel.iconUrl != null && channel.iconUrl!.isNotEmpty
          ? Image.network(
              channel.iconUrl!,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.broken_image, color: Colors.grey);
              },
            )
          : Icon(Icons.video_collection, size: 40, color: Colors.grey),

      title: Text(
        channel.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),

      subtitle: Text(
        _shortenUrl(channel.url),
        style: TextStyle(color: Colors.grey),
      ),

      onTap: onTap,

      trailing: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: onDelete,
      ),

      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  /// 🔹 URLを省略表示する（例: "https://www.youtube.com/...channelID"）
  String _shortenUrl(String url) {
    if (url.length > 30) {
      return url.substring(0, 27) + "...";
    }
    return url;
  }
}
