// import 'package:flutter/material.dart';
// import 'package:timezone/timezone.dart' as tz;
//
// import 'notifications/notification_service.dart';
//
// class FirstScreen extends StatefulWidget {
//   const FirstScreen({super.key});
//
//   @override
//   State<FirstScreen> createState() => _FirstScreenState();
// }
//
// class _FirstScreenState extends State<FirstScreen> {
//
//   NotificationServices notificationServices = NotificationServices();
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     notificationServices.initializeNotifications();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Send Notifications"),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 15.0),
//             child: IconButton(onPressed: (){}, icon: const Icon(Icons.notification_important),),
//           )
//         ],
//       ),
//       body: SizedBox(
//         width: double.infinity,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(onPressed: (){
//               notificationServices.sendNotification("This is a title", "This is a body");
//             }, child: const Text("Send Notification"),),
//             ElevatedButton(onPressed: (){
//               List<TimeOfDay> notificationTimes = [
//                 const TimeOfDay(hour: 6, minute: 52),
//                 const TimeOfDay(hour: 6, minute: 53),
//                 const TimeOfDay(hour: 6, minute: 54),
//               ];
//
//               List<DateTime> formattedNotificationTimes = notificationTimes.map((time) {
//                 DateTime now = DateTime.now();
//                 // Set the correct am/pm based on the current time
//                 int hour = time.hour;
//                 if (now.hour > 12) {
//                   hour += 12;
//                 }
//                 return tz.TZDateTime(
//                   tz.local,
//                   now.year,
//                   now.month,
//                   now.day,
//                   hour,
//                   time.minute,
//                 );
//               }).toList();
//
//               notificationServices.scheduleNotification(
//                 formattedNotificationTimes,
//                 'Your Title',
//                 'Your Body',
//               );
//
//             }, child: const Text("Schedule Notification"),),
//             ElevatedButton(onPressed: (){
//               notificationServices.stopNotifications();
//             }, child: const Text("Stop Notification"),),
//           ],
//         ),
//       ),
//     );
//   }
// }
