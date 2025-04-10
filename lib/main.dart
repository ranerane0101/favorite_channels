import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/channel_list_screen.dart';
import 'models/channel_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 AdMob 初期化
  // await MobileAds.instance.initialize();

  // 🔹 .env の読み込み（assets/.env に配置されていることを想定）
  await dotenv.load(fileName: ".env");

  // 🔹 Hive 初期化
  await Hive.initFlutter();
  Hive.registerAdapter(ChannelModelAdapter());
  await Hive.openBox<ChannelModel>('youtube_channels');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YouTube Favorite Channels',
      theme: ThemeData(primarySwatch: Colors.red),
      home: ChannelListScreen(),
    );
  }
}
