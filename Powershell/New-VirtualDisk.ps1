# Use this when creating a new virtual disk on Windows Server
# GUI is broken and does not create disk
New-VirtualDisk -StoragePoolFriendlyName "<#StoragePoolName#>" -FriendlyName "<#DiskName#>" -ProvisioningType Fixed -ResiliencySettingName "Parity" -UseMaximumSize
