<#
Released under MIT License

Copyright (c) 2023 Brandon J. Navarro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

# make sure to install all updates before starting

# enable VirtualMachinePlatform (needed by WSL 2, answer [N] to restart computer)
Enable-WindowsOptionalFeature -online -FeatureName VirtualMachinePlatform
# Do you want to restart the computer to complete this operation now?
# [Y] Yes  [N] No  [?] Help (default is "Y"): N

# install WSL (for question, answer [Y] to restart computer)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
# Do you want to restart the computer to complete this operation now?
# [Y] Yes  [N] No  [?] Help (default is "Y"): Y

# download and add the C++ Runtime framework packages for Desktop
curl.exe -L https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -o Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx

# update WSL and check the version
wsl --update
wsl --status
# Default Version: 2

# check avaliable distributions that can be installed
wsl -l -o
# NAME              FRIENDLY NAME
# Ubuntu-22.04      Ubuntu 22.04 LTS
# OracleLinux_9_1   Oracle Linux 9.1

# install choice of distribution and follow prompts during setup
wsl --install -d Ubuntu-22.04
wsl --install -d OracleLinux_9_1

# check installed distributions
wsl -l -v
#   NAME                                   STATE           VERSION
#`* Ubuntu-22.04                           Running         2
#   docker-desktop-data                    Running         2
#   docker-desktop                         Running         2
#   OracleLinux_9_1                        Stopped         2
#   SUSE-Linux-Enterprise-Server-15-SP4    Stopped         2
#   OracleLinux_8_5                        Stopped         2
