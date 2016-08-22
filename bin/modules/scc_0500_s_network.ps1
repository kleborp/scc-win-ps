$computer = $env:COMPUTERNAME

# Import generic functions
$currentPath = $MyInvocation.MyCommand.Path | Split-Path
Import-Module $currentPath\include\sccFunctions.psm1

# Get some general network related information
# Reference: https://msdn.microsoft.com/en-us/library/aa394102(v=vs.85).aspx
$cs = Get-WmiObject -class Win32_ComputerSystem -computername $computer
Write-Output "hlp:network:general::Data from class Win32_ComputerSystem"
Write-Output ("fix:network:general::NetworkServerModeEnabled:" + $cs.NetworkServerModeEnabled)
Write-Output ("fix:network:general::PartOfDomain:" + $cs.PartOfDomain)
Write-Output ("fix:network:general::Roles:" + ($cs.Roles -join ", "))

# Get configuration of network adapters
# Reference: https://msdn.microsoft.com/en-us/library/aa394217(v=vs.85).aspx
$networkAdapters = Get-WmiObject -class Win32_NetworkAdapterConfiguration -computername $computer
Write-Output "hlp:network:general::Data from class Win32_NetworkAdapterConfiguration"
foreach ($networkAdapter in $networkAdapters) {
    # Ignore adapter if not IP Enabled
    if($networkAdapter.IPEnabled -eq 1) {
        # Make sure we don't flag certain changes if it's DHCP (IP can change for example)
        if($networkAdapter.DHCPEnabled -eq 1) {
            $ipDataClass = "var"
        } else {
            $ipDataClass = "fix"
        }
        $label = (":network:lan::" + $networkAdapter.InterfaceIndex)
        Write-Output ("fix" + $label + "::ServiceName:" + $networkAdapter.ServiceName)
        Write-Output ("fix" + $label + "::MACAddress:" + ($networkAdapter.MACAddress -replace ":",""))
        Write-Output ($ipDataClass + $label + "::IPAddress:" + ($networkAdapter.IPAddress -join ","))
        Write-Output ($ipDataClass + $label + "::IPSubnet:" + ($networkAdapter.IPSubnet -join ","))
        Write-Output ($ipDataClass + $label + "::DefaultIPGateway:" + ($networkAdapter.DefaultIPGateway -join ","));
        Write-Output ($ipDataClass + $label + "::DNSServerSearchOrder:" + ($networkAdapter.DNSServerSearchOrder -join ","))
        Write-Output ($ipDataClass + $label + "::DNSDomain:" + $networkAdapter.DNSDomain)
        Write-Output ($ipDataClass + $label + "::DNSDomainSuffixSearchOrder:" + ($networkAdapter.DNSDomainSuffixSearchOrder -join ","))
        Write-Output ("fix" + $label + "::DomainDNSRegistrationEnabled:" + $networkAdapter.DomainDNSRegistrationEnabled)
        Write-Output ("fix" + $label + "::WINSEnableLMHostsLookup:" + $networkAdapter.WINSEnableLMHostsLookup)
        if($networkAdapter.WINSEnableLMHostsLookup) {
            Write-Output ("fix" + $label + "::WINSHostLookupFile:" + $networkAdapter.WINSHostLookupFile)
            Write-Output ("fix" + $label + "::WINSScopeID:" + $networkAdapter.WINSScopeID)
            Write-Output ("fix" + $label + "::WINSPrimaryServer:" + $networkAdapter.WINSPrimaryServer)
            Write-Output ("fix" + $label + "::WINSSecondaryServer:" + $networkAdapter.WINSSecondaryServer)
        }
        Write-Output ("fix" + $label + "::DHCPEnabled:" + $networkAdapter.DHCPEnabled)
        if($networkAdapter.DHCPEnabled) {
            Write-Output ("fix" + $label + "::DHCPServer:" + $networkAdapter.DHCPServer)
            Write-Output ($ipDataClass + $label + "::DHCPLeaseExpires:" + $networkAdapter.DHCPLeaseExpires)
            Write-Output ($ipDataClass + $label + "::DHCPLeaseObtained:" + $networkAdapter.DHCPLeaseObtained)
        }
        Write-Output ("fix" + $label + "::DatabasePath:" + $networkAdapter.DatabasePath)
        Write-Output ("fix" + $label + "::DefaultTOS:" + $networkAdapter.DefaultTOS)
        Write-Output ("fix" + $label + "::DefaultTTL:" + $networkAdapter.DefaultTTL)
        Write-Output ("fix" + $label + "::Description:" + $networkAdapter.Description)
        Write-Output ("fix" + $label + "::FullDNSRegistrationEnabled:" + $networkAdapter.FullDNSRegistrationEnabled)
        Write-Output ("fix" + $label + "::GatewayCostMetric:" + ($networkAdapter.GatewayCostMetric -join ","))
        Write-Output ("fix" + $label + "::IGMPLevel:" + $networkAdapter.IGMPLevel)
        Write-Output ("fix" + $label + "::IPConnectionMetric:" + $networkAdapter.IPConnectionMetric)
        Write-Output ("fix" + $label + "::IPFilterSecurityEnabled:" + $networkAdapter.IPFilterSecurityEnabled)
        if($networkAdapter.IPPortSecurityEnabled) {
            Write-Output ("fix" + $label + "::IPSecPermitIPProtocols:" + ($networkAdapter.IPSecPermitIPProtocols -join ","))
            Write-Output ("fix" + $label + "::IPSecPermitTCPPorts:" + ($networkAdapter.IPSecPermitTCPPorts -join ","))
            Write-Output ("fix" + $label + "::IPSecPermitUDPPorts:" + ($networkAdapter.IPSecPermitUDPPorts -join ","))
        }
        Write-Output ("fix" + $label + "::IPUseZeroBroadcast:" + $networkAdapter.IPUseZeroBroadcast)
        Write-Output ("fix" + $label + "::KeepAliveInterval:" + $networkAdapter.KeepAliveInterval)
        Write-Output ("fix" + $label + "::KeepAliveTime:" + $networkAdapter.KeepAliveTime)
        Write-Output ("fix" + $label + "::MTU:" + $networkAdapter.MTU)
        Write-Output ("fix" + $label + "::NumForwardPackets:" + $networkAdapter.NumForwardPackets)
        Write-Output ("fix" + $label + "::PMTUBHDetectEnabled:" + $networkAdapter.PMTUBHDetectEnabled)
        Write-Output ("fix" + $label + "::PMTUDiscoveryEnabled:" + $networkAdapter.PMTUDiscoveryEnabled)
        Write-Output ("fix" + $label + "::ServiceName:" + $networkAdapter.ServiceName)
        Write-Output ("fix" + $label + "::SettingID:" + $networkAdapter.SettingID)
        Write-Output ("fix" + $label + "::TcpipNetbiosOptions:" + $networkAdapter.TcpipNetbiosOptions)
        Write-Output ("fix" + $label + "::TcpMaxConnectRetransmissions:" + $networkAdapter.TcpMaxConnectRetransmissions)
        Write-Output ("fix" + $label + "::TcpMaxDataRetransmissions:" + $networkAdapter.TcpMaxDataRetransmissions)
        Write-Output ("fix" + $label + "::TcpNumConnections:" + $networkAdapter.TcpNumConnections)
        Write-Output ("fix" + $label + "::TcpUseRFC1122UrgentPointer:" + $networkAdapter.TcpUseRFC1122UrgentPointer)
        Write-Output ("fix" + $label + "::TcpWindowSize:" + $networkAdapter.TcpWindowSize)
    }
}

# Get Network Connection details
# Reference: https://msdn.microsoft.com/en-us/library/aa394220(v=vs.85).aspx
$networkConnections = Get-WmiObject -class Win32_NetworkConnection -computername $computer
Write-Output "hlp:network:connections::Data from class Win32_NetworkConnection"
foreach($nc in $networkConnections) {
    Write-Output ("fix:network:connections:" + $nc.LocalName)
    # I have nothing to test with, skipping for now
}

# Get Proxy Configuration details
# Reference: https://msdn.microsoft.com/en-us/library/aa394389(v=vs.85).aspx
# End of Support as of XP / Server 2003, commenting out
#$proxyConfig = Get-WmiObject -class Win32_Proxy -computername $computer
#Write-Output "hlp:network:proxy::Data from class Win32_Proxy"
#Write-Output ("fix:network:proxy::ProxyServer:" + $proxyConfig.ProxyServer)
#Write-Output ("fix:network:proxy::ProxyPortNumber:" + $proxyConfig.ProxyPortNumber)
#Write-Output ("fix:network:proxy::ServerName:" + $proxyConfig.ServerName)

# Get IP Routing table
# Reference: https://msdn.microsoft.com/en-us/library/aa394162(v=vs.85).aspx
$routes = Get-WmiObject -class Win32_IP4RouteTable -computername $computer
$protocols = @("","other","local","netmgmt","icmp","egp","ggp","hello","rip","is-is","es-is","ciscoIgrp","bbnSpfIgp","ospf","bgp")
Write-Output "hlp:network:routes::Data from class Win32_IP4RouteTable"
Write-Output ("var:network:routes::{0,-16}{1,-16}{2,-16}{3,-7}{4,-8}" -f "Destination", "Mask", "Gateway", "Metric", "Proto")
foreach($route in $routes) {
    Write-Output ("var:network:routes::{0,-16}{1,-16}{2,-16}{3,-7}{4,-8}" -f $route.Destination, $route.Mask, $route.NextHop, $route.Metric1, $protocols[$route.Protocol])
}