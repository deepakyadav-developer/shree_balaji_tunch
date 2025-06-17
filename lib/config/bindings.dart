import 'package:get/get.dart';
import 'package:loginuicolors/controllers/language_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(LanguageController(), permanent: true);
  }
}
