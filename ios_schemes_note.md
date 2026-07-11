# iOS Flavor Setup (Schemes)

Flutter flavors on iOS require matching Xcode schemes.

## Steps in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Go to **Product → Scheme → Manage Schemes**
3. You'll see one scheme called `Runner` — duplicate it **3 times**
4. Rename the duplicates to exactly: `dev`, `staging`, `prod`  
   (must match the strings passed to `--flavor`)

## For each scheme:
- Edit the scheme → **Run** tab
- Set **Build Configuration** to the matching one  
  (you may need to create `Debug-dev`, `Debug-staging`, `Release-prod` etc. in  
  `ios/Flutter/` xcconfig files — Flutter usually auto-generates these on first build)

## Simplest approach — let Flutter generate them:
Run once WITHOUT flavor first to let Flutter generate the xcconfig files:
```bash
flutter run
```
Then add schemes in Xcode as above.

## xcconfig files Flutter generates:
```
ios/Flutter/
├── Debug.xcconfig
├── Release.xcconfig
└── Generated.xcconfig
```
You can duplicate these per flavor:
```
ios/Flutter/
├── Debug-dev.xcconfig     ← copy of Debug.xcconfig
├── Debug-staging.xcconfig
├── Release-dev.xcconfig   ← copy of Release.xcconfig
├── Release-staging.xcconfig
├── Release-prod.xcconfig
```
