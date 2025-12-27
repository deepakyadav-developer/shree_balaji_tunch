// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../constant/app_info.dart';
// import '../services/network_connectivity_service.dart';

// class NoInternetScreen extends StatelessWidget {
//   final NetworkConnectivityService _connectivityService =
//       Get.find<NetworkConnectivityService>();

//   NoInternetScreen({Key key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.wifi_off,
//               size: 100,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'No Internet Connection',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: bgColor,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Please check your internet connection',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 30),
//             Obx(() => _connectivityService.isConnected.value
//                 ? const SizedBox()
//                 : ElevatedButton(
//                     onPressed: () {
//                       _connectivityService.initConnectivity();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: bgColor,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 30,
//                         vertical: 15,
//                       ),
//                     ),
//                     child: const Text(
//                       'Retry',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                   )),
//           ],
//         ),
//       ),
//     );
//   }
// }
