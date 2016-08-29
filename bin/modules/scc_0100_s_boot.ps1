$computer = $env:COMPUTERNAME

# Reference: https://msdn.microsoft.com/en-us/library/aa394077(v=vs.85).aspx
$bios = Get-WmiObject -class Win32_BIOS -computername $computer
Write-Output "hlp:boot:BIOS::Data from class Win32_BIOS"
$biosDetailList = @(
	"Reserved",
	"Reserved",
	"Unknown",
	"BIOS Characteristics Not Supported",
	"ISA is supported",
	"MCA is supported",
	"EISA is supported",
	"PCI is supported",
	"PC Card (PCMCIA) is supported",
	"Plug and Play is supported",
	"APM is supported",
	"BIOS is Upgradable (Flash)",
	"BIOS shadowing is allowed",
	"VL-VESA is supported",
	"ESCD support is available",
	"Boot from CD is supported",
	"Selectable Boot is supported",
	"BIOS ROM is socketed",
	"Boot From PC Card (PCMCIA) is supported",
	"EDD (Enhanced Disk Drive) Specification is supported",
	"Int 13h - Japanese Floppy for NEC 9800 1.2mb (3.5, 1k Bytes/Sector, 360 RPM) is supported",
	"Int 13h - Japanese Floppy for Toshiba 1.2mb (3.5, 360 RPM) is supported",
	"Int 13h - 5.25 / 360 KB Floppy Services are supported",
	"Int 13h - 5.25 /1.2MB Floppy Services are supported",
	"Int 13h - 3.5 / 720 KB Floppy Services are supported",
	"Int 13h - 3.5 / 2.88 MB Floppy Services are supported",
	"Int 5h, Print Screen Service is supported",
	"Int 9h, 8042 Keyboard services are supported",
	"Int 14h, Serial Services are supported",
	"Int 17h, printer services are supported",
	"Int 10h, CGA/Mono Video Services are supported",
	"NEC PC-98",
	"ACPI supported",
	"USB Legacy is supported",
	"AGP is supported",
	"I2O boot is supported",
	"LS-120 boot is supported",
	"ATAPI ZIP Drive boot is supported",
	"1394 boot is supported",
	"Smart Battery supported"
)
foreach($biosCharacteristic in $bios.BiosCharacteristics) {
    if($biosCharacteristic -le 39) {
        Write-Output ("fix:boot:BIOS::BiosCharacteristics:" + $biosDetailList[$biosCharacteristic])
    } elseif($biosCharacteristic -ge 40 -and $biosCharacteristic -le 47) {
        Write-Output ("fix:boot:BIOS::BiosCharacteristics:" + $biosCharacteristic + ":Reserved for BIOS vendor")
    } elseif($biosCharacteristic -ge 48 -and $biosCharacteristic -le 63) {
        Write-Output ("fix:boot:BIOS::BiosCharacteristics:" + $biosCharacteristic + ":Reserved for system vendor")
    } else {
        Write-Output ("fix:boot:BIOS::BiosCharacteristics:" + $biosCharacteristic + ":Unknown BIOS characteristic")
    }
}
Write-Output ("fix:boot:BIOS::BuildNumber:" + $bios.BuildNumber)
Write-Output ("fix:boot:BIOS::Caption:" + $bios.Caption)
Write-Output ("fix:boot:BIOS::CodeSet:" + $bios.CodeSet)
Write-Output ("fix:boot:BIOS::CurrentLanguage:" + $bios.CurrentLanguage)
Write-Output ("fix:boot:BIOS::Description:" + $bios.Description)
Write-Output ("fix:boot:BIOS::IdentificationCode:" + $bios.IdentificationCode)
Write-Output ("fix:boot:BIOS::InstallableLanguages:" + $bios.InstallableLanguages)
Write-Output ("fix:boot:BIOS::InstallDate:" + $bios.InstallDate)
Write-Output ("fix:boot:BIOS::LanguageEdition:" + $bios.LanguageEdition)
Write-Output ("fix:boot:BIOS::ListOfLanguages:" + $bios.ListOfLanguages)
Write-Output ("fix:boot:BIOS::Manufacturer:" + $bios.Manufacturer)
Write-Output ("fix:boot:BIOS::Name:" + $bios.Name)
Write-Output ("fix:boot:BIOS::OtherTargetOS:" + $bios.OtherTargetOS)
Write-Output ("fix:boot:BIOS::PrimaryBIOS:" + $bios.PrimaryBIOS)
Write-Output ("fix:boot:BIOS::ReleaseDate:" + $bios.ReleaseDate)
Write-Output ("fix:boot:BIOS::SerialNumber:" + $bios.SerialNumber)
Write-Output ("fix:boot:BIOS::SMBIOSBIOSVersion:" + $bios.SMBIOSBIOSVersion)
Write-Output ("fix:boot:BIOS::SMBIOSMajorVersion:" + $bios.SMBIOSMajorVersion)
Write-Output ("fix:boot:BIOS::SMBIOSMinorVersion:" + $bios.SMBIOSMinorVersion)
Write-Output ("fix:boot:BIOS::SMBIOSPresent:" + $bios.SMBIOSPresent)
Write-Output ("fix:boot:BIOS::SoftwareElementID:" + $bios.SoftwareElementID)
Write-Output ("fix:boot:BIOS::SoftwareElementState:" + $bios.SoftwareElementState)
Write-Output ("fix:boot:BIOS::Status:" + $bios.Status)
Write-Output ("fix:boot:BIOS::TargetOperatingSystem:" + $bios.TargetOperatingSystem)
Write-Output ("fix:boot:BIOS::Version:" + $bios.Version)

# Reference: https://msdn.microsoft.com/en-us/library/aa394102(v=vs.85).aspx
$chassisBootupList = @("Undefined","Other","Unknown","Safe","Warning","Critical","Non-recoverable")
$cs = Get-WmiObject -class Win32_ComputerSystem -computername $computer
Write-Output "hlp:boot:general::Data from class Win32_ComputerSystem"
Write-Output ("fix:boot:general::BootROMSupported:" + $cs.BootROMSupported)
Write-Output ("fix:boot:general::BootupState:" + $cs.BootupState)
Write-Output ("fix:boot:general::ChassisBootupState:" + $chassisBootupList[$cs.ChassisBootupState])
Write-Output ("fix:boot:general::SystemStartupDelay:" + $cs.SystemStartupDelay)
Write-Output ("fix:boot:general::SystemStartupOptions:" + ($cs.SystemStartupOptions -Join ","))
Write-Output ("fix:boot:general::SystemStartupSetting:" + $cs.SystemStartupSetting)

# Reference: https://msdn.microsoft.com/en-us/library/aa394464(v=vs.85).aspx
$sc = Get-WmiObject -class Win32_StartupCommand -computername $computer | Sort-Object Caption
Write-Output "hlp:boot:startup::Data from class Win32_StartupCommand"
foreach($startupCommand in $sc) {
    $label = ("fix:boot:startup:" + $startupCommand.Caption)
    Write-Output ($label + "::Command:" + $startupCommand.Command)
    Write-Output ($label + "::Description:" + $startupCommand.Description)
    Write-Output ($label + "::Location:" + $startupCommand.Location)
    Write-Output ($label + "::Name:" + $startupCommand.Name)
    Write-Output ($label + "::SettingID:" + $startupCommand.SettingID)
    Write-Output ($label + "::User:" + $startupCommand.User)
}