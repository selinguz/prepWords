import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prep_words/models/word.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'word_list'; 

  Future<List<WordModel>> fetchWords() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      return snapshot.docs.map((doc) => WordModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Kelime listesi alınırken hata oluştu: $e');
    }
  }

  Future<List<WordModel>> fetchWordsByUnit(int unitNumber) async {
    try {
      print('Aranan ünite numarası: $unitNumber'); // Debug için

      final QuerySnapshot querySnapshot = await _firestore
          .collection('word_list')
          .where('unit', isEqualTo: unitNumber)
          .get();

      print(
          'Bulunan döküman sayısı: ${querySnapshot.docs.length}'); // Debug için

      // Her bir dökümanın içeriğini kontrol edelim
      for (var doc in querySnapshot.docs) {
        print('Döküman verisi: ${doc.data()}'); // Debug için
      }

      return querySnapshot.docs
          .map((doc) => WordModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Hata detayı: $e'); 
      rethrow;
    }
  }
}
