# SOURCE: https://gist.github.com/Ruffo324/1044ceea67d6dbc43d35cae8cb250212

# Change to name of TARGET-VM.
$vm='CHANGE_ME'
# Change to PCI device location (💡 Location).
$Location = 'CHANGE_ME'

# Enable CPU features.
Set-VM -GuestControlledCacheTypes $true -VMName $vm
# Host-Shutdown rule must be changed for the VM.
Set-VM -Name $vm -AutomaticStopAction TurnOff

# Change size to fit your requirements ("💡 Min required MMOU Space"). 
# (See https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/plan-for-deploying-devices-using-discrete-device-assignment#mmio-space)
Set-VM -LowMemoryMappedIoSpace 3Gb -VMName $vm # 32bit
Set-VM -HighMemoryMappedIoSpace 6Gb -VMName $vm # 64bit

# Dismount device
Dismount-VMHostAssignableDevice -LocationPath $Location
Dismount-VMHostAssignableDevice -force -LocationPath $Location

Add-VMAssignableDevice -LocationPath $Location -VMName $vm

# Try start the VM in Hyper-V manager.
# ❓ Starting fails with: "A hypervisor feature is not available to the user." ❓
# See: https://social.technet.microsoft.com/Forums/ie/en-US/a7c2940a-af32-4dab-8b31-7a605e8cf075/a-hypervisor-feature-is-not-available-to-the-user?forum=WinServerPreview
# Reboot host.
bcdedit /set hypervisoriommupolicy enable
Restart-Computer -Confirm
