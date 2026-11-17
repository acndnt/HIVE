# Hive — iOS app

**On Windows?** Jump to "Building on Windows" at the bottom. You don't need a Mac.

This folder is a ready-to-build iOS app. The whole app lives in `www/` (plain HTML + JavaScript, no build step).
Capacitor wraps it in a native iOS shell so it installs like any other app, saves your data on the phone,
and can send your reminders as real notifications.

## What you need

- A **Mac** with **Xcode 26 or newer** (free from the Mac App Store). Apple only lets you build iOS apps on a Mac.
- **Node.js 22 or newer** (https://nodejs.org).
- An **Apple ID**.
  - A free Apple ID is enough to run the app on **your own iPhone**, but Apple makes it stop opening after 7 days until you run it from Xcode again.
  - To get an **.ipa file** you can keep installed for a year, send to TestFlight or put on the App Store, you need the **Apple Developer Program** ($99/year).

## 1. Set up the project (once)

In Terminal, inside this folder:

```bash
npm install
npx cap add ios
npm run assets           # makes the app icon and splash screen from resources/
npx cap sync ios
```

Open `capacitor.config.json` first and change `"appId"` to something unique to you, like `com.alexsmith.hive`.

## 2. Allow the photo picker

The profile photo uses the phone's photo library. Open `ios/App/App/Info.plist` and add these two lines inside the top `<dict>`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Choose a photo for your profile.</string>
<key>NSCameraUsageDescription</key>
<string>Take a photo for your profile.</string>
```

## 3. Run it on your iPhone

```bash
npm run ios              # opens the project in Xcode
```

In Xcode:
1. Click **App** in the left sidebar → **Signing & Capabilities** → choose your **Team** (your Apple ID; add it under Xcode › Settings › Accounts if it isn't listed).
2. Plug in your iPhone, pick it at the top of the window, and press **Run** (▶).
3. On the iPhone, the first time: **Settings › Privacy & Security › Developer Mode** → on, and **Settings › General › VPN & Device Management** → trust your developer profile.

## 4. Make the .ipa file

1. At the top of Xcode, set the run destination to **Any iOS Device (arm64)**.
2. **Product › Archive**. When it finishes, the Organizer window opens.
3. Select the archive → **Distribute App**, then choose one:
   - **TestFlight & App Store** — uploads to App Store Connect; install it with TestFlight. (Developer Program)
   - **Release Testing** (Ad Hoc) — exports an `.ipa` for iPhones whose device IDs you've registered in your developer account. (Developer Program)
   - **Debugging** — exports a development `.ipa` for your registered devices.
4. Choose a folder; Xcode writes `Hive.ipa` there. Install it with Apple Configurator, Finder (drag onto the phone), or TestFlight.

## Changing the app later

Edit the pages in `www/`, then run `npx cap sync ios` and build again in Xcode.

## Try it without a Mac

`www/` also works as a home-screen web app: host the folder anywhere with HTTPS (Netlify Drop, GitHub Pages, Vercel), open it in Safari on your iPhone, then **Share › Add to Home Screen**. Everything works except notifications and haptics.

## How it behaves

- Starts empty, like a fresh install: no example dreams, goals or tasks.
- Everything is saved on the phone. Deleting the app deletes your data; there's no account or cloud backup yet.
- Each day's ticks are filed under that date at midnight, so streaks, points, the 5 week grid, badges and titles come from your real history.
- Reminders in Settings become real notifications in the iOS app (on the days and times you set). "Nudge again if not done" isn't scheduled yet.
- The leaderboard only shows you; friends need an online account system, which isn't built.
- Light mode isn't designed yet; Dark, AMOLED and System use the dark look.
- Fonts (Inter, Source Code Pro) load from Google Fonts when online; offline the phone's own fonts are used.

## Building on Windows (no Mac)

Apple only builds iOS apps on macOS, so this project includes a workflow that builds it on a Mac in GitHub's cloud
(`.github/workflows/ios.yml`). You then install the result on your iPhone from Windows with Sideloadly.

1. Make a free account at github.com and create a **new repository** (public builds are free; private ones use your monthly free minutes).
2. In the repository, **Add file › Upload files** and drag in everything from this folder (`www`, `resources`, `package.json`,
   `capacitor.config.json`, `README.md`). Commit.
3. **Add file › Create new file**, name it `.github/workflows/ios.yml`, paste in the contents of the same file from this folder, and commit.
   (Windows can hide folders starting with a dot when uploading, which is why this one is created by hand.)
4. Open the **Actions** tab › **Build iOS app** › **Run workflow**. It takes about 10–15 minutes.
5. Open the finished run, download **Hive-ipa** under Artifacts, and unzip it: inside is `Hive-unsigned.ipa`.
6. On your PC, install **iTunes** and **iCloud from Apple's website** (not the Microsoft Store versions), then install **Sideloadly** (sideloadly.io).
7. Plug in your iPhone, tap **Trust**, open Sideloadly, drag in `Hive-unsigned.ipa`, enter your Apple ID and press **Start**.
8. On the iPhone: **Settings › General › VPN & Device Management** › trust your Apple ID, and turn on **Settings › Privacy & Security › Developer Mode**.

With a free Apple ID the app stops opening after 7 days; plug in and press Start in Sideloadly again (your data stays).
With the Apple Developer Program ($99/year) it lasts a year, and you can sign and send builds to TestFlight from the cloud
with a service like Codemagic or Ionic Appflow instead.
