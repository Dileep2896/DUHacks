import 'dart:developer';
import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evon_merchant/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../utils/utils_functions.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({
    Key? key,
    required this.requestId,
  }) : super(key: key);

  static String id = "qr_scanner";
  final String requestId;

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  // Barcode? result;
  String codeResult = "No Result";

  bool qrCorrect = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  // DocumentSnapshot? snapshot;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: darkColor,
    //   body: Column(
    //     children: [
    //       Expanded(
    //         flex: 4,
    //         child: buildQrView(context),
    //       ),
    //       Expanded(
    //         flex: 1,
    //         child: Center(
    //           child: Padding(
    //             padding: const EdgeInsets.symmetric(horizontal: 20.0),
    //             child: Container(
    //               padding: const EdgeInsets.all(10),
    //               decoration: BoxDecoration(
    //                 color: Colors.white24,
    //                 borderRadius: BorderRadius.circular(10),
    //               ),
    //               child: result != null
    //                   ? Text(
    //                       'Data: ${result!.code}',
    //                       style: const TextStyle(
    //                         color: Colors.white,
    //                         fontSize: 18,
    //                         fontWeight: FontWeight.bold,
    //                       ),
    //                     )
    //                   : Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       children: const [
    //                         Icon(
    //                           Icons.qr_code,
    //                           color: Colors.white,
    //                         ),
    //                         SizedBox(
    //                           width: 10,
    //                         ),
    //                         Text(
    //                           'Scan a code',
    //                           style: TextStyle(
    //                             color: Colors.white,
    //                             fontSize: 18,
    //                             fontWeight: FontWeight.bold,
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //             ),
    //           ),
    //         ),
    //       ),
    //       Image.asset(
    //         'images/evon_logos/EVon_text_trans.png',
    //         scale: 4,
    //       ),
    //       const SizedBox(
    //         height: 20,
    //       ),
    //     ],
    //   ),
    // );

    MobileScannerController cameraController = MobileScannerController();

    return Scaffold(
      backgroundColor: darkColor,
      appBar: AppBar(
        title: const Text('Mobile Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  allowDuplicates: false,
                  controller: cameraController,
                  onDetect: (barcode, args) {
                    if (barcode.rawValue != widget.requestId) {
                      toast(message: 'Failed to scan Barcode');
                    } else {
                      HapticFeedback.vibrate();
                      final String code = barcode.rawValue!;
                      setState(() {
                        codeResult = code;
                      });
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: MediaQuery.of(context).size.width / 1.5,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white60,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        codeResult,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQrView(
    BuildContext context,
  ) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 400.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    // this.controller = controller;
    // this.controller!.resumeCamera();

    // log("Hello");
    // controller.scannedDataStream.listen((scanData) {
    //   log(scanData.code.toString());
    //   HapticFeedback.vibrate();
    //   setState(() {
    //     result = scanData;
    //   });
    //   if ("12345" == scanData.code) {
    //     Navigator.of(context).pop(true);
    //
    //   }
    // });
    // this.controller!.pauseCamera();
    // this.controller!.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
