# Released under MIT License

# Copyright (c) 2023 Brandon J. Navarro

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
