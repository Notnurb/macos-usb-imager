# macOS USB Installer Prep (Windows PowerShell)
# by alexbrunton

Write-Host "🔍 Searching all drives for macOS installers..."

# Find all macOS installers (*.app folders)
$installers = Get-ChildItem -Path C:\,D:\,E:\ -Recurse -Directory -Filter "Install macOS *.app" -ErrorAction SilentlyContinue

if ($installers.Count -eq 0) {
    Write-Host "❌ No macOS installers found. Make sure you’ve copied them to this computer."
    exit
}

Write-Host "📦 Found the following macOS installers:"
for ($i = 0; $i -lt $installers.Count; $i++) {
    Write-Host "$($i+1): $($installers[$i].FullName)"
}

$installerIndex = Read-Host "➡️ Enter the number of the installer you want to use"
$installerPath = $installers[$installerIndex-1].FullName
Write-Host "✅ Selected: $installerPath"

# List removable USB drives
Write-Host "🔍 Scanning for USB drives..."
$usbDrives = Get-WmiObject Win32_Volume | Where-Object { $_.DriveType -eq 2 }

if ($usbDrives.Count -eq 0) {
    Write-Host "❌ No USB drives found."
    exit
}

Write-Host "💽 Found the following USB drives:"
for ($i = 0; $i -lt $usbDrives.Count; $i++) {
    Write-Host "$($i+1): $($usbDrives[$i].Name) - Label: $($usbDrives[$i].Label)"
}

$usbIndex = Read-Host "➡️ Enter the number of the USB drive to use"
$usbPath = $usbDrives[$usbIndex-1].Name
Write-Host "✅ Selected USB drive: $usbPath"

# Confirm format
$confirm = Read-Host "⚠️ WARNING: This will ERASE all data on $usbPath. Type YES to continue"
if ($confirm -ne "YES") {
    Write-Host "🚫 Cancelled."
    exit
}

# Format the USB drive to exFAT
Write-Host "💥 Formatting USB drive..."
Format-Volume -DriveLetter $usbPath[0] -FileSystem exFAT -Force -Confirm:$false

# Copy installer to USB
Write-Host "📂 Copying installer to USB..."
Copy-Item -Path "$installerPath\*" -Destination $usbPath -Recurse

Write-Host "✅ Installer copied to $usbPath"
Write-Host "📦 To make it bootable, run createinstallmedia on macOS later."
