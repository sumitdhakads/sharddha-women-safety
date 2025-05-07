import 'package:flutter/material.dart';
import 'package:shraddha/constant/theme.dart';
import 'package:shraddha/screens/home_screen.dart';
import 'package:shraddha/screens/loginpage/welcome_page.dart';
import 'package:shraddha/utils/api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    print("LoginPage widget built"); // Debugging print

    return Scaffold(
      backgroundColor: AppColors.cardBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 20),
            _buildWelcomeText(),
            const SizedBox(height: 30),
            _buildGoogleLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: AppColors.backgroundColor,
      child: Icon(
        Icons.shield_outlined,
        size: 50,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: const [
        Text(
          "Welcome Back!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryTextColor,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Login to continue",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          print("google");
          setState(() => _isLoading = true);
          bool result = await _supabaseService.signInWithGoogle();
          setState(() => _isLoading = false);
         // if(result)
         //   {
         //     Navigator.push(
         //       context,
         //       MaterialPageRoute(builder: (context) => const WelcomePage()),
         //     );
          if (result) {
            final userId = Supabase.instance.client.auth.currentUser?.id;

            final response = await Supabase.instance.client
                .from('users')
                .select()
                .eq('id', userId!)
                .maybeSingle();

            if (response != null) {
              // User exists, go to HomePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  HomeScreen()),
              );
            } else {
              // New user, go to WelcomePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomePage()),
              );
            }
          }
        else{
           print("Some error in login page");
         }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
        ),
        child:
        _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/google.png', width: 24, height: 24),
            const SizedBox(width: 10),
            const Text(
              "Continue with Google",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// <!--    B9:DB:F5:CA:95:1C:6D:6C:D1:12:FD:F2:AE:B0:8A:09:7A:3E:FD:10-->