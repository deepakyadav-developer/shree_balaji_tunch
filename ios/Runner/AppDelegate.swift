import UIKit
import Flutter
import UserNotifications
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Handle method channel for developer mode
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "com.shreebalajitunch/developer_mode", binaryMessenger: controller.binaryMessenger)
    
    methodChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "isDeveloperModeEnabled" {
        // iOS doesn't have a direct equivalent of Android's developer mode
        // Always return false for iOS
        result(false)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    // Set up notification authorization for iOS
    if #available(iOS 10.0, *) {
      let center = UNUserNotificationCenter.current()
      center.delegate = self as? UNUserNotificationCenterDelegate
      
      // Register notification sounds
      let soundNames = ["notification.mp3", "tts.mp3", "tts2.mp3"]
      for soundName in soundNames {
        let soundBaseName = soundName.replacingOccurrences(of: ".mp3", with: "")
        let soundURL = Bundle.main.url(forResource: soundBaseName, withExtension: "mp3")
        if let _ = soundURL {
          let _ = UNNotificationSound.customSound(soundName)
          print("Registered sound: \(soundName)")
        } else {
          print("Could not find sound file: \(soundName)")
        }
      }
      
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      center.requestAuthorization(
        options: authOptions,
        completionHandler: {_, _ in })
    } else {
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      application.registerUserNotificationSettings(settings)
    }
    
    application.registerForRemoteNotifications()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
