import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const XoliiFlashlightApp());
}

class XoliiFlashlightApp extends StatelessWidget {
  const XoliiFlashlightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Xolii Flashlight',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080808),
        useMaterial3: true,
      ),
      home: const FlashlightPage(),
    );
  }
}

class FlashlightPage extends StatefulWidget {
  const FlashlightPage({super.key});

  @override
  State<FlashlightPage> createState() => _FlashlightPageState();
}

class _FlashlightPageState extends State<FlashlightPage> {
  CameraController? _controller;

  bool _flashOn = false;
  bool _loading = true;
  bool _supported = true;

  @override
  void initState() {
    super.initState();
    _initializeFlashlight();
  }

  Future<void> _initializeFlashlight() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _supported = false;
          _loading = false;
        });
        return;
      }

      CameraDescription? rearCamera;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          rearCamera = camera;
          break;
        }
      }

      rearCamera ??= cameras.first;

      final controller = CameraController(
        rearCamera,
        ResolutionPreset.low,
        enableAudio: false,
      );

      await controller.initialize();

      _controller = controller;

      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _supported = false;
        _loading = false;
      });
    }
  }

  Future<void> _turnOn() async {
    if (_controller == null) return;

    try {
      await _controller!.setFlashMode(FlashMode.torch);

      setState(() {
        _flashOn = true;
      });
    } catch (e) {
      _showMessage(
        'This device or browser does not support flashlight control.',
      );
    }
  }

  Future<void> _turnOff() async {
    if (_controller == null) return;

    try {
      await _controller!.setFlashMode(FlashMode.off);

      setState(() {
        _flashOn = false;
      });
    } catch (e) {
      setState(() {
        _flashOn = false;
      });
    }
  }

  void _showPaymentDemo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF171717),
          title: const Text('Demo Payment'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flashlight_on,
                size: 50,
                color: Colors.amber,
              ),
              SizedBox(height: 20),
              Text(
                'This is a simulated payment screen.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'No real money will be charged.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 20),
              Text(
                'Demo amount: R5.00',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);

                // Simulate a successful payment.
                await _turnOff();

                if (mounted) {
                  _showMessage('Demo payment successful.');
                }
              },
              child: const Text('SIMULATE PAYMENT'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _turnOff();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'XOLII',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'FLASHLIGHT',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _loading
                        ? 'INITIALIZING...'
                        : !_supported
                            ? 'FLASHLIGHT UNAVAILABLE'
                            : _flashOn
                                ? 'FLASHLIGHT ON'
                                : 'FLASHLIGHT OFF',
                    style: TextStyle(
                      color: _flashOn ? Colors.amber : Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _flashOn
                          ? Colors.amber
                          : const Color(0xFF202020),
                      boxShadow: _flashOn
                          ? [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.45),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      Icons.flashlight_on,
                      size: 90,
                      color: _flashOn ? Colors.black : Colors.white,
                    ),
                  ),

                  const SizedBox(height: 50),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      onPressed: _loading || !_supported
                          ? null
                          : _flashOn
                              ? _showPaymentDemo
                              : _turnOn,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            _flashOn ? Colors.amber : Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        _flashOn ? 'TURN OFF' : 'TURN ON',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    isWeb
                        ? 'Web flashlight control depends on browser support.'
                        : 'Tap the button to control your device flashlight.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  if (_flashOn) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'DEMO PAYMENT MODE',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
