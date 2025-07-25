class KasirDashboardModel {
  final int totalProduk;
  final int totalSupplier;
  final int totalTransaksi;
  final Map<String, int> grafikTransaksi;
  final List<TransaksiTerbaru> transaksiTerbaru;

  KasirDashboardModel({
    required this.totalProduk,
    required this.totalSupplier,
    required this.totalTransaksi,
    required this.grafikTransaksi,
    required this.transaksiTerbaru,
  });

  factory KasirDashboardModel.fromJson(Map<String, dynamic> json) {
    return KasirDashboardModel(
      totalProduk: json['jumlah_produk'] ?? 0,
      totalSupplier: json['jumlah_supplier'] ?? 0,
      totalTransaksi: json['jumlah_transaksi'] ?? 0,
      grafikTransaksi: (json['grafik_transaksi'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value as int)),
      transaksiTerbaru: (json['transaksi_terbaru'] as List<dynamic>)
          .map((item) => TransaksiTerbaru.fromJson(item))
          .toList(),
    );
  }
}

class TransaksiTerbaru {
  final String kode;
  final String tanggal;
  final String total;

  TransaksiTerbaru({
    required this.kode,
    required this.tanggal,
    required this.total,
  });

  factory TransaksiTerbaru.fromJson(Map<String, dynamic> json) {
    return TransaksiTerbaru(
      kode: json['kode'] ?? '',
      tanggal: json['tanggal'] ?? '',
      total: json['total'] ?? '',
    );
  }
}
