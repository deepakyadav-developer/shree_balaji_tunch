# 🔐 NEW KEYSTORE INFORMATION

## ✅ Keystore Successfully Created!

**Created Date:** January 31, 2026

---

## 📋 Keystore Details

| Property | Value |
|----------|-------|
| **File Name** | `upload-keystore.jks` |
| **Location** | `android/app/` directory |
| **Key Alias** | `upload` |
| **Store Password** | `sbt@123` |
| **Key Password** | `sbt@123` |
| **Validity** | 10,000 days (until June 18, 2053) |
| **Key Algorithm** | RSA |
| **Key Size** | 2048 bits |

---

## 🔑 Certificate Fingerprints

### SHA-1 Fingerprint:
```
B9:AC:B9:CD:BD:60:29:28:A4:69:22:63:DE:BF:83:24:84:E0:2B:69
```

### SHA-256 Fingerprint:
```
12:E1:56:28:C2:76:C2:27:BB:1A:C0:73:19:66:E6:21:22:59:0D:9D:25:A8:3B:E7:F2:86:DB:6F:35:D0:E2:D4
```

---

## 📱 Firebase Configuration

**⚠️ IMPORTANT:** You need to update Firebase with the new SHA-1 fingerprint!

### Steps to Update Firebase:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **Shree Balaji Tunch**
3. Go to **Project Settings** (gear icon)
4. Scroll down to **Your apps** section
5. Select your Android app
6. Click **Add fingerprint**
7. Add the new **SHA-1** fingerprint:
   ```
   B9:AC:B9:CD:BD:60:29:28:A4:69:22:63:DE:BF:83:24:84:E0:2B:69
   ```
8. Also add the **SHA-256** fingerprint (optional but recommended)
9. Download the new `google-services.json` file
10. Replace the old file in `android/app/google-services.json`

---

## 📂 Key Properties File

The `android/key.properties` file contains:

```properties
storePassword=sbt@123
keyPassword=sbt@123
keyAlias=upload
storeFile=upload-keystore.jks
```

**Note:** The `storeFile` path is relative to the `android/app/` directory.

---

## 🔍 Verify Keystore Commands

### List keystore contents:
```bash
keytool -list -keystore android/app/upload-keystore.jks -storepass sbt@123
```

### View detailed certificate info:
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -storepass sbt@123
```

### Get SHA-1 fingerprint:
```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload -storepass sbt@123 | findstr SHA1
```

---

## 🏗️ Build Release APK

```bash
flutter clean
flutter pub get
flutter build apk --release
```

The signed APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🛡️ Security Reminders

- ✅ Keystore file is in `.gitignore` (won't be committed to Git)
- ✅ Keystore moved to `android/app/upload-keystore.jks`
- ✅ Backup `android/app/upload-keystore.jks` to a secure location
- ✅ Store passwords securely
- ✅ Never share keystore file publicly
- ⚠️ **CRITICAL:** If you lose this keystore, you cannot update your app on Play Store!

---

## 📝 Certificate Information

**Owner:** CN=Shree Balaji, OU=Development, O=SBT, L=India, ST=India, C=IN  
**Valid From:** January 31, 2026  
**Valid Until:** June 18, 2053  
**Serial Number:** 44306e81c7a619cc

---

## ✅ Next Steps

1. ✅ Keystore created successfully
2. 🔄 Update Firebase with new SHA-1 fingerprint
3. 🔄 Download new `google-services.json` from Firebase
4. 🔄 Replace old `google-services.json` in `android/app/`
5. ✅ Build and test release APK
6. ✅ Backup keystore file securely

---

**Generated:** January 31, 2026  
**Status:** ✅ Ready for Production Build
