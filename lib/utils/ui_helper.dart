import 'package:flutter/material.dart';

extension ScreenUtil on BuildContext {
  double s(double size) {
    // ambil lebar layar saat ini
    double screenWidth = MediaQuery.of(this).size.width;
    // 375.0 adlh standar lebar desain (biasanya iPhone X/11/12 Pro)
    double scale = screenWidth / 375.0;
    
    // batasi skala agar tidak terlalu ekstrem
    // min 85% (untuk HP kecil), maks 120% (untuk Tablet/HP Besar)
    scale = scale.clamp(0.85, 1.2); 
    
    // kembalikan ukuran yang sudah disesuaikan
    return size * scale;
  }
}