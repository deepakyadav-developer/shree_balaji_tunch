# 🚀 Codemagic se iOS Build Kaise Banaye - Complete Guide

## ✅ Windows se iOS Build - Step by Step

Codemagic ek cloud service hai jo macOS machines provide karti hai. Aap Windows se hi iOS build bana sakte ho!

---

## 📋 Prerequisites (Pehle Yeh Chahiye)

### 1. Apple Developer Account (Zaroori)
- **Cost**: $99/year (₹8,000 approx)
- **Website**: https://developer.apple.com
- **Signup karo**: Apple ID se login karo

### 2. GitHub/GitLab Account (Free)
- Apna code GitHub pe push karo
- Private repo bhi chal jayega

### 3. Codemagic Account (Free)
- **Website**: https://codemagic.io
- **Free tier**: 500 build minutes/month
- GitHub se signup karo

---

## 🔧 Step 1: Apple Developer Setup

### A. Certificates Banao
1. Go to: https://developer.apple.com/account
2. **Certificates, IDs & Profiles** pe click karo
3. **Certificates** > **+** (Plus icon)
4. Select: **iOS Distribution (App Store and Ad Hoc)**
5. Download certificate (.cer file)

### B. App ID Create karo
1. **Identifiers** > **+** (Plus icon)
2. Select: **App IDs** > **Continue**
3. **Bundle ID**: `com.sbt.sbtunch` (exactly same as your app)
4. **Capabilities** enable karo:
   - Push Notifications ✅
   - Sign in with Apple (agar use kar rahe ho)
5. **Register** pe click karo

### C. Provisioning Profile Banao
1. **Profiles** > **+** (Plus icon)
2. Select: **App Store** > **Continue**
3. Select your App ID
4. Select your certificate
5. Profile name: `Shree Balaji Store Distribution`
6. Download provisioning profile (.mobileprovision file)

---

## 🔑 Step 2: App Store Connect API Key Banao

Yeh zaroori hai automatic upload ke liye:

1. Go to: https://appstoreconnect.apple.com
2. **Users and Access** > **Keys** tab
3. **+** (Generate API Key) click karo
4. **Name**: "Codemagic"
5. **Access**: "Admin" (or "App Manager")
6. **Generate** click karo
7. **Download** key (.p8 file) - SAVE IT SAFELY!
8. Note down:
   - **Issuer ID** (UUID format)
   - **Key ID** (10 character string)

⚠️ **Important**: .p8 file sirf ek baar download hoti hai, dobara nahi milegi!

---

## 🐙 Step 3: Code ko GitHub pe Push karo

```bash
# Terminal mein yeh commands chalao

# Git initialize (agar pehle se nahi hai)
git init

# Files add karo
git add .

# Commit karo
git commit -m "Initial commit for iOS build"

# GitHub pe repo banao aur remote add karo
git remote add origin https://github.com/YOUR_USERNAME/shree_balaji_store.git

# Push karo
git push -u origin main
```

---

## 🎯 Step 4: Codemagic Setup

### A. Codemagic pe Signup
1. Go to: https://codemagic.io
2. **Sign up with GitHub** click karo
3. GitHub authorization allow karo

### B. App Add karo
1. Dashboard pe **Add application** click karo
2. **GitHub** select karo
3. Your repository select karo: `shree_balaji_store`
4. **Add application** click karo

### C. Workflow Configure karo
1. **Start your first build** > **Set up build configuration**
2. **Select workflow editor**: Switch to **codemagic.yaml**
3. ✅ Already created! (codemagic.yaml file in your project)

### D. Environment Variables Add karo
1. **App settings** > **Environment variables** pe jao
2. Yeh variables add karo:

**Add these variables:**
```
APP_STORE_CONNECT_ISSUER_ID = [Your Issuer ID from Step 2]
APP_STORE_CONNECT_KEY_IDENTIFIER = [Your Key ID from Step 2]
APP_STORE_CONNECT_PRIVATE_KEY = [Paste .p8 file content]
CERTIFICATE_PRIVATE_KEY = [Your certificate password - create new if needed]
```

**How to add .p8 file content:**
- Open .p8 file in Notepad
- Copy EVERYTHING (including BEGIN and END lines)
- Paste in Codemagic

### E. Code Signing Setup
1. **Code signing** tab pe jao
2. **Upload certificate**:
   - Upload your .cer file
   - Set password (remember it!)
3. **Upload provisioning profile**:
   - Upload .mobileprovision file
   - Link with certificate

---

## 🚀 Step 5: Build Start karo!

1. **Start new build** button click karo
2. Select workflow: **ios-workflow**
3. **Start build** click karo
4. ☕ Wait 15-20 minutes...

### Build Process:
- ✅ Environment setup
- ✅ Clone repository
- ✅ Install dependencies
- ✅ Build iOS app
- ✅ Sign with certificate
- ✅ Upload to TestFlight

---

## 📱 Step 6: TestFlight pe Test karo

Build success hone ke baad:

1. Go to: https://appstoreconnect.apple.com
2. **My Apps** > **Shree Balaji Store** select karo
3. **TestFlight** tab pe jao
4. Build appear hoga (1-2 hours lag sakta hai)
5. **Testers** add karo (your email)
6. App test karo iPhone pe

---

## 🎉 Step 7: App Store pe Submit karo

Sab kuch theek hai to:

1. **App Store** tab pe jao
2. **+ Version or Platform** > **iOS**
3. Version info fill karo:
   - App Name: "Shree Balaji Store"
   - Subtitle: "Your Trusted Shopping Partner"
   - Description: [Use from ios_promotional_text.md]
   - Keywords: [Use from ios_promotional_text.md]
   - Screenshots upload karo (required sizes)
4. **Build** select karo (TestFlight wala)
5. **Pricing**: Free (or set price)
6. **App Review Information** fill karo
7. **Submit for Review** click karo

---

## 💰 Cost Breakdown

| Service | Cost | Frequency |
|---------|------|-----------|
| Apple Developer | $99 | Per Year |
| Codemagic Free | Free | 500 min/month |
| Codemagic Paid (optional) | $45 | Per Month |

**Total minimum cost**: $99/year (sirf Apple Developer account)

---

## 🆘 Common Errors & Solutions

### Error: "Code signing failed"
**Solution**: 
- Check certificate password
- Verify bundle ID matches exactly
- Re-upload provisioning profile

### Error: "Build timed out"
**Solution**:
- Upgrade to paid plan (more build time)
- Or split into smaller builds

### Error: "Invalid API Key"
**Solution**:
- Check Issuer ID and Key ID are correct
- Verify .p8 file content is complete
- Regenerate API key if needed

### Error: "Missing compliance"
**Solution**:
- In App Store Connect, answer export compliance questions
- Usually "No" for encryption if using standard HTTPS

---

## 🎓 Alternative: GitHub Actions (Free but Complex)

Agar Codemagic free minutes khatam ho jaye:

1. GitHub Actions use karo (unlimited builds on public repos)
2. `.github/workflows/ios.yml` file banao
3. Secrets add karo repository settings mein
4. But setup thoda complex hai

---

## 📞 Need Help?

**Codemagic Documentation**: https://docs.codemagic.io/flutter-configuration/flutter-projects/
**Apple Developer Support**: https://developer.apple.com/support/

---

## ✅ Checklist

Before starting build:

- [ ] Apple Developer Account active ($99 paid)
- [ ] Bundle ID registered (com.sbt.sbtunch)
- [ ] App Store Connect API Key (.p8 file downloaded)
- [ ] Certificate created and downloaded
- [ ] Provisioning Profile created and downloaded
- [ ] Code pushed to GitHub
- [ ] Codemagic account created
- [ ] Environment variables added
- [ ] Code signing files uploaded
- [ ] codemagic.yaml file in project root

---

## 🎯 Quick Summary

1. **Apple Developer Account** banao → $99/year
2. **Certificates & Profiles** create karo
3. **API Key** generate karo (.p8 file)
4. **Code ko GitHub** pe push karo
5. **Codemagic** account banao
6. **Environment variables** add karo
7. **Build start** karo
8. **TestFlight** pe test karo
9. **App Store** pe submit karo

**Total Time**: 2-3 hours (pehli baar)
**Total Cost**: $99/year

---

Koi doubt ho to contact karo! Good luck! 🚀
