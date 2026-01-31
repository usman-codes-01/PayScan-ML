import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:card_scanner/animation/fade_animation.dart';
import 'package:card_scanner/utils/card_input_formatter.dart';
import 'package:card_scanner/widgets/credit_card_widget.dart';

class ResultPage extends StatefulWidget {
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName; //

  const ResultPage({
    super.key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName, // Required
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryDateController;
  late TextEditingController _nameController; //  Name Controller

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController(text: widget.cardNumber);
    _expiryDateController = TextEditingController(text: widget.expiryDate);
    // Name set karna
    _nameController = TextEditingController(text: widget.cardHolderName.toUpperCase());
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context)
        ),
        title: Text(
            "CARD DETAILS",
            style: GoogleFonts.orbitron(fontSize: 14, color: Colors.grey, letterSpacing: 2)
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // PREVIEW
            FadeAnimation(
              delay: const Duration(milliseconds: 100),
              child: Hero(
                tag: 'scanner',
                child: CreditCardWidget(
                  cardNumber: _cardNumberController.text,
                  expiryDate: _expiryDateController.text,
                ),
              ),
            ),
            const SizedBox(height: 50),

            // 1. CARD NUMBER
            _buildProField(
                "CARD NUMBER",
                _cardNumberController,
                Icons.credit_card,
                [CardNumberInputFormatter()]
            ),

            const SizedBox(height: 25),

            // 2. NAME (Added)
            _buildProField(
                "CARD HOLDER",
                _nameController,
                Icons.person_outline,
                []
            ),

            const SizedBox(height: 25),

            // 3. EXPIRY
            _buildProField(
                "EXPIRY DATE",
                _expiryDateController,
                Icons.calendar_today,
                [],
                isReadOnly: true
            ),

            const SizedBox(height: 80),

            // BUTTON
            FadeAnimation(
              delay: const Duration(milliseconds: 500),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Card Saved Successfully!"))
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                      "CONFIRM & SAVE",
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 16)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProField(String label, TextEditingController controller, IconData icon, List<TextInputFormatter> formatters, {bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: GoogleFonts.montserrat(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold, letterSpacing: 1)
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          inputFormatters: formatters,
          style: GoogleFonts.orbitron(color: Colors.white, fontSize: 17, letterSpacing: 1.5),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF111111),
            prefixIcon: Icon(icon, color: Colors.greenAccent, size: 20),
            contentPadding: const EdgeInsets.all(20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF222222)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.greenAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}