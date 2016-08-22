$computer = $env:COMPUTERNAME

# Import generic functions
$currentPath = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $currentPath\include\sccFunctions.psm1

# Reference: https://msdn.microsoft.com/en-us/library/aa394373(v=vs.85).aspx
$processors = Get-WmiObject -class Win32_Processor -computername $computer
Write-Output "hlp:hardware:cpu::Data from class Win32_Processor"
$architectureList = @("x86","MIPS","Alpha","PowerPC","","ARM","ia64","","","x64")
$availabilityList = @("","Other","Unknown","Running/Full Power","Warning","In Test","Not Applicable","Power Off","Off Line","Off Duty","Degraded","Not Installed","Install Error","Power Save - Unknown","Power Save - Low Power Mode","Power Save - Standby","Power Cycle","Power Save - Warning","Paused","Not Ready","Not Configured","Quiesced")

foreach($processor in $processors) {
    $label = ("hardware:cpu:" + $processor.DeviceID)
    Write-Output ("fix:" + $label + "::AddressWidth:" + $processor.AddressWidth)
    Write-Output ("fix:" + $label + "::Architecture:" + $architectureList[$processor.Architecture])
    Write-Output ("var:" + $label + "::Availability:" + $availabilityList[$processor.Availability])
    Write-Output ("var:" + $label + "::CurrentClockSpeed:" + $processor.CurrentClockSpeed)
    Write-Output ("fix:" + $label + "::Description:" + $processor.Description)
    Write-Output ("fix:" + $label + "::ExtClock:" + $processor.ExtClock)
    Write-Output ("fix:" + $label + "::MaxClockSpeed:" + $processor.MaxClockSpeed)
    Write-Output ("fix:" + $label + "::NumberOfCores:" + $processor.NumberOfCores)
    Write-Output ("fix:" + $label + "::NumberOfLogicalProcessors:" + $processor.NumberOfLogicalProcessors)
    Write-Output ("fix:" + $label + "::L2CacheSize:" + $processor.L2CacheSize)
    Write-Output ("fix:" + $label + "::L3CacheSize:" + $processor.L3CacheSize)
    Write-Output ("fix:" + $label + "::Manufacturer:" + $processor.Manufacturer)
    Write-Output ("fix:" + $label + "::Name:" + $processor.Name)
    Write-Output ("fix:" + $label + "::ProcessorType:" + $processor.ProcessorType)
    Write-Output ("fix:" + $label + "::Revision:" + $processor.Revision)
    Write-Output ("fix:" + $label + "::Stepping:" + $processor.Stepping)
    Write-Output ("fix:" + $label + "::Version:" + $processor.Version)

}

# Reference: https://msdn.microsoft.com/en-us/library/aa394132(v=vs.85).aspx
$disks = Get-WmiObject -class Win32_DiskDrive -computername $computer
Write-Output "hlp:hardware:diskdrive::Data from class Win32_DiskDrive"
foreach($disk in $disks) {
    $label = "fix:hardware:diskdrive:" + $disk.DeviceID -replace "\\",""
    Write-Output ($label + "::Model:" + $disk.Model)
    Write-Output ($label + "::Description:" + $disk.Description)
    Write-Output ($label + "::FirmwareRevision:" + $disk.FirmwareRevision)
    Write-Output ($label + "::Size:" + $disk.Size)
    Write-Output ($label + "::SizeReadable:" + (sccBytesToString $disk.Size))
    Write-Output ($label + "::MediaType:" + $disk.MediaType)
    Write-Output ($label + "::InterfaceType:" + $disk.InterfaceType)
    Write-Output ($label + "::Partitions:" + $disk.Partitions)
    Write-Output ($label + "::SCSIBus:" + $disk.SCSIBus)
    Write-Output ($label + "::SCSILogicalUnit:" + $disk.SCSILogicalUnit)
    Write-Output ($label + "::SCSIPort:" + $disk.SCSIPort)
    Write-Output ($label + "::SCSITargetId:" + $disk.SCSITargetId)
    Write-Output ($label + "::Status:" + $disk.Status)
}

# Reference: https://msdn.microsoft.com/en-us/library/aa394138(v=vs.85).aspx
$display = Get-WmiObject -class Win32_DisplayControllerConfiguration -computername $computer
Write-Output "hlp:hardware:display::Data from class Win32_DisplayControllerConfiguration"
Write-Output ("fix:hardware:display:Name:" + $display.Name)
Write-Output ("fix:hardware:display:BitsPerPixel:" + $display.BitsPerPixel)
Write-Output ("fix:hardware:display:HorizontalResolution:" + $display.HorizontalResolution)
Write-Output ("fix:hardware:display:VerticalResolution:" + $display.VerticalResolution)
Write-Output ("fix:hardware:display:RefreshRate:" + $display.RefreshRate)
Write-Output ("fix:hardware:display:VideoMode:" + $display.VideoMode)

# Reference: https://msdn.microsoft.com/en-us/library/aa394347(v=vs.85).aspx
$physicalMemory = Get-WmiObject -class Win32_PhysicalMemory -computername $computer
Write-Output "hlp:hardware:memory::Data from class Win32_PhysicalMemory"
$totalMemory = 0;
foreach ($memory in $physicalMemory) {
    $label = ("fix:hardware:memory:" + $memory.DeviceLocator)
    Write-Output ($label + "::Manufacturer:" + $memory.Manufacturer)
    Write-Output ($label + "::PartNumber:" + $memory.PartNumber)
    Write-Output ($label + "::SerialNumber:" + $memory.SerialNumber)
    Write-Output ($label + "::BankLabel:" + $memory.BankLabel)
    Write-Output ($label + "::Capacity:" + ($memory.Capacity / 1024 / 1024 / 1024) + " GB")
    Write-Output ($label + "::Speed:" + $memory.Speed)
    Write-Output ($label + "::DataWidth:" + $memory.DataWidth)
    $totalMemory += $memory.Capacity
}
Write-Output ("fix:hardware:memory:general::TotalMemory:" + ($totalMemory / 1024 / 1024 / 1024) + " GB")


# Reference: https://msdn.microsoft.com/en-us/library/aa394347(v=vs.85).aspx
$printers = Get-WmiObject -class Win32_Printer -computername $computer | Sort-Object DeviceID
Write-Output "hlp:hardware:printer::Data from class Win32_Printer"
foreach($printer in $printers){
    $label = ("fix:hardware:printer:" + $printer.DeviceID)
    Write-Output ($label + "::Comment:" + $printer.Comment)
    Write-Output ($label + "::Default:" + $printer.Default)
    Write-Output ($label + "::Description:" + $printer.Description)
    Write-Output ($label + "::Direct:" + $printer.Direct)
    Write-Output ($label + "::DoCompleteFirst:" + $printer.DoCompleteFirst)
    Write-Output ($label + "::DriverName:" + $printer.DriverName)
    Write-Output ($label + "::EnableBIDI:" + $printer.EnableBIDI)
    Write-Output ($label + "::EnableDevQueryPrint:" + $printer.EnableDevQueryPrint)
    Write-Output ($label + "::Local:" + $printer.Local)
    Write-Output ($label + "::Location:" + $printer.Location)
    Write-Output ($label + "::Network:" + $printer.Network)
    Write-Output ($label + "::PortName:" + $printer.PortName)
    Write-Output ($label + "::PrintJobDataType:" + $printer.PrintJobDataType)
    Write-Output ($label + "::PrintProcessor:" + $printer.PrintProcessor)
    Write-Output ($label + "::Priority:" + $printer.Priority)
    Write-Output ($label + "::RawOnly:" + $printer.RawOnly)
    Write-Output ($label + "::ServerName:" + $printer.ServerName)
    Write-Output ($label + "::Shared:" + $printer.Shared)
    Write-Output ($label + "::ShareName:" + $printer.ShareName)
    Write-Output ($label + "::SpoolEnabled:" + $printer.SpoolEnabled)
    Write-Output ($label + "::WorkOffline:" + $printer.WorkOffline)
}

