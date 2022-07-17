import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evon_merchant/screens/bluetooth_serial/bluetooth_serial_main.dart';
import 'package:evon_merchant/screens/qr_scanner.dart';
import 'package:evon_merchant/utils/merchant_fb.dart';
import 'package:evon_merchant/utils/style.dart';
import 'package:evon_merchant/utils/utils_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class HomeChargers extends StatefulWidget {
  const HomeChargers({Key? key}) : super(key: key);

  @override
  State<HomeChargers> createState() => _HomeChargersState();
}

class _HomeChargersState extends State<HomeChargers> {
  String username = "";
  String userId = "";

  void getRequests() {
    FirebaseFirestore.instance
        .collection('ChargingRequest')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("RequestedUser")
        .where('accepted', isEqualTo: true)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          userId = value.docs[0].id;
          isChargingAccepted = true;
          username = value.docs[0].get('username');
        });
      } else {
        isChargingAccepted = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getRequests();
  }

  void disconnectBT() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
  }

  bool isBluetoothOn = false;
  BluetoothDevice? selectedDevice;

  BluetoothConnection? connection;
  bool isConnecting = true;
  bool isDisconnecting = false;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isChargingAccepted = false;
  bool isCharging = false;
  bool isFinised = false;

  String sendMessage = 'a';

  double percentage = 1;

  void changeChargerType(bool isStart, bool isFinised) {
    FirebaseFirestore.instance
        .collection('ChargingStations')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("chargers")
        .doc("charger 0")
        .update(
      {
        'charging': isStart,
        'isFinished': isFinised,
      },
    );
  }

  void connectToDevice(BluetoothDevice service) {
    BluetoothConnection.toAddress(service.address).then((_connection) {
      connection = _connection;
      getRequests();
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
    }).catchError((error) {
      toast(message: 'Cannot connect, exception occured');
    });
  }

  @override
  void dispose() {
    disconnectBT();

    super.dispose();
  }

  Duration countdownDuration = const Duration(minutes: 45);
  Duration duration = const Duration();
  Timer? timer;
  double volts = 0;
  bool countDown = true;

  void startTimer() {
    reset();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final addSeconds = countDown ? -1 : 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer!.cancel();
      } else {
        duration = Duration(seconds: seconds);
        setState(() {
          volts += 0.01;
        });
      }
    });
  }

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer!.cancel());
  }

  void reset() {
    if (countDown) {
      setState(() => duration = countdownDuration);
    } else {
      setState(() => duration = const Duration());
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  Stream<DocumentSnapshot>? documentStream = FirebaseFirestore.instance
      .collection('ChargingStations')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("chargers")
      .doc("charger 0")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return isConnected || selectedDevice != null
        ? Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: StreamBuilder<DocumentSnapshot>(
                  stream: documentStream,
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: darkColor,
                      );
                    }

                    return !snapshot.data!.get('showPayment')
                        ? Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedDevice!.name.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        selectedDevice!.address.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  isConnecting
                                      ? const CircularProgressIndicator(
                                          color: primaryColor,
                                        )
                                      : Icon(
                                          Icons.circle,
                                          color: isConnected
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          size: 25,
                                        ),
                                ],
                              ),
                              const Divider(
                                color: Colors.white,
                              ),
                              isChargingAccepted
                                  ? Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            username,
                                            style: const TextStyle(
                                              color: darkColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute<bool>(
                                                  builder: (contect) =>
                                                      QRScanner(
                                                    requestId: FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                  ),
                                                ),
                                              ).then((bool? isCodeTrue) {
                                                if (isCodeTrue! &&
                                                    sendMessage == 'a') {
                                                  _sendMessage('a');
                                                  setState(() {
                                                    isFinised = true;
                                                    sendMessage = 'd';
                                                    isCharging = true;
                                                    startTimer();
                                                    changeChargerType(
                                                        true, false);
                                                  });
                                                } else {
                                                  _sendMessage('d');
                                                  setState(() {
                                                    sendMessage = 'a';
                                                    isCharging = false;
                                                    stopTimer();
                                                  });
                                                  if (isFinised) {
                                                    changeChargerType(
                                                        false, isFinised);
                                                  }
                                                }
                                              });
                                            },
                                            child: const Icon(
                                              Icons.qr_code_scanner,
                                              color: darkColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        "No Charging requests",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                              const Divider(
                                color: Colors.white,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Total Power Provided",
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      buildTime(duration),
                                    ],
                                  ),
                                  RowTexts(
                                    text1: "Total Power Provided",
                                    text2: "${volts.toStringAsFixed(2)} volts",
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Colors.white,
                              ),
                              !isCharging
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Total Earnings",
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          "Rs. ${snapshot.data!.get('totalEarnings')}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Text(
                                            "Charging....",
                                            style: TextStyle(
                                              color: Colors.greenAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        LinearPercentIndicator(
                                          percent: percentage,
                                          animation: true,
                                          animationDuration: 2000,
                                          backgroundColor: Colors.black54,
                                          progressColor: Colors.greenAccent,
                                          barRadius: const Radius.circular(10),
                                        ),
                                      ],
                                    ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Lottie.asset(
                                  'images/lottie/payment.json',
                                ),
                              ),
                              const Text(
                                "Received Payment Of",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Rs. ${snapshot.data!.get('receivePayment')}",
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      MerchantFB().receivePaymentUpdate();
                                      MerchantFB().deleteChargingRequests();
                                      setState(() {
                                        countdownDuration =
                                            const Duration(minutes: 0);
                                        volts = 0;
                                      });
                                      disconnectBT();
                                    },
                                    child: const Icon(
                                      Icons.thumb_up,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                  }),
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bluetooth,
                  size: 80,
                  color: Colors.white30,
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (isChargingAccepted) {
                      final BluetoothDevice selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return const BluetoothSerialMain();
                          },
                        ),
                      );
                      setState(() {
                        this.selectedDevice = selectedDevice;
                        connectToDevice(selectedDevice);
                      });
                    } else {
                      toast(message: 'No charging requests has been accepted');
                    }
                  },
                  child: const Text("Connect to charger"),
                  style: ElevatedButton.styleFrom(
                    primary: primaryColor,
                  ),
                )
              ],
            ),
          );
  }
}

Widget buildTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      buildTimeCard(time: hours, header: 'HOURS'),
      const Text(
        ":",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      buildTimeCard(time: minutes, header: 'MINUTES'),
      const Text(
        ":",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      buildTimeCard(time: seconds, header: 'SECONDS'),
    ],
  );
}

Widget buildTimeCard({required String time, required String header}) => Text(
      time,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );

class RowTexts extends StatelessWidget {
  const RowTexts({
    Key? key,
    required this.text1,
    required this.text2,
  }) : super(key: key);

  final String text1;
  final String text2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text1,
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text2,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
