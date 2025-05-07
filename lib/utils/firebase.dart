// CREATE OR REPLACE FUNCTION notify_on_new_message()
// RETURNS TRIGGER AS $$
// DECLARE
// receiver_uuid UUID;
// BEGIN
// -- Get receiver UUID using plea_id from messages table
// SELECT uuid INTO receiver_uuid
// FROM messages
// WHERE plea_id = NEW.plea_id;
//
// -- Call the Edge function with the new message details
// PERFORM
// http_post(
// 'https://<your-supabase-url>.functions.supabase.co/sendNotification',
// json_build_object(
// 'senderId', NEW.sender_type,
// 'receiverId', receiver_uuid,
// 'message', NEW.content
// )
// );
//
// RETURN NEW;
// END;
// $$ LANGUAGE plpgsql;
//
// DROP TRIGGER IF EXISTS on_new_message ON messages;
//
// CREATE TRIGGER on_new_message
// AFTER INSERT ON messages
// FOR EACH ROW EXECUTE FUNCTION notify_on_new_message();
// DECLARE
// receiver_uuid UUID;
// BEGIN
// -- Get receiver UUID using plea_id from messages table
// SELECT id INTO receiver_uuid
// FROM messages
// WHERE plea_id = NEW.plea_id;
//
// -- Call the Edge function with the new message details
// PERFORM
// http_post(
// 'https://<your-supabase-url>.functions.supabase.co/sendNotification',
// json_build_object(
// 'senderId', NEW.sender_type,
// 'receiverId', receiver_uuid,
// 'message', NEW.content
// )
// );
//
// RETURN NEW;
// END;

// Widget _buildStatusSection() {
//   return Row(
//     children: [
//       // Status Badge
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: status == "Open" ? Colors.green.shade100 : Colors.red.shade100,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Text(
//           status,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: status == "Open" ? Colors.green.shade800 : Colors.red.shade800,
//           ),
//         ),
//       ),
//       const SizedBox(width: 8),
//       // Toggle Button: When pressed, toggles the status.
//       ElevatedButton(
//         onPressed: () {
//           setState(() {
//             status = (status == "open") ? "closed" : "Open";
//             print("plea id ${widget.complainId}");
//             final SupabaseService _supabaseService = SupabaseService();
//             _supabaseService.updatePleaStatus(widget.complainId,status ==  "open" ? "closed" : "open");
//
//           });
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.white, // Constant white background
//           elevation: 4, // Shadow effect
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: Text(
//           status == "open" ? "Close plea" : "Open plea",
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: status == "open" ? Colors.green : Colors.red,
//           ),
//         ),
//       ),
//     ],
//   );
// }




// Future<void> _fetchMessages() async {
//   print("hello");
//   List<Map<String, dynamic>> fetchedMessages = await _supabaseService.fetchComplainMessage(widget.complainId);
//   print("2");
//   setState(() {
//     messages.clear();
//     messages.addAll(fetchedMessages.map((msg) => ChatMessage(
//       sender: msg['sender_type'] == 'user' ? "You" : "Support Team",
//       message: msg['content'],
//       time: DateTime.parse(msg['created_at']),
//       role: msg['sender_type'] == 'user' ? ChatRole.user : ChatRole.aiSupport,
//     )));
//   });
// }


// Single Message Bubble
// Widget _buildMessageBubble(ChatMessage msg) {
//   bool isUser = msg.role == ChatRole.user;
//   bool isAI = msg.role == ChatRole.aiSupport;
//   bool isSupport = msg.role == ChatRole.supportTeam;
//
//   // Choose bubble color based on role
//   Color bubbleColor = Colors.white;
//   if (isAI) {
//     bubbleColor = Colors.blue.shade50;
//   } else if (isSupport) {
//     bubbleColor = Colors.white;
//   } else if (isUser) {
//     bubbleColor = Colors.red.shade50;
//   }
//
//   // Calculate the fixed width dynamically based on the screen size
//   double fixedWidth = isAI || msg.sender == "Brief" ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.8;
//
//   return Align(
//     alignment: isUser || isSupport ? Alignment.centerRight : Alignment.centerLeft,  // Same alignment for User and Support
//     child: Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       width: fixedWidth, // Width is based on sender's role (full width for AI and Brief)
//       child: Column(
//         crossAxisAlignment: isUser || isSupport ? CrossAxisAlignment.end : CrossAxisAlignment.start,  // Same for User and Support
//         children: [
//           // For AI and Brief messages, span full width
//           if (isAI || msg.sender == "Brief")
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: bubbleColor,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                 children: [
//                   // Sender and Date/Time in the same row for AI or Brief
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Text(
//                         msg.sender,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: isAI
//                               ? Colors.deepPurple
//                               : (isSupport ? Colors.blue : Colors.green),
//                         ),
//                       ),
//                       const Spacer(),
//                       // Date & Time label for AI or Brief
//                       Text(
//                         _formatTime(msg.time),
//                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8), // Space between sender + timestamp and message content
//                   // Message content for AI or Brief
//                   Text(
//                     msg.message.trim(),
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//           // For User or Support messages, regular message bubble (same layout for both)
//           if (isSupport || isUser)
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: bubbleColor,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: isUser || isSupport ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//                 children: [
//                   // Sender and Date/Time in the same row for Support or User
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Sender label
//                       Text(
//                         msg.sender,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: isAI
//                               ? Colors.deepPurple
//                               : (isSupport ? Colors.blue : Colors.green),
//                         ),
//                       ),
//                       // Date & Time label for Support or User
//                       Text(
//                         _formatTime(msg.time),
//                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8), // Space between sender + timestamp and message content
//                   // Message content for Support or User
//                   Text(
//                     msg.message.trim(),
//                     style: const TextStyle(fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     ),
//   );
// }



// Widget _buildPleaCard({
//   required BuildContext context,
//   required double screenWidth,
//   required String pleaId,
//   required String date,
//   required String status,
//   required Color statusColor,
//   required String description,
// }) {
//   return Container(
//     width: screenWidth * 0.9,
//     margin: const EdgeInsets.symmetric(vertical: 10),
//     padding: EdgeInsets.all(screenWidth * 0.04),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.grey.withOpacity(0.2),
//           blurRadius: 5,
//           spreadRadius: 2,
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Plea ID + Status, and Date on the Right
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Text(
//                   "Plea #$pleaId ",
//                   style: const TextStyle(
//                     color: Colors.purple,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     status,
//                     style: TextStyle(
//                       color: statusColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Text(
//               date,
//               style: const TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//
//
//         const SizedBox(height: 5),
//
//
//         // Description
//         Text(
//           description,
//           style: const TextStyle(
//             color: Colors.black87,
//             fontSize: 14,
//           ),
//         ),
//
//         const SizedBox(height: 8),
//
//         // View Details Row
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PleaDetailPage(),
//               ),
//             );
//           },
//           child: const Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "View Details",
//                 style: TextStyle(
//                   color: Colors.purple,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Icon(
//                 Icons.arrow_forward_ios,
//                 size: 14,
//                 color: Colors.purple,
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
