import 'package:flutter/material.dart';

const Color secondaryGreen = Color(0xFFA8D08D);
const Color secondaryBlue = Color(0xFFDDECF9);
const Color secondaryOrange = Color(0xFFFFE8CC);

const Color primary = Color(0xFFF5A623);
const Color secondary = Color(0xFF23A6F5);
const Color backgrnd = Color(0xFFF7F7F7);
const Color textWhiteColor = Colors.white;
const Color textGreyColor = Color(0xFF4A4A4A);
const Color cardFrontColor = Color(0xFF333333);
const Color cardBackColor = Color(0xFFF8F8F8);
const Color warnOrange = Color(0xFFFF715B);

/*
Ana Renk: Uygulama başlığı, kategori butonları ve önemli öğeler için kullanın.
Vurgu Rengi: Bildirimler, ilerleme çubuğu veya butonların dikkat çekmesi gereken yerlerinde tercih edin.
Arka Plan: Temiz ve düzenli bir arka plan ile uygulamanın dağınık görünmesini engelleyin.
Metin Renkleri: Koyu gri tonları metinler için en iyi seçimdir, göz yormaz.


Turuncu (#F5A623):
Uygulamanın ana başlıkları, önemli butonlar ve ikonlar için kullanılabilir. Örneğin: "Başla" ya da "Devam Et" gibi ana eylem butonları.
Mavi (#23A6F5):
Sekonder aksan renk olarak kullanılabilir. Örneğin, "Kaydet" butonları veya bilgi mesajları için.
Beyaz (#FFFFFF):
Arka plan rengi olarak kullanılmalı. Temiz ve modern bir görünüm sağlar.
Açık Gri (#F8F8F8):
Kartların arka planı ya da alanları birbirinden ayırmak için.
Pastel Turuncu (#FFE8CC):
Hafif göze çarpması gereken öğeler veya dolgu alanları için.
Kırmızımsı Turuncu (#FF715B):
Uyarı mesajları ya da hızlı aksiyon gerektiren durumlar için.
 */

// Typography - Headings (Montserrat)
const TextStyle headingLarge = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 24,
  fontWeight: FontWeight.w600, // SemiBold
  color: textGreyColor,
);

const TextStyle headingMedium = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 20,
  fontWeight: FontWeight.w500, // Medium
  color: textGreyColor,
);

const TextStyle headingSmall = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 18,
  fontWeight: FontWeight.w500, // Medium
  color: textGreyColor,
);

// Typography - Body (Nunito)
const TextStyle bodyLarge = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 16,
  fontWeight: FontWeight.w500, // Medium
  color: textGreyColor,
);

const TextStyle bodyMedium = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 14,
  fontWeight: FontWeight.normal, // Regular
  color: textGreyColor,
);

const TextStyle bodySmall = TextStyle(
  fontFamily: 'Nunito',
  fontSize: 12,
  fontWeight: FontWeight.normal, // Regular
  color: textGreyColor,
);

// İtalik stiller
const TextStyle italicText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 14,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.italic,
  color: textGreyColor,
);

// Button Text Style
const TextStyle whiteButtonText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontWeight: FontWeight.w600, // SemiBold
  color: textWhiteColor,
);

const TextStyle greyButtonText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 16,
  fontWeight: FontWeight.w600, // SemiBold
  color: textGreyColor,
);

// Özel durumlar için extension
extension TextStyleExtension on TextStyle {
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
}
