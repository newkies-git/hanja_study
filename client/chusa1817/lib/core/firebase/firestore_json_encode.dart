import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore 문서 맵을 [jsonEncode] 가능한 형태로 바꾼 뒤 JSON 문자열로 만든다.
///
/// [Timestamp], [GeoPoint], [DocumentReference] 등은 JSON 기본 인코더가 처리하지 못한다.
String jsonEncodeFirestoreMap(Map<String, dynamic> data) {
  return jsonEncode(_firestoreValueToJson(data));
}

dynamic _firestoreValueToJson(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate().toIso8601String();
  if (value is DateTime) return value.toIso8601String();
  if (value is DocumentReference) return value.path;
  if (value is GeoPoint) {
    return <String, double>{
      'latitude': value.latitude,
      'longitude': value.longitude,
    };
  }
  if (value is Map) {
    return value.map(
      (dynamic k, dynamic v) => MapEntry(k.toString(), _firestoreValueToJson(v)),
    );
  }
  if (value is Iterable) {
    return value.map(_firestoreValueToJson).toList();
  }
  return value;
}
