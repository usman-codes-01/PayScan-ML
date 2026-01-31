import 'package:card_scanner/animation/fade_animation.dart';
import 'package:card_scanner/utils/card_input_formatter.dart';
import 'package:card_scanner/utils/month_year_picker.dart';
import 'package:card_scanner/widgets/credit_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultPage extends StatefulWidget {
  final String cardNumber;
  final String expiryDate;

  const ResultPage({
    super.key,
    required this.cardNumber,
    required this.expiryDate,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryDateController;

  static const int animateDelay = 450;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController(text: widget.cardNumber);
    _expiryDateController = TextEditingController(text: widget.expiryDate);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  void onTapExpiryDate() async {
    final result = await showExpiryPicker(context, _expiryDateController.text);
    if (result != null) {
      setState(() {
        _expiryDateController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matching Scanner Page
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Card Details",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // 1. HERO CARD PREVIEW
              FadeAnimation(
                delay: const Duration(milliseconds: 0),
                child: Hero(
                  tag: 'scanner', // Smooth transition from scanner box
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: -5,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_cardNumberController, _expiryDateController]),
                        builder: (context, child) {
                          return CreditCardWidget(
                            cardNumber: _cardNumberController.text,
                            expiryDate: _expiryDateController.text,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 2. FORM SECTION
              FadeAnimation(
                delay: const Duration(milliseconds: animateDelay),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Number
                    _buildLabel("Card Number"),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _cardNumberController,
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      inputFormatters: [
                        CardNumberInputFormatter(),
                      ],
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.greenAccent,
                      decoration: _darkInputDecoration(
                        "XXXX XXXX XXXX XXXX",
                        Icons.credit_card,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Expiry Date
                    _buildLabel("Expiry Date"),
                    const SizedBox(height: 10),
                    TextFormField(
                      readOnly: true,
                      onTap: onTapExpiryDate,
                      controller: _expiryDateController,
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      decoration: _darkInputDecoration(
                        "MM/YY",
                        Icons.calendar_month_outlined,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // 3. CONFIRM BUTTON
              FadeAnimation(
                delay: const Duration(milliseconds: animateDelay + 100),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Saved: ${_cardNumberController.text}");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Card Saved Successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // High Contrast
                      foregroundColor: Colors.black,
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Confirm & Save",
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Label Style
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: Colors.grey[400],
        letterSpacing: 0.5,
      ),
    );
  }

  // Dark Theme Input Style
  InputDecoration _darkInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1C1C1E), // Dark Grey Background
      hintText: hint,
      hintStyle: GoogleFonts.orbitron(color: Colors.grey[700], fontSize: 16, letterSpacing: 1.5),
      prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey[900]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.greenAccent, width: 1.5), // Neon Green Focus
      ),
    );
  }
}