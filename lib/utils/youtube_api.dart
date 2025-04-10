import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YouTubeAPI {
  static final String _apiKey = dotenv.env['YOUTUBE_API_KEY'] ?? "";
  static const String _baseUrl = "https://www.googleapis.com/youtube/v3";

  /// 🔹 `@channelName` から `channelId` を取得
  static Future<String?> _resolveChannelId(String handle) async {
    final url = Uri.parse("$_baseUrl/channels?part=id&forHandle=$handle&key=$_apiKey");

    final response = await http.get(url);
    print("🔹 チャンネルID取得API: $url");
    print("🔹 APIレスポンス: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] != null && data['items'].isNotEmpty) {
        return data['items'][0]['id'];
      }
    }
    return null;
  }

  /// 🔹 チャンネル情報を取得
  static Future<Map<String, String>?> fetchChannelInfo(String input) async {
    String finalChannelId = input;

    // 🔹 `@channelName` の場合、チャンネルIDを取得
    if (input.startsWith('@')) {
      final resolvedId = await _resolveChannelId(input);
      if (resolvedId != null) {
        finalChannelId = resolvedId;
      } else {
        print("❌ チャンネルIDを取得できませんでした");
        return null;
      }
    }

    final url = Uri.parse("$_baseUrl/channels?part=snippet&id=$finalChannelId&key=$_apiKey");

    final response = await http.get(url);
    print("🔹 API URL: $url");
    print("🔹 API レスポンス: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] == null || data['items'].isEmpty) {
        print("❌ チャンネル情報が見つかりませんでした");
        return null;
      }

      final snippet = data['items'][0]['snippet'];
      return {
        "title": snippet["title"],
        "iconUrl": snippet["thumbnails"]["high"]["url"] ?? "",
      };
    }

    print("❌ APIリクエスト失敗: ${response.statusCode}");
    return null;
  }
}
