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

# Version 202307

<#
.NOTES
	Name: TrelloAPI.ps1
	Requires: 
    Major Release History:
        07/11/2023  - Initial Creation.
        07/25/2023  - Initial Release.

.SYNOPSIS
    None

.DESCRIPTION
    None

.PARAMETER none
    None

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    None

#>
#-------------Required Trello Information-------------
$apiKey = "[KEY]"
$apiToken = "[TOKEN]"
$Headers = @{
    "Authorization" = "OAuth oauth_consumer_key=`"$apiKey`", oauth_token=`"$apiToken`""
}
$TrelloURL = 'https://api.trello.com/1/cards/'

#-------------Get Trello Card-------------
$TrelloCardID = '[CARDID]'
$TrelloAttachmentEndpoint = '/attachments'
$URI = $TrelloURL + $TrelloCardID + $TrelloAttachmentEndpoint
$TrelloCard = Invoke-RestMethod -Uri $URI -Method Get -Headers $Headers

#-------------Get Trello Attachment-------------
$Attachement = $TrelloCard | Where { $_.name -eq 'image.png'}
$Download = $Attachement.URL
$TrelloAttachment = Invoke-WebRequest -Uri $Download -OutFile "C:\Users\[USER]\Downloads\image.png" -Headers $Headers

