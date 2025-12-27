// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class NetworkConnectivityService extends GetxController {
//   final Connectivity _connectivity = Connectivity();
//   final RxBool isConnected = true.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     initConnectivity();
//     _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
//   }

//   Future<void> initConnectivity() async {
//     ConnectivityResult result;
//     try {
//       result = await _connectivity.checkConnectivity();
//       _updateConnectionStatus(result);
//     } catch (e) {
//       debugPrint('Couldn\'t check connectivity status: $e');
//     }
//   }

//   void _updateConnectionStatus(ConnectivityResult result) {
//     if (result == ConnectivityResult.none) {
//       isConnected.value = false;
//       Get.offAllNamed('/no-internet');
//     } else {
//       isConnected.value = true;
//       if (Get.currentRoute == '/no-internet') {
//         Get.back();
//       }
//     }
//   }
// }
