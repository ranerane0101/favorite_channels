import 'package:flutter/material.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('このアプリの使い方'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("\u{1F4CC} アプリの基本操作",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 16),
            Text("1. 上部の入力欄にYouTubeチャンネルのURLを貼り付けます。",
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 12),
            Text("2. 右側の ➕ ボタンをタップすると、お気に入りチャンネルとして保存されます。",
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 12),
            Text("3. 保存されたチャンネルは一覧で表示され、タップするとYouTubeで開きます。",
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 12),
            Text("4. ごみ箱アイコンをタップするとチャンネルを削除できます。",
                style: TextStyle(fontSize: 16, color: Colors.white70)),
            SizedBox(height: 24),
            Divider(color: Colors.grey),
            SizedBox(height: 16),
            Text("\u{1F517} 対応しているチャンネルURLの形式",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 12),
            Text("✅ https://www.youtube.com/@channelName\n✅ https://www.youtube.com/channel/UCxxxxx",
                style: TextStyle(fontSize: 15, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
