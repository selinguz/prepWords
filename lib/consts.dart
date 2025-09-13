import 'package:flutter/material.dart';

// 🌿 Verilen 4 ana renk
const Color green = Color(0xFF0A7029);
const Color yellow = Color(0xFFFEDE00);
const Color yellowGreen = Color(0xFFC8DF52);
const Color mint = Color(0xFFDBE8D8);

// 🔹 Sekonder destek renkleri
const Color secondaryGreen = yellowGreen; // destekleyici yeşil ton
const Color secondaryBlue = mint; // ferahlatıcı mint, mavi yerine geçti
const Color secondaryOrange = yellow; // turuncu yerine sarı vurgusu

// 🔹 Ana renkler
const Color primary = green; // ana vurgu yeşil
const Color secondary = yellow; // ikinci vurgu sarı
const Color backgrnd = Color(0xFFFDFDF9); // hafif krem-beyaz
const Color textWhiteColor = Colors.white;
const Color textGreyColor = Color(0xFF2E2E2E); // koyu nötr gri
const Color cardFrontColor = green; // kart ön yüzü koyu yeşil
const Color cardBackColor = mint; // kart arka yüzü mint
const Color warnOrange =
    Color(0xFFE67E22); // gerektiğinde kontrast için sıcak turuncu

// 🔹 Kelime türleri için kategori renkleri
const Color nounsFront = Color(0xFF0A7029);
const Color nounsBack = Color(0xFFC8DF52);

const Color adjsFront = Color(0xFFF5C200);
const Color adjsBack = Color(0xFFFFF9CC);

const Color verbsFront = Color(0xFFD9534F);
const Color verbsBack = Color(0xFFF8D6D6);

const Color advsFront = Color(0xFFFF8C42);
const Color advsBack = Color(0xFFFFE5B4);

Color getFrontColor(String wordType) {
  switch (wordType) {
    case 'Noun - İsim':
      return nounsFront;
    case 'Adjective - Sıfat':
      return adjsFront;
    case 'Verb - Fiil':
      return verbsFront;
    case 'Adverb - Zarf':
      return advsFront;
    default:
      return Colors.grey; // Varsayılan renk
  }
}

Color getBackColor(String wordType) {
  switch (wordType) {
    case 'Noun - İsim':
      return nounsBack;
    case 'Adjective - Sıfat':
      return adjsBack;
    case 'Verb - Fiil':
      return verbsBack;
    case 'Adverb - Zarf':
      return advsBack;
    default:
      return Colors.grey[200]!; // Varsayılan renk
  }
}

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
