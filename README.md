# Enhanced File Organizer - PowerShell Edition

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

> A powerful and safe PowerShell-based tool for organizing files by type, size, date, or extension, with intelligent duplicate detection, undo support, and a step-by-step interactive interface.

---

## 🎉 Features

* Organize files by:

  * 📝 **Type** (Documents, Images, Videos, etc.)
  * 🗓️ **Date** (Year/Month)
  * 📊 **Size** (Small, Medium, Large)
  * 🏷️ **Extension** (e.g., `.mp4`, `.docx`, etc.)
* 🔄 **Duplicate Handling**: Rename, Skip, Replace, or Merge
* ⚖️ **Dry Run** mode: See what will happen before applying changes
* ↩️ **Undo**: Revert the last organization session
* 🔍 **Show Supported File Types**
* 🧠 Smart detection of junk files (small sizes)
* 🌐 Multi-platform file format support: code, 3D models, archives, system, mobile apps
* ⚡ Multi-threaded and efficient with logs and error recovery

---

## 💡 Usage Instructions

### 1. Open PowerShell as Administrator (recommended)

### 2. Run via GitHub (raw hosted script)

> Raw script link (no token needed): [https://raw.githubusercontent.com/driyqnn/File-Organizer/main/organizer.ps1](https://raw.githubusercontent.com/driyqnn/File-Organizer/main/organizer.ps1)

#### Interactive Mode:

```powershell
irm "https://raw.githubusercontent.com/driyqnn/File-Organizer/main/organizer.ps1" | iex
```

#### Dry Run Mode (Preview only):

```powershell
irm "https://raw.githubusercontent.com/driyqnn/File-Organizer/main/organizer.ps1" | iex; organizer.ps1 -DryRun
```

#### Other Online Parameters:

```powershell
irm "https://raw.githubusercontent.com/driyqnn/File-Organizer/main/organizer.ps1" | iex; organizer.ps1 -Undo
irm "https://raw.githubusercontent.com/driyqnn/File-Organizer/main/organizer.ps1" | iex; organizer.ps1 -ShowTypes
irm "https://raw.githubusercontent.com/driyqnn/File-Organizer/main/organizer.ps1" | iex; organizer.ps1 -ShowDuplicates
irm "https://raw.githubusercontent.com/driyqnn/File-Organizer/main/organizer.ps1" | iex; organizer.ps1 -Help
```

> This executes the script directly from GitHub and makes all features available.

### 3. Or, If You Have the Script Locally

```powershell
# Example (rename organizer.txt to organizer.ps1 first)
.\organizer.ps1
```

### 4. Available Command-Line Parameters

```powershell
.\organizer.ps1             # Interactive mode
.\organizer.ps1 -DryRun     # Preview changes without moving files
.\organizer.ps1 -Undo       # Undo last organization
.\organizer.ps1 -ShowTypes  # Show all supported file types
.\organizer.ps1 -ShowDuplicates # Show duplicate analysis
.\organizer.ps1 -Help       # Show detailed help screen
```

---

## 📃 Supported Categories

* 📄 Documents (PDF, Word, Excel, etc.)
* 📷 Images (JPEG, PNG, RAW, etc.)
* 🎥 Videos (MP4, MKV, AVI, etc.)
* 🎵 Audio (MP3, WAV, FLAC, etc.)
* 📦 Archives (ZIP, RAR, ISO, etc.)
* 👨‍💻 Code (Python, JS, HTML, C++, etc.)
* 🌐 Web (HTML, CSS, JS)
* 🤝 3D/CAD (STL, OBJ, DWG, etc.)
* 📲 Mobile Apps (APK, IPA)
* 🌎 System Files, Fonts, Torrents, etc.

---

## ⚠️ Safety Features

* 🛡️ Protected folders: system folders (Windows, Program Files, etc.) are ignored
* ⏳ Atomic operations: rollback and undo support
* 🔍 Logging: every operation is logged (log file: `organizer_log.txt`)
* ❌ Undo file: stored in `undo.json`
* 🔎 Duplicate tracking: stored in `duplicates.json`

---

## 🤔 Examples

```powershell
.\organizer.ps1 -DryRun
```

Preview the results of organizing your files before anything is moved.

```powershell
.\organizer.ps1 -Undo
```

Undo your last organization session and restore all files.

```powershell
.\organizer.ps1 -ShowDuplicates
```

Display detailed duplicate file analysis using MD5 hashing.

---

## 📅 Requirements

* PowerShell 5.1+
* Windows OS (Admin access recommended for full functionality)

---

## 🌟 Disclaimer

This is a side project. While powerful, **use with caution**. Always:

* Backup critical files first
* Run `-DryRun` to preview results
* Read the log file if something went wrong

---

## 🔒 License

MIT License

```
MIT License

Copyright (c) 2025 Drae

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🚀 Contribute or Feedback

This project is not actively maintained but feel free to fork it or leave feedback.

**Made with passion by Drae, converted to PowerShell by Claude.**
