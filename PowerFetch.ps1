$This_Device = "$(hostname)@$([Environment]::UserName)"

# A fancy line to put under $This_Device
[System.Collections.ArrayList][String[]]$FancyLine = @()
for ($i = 0; $i -lt $This_Device.Length; $i++) {
    [void]$FancyLine.Add("~")
}

# Device model
[Object]$Device = (Get-WmiObject Win32_ComputerSystem | Select-Object ("Model", "Manufacturer") | ForEach-Object {$_})

# Screen resolution
$ScreenRes = ((Get-WmiObject Win32_VideoController).VideoModeDescription).Substring(0, 11)

# OS
$OS = (Get-WmiObject Win32_OperatingSystem | Select-Object ("Caption", "OSArchitecture")) | ForEach-Object {$_}

# CPU
[Object]$CPU = (Get-WmiObject Win32_Processor | Select-Object ("Name", "NumberOfCores") | ForEach-Object {$_})

# GPU
$GPU = (Get-WmiObject Win32_VideoController).Name

# Memory
$Memory = (
    (Get-WmiObject Win32_PhysicalMemory | Select-Object Capacity | ForEach-Object {$_.Capacity /1GB} | Measure-Object -Sum).Sum
)

# Disk space
[Object]$Disk = (Get-Volume C | Select-Object ("SizeRemaining", "Size") | ForEach-Object {$_})
$DiskUsed = [math]::Round(($Disk.Size - $Disk.SizeRemaining) /1GB, 2)
$Disk.Size = [math]::Round($Disk.Size /1GB, 2)

# Powershell version
[Object]$PwsVersion = ($PSVersionTable.PSVersion) | Select-Object ("Major", "Minor") | ForEach-Object {$_}

# Up timme
[Object]$Uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime |
Select-Object ("Days", "Hours", "Minutes") | ForEach-Object {$_}


@"

                      ....,,:;+ccllll   
        ...,,+:;  cllllllllllllllllll 
  ,cclllllllllll  lllllllllllllllllll   $This_Device
  llllllllllllll  lllllllllllllllllll   $($FancyLine -join '')
  llllllllllllll  lllllllllllllllllll   
  llllllllllllll  lllllllllllllllllll   Device: $($Device.Manufacturer) $($Device.Model)
  llllllllllllll  lllllllllllllllllll   Screen res: $ScreenRes
  llllllllllllll  lllllllllllllllllll   OS: $($OS.Caption) $($OS.OSArchitecture)
                                        CPU: $($CPU.NumberOfCores) Core $($CPU.Name)
  llllllllllllll  lllllllllllllllllll   GPU: $GPU
  llllllllllllll  lllllllllllllllllll   Memory: $Memory GB
  llllllllllllll  lllllllllllllllllll   Disk (C:): $DiskUsed GB / $($Disk.Size) GB
  llllllllllllll  lllllllllllllllllll   PowerShell: $($PwsVersion.Major).$($PwsVersion.Minor)
  llllllllllllll  lllllllllllllllllll   Uptime: $($Uptime.Days) d, $($Uptime.Hours) h, $($Uptime.Minutes) m
  '"ccllllllllll  lllllllllllllllllll   Process: $((Get-Process).Count)
         ''""*::  :ccllllllllllllllll
                        ''''''"*::cll

"@