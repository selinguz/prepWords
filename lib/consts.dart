import 'dart:ui';

import 'package:flutter/material.dart';

const Color secondaryGreen = Color(0xFFA8D08D);
const Color secondaryBlue = Color(0xFFDDECF9);
const Color secondaryOrange = Color(0xFFFFE8CC);

const Color primary = Color(0xFFF5A623);
const Color secondary = Color(0xFF23A6F5);
const Color backgrnd = Color(0xffffffff);
const Color textWhiteColor = Color(0xffffffff);
const Color textGreyColor = Color(0xFF333333);
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

double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}
