<br/>
<p align="center" style="padding-bottom: 12px">                    
<img  src="https://raw.githubusercontent.com/Milad-Akarie/permit/main/art/permit_logo.svg" height="100" alt="Permit logo">                    
</p>                    


<p align="center">                    
<a href="https://img.shields.io/badge/License-MIT-green"><img src="https://img.shields.io/badge/License-MIT-green" alt="MIT License"></a>                    
<a href="https://github.com/Milad-Akarie/permit/stargazers"><img src="https://img.shields.io/github/stars/Milad-Akarie/permit?style=flat&logo=github&colorB=green&label=stars" alt="stars"></a>                    
<a href="https://pub.dev/packages/permit"><img src="https://img.shields.io/pub/v/permit.svg?label=pub&color=orange" alt="pub version"></a>                    
<a align="center" href="https://codecov.io/github/Milad-Akarie/permit" > 
 <img src="https://codecov.io/github/Milad-Akarie/permit/graph/badge.svg?token=ZSTW5VFTJD"/> 
 </a>
</p>                    

<p align="center">                  
<a href="https://www.buymeacoffee.com/miladakarie" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>                  
</p> 


Below is a refined version of your documentation. Typos are fixed, structure is tightened, and clarity is improved—without changing the core concepts or behavior.

---

# Permit

A command-line tool for managing permissions in Flutter projects.
`permit` simplifies adding, removing, listing, and localizing permissions in `AndroidManifest.xml` and `Info.plist`.

---

## Installation

```bash
dart pub global activate permit
```

---

## Motivation & Features

* **CLI-first**: no Xcode or Android Studio opening, no manual file editing.
* **Reduces the risk of store rejections** by generating native permission code only for APIs your app actually uses.
* **No key memorization**: use keywords instead of platform-specific permission names.
* **Usage descriptions on the fly**: add iOS descriptions inline, or by follow-up prompts.
* **Zero missing config**: if runtime code exists, metadata exists in at least one platform config file.
* **Simple localization**: one command to generate and keep iOS permission strings in sync.
* **Platform-scoped permissions**: generate permissions and runtime code for Android or iOS independently.
* **Instant auditing**: list all added permissions and their runtime code status.
* **Zero external dependencies**: generates a local plugin you own and control—no third-party versioning issues.

---

## Usage

```bash
permit <command> [options]
```

---

## `add` Command

```bash
permit add <permission>
```

Adds permission metadata to the relevant platform files. Optionally, it can also generate runtime permission request code.

### Supported Inputs

* **Explicit platform keys**

    * `android.permission.CAMERA`
    * `NSCameraUsageDescription`
* **Searchable keywords**

    * `camera`, `location`, `microphone`, etc.

If a keyword matches multiple permissions, you will be prompted to choose.

### Examples

#### Add specific permission keys

```bash
permit add NSCameraUsageDescription
permit add android.permission.CAMERA
```

Platform detection is automatic; no flags are required.

#### Add permissions using keywords

```bash
permit add camera
```

If multiple matches are found:

```text
Select permissions to add ›
[ ] Android: android.permission.CAMERA
[ ] iOS: NSCameraUsageDescription
```

#### Limit search to a platform

* `[-a]`, `[--android]` → Android only
* `[-i]`, `[--ios]` → iOS only

```bash
permit add contacts -a
```

```text
Select permissions to add ›
[ ] Android: android.permission.READ_CONTACTS
[ ] Android: android.permission.WRITE_CONTACTS
[ ] Android: android.permission.GET_ACCOUNTS
```

#### Provide iOS usage descriptions inline

For iOS permissions, use `[-d]` / `[--desc]` to avoid interactive prompts:

```bash
permit add NSCameraUsageDescription -d "This app requires camera access to take photos."
```

#### Generate runtime permission code

By default, only metadata is added. To also generate runtime request code:

```bash
permit add camera -c
```

This will:

* Add permission metadata
* Generate runtime permission request code
* Create a minimal local plugin at `tools/permit_plugin`
* Automatically add the plugin to `pubspec.yaml`

**Important**

* Run `flutter pub get` after the plugin is added
* Hot-restart or rebuild after plugin updates

---

## `remove` Command

```bash
permit remove <permission>
```

Removes permission metadata and any generated runtime code.

### Supported Inputs

* Explicit permission keys
* Searchable keywords

### Examples

#### Remove specific permission keys

```bash
permit remove NSCameraUsageDescription
permit remove android.permission.CAMERA
```

Platform detection is automatic.

#### Remove using keywords

```bash
permit remove camera
```

If multiple matches are found:

```text
Select which permissions to remove ›
[ ] Android: android.permission.CAMERA
[ ] iOS: NSCameraUsageDescription
```

#### Remove interactively

If no argument is provided, all added permissions are listed:

```bash
permit remove
```

```text
Select which permissions to remove ›
[ ] Android: android.permission.CAMERA
[ ] Android: android.permission.RECORD_AUDIO
[ ] iOS: NSCameraUsageDescription
[ ] iOS: NSMicrophoneUsageDescription
```

---

## `list` Command

```bash
permit list
```

Lists all permissions currently added to the project.

### Example

```bash
permit list
```

```text
Android: Uses Permissions (2):
  - android.permission.CAMERA [CODE]
  - android.permission.RECORD_AUDIO

iOS: Usage Descriptions (2):
  - NSCameraUsageDescription: This is used to record videos
  - NSMicrophoneUsageDescription: We need mic access to record audio with the video
```

`[CODE]` indicates that runtime permission code has been generated.

### Platform filtering

* `[-a]`, `[--android]` → Android only
* `[-i]`, `[--ios]` → iOS only

```bash
permit list -a
```

---

## `localize` Command (iOS only)

```bash
permit localize [language_codes...]
```

Generates or updates `InfoPlist.xcstrings` with localized usage description keys.

### Behavior

* Adds missing keys only; never removes existing ones
* Respects:

    * Known region languages defined in the iOS project
    * Existing keys in `InfoPlist.xcstrings`
* Language codes are **not validated**—use valid Apple locale identifiers

Language codes must be space-separated:

```text
en ar_LY it fr
```

### Examples

#### Generate localization for specific languages

```bash
permit localize en ar_LY it
```

#### Update all supported languages

If no arguments are passed:

```bash
permit localize
```

This updates existing localization files with any new permission keys.

#### Add additional languages

```bash
permit localize fr de
```

Creates French and German localization files if they don’t already exist.

---

## `build` Command

```bash
permit build
```

Rebuilds runtime permission code based on the current platform permission metadata.

### When to use

* After manually modifying the generated plugin
* To regenerate code from existing permission entries

**NOTE:** it's automatically run after `add` with the `-c` flag or removing permissions

`permit` detects which permissions require runtime code using the annotation:

```xml
<!--@permit:code-->
```

### Examples

**AndroidManifest.xml**

```xml
<!--@permit:code-->
<uses-permission android:name="android.permission.CAMERA"/>
```

**Info.plist**

```xml
<!--@permit:code-->
<key>NSCameraUsageDescription</key>
<string>This app requires camera access to take photos.</string>
```

### Generated Code
The generated code is placed in `tools/permit_plugin/lib/permit.dart`.
E.g after adding camera permission with code generation:

```dart
import 'package:permit_plugin/permit.dart';    

// check permission status
final status = await Permit.camera.status;

switch(status){
    case PermissionStatus.denied:
    // Permission was denied or not yet requested.
    case PermissionStatus.granted:
    //  Permission was granted.
    case PermissionStatus.restricted:
    //  Permission is restricted (iOS only).
    case PermissionStatus.limited:
    //  Permission is limited (iOS only).
    case PermissionStatus.permanentlyDenied:
    //  Permission is permanently denied, user must enable it from settings.
    case PermissionStatus.provisional:
    // Permission is provisional (iOS only).
    case PermissionStatus.notApplicable:
    // Permission is not applicable for this platform, either not supported or not added in config files.
}

// request permission
final status = await Permit.camera.request();

// some permissions report service status
final serviceStatus = await Permit.location.serviceStatus;

// check if you should show rationale on Android
final shouldShowRationale = await Permit.microphone.shouldShowRequestRationale;

// open app settings
final wasOpened = await Permit.openSettings();
```

---

## Support Permit

If you find `permit` useful, consider supporting the project.
More details coming soon.

