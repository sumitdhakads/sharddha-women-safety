import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shraddha/constant/theme.dart';
import 'package:shraddha/screens/home_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shield Icon
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundColor,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.shield_outlined,
                      size: 50,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                Center(
                  child: const Text(
                    "Enter OTP",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Center(
                  child: Text(
                    "We've sent a 6-digit code to your number.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),

                // OTP Input Field
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textStyle: const TextStyle(color: Colors.black, fontSize: 18),
                  cursorColor: AppColors.primaryColor,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(12),
                    fieldHeight: 55,
                    fieldWidth: 50,
                    inactiveColor: Colors.grey.shade300,
                    activeColor: AppColors.primaryColor,
                    selectedColor: AppColors.primaryColor,
                  ),
                  obscureText: false, // Set true if you want to hide digits
                  obscuringCharacter: '*', // If using obscureText, this will be used instead of numbers
                  onChanged: (value) {},
                ),

                const SizedBox(height: 16),

                // Resend OTP
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Handle OTP resend
                      print("Resend OTP clicked");
                    },
                    child: const Text(
                      "Resend OTP",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Verify Button at Bottom
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_otpController.text.length == 6) {
                    print("OTP Verified: ${_otpController.text}");

                    // Navigate to Home Screen after successful OTP verification
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(), // Replace with your actual home screen widget
                      ),
                    );
                  } else {
                    print("Enter a valid OTP");
                  }
                },
                child: const Text("Verify OTP", style: TextStyle(fontWeight: FontWeight.bold)),

              ),
            ),
          ),
        ],
      ),
    );
  }
}