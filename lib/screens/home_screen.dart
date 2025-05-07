import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shraddha/constant/theme.dart';
import 'package:shraddha/screens/login_page.dart';
import 'package:shraddha/screens/plea_details.dart';
import 'package:shraddha/screens/requestsupport.dart';
import 'package:shraddha/utils/api.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> pleas = [];
  bool isLoading = true;
  final SupabaseService _supabaseService = SupabaseService();

  @override
  void initState() {
    super.initState();
    fetchMessagesByPleaId();
    _subscribeToUnread();
  }

  Future<void> fetchMessagesByPleaId() async {
    try {
      final fetchedPleas = await _supabaseService.fetchMessagesByPleaId();

      final reversedPleas = fetchedPleas.reversed.toList();
      final SupabaseClient _client = Supabase.instance.client;
      // Sort by status ('open' first)
      reversedPleas.sort((a, b) {
        if (a['status'] == 'open' && b['status'] != 'open') {
          return -1;
        } else if (a['status'] != 'open' && b['status'] == 'open') {
          return 1;
        } else {
          return 0;
        }
      });

      // Get list of plea IDs
      final pleaIds = reversedPleas.map((p) => p['id']).toList();
      final formattedIds = '(${pleaIds.map((id) => '"$id"').join(",")})';

      // Fetch unread messages for these pleas
      final unreadMessages = await _client
          .from('messages')
          .select('plea_id, is_read, sender_type')
          .eq('is_read', false)
          .not('sender_type', 'eq', 'user')
          .filter('plea_id', 'in', formattedIds);

      // Count unread messages per plea_id
      final Map<String, int> unreadCountMap = {};
      for (var msg in unreadMessages) {
        final pleaId = msg['plea_id'];
        unreadCountMap[pleaId] = (unreadCountMap[pleaId] ?? 0) + 1;
      }

      // Attach unread count to each plea
      for (var plea in reversedPleas) {
        plea['unread_count'] = unreadCountMap[plea['id']] ?? 0;
      }

      setState(() {
        pleas = reversedPleas;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching pleas: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  // void _subscribeToUnread() {
  //   final supabase = Supabase.instance.client;
  //   final currentUserId = supabase.auth.currentUser?.id;
  //
  //   if (currentUserId == null) {
  //     print('Cannot subscribe: User not logged in');
  //     return;
  //   }
  //
  //   // Create a channel for messages
  //   final channel = supabase.channel('public:messages');
  //
  //   // Subscribe to message changes
  //   channel
  //       .onPostgresChanges(
  //     event: PostgresChangeEvent.insert,
  //     schema: 'public',
  //     table: 'messages',
  //     filter: PostgresChangeFilter(
  //       column: 'is_read',
  //       type: PostgresChangeFilterType.eq,
  //       value: false,
  //     ),
  //     callback: (payload) {
  //       print("New unread message: ${payload.newRecord}");
  //       // Fetch updated data when we receive a new message
  //       fetchMessagesByPleaId();
  //     },
  //   )
  //       .onPostgresChanges(
  //     event: PostgresChangeEvent.update,
  //     schema: 'public',
  //     table: 'messages',
  //     callback: (payload) {
  //       print("Message updated: ${payload.newRecord}");
  //       // Fetch updated data when a message is updated (like marked as read)
  //       fetchMessagesByPleaId();
  //     },
  //   )
  //       .subscribe();
  //
  //
  //   _messageChannel = channel;
  // }
  //
  //
  // RealtimeChannel? _messageChannel;

  void _subscribeToUnread() {
    final supabase = Supabase.instance.client;

    final channel = supabase.channel('realtime:public:messages');

    channel
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      filter: PostgresChangeFilter(
        column: 'is_read',
        type: PostgresChangeFilterType.eq,
        value: false,
      ),
      callback: (payload) {
        print("Updated message received via realtime: ${payload.newRecord}");

        // Check if widget is still mounted before updating state
        if (mounted) {
          setState(() {
            // Update state here
            fetchMessagesByPleaId();
          });
        }
      },
    )
        .subscribe();

    // Store the channel reference
    _messageChannel = channel;
  }

// Add this field to your class
  RealtimeChannel? _messageChannel;

// Make sure to dispose of the channel when the widget is disposed
  @override
  void dispose() {
    _messageChannel?.unsubscribe();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return RefreshIndicator(
      onRefresh: fetchMessagesByPleaId,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Center(child: _buildWelcomeCard(screenWidth)),
                const SizedBox(height: 20),
                _buildGetHelpButton(screenWidth, context),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        Icons.phone_outlined,
                        "Emergency Contacts",
                        Colors.purple,
                        Colors.black,
                          onTap: () async {
                            final Uri phoneNumber = Uri(scheme: 'tel' , path: '7089310711' );
                            if (await canLaunchUrl(phoneNumber)) {
                              await launchUrl(phoneNumber,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              print('Could not launch $phoneNumber');
                            }
                          }
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        Icons.chat,
                        "Chat Support",
                        Colors.purple,
                        Colors.black,
                          onTap: () async {
                            final Uri whatsappNumber = Uri.parse('https://wa.me/7089310711'); // Add country code
                            if (await canLaunchUrl(whatsappNumber)) {
                              await launchUrl(whatsappNumber, mode: LaunchMode.externalApplication);
                            } else {
                              print('Could not launch $whatsappNumber');
                            }
                          }
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Pleas",
                      style: TextStyle(
                        color: AppColors.primaryTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 10),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : pleas.isEmpty
                    ? Center(
                  child: Text(
                    "No Pleas Complaints",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                )
                    : Column(
                  children: pleas.map((plea) {

                    return _buildPleaCard(
                      context: context,
                      screenWidth: screenWidth,
                      pleaId: plea['plea_number'] ?? 'Unknown',
                      date: plea['created_at'].toString().split('T')[0],
                      status: plea['status'],
                      statusColor: plea['status'] == 'open'
                          ? Colors.green
                          : Colors.red,
                      description: plea['story'] ?? 'No details available',
                      brief: plea['threat_description'] ?? "no Data",
                      uuid: plea['user_id'] ?? "unavailable",
                      complainId: plea['id'] ?? "unavailable",
                      time: plea['created_at'] ?? "",
                      name: plea['name'],
                      phoneNumber: plea['phone_no'],
                      address: plea['address'],
                      unread: plea['unread_count']
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPleaCard({
    required BuildContext context,
    required double screenWidth,
    required String pleaId,
    required String date,
    required String status,
    required Color statusColor,
    required String description,
    required String brief,
    required String uuid,
    required String complainId,
    required String time,
    required String name,
    required String phoneNumber,
    required String address,
    required int unread
  }) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PleaDetailPage(
                  uuid: uuid,
                  complainId: complainId,
                  description: description,
                  brief: brief,
                  date: date,
                  pleaId: pleaId,
                  openPls: status,
                  time: time,
                  name: name,
                  phoneNumber: phoneNumber,
                  address: address,
                ),
          ),
        );

        // Refresh the data if the result is true
        if (result == true) {
          fetchMessagesByPleaId();
          _subscribeToUnread();
        }
      },
      child: Container(
        width: screenWidth * 0.9,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(unread != 0)
           Column(
             children: [
               Align(
                 alignment: Alignment.center,
                 child: Text("$unread new message"),
               ),
               SizedBox(height: 10,),
             ],
           ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Plea #$pleaId ",
                      style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 5),

            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PleaDetailPage(
                          uuid: uuid,
                          complainId: complainId,
                          description: description,
                          brief: brief,
                          date: date,
                          pleaId: pleaId,
                          openPls: status,
                          time: time,
                          name: name,
                          phoneNumber: phoneNumber,
                          address: address,
                        ),
                  ),
                );

                // Refresh the data if the result is true
                if (result == true) {
                  fetchMessagesByPleaId();
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "View Details",
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.purple,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget _buildWelcomeCard(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.logout, color: AppColors.primaryTextColor),
              tooltip: 'Logout',
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Logout", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    );
                  },
                );

                if (shouldLogout == true) {
                  await Supabase.instance.client.auth.signOut();

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple[50],
            ),
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Icon(Icons.shield_outlined,
                size: screenWidth * 0.1, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 10),
          const Text(
            "Welcome to Shraddha",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTextColor),
          ),
          const SizedBox(height: 20),
          const Text(
            "You're safe here. We're here to support you without judgment.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildGetHelpButton(double screenWidth, BuildContext context) {
    return Center(
      child: SizedBox(
        width: screenWidth * 0.9,
        child: ElevatedButton(
          onPressed: () async {

          if(pleas.isNotEmpty)
            {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestSupportPage(name: pleas[0]['name'],
                    phoneNumber: pleas[0]['phone_no'],
                  address: pleas[0]['address'],),
                ),
              );

              if(result == true)
              {
                fetchMessagesByPleaId();
              }
            }else{

            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestSupportPage(),
              ),
            );

            if(result == true)
            {
              fetchMessagesByPleaId();
            }

          }


          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding:
            EdgeInsets.symmetric(vertical: screenWidth * 0.04),
          ),
          child: const Text(
            "Get Help Now", style: TextStyle(fontWeight: FontWeight.bold,),),
        ),
      ),
    );
  }
}

  Widget _buildActionButton(IconData icon, String label, Color iconColor,
      Color textColor, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      // borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor), // Set icon color
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ), // Set text color
          ],
        ),
      ),
    );
  }
