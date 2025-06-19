# Enhanced File Organizer – PowerShell Edition

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

> A powerful PowerShell tool to organize your files by type, date, size, or extension — with smart duplicate detection, undo support, and interactive CLI.

---

## 🎉 Features

- Organize files by:
  - 📝 **Type** (Documents, Images, Videos, etc.)
  - 🗓️ **Date** (Year/Month)
  - 📊 **Size** (Small, Medium, Large)
  - 🏷️ **Extension** (e.g., `.mp4`, `.docx`, etc.)
- 🔄 **Duplicate Handling**: Rename, Skip, Replace, or Merge
- ⚖️ **Dry Run** mode: Preview changes without touching your files
- ↩️ **Undo** support
- 🔍 **Supported File Types Viewer**
- 🧠 Smart junk file detection (tiny size threshold)
- 🌐 Multi-platform file formats: code, 3D, archives, mobile apps, system files
- ⚡ Multi-threaded execution with logs and fail-safe recovery

---

## 💡 Quick Start (One-Liner)

### 🔹 PowerShell (Run as Administrator recommended):

```powershell
iwr -Uri "https://raw.githubusercontent.com/driyqnn/File-Organizer/main/organizer.ps1" -OutFile "organizer.ps1"; .\organizer.ps1
```

---

## 💻 Other Usage Options

### 🧪 Dry Run (Preview Mode)
```powershell
.\organizer.ps1 -DryRun
```

### ↩️ Undo Last Session
```powershell
.\organizer.ps1 -Undo
```

### 📋 Show Supported File Types
```powershell
.\organizer.ps1 -ShowTypes
```

### 🧬 Duplicate File Analysis
```powershell
.\organizer.ps1 -ShowDuplicates
```

### ❓ Help
```powershell
.\organizer.ps1 -Help
```

---

## 📂 Supported Categories

- 📄 Documents (PDF, Word, Excel, etc.)
- 📷 Images (JPEG, PNG, RAW, etc.)
- 🎥 Videos (MP4, MKV, AVI, etc.)
- 🎵 Audio (MP3, WAV, FLAC, etc.)
- 📦 Archives (ZIP, RAR, ISO, etc.)
- 👨‍💻 Code (Python, JS, HTML, C++, etc.)
- 🌐 Web (HTML, CSS, JS)
- 🧱 3D/CAD (STL, OBJ, DWG, etc.)
- 📲 Mobile Apps (APK, IPA)
- ⚙️ System Files, Fonts, Torrents, etc.

---

## ⚠️ Safety Features

- 🚫 Ignores critical system folders (e.g., Windows, Program Files)
- ⏪ Rollback support with `undo.json`
- 📜 All operations logged in `organizer_log.txt`
- 🔍 Duplicate data stored in `duplicates.json`

---

## 📅 Requirements

- Windows with PowerShell 5.1+
- Admin privileges (recommended for full functionality)

---

## 🛡️ Disclaimer

This script is powerful — use responsibly:

- Back up important files before running
- Always run `-DryRun` first
- Check the `organizer_log.txt` if something seems off

---

## 🔒 License

MIT License

```
MIT License

Copyright (c) 2025 Drae

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction...
```

---

## 🚀 Contribute or Feedback

This isn’t actively maintained, but forks are welcome. Feedback or PRs? Fire away.

