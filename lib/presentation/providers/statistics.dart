import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klasio/data/datasources/statistics.dart';
import 'package:klasio/domain/entities/statistics.dart';

final statisticsDatasourceProvider = Provider<StatisticsDatasource>(
  (ref) => StatisticsDatasource(),
);

final statisticsNotifierProvider =
    AsyncNotifierProvider<StatisticsNotifier, Statistics>(
      StatisticsNotifier.new,
    );

class StatisticsNotifier extends AsyncNotifier<Statistics> {
  late final StatisticsDatasource _ds;

  @override
  Future<Statistics> build() async {
    _ds = ref.read(statisticsDatasourceProvider);

    final result = await _ds.getStatistics();

    return result;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _ds.getStatistics();
      return result;
    });
  }
}
