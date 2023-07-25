: Released under MIT License

: Copyright (c) 2023 Brandon J. Navarro

: Permission is hereby granted, free of charge, to any person obtaining a copy
: of this software and associated documentation files (the "Software"), to deal
: in the Software without restriction, including without limitation the rights
: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
: copies of the Software, and to permit persons to whom the Software is
: furnished to do so, subject to the following conditions:

: The above copyright notice and this permission notice shall be included in all
: copies or substantial portions of the Software.

: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
: SOFTWARE.

: Version 202307

: .NOTES
:     Name: cmd_LEAVE AZURE AD.cmd
:     Requires: 
:     Major Release History:
:         06/01/2023  - Initial Creation.
:         07/25/2023  - Initial Release.

: .SYNOPSIS
:     None

: .DESCRIPTION
:     None

: .PARAMETER none
:     None

: .INPUTS
:     None

: .OUTPUTS
:     None

: .EXAMPLE
:     None

: Run
DSRegCmd /Status
: you should see AzureAdJoined : YES in the output under Device State section as shown below:
: AzureAdJoined : YES
: EnterpriseJoined : NO
: DomainJoined : NO

: In order to disjoin the machine from Azure AD, you need to run in elevated command window.
DSRegCmd /Leave

: Logout and Log back in to the server and run again to confirm if you are getting AzureAdJoined : NO in the output.
DSRegCmd /Status
