import 'package:flutter/material.dart';
import 'package:shraddha/constant/theme.dart';
import 'package:shraddha/screens/home_screen.dart';
import 'package:shraddha/utils/api.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;



  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    print("Name: $name, Phone: $phone");
    setState(() => _isLoading = true);

    bool result = await _supabaseService.saveUserDetails(name, phone);
    setState(() => _isLoading = false);
    if(result)
      {
        print("Data saved");
      }



      print("User data saved successfully!");
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomeScreen()),
      // );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
    );


  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isRequired,
    bool isPhone = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 17,color: Colors.grey,fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade500),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorStyle: TextStyle(
              color: Colors.red, // Change the error text color
              fontSize: 14, // Adjust font size
              fontWeight: FontWeight.w700, // Adjust font weight
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return "This field is required";
            }
            if (!isPhone && value!.length < 3) {
              return "Name must be at least 3 characters";
            }
            // if (isPhone  ) {
            //   return "Enter a valid phone number in +91XXXXXXXXXX format";
            // }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(
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
    );
  }

  Widget _buildWelcomeText() {
    return const Center(
      child: Text(
        "Welcome to Shraddha",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: AppColors.primaryTextColor),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _handleLogin,
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text("Submit", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(),
                const SizedBox(height: 10),
                _buildWelcomeText(),
                const SizedBox(height: 40),
                _buildInputField(
                  label: "Name*",
                  hint: "Enter your full name",
                  controller: _nameController,
                  isRequired: true,
                ),
                SizedBox(height: 10,),
                _buildInputField(
                  label: "Phone Number*",
                  hint: "Enter your contact number",
                  controller: _phoneController,
                  isRequired: true,
                  isPhone: true,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: _buildSubmitButton(),
        ),
      ),
    );
  }
}
