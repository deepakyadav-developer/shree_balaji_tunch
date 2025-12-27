# Keystore Information - Shree Balaji Tounch

## ✅ Upload Keystore Created Successfully

### Keystore Details:

| Property | Value |
|----------|-------|
| **File Name** | `upload-keystore.jks` |
| **Location** | Project root directory |
| **Key Alias** | `upload` |
| **Store Password** | `sbt@123` |
| **Key Password** | `sbt@123` |
| **Algorithm** | RSA |
| **Key Size** | 2048 bits |
| **Validity** | 10,000 days (~27 years) |
| **Type** | PKCS12 |

### Certificate Information:

```
CN=Shree Balaji Tounch
OU=SBT
O=SBT
L=India
ST=India
C=IN
```

### SHA-256 Fingerprint:
```
1B:A7:F1:43:B2:60:1B:BE:5A:DB:45:DB:3C:F8:7D:CF:38:FA:13:38:3E:C4:71:C5:BF:E0:21:2E:F0:87:EC:02
```

## Configuration Files:

### 1. key.properties (android/key.properties)
```properties
storePassword=sbt@123
keyPassword=sbt@123
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 2. build.gradle.kts
Already configured to use key.properties file for release signing.

## Building Signed APK:

### Release APK (Signed):
```bash
flutter build apk --release
```

### Release App Bundle (for Play Store):
```bash
flutter build appbundle --release
```

The APK/AAB will be automatically signed with your keystore.

## Output Locations:

- **Signed APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **Signed AAB:** `build/app/outputs/bundle/release/app-release.aab`

## Important Security Notes:

⚠️ **KEEP THESE FILES SECURE:**

1. **upload-keystore.jks** - Your keystore file
2. **android/key.properties** - Contains passwords

### Backup Instructions:

1. **Backup the keystore file** to a secure location
2. **Never commit key.properties to Git** (already in .gitignore)
3. **Store passwords securely** (password manager recommended)
4. **If you lose this keystore**, you cannot update your app on Play Store

### For Git:

The `.gitignore` should already exclude:
- `*.jks`
- `key.properties`

Verify with:
```bash
git status
```

Make sure these files are NOT listed for commit.

## Verification Commands:

### List keystore contents:
```bash
keytool -list -keystore upload-keystore.jks -storepass sbt@123
```

### View detailed certificate info:
```bash
keytool -list -v -keystore upload-keystore.jks -storepass sbt@123
```

### Get SHA-1 fingerprint (for Firebase/Google Services):
```bash
keytool -list -v -keystore upload-keystore.jks -alias upload -storepass sbt@123 | findstr SHA1
```

### Get SHA-256 fingerprint:
```bash
keytool -list -v -keystore upload-keystore.jks -alias upload -storepass sbt@123 | findstr SHA256
```

## For Google Play Console:

When uploading to Play Store, you'll need:
1. The signed AAB file
2. SHA-256 certificate fingerprint (shown above)

## Troubleshooting:

### If build fails with signing error:
1. Verify `key.properties` exists in `android/` folder
2. Verify `upload-keystore.jks` exists in project root
3. Check passwords are correct in `key.properties`
4. Ensure file paths are correct

### If you need to change passwords:
```bash
# Change keystore password
keytool -storepasswd -keystore upload-keystore.jks

# Change key password
keytool -keypasswd -alias upload -keystore upload-keystore.jks
```

Then update `android/key.properties` with new passwords.

## Next Steps:

1. ✅ Keystore created
2. ✅ key.properties configured
3. ✅ build.gradle.kts already set up
4. 🚀 Ready to build signed APK/AAB

Run:
```bash
flutter build apk --release
```

Your app will be signed and ready for distribution!
