import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/stocktake/invent_stocktake_recording.dart';

class StocktakeRepository {
  final ApiClient apiClient;

  StocktakeRepository(this.apiClient);

  Future<List<InventStockTakeRecording>> fetchStocktakeRecording() async {
    final res = await apiClient.dio.put(
      '/api/InventStockTakeRecording/GetStockTakeRecordingAsync',
    );
    final data = res.data['data'] as List<dynamic>?;
    if (data == null) return [];
    return data.map((m) => InventStockTakeRecording.fromJson(m)).toList();
  }
}
