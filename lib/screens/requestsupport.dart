import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shraddha/constant/theme.dart';
import 'package:shraddha/utils/api.dart';
// import 'package:geolocator/geolocator.dart';


class RequestSupportPage extends StatefulWidget {
  RequestSupportPage({Key? key,this.name,this.phoneNumber,this.address}) : super(key: key);

  String? name;
  String? phoneNumber;
  String? address;


  @override
  State<RequestSupportPage> createState() => _RequestSupportPageState();
}

class _RequestSupportPageState extends State<RequestSupportPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _addressController = TextEditingController();
  final _policeStationController = TextEditingController();
  final _threatController = TextEditingController();
  final _storyController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.name != null && widget.phoneNumber != null && widget.address != null)
      {
        _nameController.text = widget.name!;
        _phoneController.text = widget.phoneNumber!;
        _addressController.text = widget.address!;
      }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    _addressController.dispose();
    _policeStationController.dispose();
    _threatController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController controller,
      {bool isRequired = false, int maxLines = 1, bool isPhone = false,
        bool isAadhaar = false,bool isName = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 16,fontWeight: FontWeight.w700, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(
            minHeight: 50, // Minimum height for the field
            maxHeight: 150, // Maximum height for multiline fields
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: isPhone || isAadhaar ? TextInputType.number : TextInputType.text,
            inputFormatters: isName ? [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            ] : [],
            // keyboardType: isPhone || isAadhaar ? TextInputType.phone : TextInputType.name,
            style: const TextStyle(color: Colors.black), // Input text color
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white, // White background
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 16), // Adjust padding

              // *Always Rectangular Borders*
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Colors.grey.shade300), // Light gray border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: Colors.grey.shade500), // Darker gray when focused
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: Colors.red), // Red border on error
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Colors.red), // Ensures full red border on error
              ),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return "This field is required";
              }

              if (isPhone) {
                final phoneRegex = RegExp(r'^[6-9]\d{9}$');
                if (!phoneRegex.hasMatch(value!)) {
                  return "Enter a valid 10-digit phone number starting with 6-9";
                }
              }

              if (isAadhaar && isPhone) {
                final aadhaarRegex = RegExp(r'^\d{12}$');
                if (!aadhaarRegex.hasMatch(value!)) {
                  return "Enter a valid 12-digit Aadhaar number";
                }
              }

              return null;
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
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
        title: const Text("Request Support",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.9, // Adjust width if needed
                  child: Text(
                    "Your information will be kept confidential and secure.",
                    textAlign: TextAlign
                        .center, // Ensures text stays centered across lines
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildInputField(
                  "Name*", "Your name will be kept anonymous", _nameController,
                  isRequired: true,isName: true),
              _buildInputField("Phone Number*", "Enter your contact number",
                  _phoneController,
                  isRequired: true, isPhone: true),
              _buildInputField("Aadhaar Number",
                  "Optional - For ID verification", _aadhaarController,isAadhaar: true),
              _buildInputField(
                  "Address*", "Your current location", _addressController,
                  isRequired: true, maxLines: 3),
              _buildInputField(
                  "Nearest Police Station",
                  "Will be suggested based on your location",
                  _policeStationController),
              _buildInputField("Who is the threat?*",
                  "Who are you seeking protection from?", _threatController,
              isRequired: true),
              _buildInputField("Your Story*",
                  "Share details about your situation...", _storyController,
                  isRequired: true, maxLines: 5),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Handle form submission
                      // print("Form Submitted!");

                      SupabaseService supabaseService = SupabaseService();

                      bool success = await supabaseService.saveSupportRequest(
                        name: _nameController.text,
                        phone: _phoneController.text,
                        aadhaar: _aadhaarController.text.isNotEmpty
                            ? _aadhaarController.text
                            : null,
                        address: _addressController.text,
                        policeStation: _policeStationController.text.isNotEmpty
                            ? _policeStationController.text
                            : null,
                        threat: _threatController.text.isNotEmpty
                            ? _threatController.text
                            : null,
                        story: _storyController.text,
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  "Support request submitted successfully!")),
                        );
                        Navigator.pop(context,true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Failed to submit request. Try again.")),
                        );
                      }
                    }
                  },
                  child: const Text("Submit",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
