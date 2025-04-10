import 'package:hive/hive.dart';

part 'channel_model.g.dart';

@HiveType(typeId: 0)
class ChannelModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String? iconUrl;

  ChannelModel({required this.name, required this.url, this.iconUrl});
}
