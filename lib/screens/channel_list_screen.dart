import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/channel_model.dart';
import '../utils/youtube_api.dart';
import 'how_to_use_page.dart';

class ChannelListScreen extends StatefulWidget {
  @override
  _ChannelListScreenState createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends State<ChannelListScreen> {
  final _channelBox = Hive.box<ChannelModel>('youtube_channels');
  final _urlController = TextEditingController();
  bool _isLoading = false;

  RewardedAd? _rewardedAd;
  bool _isRewardEarned = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    final adUnitId = dotenv.env['ADMOB_REWARDED_AD_UNIT_ID'];
    if (adUnitId == null || adUnitId.isEmpty) return;

    RewardedAd.load(
      adUnitId: adUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  Future<bool> _showRewardedAd() async {
    if (_rewardedAd == null) return false;
    _isRewardEarned = false;
    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedAd();
        completer.complete(_isRewardEarned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewardedAd();
        completer.complete(false);
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        _isRewardEarned = true;
      },
    );

    return completer.future;
  }

  bool _requiresAd(int nextIndex) {
    return (nextIndex - 1) % 7 == 0 && nextIndex >= 8;
  }

  void _addChannel() async {
    final nextIndex = _channelBox.length + 1;

    if (_requiresAd(nextIndex)) {
      final adWatched = await _showRewardedAd();
      if (!adWatched) {
        _showError("このチャンネルを登録するには広告を視聴してください。");
        return;
      }
    }

    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError("チャンネルのURLを入力してください。");
      return;
    }

    final channelId = _extractChannelId(url);
    if (channelId == null) {
      _showError(
        "入力されたURLを確認してください。\n\n"
        "・YouTubeの公式サイトからチャンネルURLをコピーしてください。\n"
        "・URLは以下のような形式である必要があります:\n"
        "  ✅ https://www.youtube.com/@channelName\n"
        "  ✅ https://www.youtube.com/channel/UCxxxxx",
      );
      return;
    }

    setState(() => _isLoading = true);

    final channelInfo = await YouTubeAPI.fetchChannelInfo(channelId);

    setState(() => _isLoading = false);

    if (channelInfo == null) {
      _showError("チャンネル情報の取得に失敗しました。URLを確認してください。");
      return;
    }

    final channel = ChannelModel(
      name: channelInfo["title"]!,
      url: url,
      iconUrl: channelInfo["iconUrl"],
    );

    await _channelBox.put(channel.name, channel);
    _urlController.clear();
    setState(() {});
  }

  String? _extractChannelId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains("youtube.com") && uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments[0] == "channel") {
        return uri.pathSegments[1];
      } else if (uri.pathSegments[0] == "c" || uri.pathSegments[0] == "user") {
        return uri.pathSegments[1];
      } else if (uri.pathSegments[0].startsWith('@')) {
        return uri.pathSegments[0];
      }
    }
    if (uri.host == "youtu.be" && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments[0];
    }

    return null;
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("ご確認ください"),
        content: Text(message),
        actions: [
          TextButton(
            child: Text("閉じる"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index, ChannelModel channel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("本当に削除しますか？"),
        content: Text("\"${channel.name}\" を削除してもよろしいですか？"),
        actions: [
          TextButton(
            child: Text("キャンセル"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("削除", style: TextStyle(color: Colors.red)),
            onPressed: () {
              _channelBox.deleteAt(index);
              setState(() {});
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('チャンネルリスト',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HowToUsePage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white12,
                      labelText: 'チャンネルURLを入力',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 10),
                _isLoading
                    ? CircularProgressIndicator()
                    : IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.red, size: 30),
                        onPressed: _addChannel,
                      ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _channelBox.listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return Center(
                      child: Text('登録されたチャンネルがありません',
                          style: TextStyle(color: Colors.white70, fontSize: 16)));
                }
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final channel = box.getAt(index);
                    if (channel is! ChannelModel) return SizedBox.shrink();
                    return Card(
                      color: Colors.white12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: channel.iconUrl != null && channel.iconUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(channel.iconUrl!,
                                    width: 50, height: 50, fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.broken_image,
                                          color: Colors.grey);
                                    }),
                              )
                            : Icon(Icons.video_collection, size: 50, color: Colors.grey),
                        title: Text(channel.name,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text("タップして開く",
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse(channel.url))) {
                            await launchUrl(Uri.parse(channel.url));
                          } else {
                            _showError("YouTubeを開けませんでした");
                          }
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDelete(index, channel);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
