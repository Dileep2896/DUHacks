import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> merchAccepted(String userId, String mercId) async {
  CollectionReference users = FirebaseFirestore.instance
      .collection('ChargingRequest')
      .doc(mercId)
      .collection("RequestedUser");
  return users.doc(userId).update({'accepted': true}).then((value) {
    updateCharger(userId, mercId);
    return true;
  }).catchError((error) {
    return false;
  });
}

void updateCharger(String userId, String mercId) {
  CollectionReference users = FirebaseFirestore.instance
      .collection('ChargingStations')
      .doc(mercId)
      .collection("chargers");

  users.doc('1').update({'isEngaged': true});
}
