# SkyMobile

SkyMobile is a remake of the original SkyMobile_iOS. SkyMobile is cross platform and is now supported on android.

SkyMobile has all the features of SkyMobile_iOS and more!

SkyMobile is also 1.5x faster than SkyMobile_iOS *(tests were on an iPhone 7+)* and packs in a bunch more error checking features to make sure your information is shown without error.

Join the SkyMobile discord server [here](https://discord.gg/Hqvann5).

# Changelog

### V2.0.1 Release

- Fixes bug where a decimal name would be shown in grade
- Fixes bug where no identities enrolled would cause a permanent black screen

### V2.0 Release

- Huge Update, adds many security features and settings and more.
- Replaces top three bar access to GPA Calculator with a drawer
- Adds developer console easter egg (NOTE: this console can break SkyMobile if you're not careful. Use only if developer)
- Adds biometric authentication
- Adds biometric blurring: Blurs your grades if app is paused or enters the background. Your biometric authentication is required to access the app again
- Removes screenshot ability for Android because of security
- Allow ability to change theme, more are coming soon!
- Allow ability to disable biometric authentication for blurring if not preferred
- Allow ability to default to app chooser once you enter the app
- Allow ability to automatically login to previous session

### V1.2 Release

- Redesigns UI and fixes mini bugs

### V1.1.2 Release (V1.1.1 withdrawn)

- Fixes GPA Calculator for districts without academic history
- Fixes District Searcher

### V1.1 Release

- Fixes bugs in the GPA Calculator
- Added "out of" score if integer and double grade isn't found for iOS (Already added in Android)
- 4.0 GPA Added
- GPA Calculator Settings for 4.0 GPA: Advanced, 4.33, and weighted
- Fixes bug where first school year settings aren't saved
- Added instructions for GPA Calculator

### V1.0 Release

- Updates JSON Saver to save GPA Calculator modifications
- Adds GPA Calculator
  - HUGE Upgrade from GPA Calculator iOS
  - Adds new window for modifying specific school years
  - Selectable semesters to add into the GPA Calculator
- Uses skyscrapeapi 1.0.0+3
- Merged naming schemes. Beta will no longer have a separate version scheme

### V1.1.0 Beta / V1.0.0 Internal Testing

- **WARNING: ALL PREVIOUSLY SAVED ACCOUNTS WILL BE DELETED**
- Updates JSON Saver to save GPA Calculator modifications
- Beta GPA Calculator
- **iOS Beta Build 12** fixes a miscalculation with behavior terms, ending up with an extremely low GPA
- **iOS Beta Build 13** fixes the "evelyn" bug
- **iOS Beta Build 14** fixes the red screen bug when session expires
- **iOS Beta Build 15** more efficient error checking
- **iOS Beta Build 16** final build for ios: SkyScrapeAPI departure to its own dart world
- Uses SKYSCRAPEAPI V1.6.0 up until **iOS Beta Build 16** which uses skyscrapeapi 1.0.1+3

### V1.0.0 Beta / V0.0.1 Internal Testing

- Adds DistrictSearcher
- Fixes bugs for other districts
- Fixes multiple registered taps bug
- Added account saving
- Uses SKYSCRAPEAPI V1.4.1
**Merged 1.0.0 and 1.1.0 old beta**
- Initial Release
- Can check grades, assignments, assignment details
- Uses SKYSCRAPEAPI V1.2

# Documentation Information

Since SkyScrapeAPI has been moved to its own specific package for flutter, the API Documentation is now located [here](https://pub.dev/documentation/skyscrapeapi/latest/).

The documentation is constantly being worked on. If you think there are missing parts or it's incomplete, please contact hunter.han@gmail.com or join the discord channel and chat with the developers.

# Credits

Skyward API Name Credits: @[yquan162](https://github.com/yquan162)

Skyward API & SkyMobile Development: @[lingfeishengtian](https://github.com/lingfeishengtian)

SkyMobile Maintenence: @[PotatoCurry](https://github.com/PotatoCurry)

SkyPlan: @[Thomas Kaldahl](https://github.com/ei14)

