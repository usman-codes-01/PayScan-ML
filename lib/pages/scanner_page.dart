import 'dart:async';
import 'dart:io';
import 'dart:ui'; // Needed for Glass effect

import 'package:camera/camera.dart';
import 'package:card_scanner/pages/result_page.dart';
import 'package:card_scanner/utils/string_utils.dart';
import 'package:card_scanner/widgets/credit_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:card_scanner/utils/input_image_from_camera_image.dart';
import 'package:vibration/vibration.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _controller;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isScanBusy = false;

  // Variables to hold scanned data
  String? _foundCardNumber;
  String? _foundExpiryDate;

  // Timer to force navigation if date is not found quickly
  Timer? _navigationTimer;

  // Animation Vars (Added for UI enhancement)
  AnimationController? _animController;
  Animation<double>? _anim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize Laser Animation
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(_animController!);

    // Dark Status Bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.black, statusBarIconBrightness: Brightness.light),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navigationTimer?.cancel();
    _controller?.dispose();
    _textRecognizer.close();
    _animController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _startScanning() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      await _initializeCamera();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission required')),
        );
      }
    }
  }

  Future<void> _stopScanning() async {
    _navigationTimer?.cancel();
    final CameraController? cameraToDispose = _controller;

    if (mounted) {
      setState(() {
        _controller = null;
        _foundCardNumber = null;
        _foundExpiryDate = null;
      });
    }

    // Wait slightly to ensure widget unmounts
    await Future.delayed(const Duration(milliseconds: 200));

    if (cameraToDispose != null) {
      try {
        await cameraToDispose.stopImageStream();
        await cameraToDispose.dispose();
      } catch (e) {
        debugPrint("Error stopping camera: $e");
      }
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    try {
      await controller.initialize();
      await controller.lockCaptureOrientation();

      if (mounted) {
        setState(() {
          _controller = controller;
        });
        controller.startImageStream(_processImage);
      }
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  Future<void> _processImage(CameraImage image) async {
    // If we already have a card number, stop processing to save resources
    if (_isScanBusy || _foundCardNumber != null || _controller == null) return;
    _isScanBusy = true;

    try {
      final inputImage = inputImageFromCameraImage(image, _controller!);
      if (inputImage == null) return;

      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Date Regex (flexible)
      final dateRegex = RegExp(r'(0[1-9]|1[0-2])\s*[\/\.-]\s*\d{2,4}');

      String? potentialCardNumber;
      String? potentialDate;

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text;

          // --- 1. FAST CARD LOGIC (No strict checks) ---
          if (potentialCardNumber == null) {
            // Only keep digits
            String cleanNumber = text.replaceAll(RegExp(r'[^0-9]'), '');

            // Accept anything between 13 and 19 digits
            if (cleanNumber.length >= 13 && cleanNumber.length <= 19) {
              // Check if it starts with standard card digits (3,4,5,6)
              if (cleanNumber.startsWith(RegExp(r'[3-6]'))) {
                debugPrint("🚀 FAST DETECT: $cleanNumber");
                potentialCardNumber = cleanNumber;
              }
            }
          }

          // --- 2. Date Logic ---
          if (potentialDate == null) {
            final dateMatch = dateRegex.firstMatch(text);
            if (dateMatch != null) {
              potentialDate = dateMatch.group(0)!.replaceAll(' ', '');
            }
          }
        }
      }

      // If we found a card number, lock it in!
      if (potentialCardNumber != null) {
        _foundCardNumber = potentialCardNumber;
        _foundExpiryDate = potentialDate; // Might be null, that's okay

        if (mounted) {
          setState(() {}); // Update UI to show Green Border

          if (await Vibration.hasVibrator() ?? false) {
            Vibration.vibrate(duration: 100);
          }

          // Start a timer. If we find the date in the next few frames, good.
          // If not, we navigate anyway in 1 second.
          _startNavigationTimer();
        }
      }

    } catch (e) {
      debugPrint("Processing error: $e");
    } finally {
      _isScanBusy = false;
    }
  }

  void _startNavigationTimer() {
    // If timer is already running, don't start another
    if (_navigationTimer != null && _navigationTimer!.isActive) return;

    _navigationTimer = Timer(const Duration(milliseconds: 1000), () {
      _navigateToResult();
    });
  }

  Future<void> _navigateToResult() async {
    if (!mounted || _controller == null) return;

    // Prepare data
    final cNum = StringUtils.formatCardNumber(_foundCardNumber ?? "");
    final cExp = _foundExpiryDate != null
        ? StringUtils.formatExpiryDate(_foundExpiryDate!)
        : "";

    // Stop stream
    try {
      await _controller?.stopImageStream();
    } catch(e) {
      // ignore errors here
    }

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            cardNumber: cNum,
            expiryDate: cExp,
          ),
        ),
      );

      // Reset when back
      if (mounted) {
        setState(() {
          _foundCardNumber = null;
          _foundExpiryDate = null;
          _isScanBusy = false;
        });
        _initializeCamera(); // Re-init camera cleanly
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCameraReady = _controller != null && _controller!.value.isInitialized;

    // Card Dimensions
    final double cardWidth = MediaQuery.of(context).size.width * 0.90;
    final double cardHeight = cardWidth / 1.586;

    return Scaffold(
      backgroundColor: Colors.black, // Dark Background
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Header Text
                Text(
                  _foundCardNumber == null ? "SCAN CARD" : "PROCESSING...",
                  style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Align card within the frame",
                  style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: Colors.grey[500],
                      letterSpacing: 1.0
                  ),
                ),
                const SizedBox(height: 40),

                // 2. Camera Box (Neon Style)
                Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    // Neon Border Logic
                    border: Border.all(
                      color: _foundCardNumber != null ? Colors.greenAccent : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      // Neon Glow when found
                      if (_foundCardNumber != null)
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 2,
                        )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Camera Feed
                        if (isCameraReady)
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller!.value.previewSize!.height,
                              height: _controller!.value.previewSize!.width,
                              child: CameraPreview(_controller!),
                            ),
                          )
                        else
                          const Center(child: CircularProgressIndicator(color: Colors.white)),

                        // Animated Laser Line
                        if (_foundCardNumber == null && _animController != null)
                          AnimatedBuilder(
                            animation: _animController!,
                            builder: (context, child) {
                              return Align(
                                alignment: Alignment(0, (_anim!.value * 2) - 1),
                                child: Container(
                                  height: 3,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.greenAccent.withOpacity(0),
                                          Colors.greenAccent,
                                          Colors.greenAccent.withOpacity(0),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(color: Colors.greenAccent.withOpacity(0.8), blurRadius: 10)
                                      ]
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // 3. Scan Button (Modern Glass Style)
                GestureDetector(
                  onTap: isCameraReady ? _stopScanning : _startScanning,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                        color: isCameraReady
                            ? Colors.redAccent.withOpacity(0.2)
                            : Colors.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: isCameraReady ? Colors.redAccent : Colors.greenAccent,
                            width: 1.5
                        )
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCameraReady ? Icons.stop : Icons.camera_alt,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isCameraReady ? "Stop Scanning" : "Start Scanning",
                          style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}