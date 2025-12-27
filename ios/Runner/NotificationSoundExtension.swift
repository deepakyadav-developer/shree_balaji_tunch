import Foundation
import UserNotifications

@available(iOS 10.0, *)
extension UNNotificationSound {
    static func customSound(_ name: String) -> UNNotificationSound? {
        // Check if the filename already has .mp3 extension
        let filename = name.hasSuffix(".mp3") ? name : "\(name).mp3"
        return UNNotificationSound(named: UNNotificationSoundName(rawValue: filename))
    }
} 