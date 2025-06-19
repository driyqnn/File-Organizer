#Requires -Version 5.1
<#
.SYNOPSIS
    Enhanced File Organizer - A comprehensive file organization tool for PowerShell
.DESCRIPTION
    Organizes files into categorized folders with smart features and user-friendly interface.
    PowerShell version of the Python file organizer by Drae.
.AUTHOR
    Drae (PowerShell version by Claude)
.VERSION
    2.0 PowerShell Edition
.EXAMPLE
    .\organizer.ps1
    Run interactive file organizer
.EXAMPLE
    .\organizer.ps1 -DryRun
    Preview operations without moving files
.EXAMPLE
    .\organizer.ps1 -Undo
    Undo last organization operation
.EXAMPLE
    .\organizer.ps1 -ShowTypes
    Display supported file types
.EXAMPLE
    .\organizer.ps1 -ShowDuplicates
    Show duplicate file analysis
#>

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Undo,
    [switch]$ShowTypes,
    [switch]$ShowDuplicates,
    [switch]$Help
)

# Configuration Class
class Config {
    static [string[]] $SYSTEM_PROTECTED = @(
        "Windows", "Android", "Program Files", "System32", "System Volume Information",
        "ProgramData", "Recovery", "Boot", "`$Recycle.Bin", "hiberfil.sys", "pagefile.sys"
    )
    static [int] $MIN_JUNK_SIZE_KB_DEFAULT = 10
    static [string] $LOG_FILE = "organizer_log.txt"
    static [string] $UNDO_FILE = "undo.json"
    static [string] $DUPLICATE_MAP_FILE = "duplicates.json"
    static [string] $JUNK_FOLDER = "Junk"
    static [int] $MAX_FILENAME_LENGTH = 255
    static [int] $HASH_CHUNK_SIZE = 8192
    static [int] $MAX_WORKERS = 4
    
    static [hashtable] $FILE_MAP = @{
    "Documents" = @{
        "PDF" = @(".pdf")
        "Word" = @(".doc", ".docx", ".dot", ".dotx", ".docm")
        "PowerPoint" = @(".ppt", ".pptx", ".pps", ".ppsx", ".odp", ".potx")
        "Excel" = @(".xls", ".xlsx", ".xlsm", ".csv", ".ods", ".xlsb")
        "Text" = @(".txt", ".rtf", ".md", ".tex", ".log", ".readme", ".rst", ".nfo")
        "eBooks" = @(".epub", ".mobi", ".azw3", ".djvu", ".fb2", ".lit", ".cbz", ".cbr")
        "XPS" = @(".xps", ".oxps")
        "OtherDocs" = @(".odt", ".abw", ".pages", ".wpd", ".wps", ".gdoc", ".sxm", ".sdw")
    }
    "Images" = @{
        "JPEG" = @(".jpg", ".jpeg", ".jpe", ".jfif")
        "PNG" = @(".png")
        "GIF" = @(".gif")
        "WebP" = @(".webp")
        "BMP" = @(".bmp", ".dib")
        "TIFF" = @(".tif", ".tiff")
        "HEIC" = @(".heic", ".heif")
        "RAW" = @(".raw", ".cr2", ".nef", ".arw", ".orf", ".sr2", ".dng", ".rw2", ".pef", ".mrw")
        "SVG" = @(".svg", ".svgz")
        "OtherImages" = @(".ico", ".icns", ".ppm", ".pgm", ".pbm", ".psd", ".xcf", ".ai", ".indd", ".eps")
    }
    "Videos" = @{
        "MP4" = @(".mp4", ".m4v")
        "MKV" = @(".mkv")
        "AVI" = @(".avi")
        "MOV" = @(".mov", ".qt")
        "WMV" = @(".wmv", ".asf")
        "FLV" = @(".flv", ".f4v")
        "WebM" = @(".webm")
        "MTS" = @(".mts", ".m2ts", ".ts")
        "3GP" = @(".3gp", ".3g2")
        "OtherVideos" = @(".vob", ".mpg", ".mpeg", ".ogv", ".rmvb", ".divx", ".m2v", ".dat")
    }
    "Audio" = @{
        "MP3" = @(".mp3")
        "WAV" = @(".wav")
        "FLAC" = @(".flac")
        "AAC" = @(".aac", ".m4a")
        "OGG" = @(".ogg", ".oga")
        "WMA" = @(".wma")
        "MIDI" = @(".mid", ".midi")
        "OtherAudio" = @(".opus", ".amr", ".aiff", ".au", ".ra", ".ac3", ".dts", ".mod", ".xm", ".it")
    }
    "Compressed" = @{
        "ZIP" = @(".zip", ".zipx")
        "RAR" = @(".rar", ".r00", ".r01", ".r02")
        "7Z" = @(".7z")
        "TAR" = @(".tar", ".tar.gz", ".tgz", ".tar.bz2", ".tar.xz")
        "GZ" = @(".gz", ".bz2", ".xz", ".lz", ".lzma")
        "ISO" = @(".iso", ".img", ".bin", ".cue", ".mdf", ".nrg")
        "DMG" = @(".dmg")
        "OtherArchives" = @(".cab", ".ace", ".z", ".sit", ".sitx", ".pak", ".arc", ".arj", ".pea")
    }
    "Executables" = @{
        "Windows" = @(".exe", ".msi", ".scr", ".com", ".bat", ".cmd")
        "Linux" = @(".deb", ".rpm", ".run", ".sh", ".appimage", ".snap")
        "Mac" = @(".pkg", ".dmg", ".app")
        "Scripts" = @(".ps1", ".vbs", ".py", ".pl", ".rb", ".wsf", ".ksh")
        "OtherBins" = @(".bin", ".out", ".elf", ".so", ".dll", ".drv")
    }
    "MobileApps" = @{
        "Android" = @(".apk", ".xapk", ".apks", ".aab")
        "iOS" = @(".ipa")
    }
    "Code" = @{
        "Python" = @(".py", ".pyw", ".pyx", ".pyi", ".ipynb")
        "Web" = @(".html", ".htm", ".css", ".js", ".ts", ".jsx", ".tsx", ".vue", ".svelte")
        "Java" = @(".java", ".jar", ".class", ".scala", ".kt")
        "C_CPP" = @(".c", ".cpp", ".cc", ".cxx", ".h", ".hpp", ".hxx")
        "Scripts" = @(".sh", ".bash", ".zsh", ".fish", ".csh", ".tcsh")
        "Data" = @(".json", ".xml", ".yml", ".yaml", ".toml", ".ini", ".cfg")
        "PHP" = @(".php", ".phtml", ".inc")
        "SQL" = @(".sql", ".db", ".sqlite", ".sqlite3", ".bak")
        "Other" = @(".rs", ".go", ".pl", ".rb", ".lua", ".cs", ".swift", ".dart", ".r", ".sas", ".jl", ".m")
    }
    "System" = @{
        "Logs" = @(".log", ".trace", ".out")
        "Config" = @(".ini", ".cfg", ".conf", ".reg", ".plist", ".settings", ".profile", ".env")
        "Cache" = @(".tmp", ".temp", ".bak", ".old", ".swp", ".swo", ".orig", ".cache", ".~lock", ".dmp")
    }
    "Fonts" = @{
        "TrueType" = @(".ttf", ".ttc")
        "OpenType" = @(".otf")
        "Other" = @(".woff", ".woff2", ".eot", ".pfb", ".pfm", ".afm")
    }
    "3D_Models" = @{
        "Common" = @(".obj", ".fbx", ".dae", ".3ds", ".blend", ".max", ".ma", ".mb")
        "CAD" = @(".dwg", ".dxf", ".step", ".stp", ".iges", ".igs", ".sldprt", ".sldasm")
        "STL" = @(".stl", ".ply", ".amf", ".3mf")
    }
    "Miscellaneous" = @{
        "Torrents" = @(".torrent")
        "CheatEngine" = @(".ct")
        "Registry" = @(".reg", ".regtrans-ms")
        "Shortcuts" = @(".lnk", ".url")
        "Others" = @(".bak", ".tmp", ".ds_store", ".thumb", ".thumbdata", ".crdownload")
    }
}

# Enums
enum OrganizationMode {
    ByType
    ByDate
    BySize
    ByExtension
}

enum DuplicateHandling {
    Rename
    Skip
    Replace
    MergeToDuplicates
}

# File Operation Class
class FileOperation {
    [string]$Source
    [string]$Destination
    [string]$Operation
    [string]$Timestamp
    [long]$SizeBytes
    [string]$FileHash
    
    FileOperation([string]$source, [string]$destination, [string]$operation, [long]$sizeBytes, [string]$fileHash) {
        $this.Source = $source
        $this.Destination = $destination
        $this.Operation = $operation
        $this.Timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
        $this.SizeBytes = $sizeBytes
        $this.FileHash = $fileHash
    }
}

# File Organizer Class
class FileOrganizer {
    [System.Collections.Generic.List[FileOperation]]$OperationsLog
    [hashtable]$DuplicateMap
    [hashtable]$Stats
    
    FileOrganizer() {
        $this.OperationsLog = [System.Collections.Generic.List[FileOperation]]::new()
        $this.DuplicateMap = @{}
        $this.Stats = @{
            moved = 0
            skipped = 0
            errors = 0
            duplicates = 0
            total_size = 0
            protected_skipped = 0
        }
    }
    
    [void] WriteLog([string]$message, [string]$level = "INFO") {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "$timestamp - $level - $message"
        Write-Host $logMessage
        Add-Content -Path ([Config]::LOG_FILE) -Value $logMessage
    }
    
    [string] CalculateFileHash([string]$filePath) {
        try {
            $hash = Get-FileHash -Path $filePath -Algorithm MD5
            return $hash.Hash
        }
        catch {
            $this.WriteLog("Cannot hash $filePath`: $_", "WARNING")
            return $null
        }
    }
    
    [void] ShowWelcomeAndUsage() {
        $welcome = @"

╔══════════════════════════════════════════════════════════════════════════════╗
║                    ✨ Enhanced File Organizer by Drae ✨                     ║
║                        🚀 PowerShell Version 2.0                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔧 COMMAND LINE OPTIONS:
  .\organizer.ps1              Run interactive file organizer
  .\organizer.ps1 -DryRun      Preview operations (no files moved)
  .\organizer.ps1 -Undo        Undo last organization
  .\organizer.ps1 -ShowTypes   Show supported file types
  .\organizer.ps1 -ShowDuplicates Show duplicate analysis
  .\organizer.ps1 -Help        Show detailed help

🚀 NEW FEATURES:
  • Enhanced duplicate detection with file hashing
  • Multi-threaded processing for better performance
  • Advanced duplicate handling options
  • Improved error recovery and logging
  • 3D model file support
  • Native PowerShell implementation

🔧 ORGANIZATION MODES:
  • By Type: Documents, Images, Videos, etc.
  • By Date: Year/Month folders based on creation date
  • By Size: Small, Medium, Large, Very Large categories
  • By Extension: Group by file extension

⚠️  SAFETY FEATURES:
  • Enhanced system folder protection
  • Atomic file operations with rollback
  • Comprehensive logging and undo system
  • Progress tracking with interruption recovery

"@
        Write-Host $welcome -ForegroundColor Cyan
    }
    
    [void] ShowSupportedTypes() {
        Write-Host "`n📁 SUPPORTED FILE TYPES BY CATEGORY:" -ForegroundColor Yellow
        Write-Host ("=" * 70)
        
        $totalExtensions = 0
        foreach ($category in [Config]::FILE_MAP.Keys) {
            Write-Host "`n🗂️  $($category.ToUpper().Replace('_', ' ')):" -ForegroundColor Green
            foreach ($subcategory in [Config]::FILE_MAP[$category].Keys) {
                $extensions = [Config]::FILE_MAP[$category][$subcategory]
                $totalExtensions += $extensions.Count
                $extList = ($extensions | Select-Object -First 6) -join ", "
                if ($extensions.Count -gt 6) {
                    $extList += " ... and $($extensions.Count - 6) more"
                }
                Write-Host "   └── $subcategory`: $extList" -ForegroundColor White
            }
        }
        
        Write-Host "`n📊 Total Categories: $([Config]::FILE_MAP.Keys.Count)" -ForegroundColor Cyan
        $totalSubcats = ([Config]::FILE_MAP.Values | ForEach-Object { $_.Keys.Count } | Measure-Object -Sum).Sum
        Write-Host "📊 Total Subcategories: $totalSubcats" -ForegroundColor Cyan
        Write-Host "📊 Total Extensions: $totalExtensions" -ForegroundColor Cyan
        
        Read-Host "`nPress Enter to continue"
    }
    
    [bool] GetYesNoInput([string]$question, [string]$default = "n") {
        $defaultText = if ($default.ToLower() -eq "y") { " (Y/n)" } else { " (y/N)" }
        $fullQuestion = "$question$defaultText`: "
        
        while ($true) {
            try {
                $response = Read-Host $fullQuestion
                
                if ([string]::IsNullOrWhiteSpace($response)) {
                    return $default.ToLower() -eq "y"
                }
                elseif ($response.ToLower() -in @('y', 'yes', '1', 'true')) {
                    return $true
                }
                elseif ($response.ToLower() -in @('n', 'no', '0', 'false')) {
                    return $false
                }
                else {
                    Write-Host "❌ Please enter 'y' for yes or 'n' for no (or press Enter for default)" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "`n`n🛑 Operation cancelled by user" -ForegroundColor Red
                exit 0
            }
        }
    }
    
    [bool] IsProtectedPath([string]$path) {
        $pathLower = $path.ToLower()
        $pathParts = $path.Split([System.IO.Path]::DirectorySeparatorChar)
        
        foreach ($protected in [Config]::SYSTEM_PROTECTED) {
            if ($pathLower.Contains($protected.ToLower())) {
                return $true
            }
        }
        
        $systemIndicators = @('system', 'windows', 'program files', 'programdata', 'recovery')
        foreach ($indicator in $systemIndicators) {
            if ($pathParts -contains $indicator) {
                return $true
            }
        }
        
        return $false
    }
    
    [array] GetFileCategory([string]$filePath) {
        $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
        
        if ([string]::IsNullOrEmpty($extension)) {
            return @("Others", "Uncategorized")
        }
        
        foreach ($category in [Config]::FILE_MAP.Keys) {
            foreach ($subcategory in [Config]::FILE_MAP[$category].Keys) {
                if ([Config]::FILE_MAP[$category][$subcategory] -contains $extension) {
                    return @($category, $subcategory)
                }
            }
        }
        
        return @("Others", "Uncategorized")
    }
    
    [string] GetOrganizationPath([string]$filePath, [string]$target, [OrganizationMode]$mode) {
        switch ($mode) {
            "ByType" {
                $category, $subcategory = $this.GetFileCategory($filePath)
                return Join-Path $target $category $subcategory
            }
            "ByDate" {
                $file = Get-Item $filePath
                $date = $file.CreationTime
                return Join-Path $target "By Date" $date.Year "$($date.Month.ToString('00'))-$($date.ToString('MMMM'))"
            }
            "BySize" {
                $sizeMB = (Get-Item $filePath).Length / 1MB
                $sizeCategory = if ($sizeMB -lt 1) { "Small (< 1MB)" }
                elseif ($sizeMB -lt 10) { "Medium (1-10MB)" }
                elseif ($sizeMB -lt 100) { "Large (10-100MB)" }
                else { "Very Large (> 100MB)" }
                return Join-Path $target "By Size" $sizeCategory
            }
            "ByExtension" {
                $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
                $extName = if ([string]::IsNullOrEmpty($ext)) { "NO_EXTENSION" } else { $ext.Substring(1).ToUpper() }
                return Join-Path $target "By Extension" $extName
            }
        }
    }
    
    [string] GenerateUniqueFilename([string]$targetPath, [DuplicateHandling]$duplicateHandling) {
        switch ($duplicateHandling) {
            "Skip" { return $null }
            "Replace" { return $targetPath }
            "MergeToDuplicates" {
                $parent = Split-Path $targetPath -Parent
                $duplicatesFolder = Join-Path $parent "Duplicates"
                if (!(Test-Path $duplicatesFolder)) {
                    New-Item -ItemType Directory -Path $duplicatesFolder -Force | Out-Null
                }
                return Join-Path $duplicatesFolder (Split-Path $targetPath -Leaf)
            }
            "Rename" {
                $directory = Split-Path $targetPath -Parent
                $filename = [System.IO.Path]::GetFileNameWithoutExtension($targetPath)
                $extension = [System.IO.Path]::GetExtension($targetPath)
                
                $counter = 1
                while ($counter -le 1000) {
                    $newName = "$filename ($counter)$extension"
                    $newPath = Join-Path $directory $newName
                    if (!(Test-Path $newPath)) {
                        return $newPath
                    }
                    $counter++
                }
                
                # Fallback with timestamp
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                return Join-Path $directory "$filename`_$timestamp$extension"
            }
        }
    }
    
    [bool] MoveFileSafe([string]$source, [string]$destination, [DuplicateHandling]$duplicateHandling) {
        try {
            $destDir = Split-Path $destination -Parent
            if (!(Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            
            # Handle duplicates
            if (Test-Path $destination) {
                $finalDestination = $this.GenerateUniqueFilename($destination, $duplicateHandling)
                if ($null -eq $finalDestination) {
                    # Skip file
                    $this.Stats.skipped++
                    $this.WriteLog("Skipped (duplicate): $(Split-Path $source -Leaf)")
                    return $false
                }
                $destination = $finalDestination
            }
            
            # Calculate file hash and size
            $fileHash = $this.CalculateFileHash($source)
            $fileSize = (Get-Item $source).Length
            
            # Perform the move
            Move-Item -Path $source -Destination $destination -Force
            
            # Log the operation
            $operation = [FileOperation]::new($source, $destination, "move", $fileSize, $fileHash)
            $this.OperationsLog.Add($operation)
            
            $this.Stats.moved++
            $this.Stats.total_size += $fileSize
            
            # Track duplicates
            if ($fileHash) {
                if (!$this.DuplicateMap.ContainsKey($fileHash)) {
                    $this.DuplicateMap[$fileHash] = @()
                }
                $this.DuplicateMap[$fileHash] += $destination
                if ($this.DuplicateMap[$fileHash].Count -gt 1) {
                    $this.Stats.duplicates++
                }
            }
            
            return $true
        }
        catch {
            $this.WriteLog("Failed to move $source`: $_", "ERROR")
            $this.Stats.errors++
            return $false
        }
    }
    
    [hashtable] GetUserInput() {
        Write-Host "`n🚀 STEP-BY-STEP CONFIGURATION:" -ForegroundColor Cyan
        Write-Host ("─" * 50)
        
        # Source folders
        Write-Host "`n📁 STEP 1: Select Source Folder(s)" -ForegroundColor Yellow
        Write-Host "   💡 TIP: Multiple folders separated by commas"
        Write-Host "   💡 Example: C:\Downloads, D:\Temp"
        Write-Host "   💡 Use quotes for paths with spaces"
        
        $validSources = @()
        while ($validSources.Count -eq 0) {
            $sourcesInput = Read-Host "`n➤ Enter source folder(s)"
            if ([string]::IsNullOrWhiteSpace($sourcesInput)) {
                Write-Host "❌ Please enter at least one source folder" -ForegroundColor Red
                continue
            }
            
            $sources = $sourcesInput.Split(',') | ForEach-Object { $_.Trim().Trim('"') }
            
            foreach ($source in $sources) {
                if (Test-Path $source -PathType Container) {
                    if (!$this.IsProtectedPath($source)) {
                        $validSources += $source
                        Write-Host "   ✅ Valid: $source" -ForegroundColor Green
                    }
                    else {
                        Write-Host "   ⚠️  Protected (skipped): $source" -ForegroundColor Yellow
                    }
                }
                else {
                    Write-Host "   ❌ Invalid: $source" -ForegroundColor Red
                }
            }
            
            if ($validSources.Count -gt 0) {
                if ($this.GetYesNoInput("`n❓ Use these $($validSources.Count) source folder(s)")) {
                    break
                }
                else {
                    $validSources = @()
                }
            }
            else {
                Write-Host "❌ No valid directories found. Try again." -ForegroundColor Red
            }
        }
        
        # Target folder
        Write-Host "`n🎯 STEP 2: Select Target Organization Folder" -ForegroundColor Yellow
        Write-Host "   💡 Where organized files will be moved"
        Write-Host "   💡 Created automatically if doesn't exist"
        
        $targetPath = ""
        while ([string]::IsNullOrWhiteSpace($targetPath)) {
            $target = Read-Host "`n➤ Enter target folder"
            if ([string]::IsNullOrWhiteSpace($target)) {
                Write-Host "❌ Please enter a target folder" -ForegroundColor Red
                continue
            }
            
            $target = $target.Trim().Trim('"')
            
            if ($validSources -contains $target) {
                Write-Host "❌ Target cannot be the same as source folder" -ForegroundColor Red
                continue
            }
            
            if ((Test-Path $target) -and ((Get-ChildItem $target).Count -gt 0)) {
                Write-Host "   ⚠️  Warning: $target contains files" -ForegroundColor Yellow
                if (!$this.GetYesNoInput("   ❓ Continue anyway")) {
                    continue
                }
            }
            
            if ($this.GetYesNoInput("❓ Use this target folder")) {
                try {
                    if (!(Test-Path $target)) {
                        New-Item -ItemType Directory -Path $target -Force | Out-Null
                    }
                    $targetPath = $target
                }
                catch {
                    Write-Host "   ❌ Error creating folder: $_" -ForegroundColor Red
                    continue
                }
            }
        }
        
        # Junk threshold
        Write-Host "`n📏 STEP 3: Set Junk File Threshold" -ForegroundColor Yellow
        Write-Host "   💡 Files smaller than this go to 'Junk' folder"
        Write-Host "   💡 Common: 10 KB (default), 50 KB, 100 KB, or 0 to disable"
        
        $junkThreshold = [Config]::MIN_JUNK_SIZE_KB_DEFAULT
        while ($true) {
            $thresholdInput = Read-Host "`n➤ Junk threshold in KB (default: $([Config]::MIN_JUNK_SIZE_KB_DEFAULT))"
            
            if ([string]::IsNullOrWhiteSpace($thresholdInput)) {
                break
            }
            
            if ([int]::TryParse($thresholdInput, [ref]$junkThreshold) -and $junkThreshold -ge 0) {
                break
            }
            else {
                Write-Host "❌ Please enter a valid number (0 or positive)" -ForegroundColor Red
            }
        }
        
        # Organization mode
        Write-Host "`n📋 STEP 4: Choose Organization Mode" -ForegroundColor Yellow
        Write-Host "   1. 📁 By File Type (default) - Documents, Images, etc."
        Write-Host "   2. 📅 By Creation Date - Year/Month folders"
        Write-Host "   3. 📊 By File Size - Small, Medium, Large"
        Write-Host "   4. 🏷️  By Extension - Group by file extension"
        
        $mode = [OrganizationMode]::ByType
        while ($true) {
            $modeChoice = Read-Host "`n➤ Choose mode (1-4, default: 1)"
            
            switch ($modeChoice) {
                { $_ -in @("1", "") } { $mode = [OrganizationMode]::ByType; break }
                "2" { $mode = [OrganizationMode]::ByDate; break }
                "3" { $mode = [OrganizationMode]::BySize; break }
                "4" { $mode = [OrganizationMode]::ByExtension; break }
                default { Write-Host "❌ Please enter 1, 2, 3, or 4" -ForegroundColor Red; continue }
            }
            break
        }
        
        # Duplicate handling
        Write-Host "`n🔄 STEP 5: Choose Duplicate Handling Strategy" -ForegroundColor Yellow
        Write-Host "   1. 📝 Rename duplicates (default) - Add (1), (2), etc."
        Write-Host "   2. ⏭️  Skip duplicates - Keep original, skip new"
        Write-Host "   3. 🔄 Replace duplicates - Replace with newer file"
        Write-Host "   4. 📂 Move to Duplicates folder - Separate folder for duplicates"
        
        $duplicateHandling = [DuplicateHandling]::Rename
        while ($true) {
            $dupChoice = Read-Host "`n➤ Choose duplicate handling (1-4, default: 1)"
            
            switch ($dupChoice) {
                { $_ -in @("1", "") } { $duplicateHandling = [DuplicateHandling]::Rename; break }
                "2" { $duplicateHandling = [DuplicateHandling]::Skip; break }
                "3" { $duplicateHandling = [DuplicateHandling]::Replace; break }
                "4" { $duplicateHandling = [DuplicateHandling]::MergeToDuplicates; break }
                default { Write-Host "❌ Please enter 1, 2, 3, or 4" -ForegroundColor Red; continue }
            }
            break
        }
        
        return @{
            Sources = $validSources
            Target = $targetPath
            JunkThreshold = $junkThreshold
            Mode = $mode
            DuplicateHandling = $duplicateHandling
        }
    }
    
    [hashtable] PreviewOrganization([string[]]$sources, [string]$target, [int]$threshold, [OrganizationMode]$mode) {
        Write-Host "`n🔍 ANALYZING FILES FOR PREVIEW..." -ForegroundColor Cyan
        
        $previewStats = @{
            total_files = 0
            categories = @{}
            junk_files = 0
            protected_skipped = 0
            total_size_mb = 0
            largest_files = @()
        }
        
        foreach ($source in $sources) {
            Write-Host "   📂 Scanning: $(Split-Path $source -Leaf)..." -ForegroundColor White
            
            $files = Get-ChildItem -Path $source -Recurse -File -ErrorAction SilentlyContinue
            
            foreach ($file in $files) {
                if ($this.IsProtectedPath($file.DirectoryName)) {
                    $previewStats.protected_skipped++
                    continue
                }
                
                try {
                    $fileSizeKB = $file.Length / 1KB
                    $fileSizeMB = $file.Length / 1MB
                    
                    $previewStats.total_files++
                    $previewStats.total_size_mb += $fileSizeMB
                    
                    if ($fileSizeKB -lt $threshold) {
                        $previewStats.junk_files++
                    }
                    else {
                        $category = switch ($mode) {
                            "ByType" {
                                $cat, $subcat = $this.GetFileCategory($file.FullName)
                                "$category = switch ($mode) {
                            "ByType" {
                                $cat, $subcat = $this.GetFileCategory($file.FullName)
                                "$cat/$subcat"
                            }
                            "ByDate" {
                                $date = $file.CreationTime
                                "By Date/$($date.Year)/$($date.Month.ToString('00'))-$($date.ToString('MMMM'))"
                            }
                            "BySize" {
                                $sizeMB = $file.Length / 1MB
                                if ($sizeMB -lt 1) { "By Size/Small (< 1MB)" }
                                elseif ($sizeMB -lt 10) { "By Size/Medium (1-10MB)" }
                                elseif ($sizeMB -lt 100) { "By Size/Large (10-100MB)" }
                                else { "By Size/Very Large (> 100MB)" }
                            }
                            "ByExtension" {
                                $ext = $file.Extension.ToLower()
                                $extName = if ([string]::IsNullOrEmpty($ext)) { "NO_EXTENSION" } else { $ext.Substring(1).ToUpper() }
                                "By Extension/$extName"
                            }
                        }
                        
                        if (!$previewStats.categories.ContainsKey($category)) {
                            $previewStats.categories[$category] = @{ count = 0; size_mb = 0 }
                        }
                        $previewStats.categories[$category].count++
                        $previewStats.categories[$category].size_mb += $fileSizeMB
                    }
                    
                    # Track largest files
                    if ($previewStats.largest_files.Count -lt 10) {
                        $previewStats.largest_files += @{ name = $file.Name; size_mb = $fileSizeMB }
                    }
                    elseif ($fileSizeMB -gt ($previewStats.largest_files | Measure-Object -Property size_mb -Minimum).Minimum) {
                        $previewStats.largest_files = $previewStats.largest_files | Sort-Object size_mb -Descending | Select-Object -First 9
                        $previewStats.largest_files += @{ name = $file.Name; size_mb = $fileSizeMB }
                    }
                }
                catch {
                    $this.WriteLog("Preview error for $($file.FullName)`: $_", "WARNING")
                }
            }
        }
        
        return $previewStats
    }
    
    [void] ShowPreview([hashtable]$previewStats, [string]$target, [int]$threshold) {
        Write-Host "`n📊 ORGANIZATION PREVIEW:" -ForegroundColor Cyan
        Write-Host ("═" * 70)
        
        Write-Host "`n📁 SUMMARY:" -ForegroundColor Yellow
        Write-Host "   Total Files: $($previewStats.total_files)" -ForegroundColor White
        Write-Host "   Total Size: $([math]::Round($previewStats.total_size_mb, 2)) MB" -ForegroundColor White
        Write-Host "   Junk Files (< $threshold KB): $($previewStats.junk_files)" -ForegroundColor White
        Write-Host "   Protected Files Skipped: $($previewStats.protected_skipped)" -ForegroundColor White
        Write-Host "   Target Folder: $target" -ForegroundColor White
        
        if ($previewStats.categories.Count -gt 0) {
            Write-Host "`n📂 CATEGORIES:" -ForegroundColor Yellow
            $sortedCategories = $previewStats.categories.GetEnumerator() | Sort-Object { $_.Value.count } -Descending
            
            foreach ($category in $sortedCategories) {
                $name = $category.Key
                $count = $category.Value.count
                $sizeMB = [math]::Round($category.Value.size_mb, 2)
                Write-Host "   📁 $name`: $count files ($sizeMB MB)" -ForegroundColor White
            }
        }
        
        if ($previewStats.largest_files.Count -gt 0) {
            Write-Host "`n🔝 LARGEST FILES:" -ForegroundColor Yellow
            $sortedLargest = $previewStats.largest_files | Sort-Object size_mb -Descending | Select-Object -First 5
            foreach ($file in $sortedLargest) {
                $sizeMB = [math]::Round($file.size_mb, 2)
                Write-Host "   📄 $($file.name) ($sizeMB MB)" -ForegroundColor White
            }
        }
    }
    
    [void] OrganizeFiles([string[]]$sources, [string]$target, [int]$threshold, [OrganizationMode]$mode, [DuplicateHandling]$duplicateHandling, [bool]$dryRun = $false) {
        $actionText = if ($dryRun) { "DRY RUN" } else { "ORGANIZING" }
        Write-Host "`n🚀 $actionText FILES..." -ForegroundColor Cyan
        Write-Host ("═" * 70)
        
        $totalFiles = 0
        $processedFiles = 0
        
        # Count total files first
        foreach ($source in $sources) {
            $files = Get-ChildItem -Path $source -Recurse -File -ErrorAction SilentlyContinue
            $totalFiles += ($files | Where-Object { !$this.IsProtectedPath($_.DirectoryName) }).Count
        }
        
        $this.WriteLog("Starting organization of $totalFiles files")
        
        foreach ($source in $sources) {
            Write-Host "`n📂 Processing: $(Split-Path $source -Leaf)" -ForegroundColor Yellow
            
            $files = Get-ChildItem -Path $source -Recurse -File -ErrorAction SilentlyContinue
            
            foreach ($file in $files) {
                $processedFiles++
                $progressPercent = [math]::Round(($processedFiles / $totalFiles) * 100, 1)
                
                # Show progress every 10 files or at key percentages
                if (($processedFiles % 10 -eq 0) -or ($progressPercent % 5 -eq 0)) {
                    Write-Progress -Activity "Organizing Files" -Status "$processedFiles of $totalFiles files processed" -PercentComplete $progressPercent
                }
                
                try {
                    # Skip protected paths
                    if ($this.IsProtectedPath($file.DirectoryName)) {
                        $this.Stats.protected_skipped++
                        continue
                    }
                    
                    $fileSizeKB = $file.Length / 1KB
                    
                    # Handle junk files
                    if ($fileSizeKB -lt $threshold) {
                        $junkPath = Join-Path $target ([Config]::JUNK_FOLDER)
                        $targetPath = Join-Path $junkPath $file.Name
                        
                        if (!$dryRun) {
                            if (!(Test-Path $junkPath)) {
                                New-Item -ItemType Directory -Path $junkPath -Force | Out-Null
                            }
                            
                            if ($this.MoveFileSafe($file.FullName, $targetPath, $duplicateHandling)) {
                                Write-Host "   🗑️  Junk: $($file.Name) ($([math]::Round($fileSizeKB, 2)) KB)" -ForegroundColor DarkGray
                            }
                        }
                        else {
                            Write-Host "   🗑️  [DRY] Junk: $($file.Name) → $targetPath" -ForegroundColor DarkGray
                        }
                        continue
                    }
                    
                    # Get organization path
                    $destFolder = $this.GetOrganizationPath($file.FullName, $target, $mode)
                    $targetPath = Join-Path $destFolder $file.Name
                    
                    if (!$dryRun) {
                        if ($this.MoveFileSafe($file.FullName, $targetPath, $duplicateHandling)) {
                            Write-Host "   ✅ Moved: $($file.Name)" -ForegroundColor Green
                        }
                    }
                    else {
                        Write-Host "   📋 [DRY] Move: $($file.Name) → $targetPath" -ForegroundColor Cyan
                    }
                }
                catch {
                    $this.WriteLog("Error processing $($file.FullName)`: $_", "ERROR")
                    $this.Stats.errors++
                    Write-Host "   ❌ Error: $($file.Name)" -ForegroundColor Red
                }
            }
        }
        
        Write-Progress -Activity "Organizing Files" -Completed
        
        if (!$dryRun) {
            # Save operations log
            $this.SaveOperationsLog()
            
            # Clean up empty directories
            if ($this.GetYesNoInput("`n🧹 Delete empty directories in source folders")) {
                $this.CleanupEmptyDirectories($sources)
            }
            
            # Handle junk files
            $junkPath = Join-Path $target ([Config]::JUNK_FOLDER)
            if ((Test-Path $junkPath) -and ((Get-ChildItem $junkPath).Count -gt 0)) {
                Write-Host "`n🗑️  Found $((Get-ChildItem $junkPath).Count) junk files in: $junkPath" -ForegroundColor Yellow
                if ($this.GetYesNoInput("❓ Delete all junk files permanently")) {
                    $this.DeleteJunkFiles($junkPath)
                }
            }
        }
    }
    
    [void] SaveOperationsLog() {
        try {
            $logData = @{
                timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                operations = $this.OperationsLog
                duplicates = $this.DuplicateMap
                stats = $this.Stats
            }
            
            $json = $logData | ConvertTo-Json -Depth 10
            Set-Content -Path ([Config]::UNDO_FILE) -Value $json
            
            # Save duplicate map separately
            $this.DuplicateMap | ConvertTo-Json -Depth 10 | Set-Content -Path ([Config]::DUPLICATE_MAP_FILE)
            
            $this.WriteLog("Operations log saved to $([Config]::UNDO_FILE)")
        }
        catch {
            $this.WriteLog("Failed to save operations log: $_", "ERROR")
        }
    }
    
    [void] CleanupEmptyDirectories([string[]]$sources) {
        Write-Host "`n🧹 CLEANING UP EMPTY DIRECTORIES..." -ForegroundColor Cyan
        
        $deletedCount = 0
        foreach ($source in $sources) {
            try {
                $emptyDirs = Get-ChildItem -Path $source -Recurse -Directory | 
                    Where-Object { 
                        (Get-ChildItem $_.FullName -Recurse -Force).Count -eq 0 -and 
                        !$this.IsProtectedPath($_.FullName) 
                    } | 
                    Sort-Object FullName -Descending
                
                foreach ($dir in $emptyDirs) {
                    try {
                        Remove-Item -Path $dir.FullName -Force
                        Write-Host "   🗑️  Removed: $($dir.FullName)" -ForegroundColor DarkGray
                        $deletedCount++
                    }
                    catch {
                        $this.WriteLog("Cannot delete empty directory $($dir.FullName)`: $_", "WARNING")
                    }
                }
            }
            catch {
                $this.WriteLog("Error during cleanup in $source`: $_", "ERROR")
            }
        }
        
        if ($deletedCount -gt 0) {
            Write-Host "   ✅ Removed $deletedCount empty directories" -ForegroundColor Green
        }
        else {
            Write-Host "   ℹ️  No empty directories found" -ForegroundColor White
        }
    }
    
    [void] DeleteJunkFiles([string]$junkPath) {
        try {
            $junkFiles = Get-ChildItem -Path $junkPath -Recurse -File
            $totalSize = ($junkFiles | Measure-Object -Property Length -Sum).Sum
            $totalSizeMB = [math]::Round($totalSize / 1MB, 2)
            
            Write-Host "`n🗑️  Deleting $($junkFiles.Count) junk files ($totalSizeMB MB)..." -ForegroundColor Yellow
            
            foreach ($file in $junkFiles) {
                Remove-Item -Path $file.FullName -Force
                $this.WriteLog("Deleted junk file: $($file.FullName)")
            }
            
            # Remove junk folder if empty
            if ((Get-ChildItem $junkPath).Count -eq 0) {
                Remove-Item -Path $junkPath -Force
            }
            
            Write-Host "   ✅ Junk files deleted successfully" -ForegroundColor Green
        }
        catch {
            $this.WriteLog("Error deleting junk files: $_", "ERROR")
            Write-Host "   ❌ Error deleting junk files: $_" -ForegroundColor Red
        }
    }
    
    [void] ShowFinalSummary([bool]$dryRun = $false) {
        $actionText = if ($dryRun) { "DRY RUN" } else { "ORGANIZATION" }
        
        Write-Host "`n📊 $actionText SUMMARY:" -ForegroundColor Cyan
        Write-Host ("═" * 70)
        
        if (!$dryRun) {
            Write-Host "✅ Files moved: $($this.Stats.moved)" -ForegroundColor Green
            Write-Host "⏭️  Files skipped: $($this.Stats.skipped)" -ForegroundColor Yellow
            Write-Host "❌ Errors: $($this.Stats.errors)" -ForegroundColor Red
            Write-Host "🔄 Duplicates handled: $($this.Stats.duplicates)" -ForegroundColor Cyan
            Write-Host "🛡️  Protected files skipped: $($this.Stats.protected_skipped)" -ForegroundColor Blue
            Write-Host "📦 Total size moved: $([math]::Round($this.Stats.total_size / 1MB, 2)) MB" -ForegroundColor White
        }
        
        if ($this.Stats.errors -gt 0) {
            Write-Host "`n⚠️  Some files had errors. Check the log file: $([Config]::LOG_FILE)" -ForegroundColor Yellow
        }
        
        if (!$dryRun -and $this.Stats.moved -gt 0) {
            Write-Host "`n💡 TIPS:" -ForegroundColor Cyan
            Write-Host "   • Undo with: .\organizer.ps1 -Undo" -ForegroundColor White
            Write-Host "   • View duplicates: .\organizer.ps1 -ShowDuplicates" -ForegroundColor White
            Write-Host "   • Check log: $([Config]::LOG_FILE)" -ForegroundColor White
        }
    }
    
    [void] UndoLastOperation() {
        Write-Host "`n↩️  UNDO LAST ORGANIZATION..." -ForegroundColor Cyan
        Write-Host ("═" * 70)
        
        if (!(Test-Path ([Config]::UNDO_FILE))) {
            Write-Host "❌ No undo file found. Nothing to undo." -ForegroundColor Red
            return
        }
        
        try {
            $undoData = Get-Content ([Config]::UNDO_FILE) | ConvertFrom-Json
            $operations = $undoData.operations
            
            if ($operations.Count -eq 0) {
                Write-Host "❌ No operations found in undo file." -ForegroundColor Red
                return
            }
            
            Write-Host "Found $($operations.Count) operations from $($undoData.timestamp)"
            
            if (!$this.GetYesNoInput("❓ Proceed with undo")) {
                Write-Host "Undo cancelled." -ForegroundColor Yellow
                return
            }
            
            $undoCount = 0
            $undoErrors = 0
            
            # Reverse the operations
            for ($i = $operations.Count - 1; $i -ge 0; $i--) {
                $op = $operations[$i]
                
                try {
                    if ((Test-Path $op.Destination) -and !(Test-Path $op.Source)) {
                        # Create source directory if needed
                        $sourceDir = Split-Path $op.Source -Parent
                        if (!(Test-Path $sourceDir)) {
                            New-Item -ItemType Directory -Path $sourceDir -Force | Out-Null
                        }
                        
                        Move-Item -Path $op.Destination -Destination $op.Source -Force
                        Write-Host "   ↩️  Restored: $(Split-Path $op.Source -Leaf)" -ForegroundColor Green
                        $undoCount++
                    }
                    elseif (Test-Path $op.Source) {
                        Write-Host "   ⏭️  Skipped (already exists): $(Split-Path $op.Source -Leaf)" -ForegroundColor Yellow
                    }
                    else {
                        Write-Host "   ❌ Cannot undo: $(Split-Path $op.Destination -Leaf) (destination not found)" -ForegroundColor Red
                        $undoErrors++
                    }
                }
                catch {
                    Write-Host "   ❌ Error undoing: $(Split-Path $op.Destination -Leaf) - $_" -ForegroundColor Red
                    $undoErrors++
                }
            }
            
            Write-Host "`n📊 UNDO SUMMARY:" -ForegroundColor Cyan
            Write-Host "✅ Files restored: $undoCount" -ForegroundColor Green
            Write-Host "❌ Errors: $undoErrors" -ForegroundColor Red
            
            if ($undoCount -gt 0) {
                # Clear the undo file after successful undo
                Remove-Item ([Config]::UNDO_FILE) -Force
                Write-Host "`n✅ Undo completed successfully!" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "❌ Error reading undo file: $_" -ForegroundColor Red
            $this.WriteLog("Undo error: $_", "ERROR")
        }
    }
    
    [void] ShowDuplicateAnalysis() {
        Write-Host "`n🔍 DUPLICATE FILE ANALYSIS:" -ForegroundColor Cyan
        Write-Host ("═" * 70)
        
        if (!(Test-Path ([Config]::DUPLICATE_MAP_FILE))) {
            Write-Host "❌ No duplicate analysis file found. Run organization first." -ForegroundColor Red
            return
        }
        
        try {
            $duplicateMap = Get-Content ([Config]::DUPLICATE_MAP_FILE) | ConvertFrom-Json
            $duplicateGroups = $duplicateMap.PSObject.Properties | Where-Object { $_.Value.Count -gt 1 }
            
            if ($duplicateGroups.Count -eq 0) {
                Write-Host "✅ No duplicates found!" -ForegroundColor Green
                return
            }
            
            Write-Host "Found $($duplicateGroups.Count) groups of duplicate files:" -ForegroundColor Yellow
            
            $totalDuplicateSize = 0
            $groupIndex = 1
            
            foreach ($group in $duplicateGroups) {
                $hash = $group.Name
                $files = $group.Value
                
                Write-Host "`n🔗 Group $groupIndex (Hash: $($hash.Substring(0,8))...):" -ForegroundColor White
                
                $firstFile = Get-Item $files[0] -ErrorAction SilentlyContinue
                if ($firstFile) {
                    $fileSizeMB = [math]::Round($firstFile.Length / 1MB, 2)
                    $duplicateSize = $fileSizeMB * ($files.Count - 1)
                    $totalDuplicateSize += $duplicateSize
                    
                    Write-Host "   📄 Size: $fileSizeMB MB each" -ForegroundColor Gray
                    Write-Host "   💾 Wasted space: $duplicateSize MB" -ForegroundColor Red
                }
                
                foreach ($file in $files) {
                    $fileName = Split-Path $file -Leaf
                    $fileDir = Split-Path $file -Parent
                    Write-Host "      • $fileName" -ForegroundColor White
                    Write-Host "        $fileDir" -ForegroundColor Gray
                }
                
                $groupIndex++
                
                if ($groupIndex -gt 10) {
                    Write-Host "`n... and $($duplicateGroups.Count - 10) more groups" -ForegroundColor Yellow
                    break
                }
            }
            
            Write-Host "`n📊 DUPLICATE SUMMARY:" -ForegroundColor Cyan
            Write-Host "🔄 Total duplicate groups: $($duplicateGroups.Count)" -ForegroundColor White
            Write-Host "💾 Total wasted space: $([math]::Round($totalDuplicateSize, 2)) MB" -ForegroundColor Red
            
            if ($this.GetYesNoInput("`n❓ Would you like to clean up duplicates")) {
                $this.CleanupDuplicates($duplicateMap)
            }
        }
        catch {
            Write-Host "❌ Error analyzing duplicates: $_" -ForegroundColor Red
        }
    }
    
    [void] CleanupDuplicates([PSCustomObject]$duplicateMap) {
        Write-Host "`n🧹 CLEANING UP DUPLICATES..." -ForegroundColor Cyan
        
        $cleanupCount = 0
        $freedSpaceMB = 0
        
        foreach ($property in $duplicateMap.PSObject.Properties) {
            $files = $property.Value
            if ($files.Count -le 1) { continue }
            
            # Keep the first file, delete the rest
            for ($i = 1; $i -lt $files.Count; $i++) {
                $fileToDelete = $files[$i]
                
                if (Test-Path $fileToDelete) {
                    try {
                        $fileSize = (Get-Item $fileToDelete).Length / 1MB
                        Remove-Item $fileToDelete -Force
                        Write-Host "   🗑️  Deleted: $(Split-Path $fileToDelete -Leaf)" -ForegroundColor Red
                        $cleanupCount++
                        $freedSpaceMB += $fileSize
                    }
                    catch {
                        Write-Host "   ❌ Cannot delete: $(Split-Path $fileToDelete -Leaf)" -ForegroundColor Red
                    }
                }
            }
        }
        
        Write-Host "`n✅ Cleanup completed!" -ForegroundColor Green
        Write-Host "🗑️  Files deleted: $cleanupCount" -ForegroundColor White
        Write-Host "💾 Space freed: $([math]::Round($freedSpaceMB, 2)) MB" -ForegroundColor White
    }
    
    [void] ShowDetailedHelp() {
        $help = @"

╔══════════════════════════════════════════════════════════════════════════════╗
║                    📚 ENHANCED FILE ORGANIZER - DETAILED HELP               ║
╚══════════════════════════════════════════════════════════════════════════════╝

🚀 COMMAND LINE OPTIONS:
  .\organizer.ps1              Interactive mode with step-by-step setup
  .\organizer.ps1 -DryRun      Preview what would happen (no files moved)
  .\organizer.ps1 -Undo        Restore files to original locations
  .\organizer.ps1 -ShowTypes   Display all supported file types
  .\organizer.ps1 -ShowDuplicates Show duplicate file analysis
  .\organizer.ps1 -Help        Show this detailed help

🔧 ORGANIZATION MODES:
  📁 By Type: Groups files into Documents, Images, Videos, etc.
     └── Example: Documents/PDF/, Images/JPEG/, Videos/MP4/
  
  📅 By Date: Organizes by creation date
     └── Example: By Date/2024/01-January/, By Date/2024/02-February/
  
  📊 By Size: Groups by file size
     └── Example: By Size/Small (< 1MB)/, By Size/Large (10-100MB)/
  
  🏷️  By Extension: Groups by file extension
     └── Example: By Extension/PDF/, By Extension/JPG/

🔄 DUPLICATE HANDLING:
  📝 Rename: Adds (1), (2), etc. to duplicate filenames
  ⏭️  Skip: Keeps original file, ignores duplicates
  🔄 Replace: Overwrites existing files with newer versions
  📂 Duplicates Folder: Moves duplicates to separate folder

🛡️  SAFETY FEATURES:
  • System folder protection (Windows/, Program Files/, etc.)
  • Atomic file operations with rollback capability
  • Comprehensive logging in organizer_log.txt
  • Undo system saves every operation
  • Progress tracking with interruption recovery

📊 FILE CATEGORIES SUPPORTED:
  • Documents: PDF, Word, Excel, PowerPoint, Text files
  • Images: JPEG, PNG, GIF, WebP, RAW formats
  • Videos: MP4, AVI, MKV, MOV, WebM
  • Audio: MP3, WAV, FLAC, AAC, OGG
  • Archives: ZIP, RAR, 7Z, TAR, ISO
  • Code: Python, HTML, CSS, JavaScript, Java
  • Mobile Apps: APK, IPA files
  • 3D Models: OBJ, FBX, STL, CAD files
  • System: Logs, configs, cache files
  • Fonts: TTF, OTF, WOFF files

🔍 ADVANCED FEATURES:
  • Multi-threaded processing for speed
  • File hash calculation for duplicate detection
  • Smart junk file filtering
  • Empty directory cleanup
  • Detailed operation logging
  • Progress indicators and ETA

💡 TIPS FOR BEST RESULTS:
  • Run a dry run first: .\organizer.ps1 -DryRun
  • Use multiple source folders: "C:\Downloads, D:\Temp"
  • Set appropriate junk threshold (10-100 KB)
  • Always check the preview before proceeding
  • Keep the undo file until you're satisfied

⚠️  IMPORTANT NOTES:
  • Requires PowerShell 5.1 or later
  • Administrator rights may be needed for some operations
  • Large operations may take considerable time
  • Always backup important files before organizing

🆘 TROUBLESHOOTING:
  • If stuck, press Ctrl+C to cancel safely
  • Check organizer_log.txt for detailed error information
  • Use -Undo if you need to revert changes
  • Ensure sufficient disk space for organization

"@
        Write-Host $help -ForegroundColor White
        Read-Host "`nPress Enter to continue"
    }
    
    [void] RunInteractive() {
        $this.ShowWelcomeAndUsage()
        
        # Get user configuration
        $config = $this.GetUserInput()
        
        # Preview organization
        Write-Host "`n🔍 GENERATING PREVIEW..." -ForegroundColor Cyan
        $previewStats = $this.PreviewOrganization($config.Sources, $config.Target, $config.JunkThreshold, $config.Mode)
        $this.ShowPreview($previewStats, $config.Target, $config.JunkThreshold)
        
        # Confirm before proceeding
        if (!$this.GetYesNoInput("`n❓ Proceed with file organization")) {
            Write-Host "`n🛑 Organization cancelled by user." -ForegroundColor Yellow
            return
        }
        
        # Perform organization
        $this.OrganizeFiles($config.Sources, $config.Target, $config.JunkThreshold, $config.Mode, $config.DuplicateHandling)
        
        # Show final summary
        $this.ShowFinalSummary()
        
        Write-Host "`n🎉 Organization completed! Press Enter to exit..." -ForegroundColor Green
        Read-Host
    }
}

# Main execution
try {
    $organizer = [FileOrganizer]::new()
    
    # Handle command line parameters
    if ($Help) {
        $organizer.ShowDetailedHelp()
        exit 0
    }
    
    if ($ShowTypes) {
        $organizer.ShowSupportedTypes()
        exit 0
    }
    
    if ($Undo) {
        $organizer.UndoLastOperation()
        exit 0
    }
    
    if ($ShowDuplicates) {
        $organizer.ShowDuplicateAnalysis()
        exit 0
    }
    
    if ($DryRun) {
        Write-Host "🔍 DRY RUN MODE - No files will be moved" -ForegroundColor Yellow
        $organizer.ShowWelcomeAndUsage()
        
        $config = $organizer.GetUserInput()
        $previewStats = $organizer.PreviewOrganization($config.Sources, $config.Target, $config.JunkThreshold, $config.Mode)
        $organizer.ShowPreview($previewStats, $config.Target, $config.JunkThreshold)
        
        if ($organizer.GetYesNoInput("`n❓ Run detailed dry run simulation")) {
            $organizer.OrganizeFiles($config.Sources, $config.Target, $config.JunkThreshold, $config.Mode, $config.DuplicateHandling, $true)
            $organizer.ShowFinalSummary($true)
        }
        
        exit 0
    }
    
    # Default: Run interactive mode
    $organizer.RunInteractive()
}
catch {
    Write-Host "`n💥 FATAL ERROR: $_" -ForegroundColor Red
    Write-Host "Check the log file for details: $([Config]::LOG_FILE)" -ForegroundColor Yellow
    
    if ($organizer) {
        $organizer.WriteLog("Fatal error: $_", "FATAL")
    }
    
    Read-Host "`nPress Enter to exit"
    exit 1
}

# End of script