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

# SOURCE: https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/plan-for-deploying-devices-using-discrete-device-assignment#machine-profile-script

# 1. Get Powershell script-helper:
curl.exe -L https://raw.githubusercontent.com/MicrosoftDocs/Virtualization-Documentation/live/hyperv-tools/DiscreteDeviceAssignment/SurveyDDA.ps1 -o C:\Users\Brandon_N\Downloads\SurveyDDA.ps1

# 2. Run the script.
.\SurveyDDA.ps1

# Find your device (must be enabled). See valid example:
#
#
# AMD PSP 3.0 Device                                                <---- 💡 Device name
# Express Endpoint -- more secure.
#    And its interrupts are message-based, assignment can work.
#    And it requires at least: 2 MB of MMIO gap space               <---- 💡 Min required MMOU Space
# PCIROOT(0)#PCI(0701)#PCI(0002)                                    <---- 💡 Location

