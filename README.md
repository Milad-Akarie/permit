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


---

A command-line tool to manage permissions in Flutter projects.
It simplifies the process of adding, removing, and managing permissions in `AndroidManifest.xml` and `Info.plist`.

## Installation

```bash
dart pub global activate permit
```

or add it as a dev dependency:

```bash
dart pub add --dev permit
```

## Commands

### `add`
Adds a permission to your project. It automatically updates `AndroidManifest.xml` and `Info.plist`.

```bash
permit add <permission_name> [options]
```
**Options:**
- `-d`, `--desc`: Usage description for iOS `Info.plist`.
- `-c`, `--code`: Generate Dart code helper for checking/requesting permission.
- `-a`, `--android`: Add permission only for Android.
- `-i`, `--ios`: Add permission only for iOS.

**Example:**
```bash
permit add camera -d "We need camera access to scan QR codes" --code
```

### `remove`
Removes a permission from your project.

```bash
permit remove <permission_name> [options]
```
**Options:**
- `-a`, `--android`: Remove only from Android.
- `-i`, `--ios`: Remove only from iOS.

### `list`
Lists all permissions currently used in the project.

```bash
permit list [options]
```
**Options:**
- `-c`, `--code`: List only permissions that generate code.

### `localize` (iOS)
Generates `InfoPlist.xcstrings` for localizing iOS permission usage descriptions.

```bash
permit localize [language_codes...]
```
If no language codes are provided, it updates existing localizations.

**Example:**
```bash
permit localize en es fr
```

### `build`
Synchronizes permissions and regenerates any missing helper code.

```bash
permit build
```