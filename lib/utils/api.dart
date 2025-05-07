import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {

  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> signInWithPhone(String phoneNumber) async {
    try {
      await _client.auth.signInWithOtp(phone: phoneNumber);
      return true;
    } catch (e) {
      print("Error sending OTP: $e");
      return false;
    }
  }


  // Future<bool> signInWithGoogle() async {
  //   final supabase = Supabase.instance.client;
  //
  //   const androidClientId = 'YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com';
  //   const webClientId = '322482043018-h7ti31bie0oqjll5846gtu530pleoj0s.apps.googleusercontent.com';
  //
  //   final GoogleSignIn googleSignIn = GoogleSignIn(
  //     clientId: androidClientId,
  //     serverClientId: webClientId,
  //   );
  //
  //   final googleUser = await googleSignIn.signIn();
  //   if (googleUser == null) {
  //     print('Google sign-in cancelled.');
  //     return false;
  //   }
  //
  //   final googleAuth = await googleUser.authentication;
  //   if (googleAuth.idToken == null || googleAuth.accessToken == null) {
  //     print('No ID Token or Access Token found.');
  //     return false;
  //   }
  //
  //   // Sign in with Supabase
  //   await supabase.auth.signInWithIdToken(
  //     provider: OAuthProvider.google,
  //     idToken: googleAuth.idToken!,
  //     accessToken: googleAuth.accessToken!,
  //   );
  //
  //   final user = supabase.auth.currentUser;
  //   print("supabase uuid ${user?.id}");
  //
  //   // Insert user into 'users' table if not already present
  //   if (user != null) {
  //     final existingUser = await supabase
  //         .from('users')
  //         .select()
  //         .eq('id', user.id)
  //         .maybeSingle();
  //
  //     if (existingUser == null) {
  //       final insertResponse = await supabase.from('users').insert({
  //         'id': user.id,
  //         'phone_no': "+919807865476",
  //         'created_at': DateTime.now().toIso8601String(),
  //       });
  //
  //       if (insertResponse.error != null) {
  //         print('Error inserting user into users table: ${insertResponse.error!.message}');
  //         return false;
  //       }
  //     }
  //   }
  //
  //   print('Google Sign-In Successful! ${googleAuth.accessToken}');
  //   return true;
  // }

  Future<bool> signInWithGoogle() async {
    final supabase = Supabase.instance.client;
    const androidClientId = '322482043018-c9mctu2hb39mbgjle4bdngh6jelhc02b.apps.googleusercontent.com';
    const webClientId = '322482043018-h7ti31bie0oqjll5846gtu530pleoj0s.apps.googleusercontent.com';

    // final supabase = Supabase.instance.client;

    // await supabase.auth.signInWithOAuth(
    //   OAuthProvider.google,
    //   redirectTo: 'io.supabase.flutter://login-callback', // set this in Supabase OAuth settings
    // );

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: androidClientId,
      serverClientId: webClientId,
    );

    await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      print('Google sign-in cancelled.');
      return false;
    }

    final googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null || googleAuth.accessToken == null) {
      print('No ID Token or Access Token found.');
      return false;
    }


    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken!,
    );

    final user = Supabase.instance.client.auth.currentUser;
    print("supabase uuid ${user?.id}");



    print('Google Sign-In Successful! ${googleAuth.accessToken}');
    return true;
  }

  Future<bool> saveUserDetails(String name, String phone) async {
    try{
      final user = _client.auth.currentUser;
      if (user == null) {
        print("No authenticated user found.");
        return false;
      }

      final response = await _client.from('users').upsert({
        'id': user.id, // Use Supabase UUID
        'name': name,
        'phone_no': phone, // Change 'mobile' to 'phone_no'
        'verified': true,
      }).eq('id', user.id);
      print("User data saved successfully!");
      return true;
    }
    catch(e){
      print('error $e');
      return false;
    }
  }


  Future<bool> saveFcmToken(String fcmToken) async {
    try{
      final user = _client.auth.currentUser;
      if (user == null) {
        print("No authenticated user found.");
        return false;
      }

      final response = await _client.from('notification').insert({
        'id': user.id, // Use Supabase UUID
        'fcm_token': fcmToken,
      }).eq('id', user.id);
      print("User token successfully!");
      print("hi $response");
      return true;
    }
    catch(e){
      print('error $e');
      return false;
    }
  }




  Future<bool> saveSupportRequest({
    required String name,
    required String phone,
    required String? aadhaar,
    required String address,
    required String? policeStation,
    required String? threat,
    required String story,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print("No authenticated user found.");
        return false;
      }

      final response = await _client.from('pleas').insert({
        'user_id': user.id,
        'name': name,
        'phone_no': phone,
        'adhar_no': aadhaar,
        'address': address,
        'police_station': policeStation,
        'threat_description': threat,
        'story': story,
        'created_at': DateTime.now().toIso8601String(),
        // 'plea_number' : "PL74895"
      }).eq('id', user.id);

      print("Support request saved successfully! $response");

      List<Map<String, dynamic>> result = await fetchMessagesByPleaId();
      print("result $result");
      return true;
    } catch (e) {
      print('Error saving support request: $e');
      return false;
    }
  }


  Future<List<Map<String, dynamic>>> fetchMessagesByPleaId() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print("No authenticated user found.");
        return [];
      }

      final response = await _client
          .from('pleas')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: true); // Order messages by timestamp

      if (response.isEmpty) {
        print("No messages found for plea_id: ${user.id}");
        return [];
      }

      print("Messages fetched successfully: $response");
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }



  Future<void> insertMessage({
    required String pleaId,
    // required String senderType,
    required String content,
    required String role
  }) async {
    try {
      final response = await _client.from('messages').insert([
        {
          'plea_id': pleaId,
          'sender_type': role,
          'content': content,
          'created_at': DateTime.now().toUtc().toIso8601String(),
        }
      ]);

      print("message send successfully");


    } catch (e) {
      print('Error inserting message: $e');
    }
  }



  Future<List<Map<String, dynamic>>> fetchComplainMessage(String pleaId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print("No authenticated user found.");
        return [];
      }

      final response = await _client
          .from('messages')
          .select('*')
          .eq('plea_id', pleaId)
          .order('created_at', ascending: true); // Order messages by timestamp

      if (response.isEmpty) {
        print("No messages found for plea_id: ${user.id}");
        return [];
      }

      print("Messages fetched successfully: $response");
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }


  Future<Map<String, dynamic>> fetchUserDetails(String plea) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        print('User is not logged in');
        return {};
      }

      final response = await _client
          .from('pleas')
          .select('*') // Select all columns; modify if needed
          .eq('plea_number', plea)
          .single(); // Use `.single()` if you expect only one record

      print('Plea details: $response');
      return response; // Directly return the response
    } catch (e) {
      print('Error fetching user details: $e');
      return {};
    }
  }


  Future<void> updatePleaStatus(String id, String status) async {
    try {
      final response = await _client
          .from('pleas')
          .update({'status': status}) // Update status
          .eq('id', id).select(); // Match plea_number

      if (response != null) {
        print('Status updated successfully $response');
      } else {
        print('Failed to update status');
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }


}
// {
// "project_info": {
// "project_number": "902999392028",
// "firebase_url": "https://shraddha-ab5ad-default-rtdb.firebaseio.com",
// "project_id": "shraddha-ab5ad",
// "storage_bucket": "shraddha-ab5ad.firebasestorage.app"
// },
// "client": [
// {
// "client_info": {
// "mobilesdk_app_id": "1:902999392028:android:102e3ad67f2e0e853c44d9",
// "android_client_info": {
// "package_name": "com.eulogik.shraddha"
// }
// },
// "oauth_client": [],
// "api_key": [
// {
// "current_key": "AIzaSyCgGwFRS7q2hCv6AoCEIbr-qTLb2eoaMUI"
// }
// ],
// "services": {
// "appinvite_service": {
// "other_platform_oauth_client": []
// }
// }
// }
// ],
// "configuration_version": "1"
// }
// B2:EB:B7:A9:E4:4F:8F:35:4C:10:03:E8:39:5B:53:50:A8:A2:A5:31