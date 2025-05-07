// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:shraddha/constant/theme.dart';
// import 'package:shraddha/utils/api.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:http/http.dart' as http;
//
//
// class PleaDetailPage extends StatefulWidget {
//   const PleaDetailPage({
//     Key? key,
//     required this.uuid,
//     required this.complainId,
//     required this.date,
//     required this.description,
//     required this.brief,
//     required this.pleaId,
//     required this.openPls,
//     required this.time,
//     required this.name,
//     required this.phoneNumber,
//     required this.address
//   }) : super(key: key);
//
//   final String uuid;
//   final String complainId;
//   final String brief;
//   final String description;
//   final String date;
//   final String time;
//   final String pleaId;
//   final String openPls;
//   final String name;
//   final String phoneNumber;
//   final String address;
//
//   @override
//   State<PleaDetailPage> createState() => _PleaDetailPageState();
// }
//
// class _PleaDetailPageState extends State<PleaDetailPage> {
//   final SupabaseService _supabaseService = SupabaseService();
//   bool isLoading = true;
//   final ScrollController _scrollController = ScrollController();
//
//   late Map<String, dynamic> pleaDetail;
//   late String status;
//
//   // Define consistent role mapping
//   final Map<String, ChatRole> roleMapping = {
//     'user': ChatRole.user,
//     'ai': ChatRole.aiSupport,
//     'admin': ChatRole.admin
//   };
//
//   // Define consistent sender name mapping
//   final Map<ChatRole, String> senderNameMapping = {
//     ChatRole.user: "You",
//     ChatRole.aiSupport: "AI Support",
//     ChatRole.admin: "Support Team"
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMessages();
//     _subscribeToMessages();
//     _subscribeToStatus();
//     status = widget.openPls;
//   }
//
//   Future<void> _fetchMessages() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       List<Map<String, dynamic>> fetchedMessages =
//       await _supabaseService.fetchComplainMessage(widget.complainId);
//       print("Messages fetched! ${fetchedMessages.length}");
//
//       pleaDetail = await _supabaseService.fetchUserDetails(widget.pleaId);
//       print("Story: ${pleaDetail['story']}");
//
//       await markMessagesAsRead(widget.complainId);
//
//       setState(() {
//         // Clear existing messages and add fetched ones
//         messages.clear();
//
//         // Convert fetched messages to ChatMessage objects
//         final List<ChatMessage> fetchedChatMessages = fetchedMessages.map((msg) {
//           // Map role strings to ChatRole enum
//           ChatRole role;
//           switch (msg['sender_type']) {
//             case 'user':
//               role = ChatRole.user;
//               break;
//             case 'ai':
//               role = ChatRole.aiSupport;
//               break;
//             case 'admin':
//               role = ChatRole.admin;
//               break;
//             default:
//               role = ChatRole.admin; // Default fallback
//           }
//
//           return ChatMessage(
//             sender: senderNameMapping[role]!,
//             message: msg['content'],
//             time: DateTime.parse(msg['created_at']).toLocal(),
//             role: role,
//           );
//         }).toList();
//
//         messages.addAll(fetchedChatMessages);
//
//         // Sort messages by time (oldest to newest)
//         messages.sort((a, b) => a.time.compareTo(b.time));
//         isLoading = false;
//       });
//
//       // If no messages and we have plea details, generate AI response
//       if (fetchedMessages.isEmpty && pleaDetail.isNotEmpty) {
//         String response = await _fetchDeepSeekResponse(
//             pleaDetail['name'],
//             pleaDetail['threat_description'],
//             pleaDetail['address']
//         );
//         await _supabaseService.insertMessage(
//             pleaId: widget.complainId,
//             content: response,
//             role: "ai"
//         );
//       }
//
//       // Scroll to bottom after everything is loaded
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _scrollToBottom();
//       });
//     } catch (e) {
//       print("Error fetching messages: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 100),
//         curve: Curves.easeOut,
//       );
//     }
//   }
//
//   Future<void> markMessagesAsRead(String pleaId) async {
//     try {
//       print("plea id $pleaId");
//
//       final _supabase = Supabase.instance.client;
//
//       final response = await _supabase
//           .from('messages')
//           .update({'is_read': true})
//           .eq('plea_id', pleaId)
//           .eq('is_read', false)
//           .filter('sender_type', 'neq', 'user'); // ✅ use filter instead of not
//
//       print("✅ Marked messages as read for plea: $pleaId");
//       print("📦 Supabase response: $response");
//     } catch (e) {
//       print("❌ Error marking messages as read: $e");
//     }
//   }
//
//
//   void _subscribeToStatus() {
//     final channel = Supabase.instance.client
//         .channel('realtime:public:messages')
//         .onPostgresChanges(
//       event: PostgresChangeEvent.update,
//       schema: 'public',
//       table: 'pleas',
//       filter: PostgresChangeFilter(
//         column: 'id',
//         type: PostgresChangeFilterType.eq,
//         value: widget.complainId,
//       ),
//       callback: (payload) {
//         print("New message received via realtime: ${payload.newRecord}");
//         final newMessage = payload.newRecord;
//         if (newMessage == null) return;
//
//         setState(() {
//           String newStatus = (status.toLowerCase() == "open") ? "closed" : "open";
//           status = newStatus;
//         });
//
//         // setState(() {
//         //   String newStatus = (status.toLowerCase() == "open" ) ? "closed" : "open" ;
//         //
//         //   setState(() {
//         //     status = newStatus;
//         //   });
//         // });
//
//         WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//       },
//     ).subscribe();
//
//     print("Subscribed to real-time updates for plea_id: ${widget.pleaId}");
//   }
//
//
//   void _subscribeToMessages() {
//     print("plea id ${widget.complainId}");
//     final channel = Supabase.instance.client
//         .channel('realtime:public:messages')
//         .onPostgresChanges(
//       event: PostgresChangeEvent.insert,
//       schema: 'public',
//       table: 'messages',
//       filter: PostgresChangeFilter(
//         column: 'plea_id',
//         type: PostgresChangeFilterType.eq,
//         value: widget.complainId,
//       ),
//       callback: (payload) {
//         print("New message received via realtime: ${payload.newRecord}");
//         final newMessage = payload.newRecord;
//         if (newMessage == null) return;
//
//         setState(() {
//           messages.add(ChatMessage(
//             sender: newMessage['sender_type'] == 'user'
//                 ? "User"
//                 : (newMessage['sender_type'] == 'ai' ? "AI Support" : "Admin"),
//             message: newMessage['content'],
//             time: DateTime.parse(newMessage['created_at']).toLocal(),
//             role: newMessage['sender_type'] == 'user'
//                 ? ChatRole.user
//                 : (newMessage['sender_type'] == 'ai' ? ChatRole.aiSupport : ChatRole.admin),
//           ));
//         });
//
//         WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//       },
//     )
//         .subscribe();
//
//     print("Subscribed to real-time updates for plea_id: ${widget.pleaId}");
//   }
//
//
//   // Empty initial messages list (to be populated from database)
//   final List<ChatMessage> messages = [];
//
//   // Controller for the "Type your response..." field
//   final TextEditingController _responseController = TextEditingController();
//
//   Widget _buildDateHeader(DateTime date) {
//     final now = DateTime.now();
//     String formattedDate;
//
//     if (date.year == now.year && date.month == now.month && date.day == now.day) {
//       formattedDate = "Today";
//     } else if (date.year == now.year &&
//         date.month == now.month &&
//         date.day == now.day - 1) {
//       formattedDate = "Yesterday";
//     } else {
//       formattedDate = "${date.day}-${date.month}-${date.year}";
//     }
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             formattedDate,
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildShimmerLoader() {
//     return ListView.builder(
//       itemCount: 9, // Number of shimmer items
//       padding: const EdgeInsets.all(16),
//       itemBuilder: (context, index) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Shimmer.fromColors(
//             baseColor: Colors.grey[300]!,
//             highlightColor: Colors.grey[100]!,
//             child: Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 100,
//                     height: 10,
//                     color: Colors.grey,
//                   ),
//                   const SizedBox(height: 5),
//                   Container(
//                     width: double.infinity,
//                     height: 10,
//                     color: Colors.grey,
//                   ),
//                   const SizedBox(height: 5),
//                   Container(
//                     width: 150,
//                     height: 10,
//                     color: Colors.grey,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   void dispose() {
//     _responseController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await markMessagesAsRead(widget.complainId);
//         Navigator.pop(context, true);
//         return false;
//       },
//       child: Scaffold(
//           backgroundColor: AppColors.backgroundColor,
//           appBar: AppBar(
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back),
//               onPressed: () async{
//                 await markMessagesAsRead(widget.complainId);
//                 Navigator.pop(context, true);
//               },
//             ),
//             elevation: 1,
//             title: Row(
//               children: [
//                 Text(
//                   "${widget.pleaId}",
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.purple,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 _buildStatusSection(),
//               ],
//             ),
//           ),
//           body: isLoading
//               ? _buildShimmerLoader()
//               : Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: _scrollController,
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                         child: _buildFullStoryCard(),
//                       ),
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: NeverScrollableScrollPhysics(),
//                         padding: const EdgeInsets.all(16.0),
//                         itemCount: messages.length,
//                         itemBuilder: (context, index) {
//                           final message = messages[index];
//                           final messageDate = message.time;
//                           final previousMessageDate =
//                           index > 0 ? messages[index - 1].time : null;
//
//                           // Show date separator only if the date changes
//                           bool showDateHeader = previousMessageDate == null ||
//                               messageDate.day != previousMessageDate.day ||
//                               messageDate.month != previousMessageDate.month ||
//                               messageDate.year != previousMessageDate.year;
//
//                           return Column(
//                             children: [
//                               if (showDateHeader) _buildDateHeader(messageDate),
//                               _buildMessageBubble(message),
//                             ],
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // status.toLowerCase() == "open" ? "Open" : "Closed"
//               if(status == "open")
//                 _buildResponseField(context),
//             ],
//           )
//       ),
//     );
//   }
//
//   Widget _buildStatusSection() {
//     return Row(
//       children: [
//         // Status Badge
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: status.toLowerCase() == "open"
//                 ? Colors.green.shade100
//                 : Colors.red.shade100,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             status.toLowerCase() == "open" ? "Open" : "Closed",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: status.toLowerCase() == "open"
//                   ? Colors.green.shade800
//                   : Colors.red.shade800,
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//
//         // Toggle Button: When pressed, toggles the status.
//         ElevatedButton(
//           onPressed: () async {
//             String newStatus = (status.toLowerCase() == "open") ? "closed" : "open";
//
//             setState(() {
//               status = newStatus;
//             });
//
//             print("Plea id: ${widget.complainId}");
//             await _supabaseService.updatePleaStatus(widget.complainId, newStatus);
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.white,
//             elevation: 4,
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: Text(
//             status.toLowerCase() == "open" ? "Close Plea" : "Open Plea",
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: status.toLowerCase() == "open" ? Colors.red : Colors.green,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Future<String> _fetchDeepSeekResponse(
//       String name,
//       String threat,
//       String address
//       ) async {
//     const String apiUrl = 'https://api.deepseek.com/v1/chat/completions';
//     const String apiKey = 'sk-2f77d34a592c44efa428ae532390eb6c';
//
//     final headers = {
//       'Authorization': 'Bearer $apiKey',
//       'Content-Type': 'application/json',
//     };
//
//     final body = {
//       "model": "deepseek-chat",
//       "messages": [
//         {
//           'role': 'system',
//           'content': 'Provide quick, actionable advice to help a female victim of abuse or crime until the Shraddha team responds.'
//         },
//         {
//           "role": "user",
//           'content': '''
//               Name: ${name}
//               Address: ${address}
//               Threat: ${widget.description}
//               Story: ${widget.brief}
//             '''
//         }
//       ],
//       "temperature": 0.7
//     };
//
//     // Add Typing Indicator
//     final typingMessage = ChatMessage(
//       sender: senderNameMapping[ChatRole.aiSupport]!,
//       message: "AI Typing...",
//       time: DateTime.now(),
//       role: ChatRole.aiSupport,
//     );
//
//
//     setState(() {
//       messages.add(typingMessage);
//     });
//
//     // Allow the UI to update before making the API call
//     await Future.delayed(const Duration(milliseconds: 100));
//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: headers,
//         body: json.encode(body),
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         String aiResponse = data['choices'][0]['message']['content'];
//
//         print("DeepSeek Response: $aiResponse");
//
//         setState(() {
//           // Remove Typing Indicator
//           messages.remove(typingMessage);
//
//           // Add AI Response
//           // messages.add(
//           //   ChatMessage(
//           //     sender: senderNameMapping[ChatRole.aiSupport]!,
//           //     message: aiResponse,
//           //     time: DateTime.now(),
//           //     role: ChatRole.aiSupport,
//           //   ),
//           // );
//         });
//
//         // Scroll to Bottom after AI Response
//         WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
//         return aiResponse;
//       } else {
//         print("DeepSeek API Error: ${response.body}");
//         setState(() {
//           messages.remove(typingMessage);
//         });
//         return "";
//       }
//     } catch (e) {
//       print("DeepSeek API Exception: $e");
//       setState(() {
//         messages.remove(typingMessage);
//       });
//       return "";
//     }
//   }
//
//   // Full Story Card
//   Widget _buildFullStoryCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             widget.date,
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Name",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.purple,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.name,
//             style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Mobile Number",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.purple,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.phoneNumber,
//             style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Address",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.purple,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.address,
//             style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
//           ),
//           SizedBox(height: 8,),
//           Text(
//             "Brief",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.purple,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.brief,
//             style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Full Story",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: Colors.purple,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             widget.description,
//             style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessageBubble(ChatMessage msg) {
//     bool isUser = msg.role == ChatRole.user;
//     bool isAI = msg.role == ChatRole.aiSupport;
//     bool isSupport = msg.role == ChatRole.admin;
//
//     // Choose bubble color based on role
//     Color bubbleColor = isUser
//         ? Colors.red.shade50
//         : (isAI ? Colors.blue.shade50 : Colors.white);
//
//     return Align(
//       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
//       child: Column(
//         crossAxisAlignment:
//         isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Container(
//             margin: const EdgeInsets.symmetric(vertical: 6),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.8,
//             ),
//             decoration: BoxDecoration(
//               color: bubbleColor,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               msg.message,
//               style: const TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500,),
//             ),
//           ),
//           if(isAI) // Only show AI avatar for AI messages
//             ClipRRect(
//                 borderRadius: BorderRadius.circular(30),
//                 child: Image(image: AssetImage("assets/img.png"), height: 29,)
//             ),
//           Padding(
//             padding: const EdgeInsets.only(right: 8, left: 8),
//             child: Text(
//               _formatTime(msg.time),
//               style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Text field at the bottom: "Type your response..."
//   Widget _buildResponseField(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
//       child: Row(
//         children: [
//           // Expanded text field
//           Expanded(
//             child: TextField(
//               onSubmitted: (v) async {
//                 final text = _responseController.text.trim();
//                 if (text.isNotEmpty) {
//
//                   // setState(() {
//                   //   // Add new message from the user
//                   //   messages.add(ChatMessage(
//                   //     sender: senderNameMapping[ChatRole.user]!,
//                   //     message: text,
//                   //     time: DateTime.now(),
//                   //     role: ChatRole.user,
//                   //   ));
//                   // });
//
//                   await _supabaseService.insertMessage(
//                       pleaId: widget.complainId,
//                       content: text,
//                       role: "user"
//                   );
//                   _responseController.clear();
//
//                   // Scroll to bottom after sending message
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     _scrollToBottom();
//                   });
//                 }
//               },
//               controller: _responseController,
//               decoration: const InputDecoration(
//                 hintText: "Type your response...",
//                 hintStyle: TextStyle(color: Colors.grey),
//                 border: OutlineInputBorder(),
//               ),
//               style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
//             ),
//           ),
//
//           const SizedBox(width: 8),
//
//           // Send button
//           IconButton(
//             icon: const Icon(Icons.send, color: Colors.deepPurple),
//             onPressed: () async {
//               final text = _responseController.text.trim();
//               if (text.isNotEmpty) {
//
//                 // setState(() {
//                 //   // Add new message from the user
//                 //   messages.add(ChatMessage(
//                 //     sender: senderNameMapping[ChatRole.user]!,
//                 //     message: text,
//                 //     time: DateTime.now(),
//                 //     role: ChatRole.user,
//                 //   ));
//                 // });
//
//                 await _supabaseService.insertMessage(
//                     pleaId: widget.complainId,
//                     content: text,
//                     role: "user"
//                 );
//                 _responseController.clear();
//
//                 // Scroll to bottom after sending message
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   _scrollToBottom();
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Helper to format the timestamp
//   String _formatTime(DateTime time) {
//     return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
//   }
// }
//
// // Chat Roles
// enum ChatRole {
//   user,
//   aiSupport,
//   admin,
// }
//
// // Model for a single chat message
// class ChatMessage {
//   final String sender;
//   final String message;
//   final DateTime time;
//   final ChatRole role;
//
//   ChatMessage({
//     required this.sender,
//     required this.message,
//     required this.time,
//     required this.role,
//   });
// }
