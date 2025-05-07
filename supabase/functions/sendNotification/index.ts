// import { createClient } from 'npm:@supabase/supabase-js';
// import * as admin from 'npm:firebase-admin';
//
// // Initialize Firebase Admin SDK
// if (!admin.apps.length) {
//   const serviceAccount = JSON.parse(Deno.env.get('FIREBASE_ADMIN_CONFIG')!);
//   admin.initializeApp({
//     credential: admin.credential.cert(serviceAccount),
//   });
// }
//
// const supabaseUrl = Deno.env.get('https://pxuddyzwjfkghhejsqqv.supabase.co')!;
// const supabaseKey = Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4dWRkeXp3amZrZ2hoZWpzcXF2Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0MDU0NjI3MCwiZXhwIjoyMDU2MTIyMjcwfQ.LGqzjxvPcta3PPc5dPXkMOe2BNi_wNc1oW9Kk-5C0_c')!;
// const supabase = createClient(supabaseUrl, supabaseKey);
//
// export default async (req: any, res: any) => {
//   const { senderId, receiverId, message } = req.body;
//
//   // ✅ Get receiver's FCM token from Supabase using UUID
//   const { data, error } = await supabase
//     .from('notification')
//     .select('fcm_token')
//     .eq('id', receiverId);
//
//   if (error || !data?.fcm_token) {
//     console.error("⚠️ FCM token not found", error);
//     return res.status(400).json({ error: "FCM token not found" });
//   }
//
//   const payload = {
//     notification: {
//       title: 'New Message',
//       body: message,
//       click_action: 'FLUTTER_NOTIFICATION_CLICK',
//     },
//     token: data.fcm_token,
//   };
//
//   try {
//     await admin.messaging().send(payload);
//     console.log("✅ Notification sent successfully");
//     return res.status(200).json({ success: true });
//   } catch (err) {
//     console.error("❌ Error sending notification:", err);
//     return res.status(500).json({ error: "Error sending notification" });
//   }
// };
