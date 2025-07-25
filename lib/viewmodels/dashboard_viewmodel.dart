import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardViewModel with ChangeNotifier {
  int totalProduk = 0;
  int totalSupplier = 0;
  Map<String, int> grafikTransaksi = {};
  List<Map<String, dynamic>> transaksiTerbaru = [];
  bool isLoading = true;

  Future<void> fetchDashboardData() async {
    isLoading = true;
    notifyListeners();

    final response = await ApiService.get('/dashboard/kasir');

    if (response != null) {
      totalProduk = response['total_produk'];
      totalSupplier = response['total_supplier'];
      grafikTransaksi = Map<String, int>.from(response['grafik_transaksi']);
      transaksiTerbaru = List<Map<String, dynamic>>.from(response['transaksi_terbaru']);
    }

    isLoading = false;
    notifyListeners();
  }
}
