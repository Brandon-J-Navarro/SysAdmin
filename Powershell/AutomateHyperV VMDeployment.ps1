#Create a VM with VHD
<#
Name: Name of the Virtual Machine
Path: Path where will be stored VM files
NewVHDPath: Create a VHD(X) file to the specified path (Dynamic disk)
New-VHDSizeBytes: Size of the VHD(X) file
Generation: VM generation (1 or 2)
MemoryStartupBytes: Memory assigned to the VM (static Memory)
SwitchName: switch name where the network adapter will be connected
#>
New-VM -Name <#VMName#>
    -Path <#VMPath#>
    -NewVHDPath <#VHD Path#>
    -NewVHDSizeBytes <#VHD(X) size#>
    -Generation <#VM Gen (1 or 2)#>
    -MemoryStartupBytes <#Startup Memory#>
    -SwitchName <#VM Switch Name#>
#Create a VM with no VHD
New-VM -Name <#VMName#>
    -Path <#VMPath#>
    -NoVHD
    -Generation <#VM Gen (1 or 2)#>
    -MemoryStartupBytes <#Startup Memory#>
    -SwitchName <#VM Switch Name#> 

#Configure a VM Dynamic Memory
<#
Name: Name of the VM you would like to edit
ProcessorCount: number of vCPU that you want to assign to the VM
DynamicMemory: Enable the Dynamic Memory
MemoryMinimumBytes: set the minimum memory value
MemoryStartupBytes: set the startup memory value
MemoryMaximumBytes: set the maximum memory value
AutomaticStartAction: action which is run when the Hyper-V service is starting (Nothing, Start, StartIfRunning)
AutomaticStartDelay: number of second to wait before the automatic start action is run
AutomaticStopAction: action which is run when the Hyper-V service is stopping (Save, Shutdown, TurnOff)
#>
Set-VM -Name <#VM Name#>
    -ProcessorCount <#number of vCPU#>
    -DynamicMemory
    -MemoryMinimumBytes <#Minimum Memory#>
    -MemoryStartupBytes <#Startup Memory#>
    -MemoryMaximumBytes <#Maximum Memory#>
    -AutomaticStartAction <#automatic Start Action#>
    -AutomaticStartDelay <#Automatic Start Delay in second#>
    -AutomaticStopAction <#Automatic stop action#> 
#Configure a VM Static Memory
Set-VM -Name <#VM Name#>
    -ProcessorCount <#number of vCPU#>
    -StaticMemory
    -AutomaticStartAction <#automatic Start Action#>
    -AutomaticStartDelay <#Automatic Start Delay in second#>
    -AutomaticStopAction <#Automatic stop action#>

#Attach a VHD(x) to a VM
<#
VMName: Name of the related VM
Path: Path to the VHD(X) file
#>
Add-VMHardDiskDrive -VMName <#VMName#>
    -Path <#VHD(X) path#>

#Manage Boot Order
$OsVirtualDrive = Get-VMHardDiskDrive -VMName <#VM Name#> -ControllerNumber 0
Set-VMFirmware -VMName <#VM Name#> -FirstBootDevice $OSVirtualDrive 

#Adding additional VHD(X)
<#
Path: absolute path to the VHD(X) file
SizeBytes: Size of the VHD(X)
Dynamic (can be replace by fixed): Dynamic or fixed VHD(X)
#>
New-VHD -Path <#Path of the VHD(X)#>
    -SizeBytes <#Disk Size#>
    -Dynamic 

Add-VMHardDiskDrive -VMName <#VM Name#>
-Path <#Path of the VHD(X)#> 

#Add network adapters
<#
VMName: name of the VM
SwitchName: Name of the VM Switch to connect to
Name: Name of the network adapter
#>
Add-VMNetworkAdapter -VMName <#VM Name#>
    -SwitchName <#VM Switch Name#>
    -Name <#Network Adapter Name#> 

#Configure network adapters
<#
MacAddressSpoofing: Enable or disable Mac Spoofing
DHCPGuard: Enable or disable DHCP Guard
RouterGuard: Enable or disable router guard
#>
Set-VMNetworkAdapter -MacAddressSpoofing <#on/off#>
    -DHCPGuard <#on/off#>
    -RouterGuard <#on/off#>


#Set the VLAN
<#
Access: Set the Access mode on the network adapter
VlanId: set the VLAN ID value
#>
Set-VMNetworkAdapterVLAN -Access -VlanId <#VlanId#>
Set-VMNetworkAdapterVLAN -untagged

#Script to automatically deploy a VM
######################################################
###              Template Definition               ###
######################################################

# VM Name
$VMName          = "MyNewVM01"

# Automatic Start Action (Nothing = 0, Start =1, StartifRunning = 2)
$AutoStartAction = 1
# In second
$AutoStartDelay  = 10
# Automatic Start Action (TurnOff = 0, Save =1, Shutdown = 2)
$AutoStopAction  = 2


###### Hardware Configuration ######
# VM Path
$VMPath         = "D:\"

# VM Generation (1 or 2)
$Gen            = 2

# Processor Number
$ProcessorCount = 4

## Memory (Static = 0 or Dynamic = 1)
$Memory         = 1
# StaticMemory
$StaticMemory   = 8GB

# DynamicMemory
$StartupMemory  = 2GB
$MinMemory      = 1GB
$MaxMemory      = 4GB

# Sysprep VHD path (The VHD will be copied to the VM folder)
$SysVHDPath     = "D:\OperatingSystem-W2012R2DTC.vhdx"
# Rename the VHD copied in VM folder to:
$OsDiskName     = $VMName

### Additional virtual drives
$ExtraDrive  = @()
# Drive 1
$Drive       = New-Object System.Object
$Drive       | Add-Member -MemberType NoteProperty -Name Name -Value Data
$Drive       | Add-Member -MemberType NoteProperty -Name Path -Value $($VMPath + "\" + $VMName)
$Drive       | Add-Member -MemberType NoteProperty -Name Size -Value 10GB
$Drive       | Add-Member -MemberType NoteProperty -Name Type -Value Dynamic
$ExtraDrive += $Drive

# Drive 2
$Drive       = New-Object System.Object
$Drive       | Add-Member -MemberType NoteProperty -Name Name -Value Bin
$Drive       | Add-Member -MemberType NoteProperty -Name Path -Value $($VMPath + "\" + $VMName)
$Drive       | Add-Member -MemberType NoteProperty -Name Size -Value 20GB
$Drive       | Add-Member -MemberType NoteProperty -Name Type -Value Fixed
$ExtraDrive += $Drive
# You can copy/delete this below block as you wish to create (or not) and attach several VHDX

### Network Adapters
# Primary Network interface: VMSwitch 
$VMSwitchName = "LS_VMWorkload"
$VlanId       = 0
$VMQ          = $False
$IPSecOffload = $False
$SRIOV        = $False
$MacSpoofing  = $False
$DHCPGuard    = $False
$RouterGuard  = $False
$NicTeaming   = $False

## Additional NICs
$NICs  = @()

# NIC 1
$NIC   = New-Object System.Object
$NIC   | Add-Member -MemberType NoteProperty -Name VMSwitch -Value "LS_VMWorkload"
$NIC   | Add-Member -MemberType NoteProperty -Name VLAN -Value 10
$NIC   | Add-Member -MemberType NoteProperty -Name VMQ -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name IPsecOffload -Value $True
$NIC   | Add-Member -MemberType NoteProperty -Name SRIOV -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name MacSpoofing -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name DHCPGuard -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name RouterGuard -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name NICTeaming -Value $False
$NICs += $NIC

#NIC 2
$NIC   = New-Object System.Object
$NIC   | Add-Member -MemberType NoteProperty -Name VMSwitch -Value "LS_VMWorkload"
$NIC   | Add-Member -MemberType NoteProperty -Name VLAN -Value 20
$NIC   | Add-Member -MemberType NoteProperty -Name VMQ -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name IPsecOffload -Value $True
$NIC   | Add-Member -MemberType NoteProperty -Name SRIOV -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name MacSpoofing -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name DHCPGuard -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name RouterGuard -Value $False
$NIC   | Add-Member -MemberType NoteProperty -Name NICTeaming -Value $False
$NICs += $NIC
# You can copy/delete the above block and set it for additional NIC


######################################################
###           VM Creation and Configuration        ###
######################################################

## Creation of the VM
# Creation without VHD and with a default memory value (will be changed after)
New-VM -Name $VMName `
       -Path $VMPath `
       -NoVHD `
       -Generation $Gen `
       -MemoryStartupBytes 1GB `
       -SwitchName $VMSwitchName


if ($AutoStartAction -eq 0){$StartAction = "Nothing"}
Elseif ($AutoStartAction -eq 1){$StartAction = "Start"}
Else{$StartAction = "StartIfRunning"}

if ($AutoStopAction -eq 0){$StopAction = "TurnOff"}
Elseif ($AutoStopAction -eq 1){$StopAction = "Save"}
Else{$StopAction = "Shutdown"}

## Changing the number of processor and the memory
# If Static Memory
if (!$Memory){
    
    Set-VM -Name $VMName `
           -ProcessorCount $ProcessorCount `
           -StaticMemory `
           -MemoryStartupBytes $StaticMemory `
           -AutomaticStartAction $StartAction `
           -AutomaticStartDelay $AutoStartDelay `
           -AutomaticStopAction $StopAction


}
# If Dynamic Memory
Else{
    Set-VM -Name $VMName `
           -ProcessorCount $ProcessorCount `
           -DynamicMemory `
           -MemoryMinimumBytes $MinMemory `
           -MemoryStartupBytes $StartupMemory `
           -MemoryMaximumBytes $MaxMemory `
           -AutomaticStartAction $StartAction `
           -AutomaticStartDelay $AutoStartDelay `
           -AutomaticStopAction $StopAction

}

## Set the primary network adapters
$PrimaryNetAdapter = Get-VM $VMName | Get-VMNetworkAdapter
if ($VlanId -gt 0){$PrimaryNetAdapter | Set-VMNetworkAdapterVLAN -Access -VlanId $VlanId}
else{$PrimaryNetAdapter | Set-VMNetworkAdapterVLAN -untagged}

if ($VMQ){$PrimaryNetAdapter | Set-VMNetworkAdapter -VmqWeight 100}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -VmqWeight 0}

if ($IPSecOffload){$PrimaryNetAdapter | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 512}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 0}

if ($SRIOV){$PrimaryNetAdapter | Set-VMNetworkAdapter -IovQueuePairsRequested 1 -IovInterruptModeration Default -IovWeight 100}
Else{$PrimaryNetAdapter | Set-VMNetworkAdapter -IovWeight 0}

if ($MacSpoofing){$PrimaryNetAdapter | Set-VMNetworkAdapter -MacAddressSpoofing on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -MacAddressSpoofing off}

if ($DHCPGuard){$PrimaryNetAdapter | Set-VMNetworkAdapter -DHCPGuard on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -DHCPGuard off}

if ($RouterGuard){$PrimaryNetAdapter | Set-VMNetworkAdapter -RouterGuard on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -RouterGuard off}

if ($NicTeaming){$PrimaryNetAdapter | Set-VMNetworkAdapter -AllowTeaming on}
Else {$PrimaryNetAdapter | Set-VMNetworkAdapter -AllowTeaming off}



## VHD(X) OS disk copy
$OsDiskInfo = Get-Item $SysVHDPath
Copy-Item -Path $SysVHDPath -Destination $($VMPath + "\" + $VMName)
Rename-Item -Path $($VMPath + "\" + $VMName + "\" + $OsDiskInfo.Name) -NewName $($OsDiskName + $OsDiskInfo.Extension)

# Attach the VHD(x) to the VM
Add-VMHardDiskDrive -VMName $VMName -Path $($VMPath + "\" + $VMName + "\" + $OsDiskName + $OsDiskInfo.Extension)

$OsVirtualDrive = Get-VMHardDiskDrive -VMName $VMName -ControllerNumber 0

# Change the boot order to the VHDX first
Set-VMFirmware -VMName $VMName -FirstBootDevice $OsVirtualDrive

# For additional each Disk in the collection
Foreach ($Disk in $ExtraDrive){
    # if it is dynamic
    if ($Disk.Type -like "Dynamic"){
        New-VHD -Path $($Disk.Path + "\" + $Disk.Name + ".vhdx") `
            -SizeBytes $Disk.Size `
            -Dynamic
    }
    # if it is fixed
    Elseif ($Disk.Type -like "Fixed"){
        New-VHD -Path $($Disk.Path + "\" + $Disk.Name + ".vhdx") `
            -SizeBytes $Disk.Size `
            -Fixed
    }

    # Attach the VHD(x) to the Vm
    Add-VMHardDiskDrive -VMName $VMName `
        -Path $($Disk.Path + "\" + $Disk.Name + ".vhdx")
}

$i = 2
# foreach additional network adapters
Foreach ($NetAdapter in $NICs){
    # add the NIC
    Add-VMNetworkAdapter -VMName $VMName -SwitchName $NetAdapter.VMSwitch -Name "Network Adapter $i"
    $ExtraNic = Get-VM -Name $VMName | Get-VMNetworkAdapter -Name "Network Adapter $i" 
    # Configure the NIC regarding the option
    if ($NetAdapter.VLAN -gt 0){$ExtraNic | Set-VMNetworkAdapterVLAN -Access -VlanId $NetAdapter.VLAN}
    else{$ExtraNic | Set-VMNetworkAdapterVLAN -untagged}

    if ($NetAdapter.VMQ){$ExtraNic | Set-VMNetworkAdapter -VmqWeight 100}
    Else {$ExtraNic | Set-VMNetworkAdapter -VmqWeight 0}

    if ($NetAdapter.IPSecOffload){$ExtraNic | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 512}
    Else {$ExtraNic | Set-VMNetworkAdapter -IPsecOffloadMaximumSecurityAssociation 0}

    if ($NetAdapter.SRIOV){$ExtraNic | Set-VMNetworkAdapter -IovQueuePairsRequested 1 -IovInterruptModeration Default -IovWeight 100}
    Else{$ExtraNic | Set-VMNetworkAdapter -IovWeight 0}

    if ($NetAdapter.MacSpoofing){$ExtraNic | Set-VMNetworkAdapter -MacAddressSpoofing on}
    Else {$ExtraNic | Set-VMNetworkAdapter -MacAddressSpoofing off}

    if ($NetAdapter.DHCPGuard){$ExtraNic | Set-VMNetworkAdapter -DHCPGuard on}
    Else {$ExtraNic | Set-VMNetworkAdapter -DHCPGuard off}

    if ($NetAdapter.RouterGuard){$ExtraNic | Set-VMNetworkAdapter -RouterGuard on}
    Else {$ExtraNic | Set-VMNetworkAdapter -RouterGuard off}

    if ($NetAdapter.NicTeaming){$ExtraNic | Set-VMNetworkAdapter -AllowTeaming on}
    Else {$ExtraNic | Set-VMNetworkAdapter -AllowTeaming off}

    $i++
}
