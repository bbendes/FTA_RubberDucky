param(
    [Parameter(Mandatory=$False)]
    [int]
    $operation
)

Begin{
    function disable-Firewall{
        Write-Output "Disabling Windows Firewall"
        netsh advfirewall set allprofiles state off
    }
    function disable-NetAdapters{
        param([string]$netAdapter='Ethernet')

        Write-Output "Disabling Network dapters"
        Get-WmiObject Win32_NetworkAdapter -filter "NetConnectionID LIKE '%'" | ?{$_.NetConnectionID -notlike "$netAdapter"} | %{netsh interface set interface "$($_.NetConnectionID)" DISABLED}
    }

    function enable-dhcp{
        param([string]$netAdapter='Eth')

        Write-Output "Enabling DHCP"
        Get-WmiObject Win32_NetworkAdapter -filter "NetConnectionID LIKE '%'" | ?{$_.NetConnectionID -like "$netAdapter*"} | %{netsh interface ip set address "$($_.NetConnectionID)" dhcp}
    }
    function enable-NetAdapters{
        param([string]$netAdapter='Eth')

        Write-Output "Enabling Net Adapters"
        Get-WmiObject Win32_NetworkAdapter -filter "NetConnectionID LIKE '%'" | ?{$_.NetConnectionID -like "$netAdapter*"} | %{netsh interface set interface "$($_.NetConnectionID)" ENABLED}
    }
    function release-renew{
        ipconfig.exe /release
        ipconfig.exe /renew
    }
    function install-usbEth {
        switch([string]([enviornment]::OSVersion.Version.major)+"."+[string]([enviornment]::OSVersion.Version.minor)){
            $DuckyDir = (split-path $SCRIPT:MyInvocation.MyCommand.Path -parent)
            '10.0' {& "$DuckyDir\USB2Eth_Drivers\Win10\setup.exe"}
            '6.2','6.3' {& "$DuckyDir\USB2Eth_Drivers\Win8\setup.exe"}
            '6.1' {& "$DuckyDir\USB2Eth_Drivers\Win7\setup.exe"}
            Default {& "$DuckyDir\USB2Eth_Drivers\WinXP_Vista\setup.exe"}
        }
    }
}

Process{
    $operation = (Read-Host "Select Operation:`nFull(0); Disable Firewall & non-Ethernet(1); Enable all Network adapters(2); Refresh IP(3); Install USB2Eth(4)")
    switch ($operation) {
        0 {
            Write-verbose "Disabling Firewall"
            disable-Firewall
            Write-verbose "Disabling Network Adapters"
            disable-NetAdapters -netAdapter "1"
            Write-verbose "Enabling DHCP"
            enable-dhcp
            Start-Sleep 1
            Write-verbose "Enabling Ethernet Adapters"            
            enable-NetAdapters
        }
        1 {
            Write-verbose "Disabling Firewall and Non-Ethernet"
            disable-Firewall
            disable-NetAdapters
        }
        2 {
            Write-Verbose "Enabling all network adapters"
            enable-NetAdapters -netAdapter '*'
        }
        3 {
            Write-Verbose "Doing release renew"
            release-renew
        }
        4 {
            Write-verbose "Installing Ethernet Driver for " + [string]([enviornment]::OSVersion.Version.major)+"."+[string]([enviornment]::OSVersion.Version.minor)
            install-usbEth
        }
        Default {Write-Warning "I didn't do anything!"}
    }
}

End{
    
}


