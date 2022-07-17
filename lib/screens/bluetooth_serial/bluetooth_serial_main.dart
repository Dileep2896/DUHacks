import 'dart:async';

import 'package:evon_merchant/screens/bluetooth_serial/select_bonded_devices.dart';
import 'package:evon_merchant/utils/style.dart';
import 'package:evon_merchant/utils/utils_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'discovery_page.dart';

class BluetoothSerialMain extends StatefulWidget {
  const BluetoothSerialMain({Key? key}) : super(key: key);

  @override
  State<BluetoothSerialMain> createState() => _BluetoothSerialMainState();
}

class _BluetoothSerialMainState extends State<BluetoothSerialMain> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  bool _autoAcceptPairingRequests = false;

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;

    return Scaffold(
      backgroundColor: darkColor,
      appBar: AppBar(
        title: const Text('Search Charger'),
        backgroundColor: primaryColor,
        foregroundColor: darkColor,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(
              'General',
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
          SwitchListTile(
            activeColor: primaryColor,
            title: Text(
              'Enable Bluetooth',
              style: TextStyle(
                color: textColor,
              ),
            ),
            value: _bluetoothState.isEnabled,
            onChanged: (bool value) {
              // Do the request and update with the true value then
              future() async {
                // async lambda seems to not working
                if (value) {
                  await FlutterBluetoothSerial.instance.requestEnable();
                } else {
                  await FlutterBluetoothSerial.instance.requestDisable();
                }
              }

              future().then((_) {
                setState(() {});
              });
            },
          ),
          ListTile(
            title: Text(
              'Bluetooth status',
              style: TextStyle(
                color: textColor,
              ),
            ),
            subtitle: Text(
              _bluetoothState.toString(),
              style: TextStyle(
                color: textColor,
              ),
            ),
            trailing: ElevatedButton(
              child: const Text(
                'Settings',
                style: TextStyle(
                  color: darkColor,
                ),
              ),
              onPressed: () {
                FlutterBluetoothSerial.instance.openSettings();
              },
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Local adapter address',
              style: TextStyle(
                color: textColor,
              ),
            ),
            subtitle: Text(
              _address,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Local adapter name',
              style: TextStyle(
                color: textColor,
              ),
            ),
            subtitle: Text(
              _name,
              style: TextStyle(
                color: textColor,
              ),
            ),
            onLongPress: null,
          ),
          ListTile(
            title: _discoverableTimeoutSecondsLeft == 0
                ? Text(
                    "Discoverable",
                    style: TextStyle(
                      color: textColor,
                    ),
                  )
                : Text(
                    "Discoverable for ${_discoverableTimeoutSecondsLeft}s",
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
            subtitle: Text(
              "PsychoX-Luna",
              style: TextStyle(
                color: textColor,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _discoverableTimeoutSecondsLeft != 0,
                  onChanged: (value) {},
                  checkColor: darkColor,
                  activeColor: primaryColor,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                  color: primaryColor,
                ),
                IconButton(
                  color: primaryColor,
                  icon: const Icon(Icons.refresh),
                  onPressed: () async {
                    final int timeout = (await FlutterBluetoothSerial.instance
                        .requestDiscoverable(60))!;
                    if (timeout < 0) {
                      toast(
                        message: "Discoverable mode denied",
                      );
                    } else {
                      toast(
                        message:
                            'Discoverable mode acquired for $timeout seconds',
                      );
                    }
                    setState(() {
                      _discoverableTimeoutTimer?.cancel();
                      _discoverableTimeoutSecondsLeft = timeout;
                      _discoverableTimeoutTimer = Timer.periodic(
                          const Duration(seconds: 1), (Timer timer) {
                        setState(() {
                          if (_discoverableTimeoutSecondsLeft < 0) {
                            FlutterBluetoothSerial.instance.isDiscoverable
                                .then((isDiscoverable) {
                              if (isDiscoverable ?? false) {
                                _discoverableTimeoutSecondsLeft += 1;
                              }
                            });
                            timer.cancel();
                            _discoverableTimeoutSecondsLeft = 0;
                          } else {
                            _discoverableTimeoutSecondsLeft -= 1;
                          }
                        });
                      });
                    });
                  },
                )
              ],
            ),
          ),
          const Divider(),
          ListTile(
              title: Text(
            'Devices discovery and connection',
            style: TextStyle(
              color: textColor,
            ),
          )),
          SwitchListTile(
            activeColor: primaryColor,
            title: Text(
              'Auto-try specific pin when pairing',
              style: TextStyle(
                color: textColor,
              ),
            ),
            subtitle: Text(
              'Pin 1234',
              style: TextStyle(
                color: textColor,
              ),
            ),
            value: _autoAcceptPairingRequests,
            onChanged: (bool value) {
              setState(() {
                _autoAcceptPairingRequests = value;
              });
              if (value) {
                FlutterBluetoothSerial.instance.setPairingRequestHandler(
                    (BluetoothPairingRequest request) {
                  if (request.pairingVariant == PairingVariant.Pin) {
                    return Future.value("1234");
                  }
                  return Future.value(null);
                });
              } else {
                FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
              }
            },
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text(
                'Explore discovered devices',
                style: TextStyle(
                  color: darkColor,
                ),
              ),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const DiscoveryPage();
                    },
                  ),
                );

                if (selectedDevice != null) {
                  Navigator.of(context).pop(selectedDevice);
                } else {
                  toast(message: 'Discovery -> no device selected');
                }
              },
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
              ),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              child: const Text(
                'Connect to paired device to chat',
                style: TextStyle(
                  color: darkColor,
                ),
              ),
              onPressed: () async {
                final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SelectBondedDevicePage(
                        checkAvailability: false,
                      );
                    },
                  ),
                );

                if (selectedDevice != null) {
                  Navigator.of(context).pop(selectedDevice);
                } else {}
              },
              style: ElevatedButton.styleFrom(
                primary: primaryColor,
              ),
            ),
          ),
          // Divider(),
          // ListTile(title: const Text('Multiple connections example')),
          // ListTile(
          //   title: ElevatedButton(
          //     child: ((_collectingTask?.inProgress ?? false)
          //         ? const Text('Disconnect and stop background collecting')
          //         : const Text('Connect to start background collecting')),
          //     onPressed: () async {
          //       if (_collectingTask?.inProgress ?? false) {
          //         await _collectingTask!.cancel();
          //         setState(() {
          //           /* Update for `_collectingTask.inProgress` */
          //         });
          //       } else {
          //         final BluetoothDevice? selectedDevice =
          //             await Navigator.of(context).push(
          //           MaterialPageRoute(
          //             builder: (context) {
          //               return SelectBondedDevicePage(
          //                   checkAvailability: false);
          //             },
          //           ),
          //         );

          //         if (selectedDevice != null) {
          //           await _startBackgroundTask(context, selectedDevice);
          //           setState(() {
          //             /* Update for `_collectingTask.inProgress` */
          //           });
          //         }
          //       }
          //     },
          //   ),
          // ),
          // ListTile(
          //   title: ElevatedButton(
          //     child: const Text('View background collected data'),
          //     onPressed: (_collectingTask != null)
          //         ? () {
          //             Navigator.of(context).push(
          //               MaterialPageRoute(
          //                 builder: (context) {
          //                   return ScopedModel<BackgroundCollectingTask>(
          //                     model: _collectingTask!,
          //                     child: BackgroundCollectedPage(),
          //                   );
          //                 },
          //               ),
          //             );
          //           }
          //         : null,
          //   ),
          // ),
        ],
      ),
    );
  }
}
