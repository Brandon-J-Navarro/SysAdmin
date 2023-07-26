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

