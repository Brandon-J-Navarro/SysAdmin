# MIT License

# Copyright (c) 2023 Brandon

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Version 202307

<#
.NOTES
    Name: AzureVMDeployment.ps1
    Author: Brandon J. Navarro
    Requires:
    Major Release History:
        03/03/2023  - Initial Draft
        07/27/2023  - Current Release

.SYNOPSIS
    Creates virtual machines.

.DESCRIPTION
    This script configures and creates new Azure Virtual Machines.

.PARAMETER Data Disks
    ----- For multiple data disks -----
    dataDisk1 = "Standard_LRS"
    dataDisk1Size = "8192"

    dataDisk2 = "Standard_LRS"
    dataDisk2Size = "8192"

    Parameters for Data disk 1
    $VirtualMachine = Add-AzVMDataDisk -VM $VirtualMachine -StorageAccountType $vmDetails.$vm.dataDisk1 -DiskSizeInGB $vmDetails.$vm.dataDisk1Size -Caching None -Name "ddisk_1-$($vmDetails.$vm.vmName)" -Lun 1 -CreateOption Empty -Verbose

    Parameters for Data disk 2
    $VirtualMachine = Add-AzVMDataDisk -VM $VirtualMachine -StorageAccountType $vmDetails.$vm.dataDisk2 -DiskSizeInGB $vmDetails.$vm.dataDisk2Size -Caching None -Name "ddisk_2-$($vmDetails.$vm.vmName)" -Lun 2 -CreateOption Empty -Verbose

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    ----- Retrieves marketplace image info -----
    Get-AzVmImagePublisher -Location "[REGION]" MicrosoftWindowsServer
    Get-AzVMImageOffer -Location "[REGION]" -PublisherName 'MicrosoftWindowsDesktop'
    Get-AzVMImageOffer -Location "[REGION]" -PublisherName 'MicrosoftWindowsServer' WindowsServer
    Get-AzVMImageSku -Location "[REGION]" -Offer 'Windows-10' -PublisherName "MicrosoftWindowsDesktop"
    Get-AzVMImageSku -Location "[REGION]" -Offer 'WindowsServer' -PublisherName "MicrosoftWindowsServer" 2019-Datacenter

#>

# Constants
$location = "[REGION]"

# Store the credentials for the local admin account
$adminUsername = "[USERNAME]"
$adminPassword = ConvertTo-SecureString '[PASSWORD]' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)

# Configure VM parameters
$vmDetails = @{
    [COMPUTERNAME] = @{
        vnetRgName = "[RESOURCEGROUP]"
        vnetName = "[VNET]"
        subnetName = "[SUBNET]"
        resourceGroupName = "[RESOURCEGROUP]"
        computerName = "[COMPUTERNAME]"
        timeZone = "Eastern Standard Time"
        vmName = "[COMPUTERNAME]"
        vmSize = "[SIZE]"
        vmGen = "[GENERATION]"
        vmZone = "[AVAILABILITYZONE]"
        osDisk = "[DISKTYPE]" # Premium_LRS,StandardSSD_LRS,Standard_LRS,UltraSSD_LRS
        osDiskSize = "[DISKSIZE]"
        dataDisk = "[DISKTYPE]"
        dataDiskSize = "[DISKSIZE]"
        ipAddress = "SUBNETIP"
        ASG = "[APPLICATIONSECURITYGROUP]"
        NSG = "[NETWORKSECURITYGROUP]"
        vmPublisherName = "[IMAGEPUBLISHER]" # "MicrosoftWindowsDesktop","Oracle","MicrosoftWindowsServer"
        vmOffer = "[IMAGE]" # "Windows-10","Oracle-Linux","WindowsServer"
        vmSkus = "[IMAGEVERSION]" # "win10-22h2-ent","ol79-lvm","2022-datacenter"
        Storage = "[STORAGEACCOUNT]"
    }
}

$vms = @("[COMPUTERNAME]")

# Define the VM parameters and create the new virtual machine
foreach ($vm in $vms) {
    # Begin VM configuration
    $VirtualMachine = New-AzVMConfig -VMName $vmDetails.$vm.vmName -VMSize $vmDetails.$vm.vmSize -IdentityType SystemAssigned -Verbose

    # Set OS parameters
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $vmDetails.$vm.computerName -Credential $credential -TimeZone $vmDetails.$vm.timeZone -Verbose

    # Get the subnet details for the specified virtual network + subnet combination
    $subnet = (Get-AzVirtualNetwork -Name $vmDetails.$vm.vnetName -ResourceGroupName $vmDetails.$vm.vnetRgName).Subnets | Where-Object {$_.Name -eq $vmDetails.$vm.subnetName} -Verbose
    $asg = (Get-AzApplicationSecurityGroup -Name $vmDetails.$vm.ASG -ResourceGroupName $vmDetails.$vm.resourceGroupName)
    $nsg = (Get-AzNetworkSecurityGroup -Name $vmDetails.$vm.NSG -ResourceGroupName $vmDetails.$vm.resourceGroupName)

    # Configuration for NIC (no Public IP)
    $ipConfig1 = New-AzNetworkInterfaceIpConfig -Name "IpConfig1" -PrivateIpAddressVersion IPv4 -PrivateIpAddress $vmDetails.$vm.ipAddress -SubnetId $subnet.Id -ApplicationSecurityGroupId $asg.Id -Verbose

    # Create the network interface
    $nic = New-AzNetworkInterface -Name "nic-$($vmDetails.$vm.vmName)" -ResourceGroupName $vmDetails.$vm.resourceGroupName -Location $location -IpConfiguration $ipConfig1 -EnableAcceleratedNetworking -NetworkSecurityGroupId $nsg.id -Verbose

    # Add the NIC to the VM config
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $nic.Id -Verbose
    # VM image source - Marketplace ## Use this to create a VM from scratch
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName $vmDetails.$vm.vmPublisherName -Offer $vmDetails.$vm.vmOffer -Skus $vmDetails.$vm.vmSkus -Version "latest" -Verbose #>

    # Enable Boot diagnostics
    $VirtualMachine = Set-AzVMBootDiagnostic -VM $VirtualMachine -Enable -ResourceGroupName $vmDetails.$vm.resourceGroupName -StorageAccountName $vmDetails.$vm.Storage -Verbose

    # Parameters for OS disk
    $VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -StorageAccountType $vmDetails.$vm.osDisk -DiskSizeInGB $vmDetails.$vm.osDiskSize -Caching ReadWrite -Name "osdisk-$($vmDetails.$vm.vmName)" -CreateOption FromImage -Verbose

    # Parameters for Data disk
    $VirtualMachine = Add-AzVMDataDisk -VM $VirtualMachine -StorageAccountType $vmDetails.$vm.dataDisk -DiskSizeInGB $vmDetails.$vm.dataDiskSize -Caching ReadOnly -Name "ddisk_0-$($vmDetails.$vm.vmName)" -Lun 0 -CreateOption Empty -Verbose

    # Create the virtual machine
    New-AzVM -ResourceGroupName $vmDetails.$vm.resourceGroupName -Location $location -VM $VirtualMachine -Verbose
}
