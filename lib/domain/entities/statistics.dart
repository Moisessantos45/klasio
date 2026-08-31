import 'package:klasio/domain/entities/capture.dart';
import 'package:klasio/domain/entities/folder.dart';

class Statistics {
  final int totalCaptures;
  final int totalFolders;
  final FolderWithTotal recentFolders;
  final CaptureWithTotal lastCaptures;

  Statistics({
    required this.totalCaptures,
    required this.totalFolders,
    required this.recentFolders,
    required this.lastCaptures,
  });
}
