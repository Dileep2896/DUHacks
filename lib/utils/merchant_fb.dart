import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MerchantFB {
  CollectionReference chargingStations =
      FirebaseFirestore.instance.collection('ChargingStations');

  CollectionReference chargingRequests =
      FirebaseFirestore.instance.collection('ChargingRequest');

  Future<bool> addUser(
      String name,
      String address,
      int avail,
      List<double> latlon,
      bool isActive,
      bool isFastCharger,
      bool isHomeCharger,
      String loc) {
    // Call the user's CollectionReference to add a new user
    return chargingStations
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'name': name, // John Doe
          'address': address, // Stokes and Sons
          'avail': avail,
          'latlon': latlon,
          'isActive': true,
          'isFastCharger': isFastCharger,
          'isHomeCharger': isHomeCharger,
          'loc': loc,
          'stars': 0,
        })
        .then((value) => true)
        .catchError((error) => false);
  }

  Future addChargers(
    int num,
  ) async {
    // Call the user's CollectionReference to add a new user

    for (int i = 0; i < 5; i++) {
      return chargingStations
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('chargers')
          .doc('charger $i')
          .set({
            'isEngaged': false,
            'chargingTime': "00:00",
            'powerTransfered': "0 volts",
            'totalEarnings': "Rs.0"
          })
          .then((value) => true)
          .catchError((error) => false);
    }
  }

  Future<DocumentSnapshot> getData(String uid) async {
    return chargingStations.doc(uid).get();
  }

  void changeActiveStatus(bool isActive) {
    chargingStations.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'isActive': isActive,
    });
  }

  Future<bool> engageCharger(String merchId) async {
    chargingStations
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('chargers')
        .doc('charger 0')
        .update({'isEngaged': true}).then((value) {
      return true;
    });
    return false;
  }

  Future<bool> receivePaymentUpdate() async {
    chargingStations
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('chargers')
        .doc('charger 0')
        .update({'showPayment': false}).then((value) {
      return true;
    });
    return false;
  }

  Future<void> deleteChargingRequests() async {
    chargingRequests.doc(FirebaseAuth.instance.currentUser!.uid).delete();
  }
}
