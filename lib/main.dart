import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weapon',
      home: Bluetooth(),
    );
  }
}

class Bluetooth extends StatefulWidget {
  const Bluetooth({super.key});

  @override

  _BluetoothState createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {
  FlutterBluePlus flutterBluePlus = FlutterBluePlus();
  List<ScanResult> dispositivo = [];
  bool scanning = false;
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  _startScan() {
    setState(() {
      scanning = true;
    });
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        dispositivo = results;
      });
    });
  }

  _connectToDevice(BluetoothDevice device)  async {
    if (connectedDevice != null && connectedDevice!.id == device.id) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
      });
    } else {
      try {
        await device.connect();
        setState(() {
          connectedDevice = device;
        });
      } catch (error) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Connection error'),
              content: const Text(
                  'Could not connect to the device. Please try again later.'),
              actions: <Widget>[
                TextButton(
                  child:const Text('Accept'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Device'),
      ),
      body: 
        ListView.builder(
          itemCount: dispositivo.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(dispositivo[index].device.name),
                subtitle: Text(dispositivo[index].device.id.toString()),                
                trailing: ElevatedButton(
                onPressed: () =>
                   _connectToDevice(dispositivo[index].device),
                    child: connectedDevice != null && connectedDevice!.id == dispositivo[index].device.id
                        ? const Text('Disconnect')
                        : const Text('Connect'),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _startScan(),
        child: const Icon(Icons.bluetooth_searching),
      ),
    );
  }
}