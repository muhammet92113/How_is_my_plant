import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    torchEnabled: false,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _askedPermission = false;

  @override
  void initState() {
    super.initState();
    _ensurePermission();
  }

  Future<void> _ensurePermission() async {
    if (_askedPermission) return;
    _askedPermission = true;
    final status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Kod Okuyucu')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Kamera önizleme
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              // Şimdilik okutunca işlem yapmıyoruz, sadece açık kalsın
            },
          ),
          // Ortada tarama çerçevesi
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.9), width: 3),
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

