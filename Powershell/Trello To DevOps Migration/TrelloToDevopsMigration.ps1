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
	Name: TrelloToDevopsMigration.ps1
	Requires: 
    Major Release History:
        06/15/2023  - Initial Creation.
        07/25/2023  - Initial Release.

.SYNOPSIS
    Trello to DevOps Migration

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
#region #-------------Import Trello JSON-------------
$ContentFilePath = "FILE\PATH\TO\TRELLO\DATA"
$objMergeData = @()
Get-ChildItem -Recurse -Depth 1 -Path $ContentFilePath  | Where-Object { $_.name -like '*.json' -and $_.name -NotLike 'manifest.json' } | ForEach-Object { 
    $BoardContent = Get-Content -Path $_ | ConvertFrom-Json

    #-------------Set User Name and User ID Relationship (HASH TABLE)-------------
    $idmember = @{
        '[MEMBERID1]' = '[NAME1]'
        '[MEMBERID2]' = '[NAME2]'
    }

    #-------------Set Label Name and Lable ID Relationship-------------
    $idlabels = @{}
    $idlabels = $BoardContent.labels | Select-Object Id, Name

    #-------------Set List Name and List ID Relationship-------------
    $idlists = @{}
    $idlists = $BoardContent.lists | Select-Object Id, Name

    #-------------Get Board Action Data-------------
    $objActionsContent = [System.Collections.Generic.List[PSCustomObject]]::new()
    $BoardContent | ForEach-Object {
        $BoardContent.Actions | ForEach-Object {
            $comment = $_.data.text
            $commenter = $_.memberCreator.fullname
            if ([string]::IsNullOrWhiteSpace($comment)) {
                $comment = $null
            }
            else {
                if (![string]::IsNullOrWhiteSpace($commenter)) {
                    $comment += " - $commenter"
                }
                elseif (![string]::IsNullOrWhiteSpace($_.idMemberCreator)) {
                    $initial = $idmember[$_.idMemberCreator]
                    if (![string]::IsNullOrWhiteSpace($initial)) {
                        $comment += " - $initial"
                    }
                }
            }
            $objActionsContent.add([PSCustomObject]@{
                'BoardName'        = $_.data.board.name
                'CardID'           = $_.data.card.id
                'ShortHandID'      = $_.data.card.idshort
                'CardName'         = $_.data.card.name
                'CardDescription'  = $_.data.card.desc
                'Comment'          = $comment
                'AttachmentName'   = $_.data.attachment.name
                'AttachmentURL'    = $_.data.attachment.url
                'CardURL'          = $_.data.card.url
                'CardStatus'       = $_.data.list.name
                'CardLastActivity' = $_.date
                'Checklists'       = $null
                'CardList'         = $null
                'CardMembers'      = $null
                'CardLabels'       = $null
                'Attachments'      = $null
                'BoardId'          = $BoardContent.id
                'BoardURL'         = $BoardContent.url
                'BoardShortURL'    = $BoardContent.shorturl
            })
        }
    }

    #-------------Get Board Card Data-------------
    $objCardsContent = [System.Collections.Generic.List[PSCustomObject]]::new()
    $BoardContent | ForEach-Object {
        $board = $_
        $BoardName = $board.name
        $Boardid = $board.id
        $Boardurl = $board.url
        $Boardshorturl = $board.shorturl
        $_.Cards | ForEach-Object {
            $card = $_
            $checklists = $card.Checklists
            $attachments = [System.Collections.Generic.List[PSCustomObject]]::new()
            $card.attachments | ForEach-Object {
                $currentAttachment = $_
                $attachments.add([PSCustomObject]@{
                    'Date'     = $currentAttachment.date
                    'MimeType' = $currentAttachment.mimetype
                    'Name'     = $currentAttachment.name
                    'URL'      = $currentAttachment.url
                    'FileName' = $currentAttachment.filename
                    'ID'       = $currentAttachment.id
                })
            }
            $objChecklists = [System.Collections.Generic.List[PSCustomObject]]::new()
            $checklists | ForEach-Object {
                $list = $_
                $Checkitem = $list.Checkitems
                $objListItems = [System.Collections.Generic.List[PSCustomObject]]::new()
                $Checkitem | ForEach-Object {
                    $item = $_
                    $Member = $idmember | Where-Object { $item -Contains $_.id } | Select-Object values
                    if ($item.name -split " " -replace '^(https://trello\.com/c/\w{8}).*$', '$1' | Where-Object { $_ -match '^(https://trello\.com/c/\w{8})' }) {
                        $childtask = $true
                    }
                    else {
                        $childtask = $false
                    }
                    $objListItems.add([PSCustomObject]@{
                        'ID'          = $item.id
                        'Name'        = $item.name
                        'State'       = $item.state
                        'Member'      = $Member.values
                        'Checklist'   = $item.idchecklist
                        'IsChildTask' = [bool]$childtask
                    })
                }
                $objChecklists.add([PSCustomObject]@{
                    'ID'             = $list.id
                    'Name'           = $list.name
                    'ChecklistItems' = $objListItems
                })
            }
            $list = $idlists | Where-Object { $card.idlist -contains $_.id } | Select-Object Name
            $label = $idlabels | Where-Object { $card.idlabels -contains $_.id } | Select-Object Name
            $Member = $idmember[$card.idMembers]
            $objCardsContent.Add([PSCustomObject]@{
                'BoardName'        = $BoardContent.name
                'BoardId'          = $BoardContent.id
                'BoardURL'         = $BoardContent.url
                'BoardShortURL'    = $BoardContent.shorturl
                'CardID'           = $card.id
                'CardDescription'  = $card.desc
                'Checklists'       = $objChecklists
                'CardList'         = $list.name
                'CardMembers'      = $Member
                'ShortHandID'      = $card.idshort
                'CardLabels'       = $label.name
                'CardName'         = $card.name
                'CardURL'          = $card.url
                'CardLastActivity' = $card.datelastactivity
                'Attachments'      = $attachments
                'Comment'          = $null
                'AttachmentName'   = $null
                'AttachmentURL'    = $null
                'CardStatus'       = $null
            })
        }
    }

    #-------------Combine Board Action and Card Data-------------
    $objMergeData += $objCardsContent
    $objMergeData += $objActionsContent
}
#endregion

#region #-------------Merge Board Action and Card Data-------------
$TrelloData = [System.Collections.Generic.List[PSCustomObject]]::new()
$objMergeData | Sort-Object CardLastActivity -Descending  | Group-Object -Property CardID | ForEach-Object {
    $Url = ($_.Group.CardURL | Where-Object { $_ -ne $null }) -join [Environment]::NewLine
    $UrlShort = ($Url | Where-Object { $_ -ne $null }) -replace '^(https://trello\.com/c/\w{8}).*$', '$1'
    $AttchedCardURL = ($_.Group.AttachmentURL | Where-Object { $_ -ne $null -and $_ -match '^(https://trello\.com/c/\w{8}).*$' } | Sort-Object | Get-Unique) -replace '^(https://trello\.com/c/\w{8}).*$', '$1'
    $AttchedCardName = ($_.Group.AttachmentName | Where-Object { $_ -ne $null -and $_ -match '^(https://trello\.com/c/\w{8}).*$' } | Sort-Object | Get-Unique) -replace '^(https://trello\.com/c/\w{8}).*$', '$1'
    $attachment = ($_.Group.AttachmentName | Where-Object { $_ -ne $null } | Sort-Object | Get-Unique) -replace ' ', '_'
    $TrelloData.add([PSCustomObject]@{
        'BoardName'        = $_.Group[0].BoardName
        'BoardId'          = $_.Group[0].BoardId
        'BoardURL'         = $_.Group[0].BoardURL
        'BoardShortURL'    = $_.Group[0].BoardShortURL
        'CardID'           = $_.Group[0].CardID
        'ShortHandID'      = $_.Group[0].ShortHandID
        'CardName'         = $_.Group[0].CardName
        'CardDescription'  = ($_.Group[0].CardDescription | Where-Object { $_ -ne $null }) -join [Environment]::NewLine
        'Comment'          = ($_.Group.Comment | Where-Object { $_ -ne $null } | Sort-Object | Get-Unique)
        'AttachmentName'   = $attachment
        'AttachmentURL'    = ($_.Group.AttachmentURL | Where-Object { $_ -ne $null } | Sort-Object | Get-Unique)
        'CardURL'          = ($_.Group.CardURL | Where-Object { $_ -ne $null }) -join [Environment]::NewLine
        'CardStatus'       = $_.Group.CardStatus | Select-Object -First 1
        'CardLastActivity' = $_.Group[0].CardLastActivity
        'Checklists'       = ($_.Group.Checklists | Where-Object { $_ -ne $null })
        'CardList'         = ($_.Group.CardList | Where-Object { $_ -ne $null } | Sort-Object | Get-Unique)
        'CardMembers'      = ($_.Group.CardMembers | Where-Object { $_ -ne $null } | Sort-Object | Get-Unique)
        'CardLabels'       = ($_.Group.CardLabels | Where-Object { $_ -ne $null } | Sort-Object | Get-Unique)
        'Attachments'      = ($_.Group.Attachments | Where-Object { $_ -ne $null } )
        'CardShortURL'     = $UrlShort
        'RelatedCardURL'   = $AttchedCardURL
        'RelatedCardName'  = $AttchedCardName
    })
}
$TrelloData.count
#endregion

#region #-------------Get Trello Card that are Blank-------------
$BlankCard = @()
$TrelloData | Where-Object { $_.CardName -eq $null -or $_.CardURL -eq '' -or  $_.CardId -eq $null} | ForEach-Object {
    $CurrentTrelloCard = $_
    $BlankCard += $CurrentTrelloCard
}
$BlankCard.count
if($BlankCard){
    $NonBlankCards = $TrelloData | Where-Object { $_.CardName -ne $null -and $_.CardURL -ne '' -and  $_.CardId -ne $null}
}
$NonBlankCards.count
#endregion

#region #-------------Get Parent(Card)/Child(ChildTask) in Checklists 1st Level-------------
$MatchURLArray = @()
$MatchIDArray = @()
$ChildCardLevel1 = [System.Collections.Generic.List[PSCustomObject]]::new()
$NonBlankCards | ForEach-Object {
    $CurrentCard = $_
    $checklist = $_.checklists
    $checklist | ForEach-Object {
        $checklistitems = $_.checklistitems
        $checklistitems | ForEach-Object { 
            $IsChild = $_ | where { $_.IsChildTask -eq $true}
            $NameSplit = $IsChild.name -split " "
            $ShortenUrl = $NameSplit -replace '^(https://trello\.com/c/\w{8}).*$', '$1'
            $MatchUrl = $ShortenUrl | Where-Object { $_ -match '^(https://trello\.com/c/\w{8})' }
            $Child = $NonBlankCards | Where-Object { $MatchUrl -eq $_.CardShortURL }
            if ($Child) {
                $MatchURLArray += $MatchUrl
                $MatchIDArray += $Child.Cardid
                $ChildCardLevel1.add([PSCustomObject]@{
                    'ChildCard'  = $Child
                    'ParentCard' = $CurrentCard
                })
            }
        }
    }
}
$ChildCardLevel1.Count
#endregion

#region #-------------Get Parent(ChildTask)/Child(Task) in Checklists 2nd Level-------------
$ChildCardLevel2 = [System.Collections.Generic.List[PSCustomObject]]::new()
$ChildCardLevel1.childcard | ForEach-Object {
    $CurrentCard = $_
    $checklist = $_.checklists
    $checklist | ForEach-Object {
        $checklistitems = $_.checklistitems
        $checklistitems | ForEach-Object { 
            $IsChild = $_ | where { $_.IsChildTask -eq $true}
            $NameSplit = $IsChild.name -split " "
            $ShortenUrl = $NameSplit -replace '^(https://trello\.com/c/\w{8}).*$', '$1'
            $MatchUrl = $ShortenUrl | Where-Object { $_ -match '^(https://trello\.com/c/\w{8})' }
            $Child = $NonBlankCards | Where-Object { $MatchUrl -eq $_.CardShortURL }
            if ($Child) {
                $MatchURLArray += $MatchUrl
                $MatchIDArray += $Child.Cardid
                $ChildCardLevel2.add([PSCustomObject]@{
                    'ChildCard'  = $Child
                    'ParentCard' = $CurrentCard
                })
            }
        }
    }
}
$ChildCardLevel2.Count
#endregion

#region #-------------Get Parent(Task)/Child(Task) in Checklists 3rd Level-------------
$ChildCardLevel3 = [System.Collections.Generic.List[PSCustomObject]]::new()
$ChildCardLevel2.childcard | ForEach-Object {
    $CurrentCard = $_
    $checklist = $_.checklists
    $checklist | ForEach-Object {
        $checklistitems = $_.checklistitems
        $checklistitems | ForEach-Object { 
            $IsChild = $_ | where { $_.IsChildTask -eq $true}
            $NameSplit = $IsChild.name -split " "
            $ShortenUrl = $NameSplit -replace '^(https://trello\.com/c/\w{8}).*$', '$1'
            $MatchUrl = $ShortenUrl | Where-Object { $_ -match '^(https://trello\.com/c/\w{8})' }
            $Child = $NonBlankCards | Where-Object { $MatchUrl -eq $_.CardShortURL }
            if ($Child) {
                $MatchURLArray += $MatchUrl
                $MatchIDArray += $Child.Cardid
                $ChildCardLevel3.add([PSCustomObject]@{
                    'ChildCard'  = $Child
                    'ParentCard' = $CurrentCard
                })
            }
        }
    }
}
$ChildCardLevel3.Count
#endregion

#region #-------------Child ID/URL Array-------------
$MatchId = $MatchIDArray | Sort-Object -Unique
$MatchId.count

$MatchURL = $MatchURLArray | Sort-Object -Unique
$MatchURL.count
#endregion

#region #-------------Related Child Card-------------
$RelatedTrelloCards = [System.Collections.Generic.List[PSCustomObject]]::new()
$NonBlankCards | ForEach-Object {
    $CurrentCard = $_
    $AttachmentURL = $_.AttachmentURL
    $AttachmentURL -replace '^(https://trello\.com/c/\w{8}).*$', '$1' | Where-Object { $_ -match '^https://trello\.com/c/\w{8}$' } | ForEach-Object {
        $MatchUrl = $_
        $RelatedCard = $NonBlankCards | Where-Object { $MatchUrl -contains $_.cardshorturl }
        if ($RelatedCard) {
            $RelatedTrelloCards.add([PSCustomObject]@{
                'CurrentCard' = $CurrentCard
                'RelatedCard' = $RelatedCard
            })
        }
    }
}
$NonBlankCards | ForEach-Object {
    $CurrentCard = $_
    $Comment = $_.Comment
    $Comment = $Comment -replace "`n", ' ' -replace "`r", ' ' -split ' '
    $Comment -replace '^(https://trello\.com/c/\w{8}).*$', '$1' | Where-Object { $_ -match '^https://trello\.com/c/\w{8}$' } | ForEach-Object {
        $MatchUrl = $_
        $CommentCard = $NonBlankCards | Where-Object { $MatchUrl -eq $_.CardShortURL }
        if ($CommentCard) {
            $RelatedTrelloCards.add([PSCustomObject]@{
                'CurrentCard' = $CurrentCard
                'RelatedCard' = $CommentCard
            })
        }
    }
}
$NonBlankCards | ForEach-Object {
    $CurrentCard = $_
    $Description = $_.CardDescription
    $Description = $Description -replace "`n", ' ' -replace "`r", ' ' -split ' '
    $Description -replace '^(https://trello\.com/c/\w{8}).*$', '$1' | Where-Object { $_ -match '^https://trello\.com/c/\w{8}$' } | ForEach-Object {
        $MatchUrl = $_
        $DescriptionCard = $NonBlankCards | Where-Object { $MatchUrl -eq $_.CardShortURL }
        if ($DescriptionCard) {
            $RelatedTrelloCards.add([PSCustomObject]@{
                'CurrentCard' = $CurrentCard
                'RelatedCard' = $DescriptionCard
            })
        }
    }
}
$RelatedTrelloCards.count
#endregion

#region #-------------Get image.png-------------
$ImagePNGCard = [System.Collections.Generic.List[PSCustomObject]]::new()
$NonBlankCards | ForEach-Object {
    $CurrentCard = $_
    $Match = $_.attachments.FileName | Where-Object { $_ -EQ 'image.png' }
    if ($Match) {
        $ImagePNGCard.add([PSCustomObject]@{
            'Card' = $CurrentCard
        })
    }
}
#endregion

#region #-------------Get Board Data-------------
$objBoardContent = [System.Collections.Generic.List[PSCustomObject]]::new()
$TrelloData | ForEach-Object { 
    $board = $_
    $objBoardContent.add([PSCustomObject]@{
        'BoardName' = $board.name
        'Boardid'   = $board.id
    })
}
#endregion

#region #-------------Set Attachment file path and Board ID Relationship (HASH TABLE)-------------
$idboard = @{
    '[BOARDID1]' = $ContentFilePath + '[BOARDNAME1]\attachments'
    '[BOARDID2]' = $ContentFilePath + '[BOARDNAME2]\attachments'
}
#endregion

#region #-------------Required Trello Information-------------
$orgURL = 'https://[ORGNIZATION].[DEVOPSURL].com/[COLLECTION]/'
$PersonalToken = '[APITOKEN]'
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PersonalToken)"))
$Header = @{authorization = "Basic $Token" }

#-------------Get Projects-------------
$Projects = $orgURL + '_apis/projects?api-version=7.0'
$GetProjects = Invoke-RestMethod -Uri $Projects -Method GET -ContentType 'application/json' -Headers $Header
$Project = $GetProjects.value | Where-Object name -EQ '[PROJECT NAME]' | Select-Object name
#endregion

#region #-------------Create Area(Boards)-------------
$SystemAreaPath = $NonBlankCards.BoardName | Sort-Object | Get-Unique
$SystemAreaPath | ForEach-Object {
    $BoardName = $_
    $Body = @{'name' = $BoardName ; 'path' = "\\$BoardName" }
    $Body = $Body | ConvertTo-Json -Depth 100
    $CreateArea = $orgURL + $Project.name + '/_apis/wit/classificationnodes/areas?api-version=7.0'
    $Area = Invoke-RestMethod -Uri $CreateArea -Body $body -Method POST -ContentType 'application/json' -Headers $Header
    Write-Output ("Creating Area: {0}" -f $BoardName)
}

#-------------Create Child Area(Lists)-------------
$NonBlankCards | Where-Object { $_.Cardlist -ne $null } | ForEach-Object {
    $ProjectArea = '\[Project Name]'
    $BoardName = $_.BoardName
    $ListName = ($_.Cardlist -replace '/' , '-' -replace ':' , '-' -replace '&' , 'and' -replace "\?" , 'X'  -replace "\+" , 'and' -replace "\#" , 'NUM')

    $Board = $GetArea.children | Where-Object { $_.name -eq $BoardName }
    $BoardId = $Board.id
    $path = $ProjectArea + '\Area\' + $BoardName + '\' + $ListName
    
    $Areas = $orgURL + $Project.name + '/_apis/wit/classificationnodes/areas?api-version=7.0&$depth=2'
    $GetArea = Invoke-RestMethod -Uri $Areas -Headers $header -Method Get

    if ($GetArea.children.children.path -notcontains $path) {
        $Body = @{name = $ListName ; structureType = 'area' ; path = "$ProjectArea\\$BoardName\\$ListName" ; parentId = $BoardId }
        $Body = $Body | ConvertTo-Json -Depth 100
        $CreateChildArea = $orgURL + $Project.name + '/_apis/wit/classificationnodes/areas/' + $BoardName + '?api-version=7.0'
        $ChildArea = Invoke-RestMethod -Uri $CreateChildArea -Body $body -Method POST -ContentType 'application/json' -Headers $Header
        Write-Output ("Creating SubArea: {0}\{1}" -f $BoardName,$ListName)
    }
}
#endregion 

#region #-------------Start Post-------------
# Saves current foreground color to $OriginalForeground
$OriginalForeground = $host.ui.RawUI.ForegroundColor
$ErrorObjects = @()
$Imported = [System.Collections.Generic.List[PSCustomObject]]::new()
$Errors = [System.Collections.Generic.List[PSCustomObject]]::new()
$NonBlankCards | Where-Object { $MatchId -notcontains $_.CardID} | Where-Object { $Imported.Trello.CardID -notcontains $_.CardID} | ForEach-Object {
    #region #-------------Assign Variables-------------
    $objCardName = $_.CardName
    $host.ui.RawUI.ForegroundColor = "Green"
    Write-Output ("{0}: is Not a Child" -f $objCardName)
    Write-Output ("Imported Count: {0}" -f $Imported.count)
    $CurrentTrelloCard = $_
    $objHasChild = @()
    $objCard = $_
    $objBoardName = $_.BoardName | Sort-Object | Get-Unique
    $objBoardId = $_.BoardId | Sort-Object | Get-Unique
    $objBoardLongUrl = $_.BoardURL | Sort-Object | Get-Unique
    $objBoardShortUrl = $_.BoardShortURL
    $objBoardList = ($_.Cardlist -replace '/' , '-' -replace ':' , '-' -replace '&' , 'and' -replace "\?" , 'X'  -replace "\+" , 'and' -replace "\#" , 'NUM')
    $objCardLongId = $_.CardID
    $objCardShortId = $_.ShortHandID
    $objCardName = $_.CardName
    $objCardDescription = $_.CardDescription -replace "`n", '<br>' -replace "`r", '<br>' -replace '    ' , '&emsp;' -replace "`”", '"' -replace "`“", '"'
    $objCardComment = $_.Comment
    $objCardAttachment = $_.AttachmentName -replace '^(https://trello\.com/c/\w{8}).*$', '$1'
    $objCardAttachedCard = $null
    $objCardAttachedCard = $NonBlankCards | Where-Object { $objCardAttachment -contains $_.CardShortURL }
    $objCardAttachmentUrl = $null
    $_.AttachmentURL | ForEach-Object { $objCardAttachmentUrl += '<li>' + $_ + '</li>' }
    $objCardMembers = $null
    $_.CardMembers | ForEach-Object { $objCardMembers += '<li>' + $_ + '</li>' }
    $objCardLongUrl = $_.CardURL
    $objCardStatus = $_.CardStatus
    $objCardLastActivity = $_.CardLastActivity
    $objCardChecklists = $_.Checklists
    $objCardLabels = $_.CardLabels | Where-Object { $_ -ne $null -and $_ -ne '' }
    $objAttachments = $_.Attachments
    $objCardShortUrl = $_.CardShortURL
    $objAttachedShortUrl = $_.AttachedShortURL
    $objAttachedName = $_.AttachedName
    $objCardHasChild = if ($_ | Where-Object { $objCardChecklists.checklistitems.name -Contains $_.CardShortURL }) { $true }else { $false }
    $objCardHasAttachedCard = if ($_ | Where-Object { $objCardAttachment -Contains $_.CardShortURL }) { $true }else { $false }
    #endregion

    #-------------Create Cards-------------
    $Create = New-Object System.Collections.ArrayList
    $CreateBody = New-Object System.Collections.ArrayList

    #region #-------------Assign Variables to objects-------------
    $host.ui.RawUI.ForegroundColor = "Blue"
    $SystemTitleData = $null
    $SystemTitleData = @{ 'op' = 'add'; 'path' = '/fields/System.Title'; 'from' = 'null'; 'value' = $objCardName }
    [void]$Create.add($SystemTitleData)
    Write-Output ("Creating System.Title: {0}" -f $objCardName)

    $SystemAreaPathData = $null
    $SystemAreaPathData = @{ 'op' = 'add'; 'path' = '/fields/System.AreaPath'; 'value' = "\\[Project Name]\\$objBoardName\\$objBoardList" }
    [void]$Create.add($SystemAreaPathData)
    Write-Output ("Creating System.AreaPath: \\[Project Name]\\{0}\\{1}" -f $objBoardName,$objBoardList)

    $CardDescriptionData = $null
    if ($objCardDescription ) { $CardDescriptionData = @{'op' = 'add'; 'path' = '/fields/Custom.CardDescription'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objCardDescription</body>" } }
    if ($CardDescriptionData ) { 
        [void]$Create.add($CardDescriptionData) 
        Write-Output ("Createing Custom.CardDescription")
    }

    $BoardData = $null
    $BoardData = @{ 'op' = 'add'; 'path' = '/fields/Custom.Board'; 'from' = 'null'; 'value' = $objBoardName }
    [void]$Create.add($BoardData)
    Write-Output ("Creating Custom.Board: {0}" -f $objBoardName)

    $BoardListData = $null
    $BoardListData = @{ 'op' = 'add'; 'path' = '/fields/Custom.BoardList'; 'from' = 'null'; 'value' = $objBoardList }
    [void]$Create.add($BoardListData)
    Write-Output ("Creating Custom.BoardList: {0}" -f $objBoardList)

    $CardIDData = $null
    $CardIDData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardID'; 'from' = 'null'; 'value' = "$objCardShortId" }
    [void]$Create.add($CardIDData)
    Write-Output ("Creating Custom.CardID: {0}" -f $objCardShortId)
    
    $CardSNData = $null
    $CardSNData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardSN'; 'from' = 'null'; 'value' = $objCardLongId }
    [void]$Create.add($CardSNData)
    Write-Output ("Creating Custom.CardSN: {0}" -f $objCardLongId)

    $CardStatusData = $null
    if ($objCardStatus ) { $CardStatusData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardStatus'; 'from' = 'null'; 'value' = $objCardStatus } }
    if ($CardStatusData ) { 
        [void]$Create.add($CardStatusData) 
        Write-Output ("Creating Custom.CardStatus: {0}" -f $objCardStatus)
    }

    $CardURLData = $null
    $CardURLData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardURL'; 'from' = 'null'; 'value' = $objCardLongUrl }
    [void]$Create.add($CardURLData)
    Write-Output ("Creating Custom.CardURLs: {0}" -f $objCardLongUrl)

    $CardMemberData = $null
    $CardMemberData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardMember'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objCardMembers</body>" }
    [void]$Create.add($CardMemberData)
    Write-Output ("Creating Custom.CardMember")
    
    $AttachmentNameData = $null
    $objCardAttachedCardName = $null
    if ($objCardAttachedCard) {
        $objCardAttachedCard | ForEach-Object {
            $CardAttachedCardURL = $_.cardshorturl
            $CardAttachedCardName = $_.CardName
            $objCardAttachedCardName += '<li>' + $CardAttachedCardName + ' (' + $CardAttachedCardURL + ')' + '</li>' 
        }
    }
    $objCardAttachmentName = $null
    $objCardAttachment | Where-Object {$_ -notmatch '^https://trello\.com/c/\w{8}$'} | Where-Object {$_ -ne 'image.png'} | ForEach-Object { $objCardAttachmentName += '<li>' + $_ + '</li>' }
    $objCardAttachedCardName += $objCardAttachmentName
    $AttachmentNameData = @{ 'op' = 'add'; 'path' = '/fields/Custom.AttachmentName'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objCardAttachedCardName</body>" }
    [void]$Create.add($AttachmentNameData)
    Write-Output ("Creating Custom.AttachmentName")

    $AttachmentURLData = $null
    $AttachmentURLData = @{ 'op' = 'add'; 'path' = '/fields/Custom.AttachmentURL'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objCardAttachmentUrl</body>" }
    [void]$Create.add($AttachmentURLData)
    Write-Output ("Creating Custom.AttachmentURL")

    $HasChildTasksData = $null
    $HasChildTasksData = @{ 'op' = 'add'; 'path' = '/fields/Custom.HasChildTasks'; 'from' = 'null'; 'value' = $objCardHasChild }
    [void]$Create.add($HasChildTasksData)
    Write-Output ("Creating Custom.HasChildTasks: {0}" -f $objCardHasChild)

    $HasAttachedCardsData = $null
    $HasAttachedCardsData = @{ 'op' = 'add'; 'path' = '/fields/Custom.HasAttachedCards'; 'from' = 'null'; 'value' = $objCardHasAttachedCard }
    [void]$Create.add($HasAttachedCardsData)
    Write-Output ("Creating Custom.HasAttachedCards: {0}" -f $objCardHasAttachedCard)

    $LastActivityDateData = $null
    $LastActivityDateData = @{ 'op' = 'add'; 'path' = '/fields/Custom.LastActivityDate'; 'from' = 'null'; 'value' = $objCardLastActivity }
    [void]$Create.add($LastActivityDateData)
    Write-Output ("Creating Custom.LastActivityDate: {0}" -f $objCardLastActivity)
    #endregion

    #region #-------------Assign objects to array-------------
    [void]$CreateBody.add($Create)

    #-------------Format array to JSON-------------
    $Body = $CreateBody | ConvertTo-Json -Depth 100

    # #-------------Create Card With Trello Data-------------
    $CreateCard = $orgURL + $Project.name + '/_apis/wit/workitems/$Card?api-version=7.0'
    $PostCard = Invoke-RestMethod -Uri $CreateCard -Body $Body -Method POST -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
    #endregion

    #-------------Capture the error object-------------
    if ($ErrorObjects) {
        $host.ui.RawUI.ForegroundColor = "Red"
        Write-Output ("{0}: Has Errors Posting" -f $objCardName)
        $Errors.add([PSCustomObject]@{
            'Message' = $ErrorObjects
            'Card'    = $CurrentTrelloCard
        })
    }else{
        $host.ui.RawUI.ForegroundColor = "Green"
        Write-Output ("{0}: Posted" -f $objCardName)
        #region #-------------Update Card-------------
        $host.ui.RawUI.ForegroundColor = "Blue"
        #-------------Post Tags-------------
        if ($objCardLabels) {
            Write-Output ("Updating Tags on: {0}" -f $objCardName)
            foreach ($CardLabels in $objCardLabels) {
                $CreateBody = New-Object System.Collections.ArrayList
                $Create = New-Object System.Collections.ArrayList 
                #-------------Assign Variables to objects-------------
                $CardLabelsData = @{ 'op' = 'add'; 'path' = '/fields/System.Tags'; 'from' = 'null'; 'value' = $CardLabels }
                [void]$Create.add($CardLabelsData)
                #-------------Assign objects to array-------------
                [void]$CreateBody.add($Create)
                #-------------Format array to JSON-------------
                $Body = $CreateBody | ConvertTo-Json -Depth 100
                #-------------Update PBI With Trello Labels-------------
                $PostCardId = $PostCard.id
                $UpdateCardId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostCardId + '?api-version=7.0'
                $UpdateCard = Invoke-RestMethod -Uri $UpdateCardId -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                #-------------Capture the error object-------------
                if ($ErrorObjects) {
                    $host.ui.RawUI.ForegroundColor = "Red"
                    Write-Output ("{0}: Has Errors Posting" -f $objCardName)
                    $Errors.add([PSCustomObject]@{
                        'Message' = $ErrorObjects
                        'Card'    = $CurrentTrelloCard
                    })
                }
            }
        }

        #-------------Post Comments-------------
        if ($objCardComment) { 
            Write-Output ("Updating Comments on: {0}" -f $objCardName)
            foreach ($CardComment in $objCardComment) {
                $CreateBody = New-Object System.Collections.ArrayList
                $Create = New-Object System.Collections.ArrayList
                $CardComment = $CardComment -replace "`n", '<br>' -replace "`r", '<br>' -replace '    ' , '&emsp;'
                #-------------Assign Variables to objects-------------
                $CommentData = @{'op' = 'add'; 'path' = '/fields/System.History'; 'from' = 'null'; 'value' = $CardComment }
                [void]$Create.add($CommentData)
                #-------------Assign objects to array-------------
                [void]$CreateBody.add($Create)
                #-------------Format array to JSON-------------
                $Body = $CreateBody | ConvertTo-Json -Depth 100
                #-------------Update PBI With Trello Comments-------------
                $PostCardId = $PostCard.id
                $UpdateCardId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostCardId + '?api-version=7.0'
                $UpdateCard = Invoke-RestMethod -Uri $UpdateCardId -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                #-------------Capture the error object-------------
                if ($ErrorObjects) {
                    $host.ui.RawUI.ForegroundColor = "Red"
                    Write-Output ("{0}: Has Errors Posting" -f $objCardName)
                    $Errors.add([PSCustomObject]@{
                        'Message' = $ErrorObjects
                        'Card'    = $CurrentTrelloCard
                    })
                }
            }
        }

        #-------------Post Checklists-------------
        if ($objCardChecklists) {
            Write-Output ("Updating Checklists on: {0}" -f $objCardName)
            $CardChecklistGroup = @()
            $CreateBody = New-Object System.Collections.ArrayList
            $Create = New-Object System.Collections.ArrayList 
            $objCardChecklists | ForEach-Object {
                $CardChecklist = $_
                $CardChecklistName = $CardChecklist.name
                $objChecklistItem = @()
                $CardChecklist.checklistitems | ForEach-Object {
                    $ChecklistItem = $_
                    $name = $ChecklistItem.name
                    $ChildTaskItem = $NonBlankCards | Where-Object { $name -contains $_.CardShortURL } | Select-Object CardName
                    if ($ChildTaskItem) {
                        if ($ChecklistItem.state -eq 'complete') {
                            $objChecklistItem += '<li>' + '<s>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChildTaskItem.CardName + '</b>' + ' (' + '<i>' + $ChecklistItem.name + '</i>' + ')' + '</s>' + '</li>'
                        }
                        else {
                            $objChecklistItem += '<li>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChildTaskItem.CardName + '</b>' + ' (' + '<i>' + $ChecklistItem.name + '</i>' + ')' + '</li>'
                        }
                    }
                    else {
                        if ($ChecklistItem.state -eq 'complete') {
                            $objChecklistItem += '<li>' + '<s>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChecklistItem.name + '</b>' + '</s>' + '</li>'
                        }
                        else {
                            $objChecklistItem += '<li>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChecklistItem.name + '</b>' + '</li>'
                        }
                    }
                }
                $CardChecklistGroup += '<h3>' + $CardChecklistName + '</h3>' + $objChecklistItem
            }
            $CheckListData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CheckList'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body> <ul> $CardChecklistGroup </ul> </body>" }
            [void]$Create.add($CheckListData)
            #-------------Assign objects to array-------------
            [void]$CreateBody.add($Create)
            #-------------Format array to JSON-------------
            $Body = $CreateBody | ConvertTo-Json -Depth 100
            #-------------Update PBI With Trello Comments-------------
            $PostCardId = $PostCard.id
            $UpdateCardId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostCardId + '?api-version=7.0'
            $UpdateCard = Invoke-RestMethod -Uri $UpdateCardId -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
            #-------------Capture the error object-------------
            if ($ErrorObjects) {
                $host.ui.RawUI.ForegroundColor = "Red"
                Write-Output ("{0}: Has Errors Posting" -f $objCardName)
                $Errors.add([PSCustomObject]@{
                    'Message' = $ErrorObjects
                    'Card'    = $CurrentTrelloCard
                })
            }
        }

        #-------------Post Attachments-------------
        if ($objCardAttachment) {
            Write-Output ("Uploading Attachments on: {0}" -f $objCardName)
            foreach ($CardAttachment in $objCardAttachment | Where-Object { $_ -ne 'image.png' }) {
                $Attchment = $CardAttachment
                $Rename = $Attchment.Replace('.', '').replace( '-', '')
                $CreateBody = New-Object System.Collections.ArrayList
                $Create = New-Object System.Collections.ArrayList 
                $objAttachmentFilePath  = $idboard[$objBoardId]
                $objAttachment = Get-ChildItem -Path $objAttachmentFilePath
                $WorkItemId = $PostCard.id
                $objAttachmentFilePath = $objAttachment | Where-Object { $Rename -Contains ($_.name.Replace('.', '').replace( '-', '')) }
                if ($objAttachmentFilePath) {
                    $FileName = $objAttachmentFilePath.name
                    $File = $objAttachmentFilePath.FullName
                    $FileUploadUrl = $orgURL + $Project.name + '/_apis/wit/attachments?fileName=' + $FileName + '&api-version=5.0'
                    $Body = [System.IO.File]::ReadAllBytes("$File")
                    $UploadAttachment = Invoke-RestMethod -Uri $FileUploadUrl -Body $Body -Method Post -ContentType 'application/json' -Headers $Header
                    $objCardAttachmentUrl = $UploadAttachment.url
                    $UpdateCardId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $WorkItemId + '?api-version=5.0'
                    $Body = "[{`"op`": `"add`",`"path`": `"/relations/-`",`"value`": {`"rel`": `"AttachedFile`",`"url`": `"$objCardAttachmentUrl`", `"attributes`": {`"comment`": `"Attachment for the specified work item`"}}}]"
                    $UpdateCard = Invoke-RestMethod -Uri $UpdateCardId -Body $Body -Method Patch -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                    #-------------Capture the error object-------------
                    if ($ErrorObjects) {
                        $host.ui.RawUI.ForegroundColor = "Red"
                        Write-Output ("{0}: Has Errors Posting" -f $objCardName)
                        $Errors.add([PSCustomObject]@{
                            'Message' = $ErrorObjects
                            'Card'    = $CurrentTrelloCard
                        })
                    }
                }
            }
        }
        #-------------Add to Imported Object-------------
        $Imported.add([PSCustomObject]@{
            'Trello' = $CurrentTrelloCard
            'DevOps' = $PostCard
        })
        #endregion

        #-------------Create Child-------------
        if ($ChildCardLevel1.ParentCard.cardid -contains $objCardLongId) {
            $host.ui.RawUI.ForegroundColor = "Yellow"
            Write-Output ("{0} is parent" -f $objCardName)
            $objchecklisturlmartch = $objCardChecklists.checklistitems.Name -split " " -replace '^(https://trello\.com/c/\w{8}).*$', '$1' | Where-Object { $_ -match '^(https://trello\.com/c/\w{8})' }
            $objHasChild += $NonBlankCards | Where-Object { $Imported.Trello.CardID -notcontains $_.CardID} | Where-Object { $objchecklisturlmartch -contains $_.cardshorturl }
            # $Item = $objCardDescription -replace "`n", ' ' -replace "`r", ' '-replace "\*", ' ' -replace '<br>', ' '-split ' '
            # $Item -replace '^(https://trello\.com/c/\w{8}).*$', '$1' | Where-Object { $_ -match '^https://trello\.com/c/\w{8}$' }| ForEach-Object {
            #     $MatchUrl = $_
            #     $objHasChild += $NonBlankCards | Where-Object { $MatchUrl -eq $_.CardShortURL }
            # }
        }
        if ($objHasChild) {
            $objHasChild | ForEach-Object { 
                $objChildCardName = $_.CardName
                $host.ui.RawUI.ForegroundColor = "Yellow"
                Write-Output ("{0} is Child" -f $objChildCardName)
                #region #-------------Assign Variables to objects-------------
                $objHasTask = @()
                $objChild = $_
                $objChildBoardName = $_.BoardName | Sort-Object | Get-Unique
                $objChildBoardId = $_.BoardId | Sort-Object | Get-Unique
                $objChildBoardLongUrl = $_.BoardURL | Sort-Object | Get-Unique
                $objChildBoardShortUrl = $_.BoardShortURL
                $objChildBoardList = ($_.Cardlist -replace '/' , '-' -replace ':' , '-' -replace '&' , 'and' -replace "\?" , 'X'  -replace "\+" , 'and' -replace "\#" , 'NUM')
                $objChildCardLongId = $_.CardID
                $objChildCardShortId = $_.ShortHandID
                $objChildCardName = $_.CardName
                $objChildCardDescription = $_.CardDescription -replace "`n", '<br>' -replace "`r", '<br>' -replace '    ' , '&emsp;' -replace "`”", '"' -replace "`“", '"'
                $objChildCardComment = $_.Comment
                $objChildCardAttachment = $_.AttachmentName  -replace '^(https://trello\.com/c/\w{8}).*$', '$1'
                $objChildCardAttachedCard = $null
                $objChildCardAttachedCard = $NonBlankCards | Where-Object { $objChildCardAttachment -contains $_.CardShortURL }
                $objChildCardAttachmentUrl = $null
                $_.AttachmentURL | ForEach-Object { $objChildCardAttachmentUrl += '<li>' + $_ + '</li>' }
                $objChildCardMembers = $null
                $_.CardMembers | ForEach-Object { $objChildCardMembers += '<li>' + $_ + '</li>' }
                $objChildCardLongUrl = $_.CardURL
                $objChildCardStatus = $_.CardStatus
                $objChildCardLastActivity = $_.CardLastActivity
                $objChildCardChecklists = $_.Checklists
                $objChildCardLabels = $_.CardLabels | Where-Object { $_ -ne $null -and $_ -ne '' }
                $objChildAttachments = $_.Attachments
                $objChildCardShortUrl = $_.CardShortURL
                $objChildAttachedShortUrl = $_.AttachedShortURL
                $objChildAttachedName = $_.AttachedName
                $objChildCardHasChild = if ($_ | Where-Object { $objChildCardChecklists.checklistitems.name -Contains $_.CardShortURL }) { $true }else { $false }
                $objChildCardHasAttachedCard = if ($_ | Where-Object { $objChildCardAttachment -Contains $_.CardShortURL }) { $true }else { $false }
                #endregion

                #-------------Create Cards-------------
                $Create = New-Object System.Collections.ArrayList
                $CreateBody = New-Object System.Collections.ArrayList

                #region #-------------Assign Variables to objects-------------
                $host.ui.RawUI.ForegroundColor = "Blue"
                $SystemTitleData = $null
                $SystemTitleData = @{ 'op' = 'add'; 'path' = '/fields/System.Title'; 'from' = 'null'; 'value' = $objChildCardName }
                [void]$Create.add($SystemTitleData)
                Write-Output ("Creating System.Title: {0}" -f $objChildCardName)

                $SystemAreaPathData = $null
                $SystemAreaPathData = @{ 'op' = 'add'; 'path' = '/fields/System.AreaPath'; 'value' = "\\[Project Name]\\$objChildBoardName\\$objChildBoardList" }
                [void]$Create.add($SystemAreaPathData)
                Write-Output ("Creating System.AreaPath: \\[Project Name]\\{0}\\{1}" -f $objChildBoardName,$objChildBoardList)

                $CardDescriptionData = $null
                if ($objChildCardDescription ) { 
                    $CardDescriptionData = @{'op' = 'add'; 'path' = '/fields/Custom.CardDescription'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objChildCardDescription</body>" } 
                    [void]$Create.add($CardDescriptionData) 
                    Write-Output ("Createing Custom.CardDescription")
                }

                $BoardData = $null
                $BoardData = @{ 'op' = 'add'; 'path' = '/fields/Custom.Board'; 'from' = 'null'; 'value' = $objChildBoardName }
                [void]$Create.add($BoardData)
                Write-Output ("Creating Custom.Board: {0}" -f $objChildBoardName)

                $BoardListData = $null
                $BoardListData = @{ 'op' = 'add'; 'path' = '/fields/Custom.BoardList'; 'from' = 'null'; 'value' = $objChildBoardList }
                [void]$Create.add($BoardListData)
                Write-Output ("Creating Custom.BoardList: {0}" -f $objChildBoardList)

                $CardIDData = $null
                $CardIDData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardID'; 'from' = 'null'; 'value' = $objChildCardShortId }
                [void]$Create.add($CardIDData)
                Write-Output ("Creating Custom.CardID: {0}" -f $objChildCardShortId)

                $CardSNData = $null
                $CardSNData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardSN'; 'from' = 'null'; 'value' = $objChildCardLongId }
                [void]$Create.add($CardSNData)
                Write-Output ("Creating Custom.CardSN: {0}" -f $objChildCardLongId)

                $CardStatusData = $null
                if ($objChildCardStatus ) { $CardStatusData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardStatus'; 'from' = 'null'; 'value' = $objChildCardStatus } }
                if ($CardStatusData ) { 
                    [void]$Create.add($CardStatusData) 
                    Write-Output ("Creating Custom.CardStatus: {0}" -f $objChildCardStatus)
                }

                $CardURLData = $null
                $CardURLData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardURL'; 'from' = 'null'; 'value' = $objChildCardLongUrl }
                [void]$Create.add($CardURLData)
                Write-Output ("Creating Custom.CardURLs: {0}" -f $objChildCardLongUrl)

                $CardMemberData = $null
                $CardMemberData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardMember'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objChildCardMembers</body>" }
                [void]$Create.add($CardMemberData)
                Write-Output ("Creating Custom.CardMember")

                $AttachmentNameData = $null
                $objChildCardAttachedCardName = $null
                if ($objChildCardAttachedCard) {
                    $objChildCardAttachedCard | ForEach-Object {
                        $CardAttachedCardURL = $_.cardshorturl
                        $CardAttachedCardName = $_.CardName
                        $objChildCardAttachedCardName += '<li>' + $CardAttachedCardName + ' (' + $CardAttachedCardURL + ')' + '</li>' 
                    }
                }
                $objChildCardAttachmentName = $null
                $objChildCardAttachment | Where-Object {$_ -notmatch '^https://trello\.com/c/\w{8}$'} | Where-Object {$_ -ne 'image.png'} | ForEach-Object { $objChildCardAttachmentName += '<li>' + $_ + '</li>' }
                $objChildCardAttachedCardName += $objChildCardAttachmentName
                $AttachmentNameData = @{ 'op' = 'add'; 'path' = '/fields/Custom.AttachmentName'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objChildCardAttachedCardName</body>" }
                [void]$Create.add($AttachmentNameData)
                Write-Output ("Creating Custom.AttachmentName")

                $AttachmentURLData = $null
                $AttachmentURLData = @{ 'op' = 'add'; 'path' = '/fields/Custom.AttachmentURL'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objChildCardAttachmentUrl</body>" }
                [void]$Create.add($AttachmentURLData)
                Write-Output ("Creating Custom.AttachmentURL")

                $HasChildTasksData = $null
                $HasChildTasksData = @{ 'op' = 'add'; 'path' = '/fields/Custom.HasChildTasks'; 'from' = 'null'; 'value' = $objChildCardHasChild }
                [void]$Create.add($HasChildTasksData)
                Write-Output ("Creating Custom.HasChildTasks: {0}" -f $objChildCardHasChild)

                $HasAttachedCardsData = $null
                $HasAttachedCardsData = @{ 'op' = 'add'; 'path' = '/fields/Custom.HasAttachedCards'; 'from' = 'null'; 'value' = $objChildCardHasAttachedCard }
                [void]$Create.add($HasAttachedCardsData)
                Write-Output ("Creating Custom.HasAttachedCards: {0}" -f $objChildCardHasAttachedCard)

                $LastActivityDateData = $null
                $LastActivityDateData = @{ 'op' = 'add'; 'path' = '/fields/Custom.LastActivityDate'; 'from' = 'null'; 'value' = $objChildCardLastActivity }
                [void]$Create.add($LastActivityDateData)
                Write-Output ("Creating Custom.LastActivityDate: {0}" -f $objChildCardLastActivity)
                #endregion

                #region #-------------Assign objects to array-------------
                [void]$CreateBody.add($Create)

                #-------------Format array to JSON-------------
                $Body = $CreateBody | ConvertTo-Json -Depth 100

                # #-------------Create Card With Trello Data-------------
                $CreateChildTask = $orgURL + $Project.name + '/_apis/wit/workitems/$Child%20Task?api-version=7.0'
                $PostChildTask = Invoke-RestMethod -Uri $CreateChildTask -Body $Body -Method POST -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                #endregion

                #-------------Capture the error object-------------
                if ($ErrorObjects) {
                    $host.ui.RawUI.ForegroundColor = "Red"
                    Write-Output ("{0}: Has Errors Posting" -f $objChildCardName)
                    $Errors.add([PSCustomObject]@{
                        'Message' = $ErrorObjects
                        'Card'    = $objChild
                    })
                }else{
                    $host.ui.RawUI.ForegroundColor = "Green"
                    Write-Output ("{0}: Posted" -f $objChildCardName)
                    #region #-------------Update Card-------------
                    $host.ui.RawUI.ForegroundColor = "Blue"
                    #-------------Post Tags-------------
                    if ($objChildCardLabels) {
                        Write-Output ("Updating Tags on: {0}" -f $objChildCardName)
                        foreach ($CardLabels in $objChildCardLabels) {
                            $CreateBody = New-Object System.Collections.ArrayList
                            $Create = New-Object System.Collections.ArrayList 
                            #-------------Assign Variables to objects-------------
                            $CardLabelsData = @{ 'op' = 'add'; 'path' = '/fields/System.Tags'; 'from' = 'null'; 'value' = $CardLabels }
                            [void]$Create.add($CardLabelsData)
                            #-------------Assign objects to array-------------
                            [void]$CreateBody.add($Create)
                            #-------------Format array to JSON-------------
                            $Body = $CreateBody | ConvertTo-Json -Depth 100
                            #-------------Update PBI With Trello Labels-------------
                            $PostChildTaskId = $PostChildTask.id
                            $UpdateChildTaskId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostChildTaskId + '?api-version=7.0'
                            $UpdateChildTask = Invoke-RestMethod -Uri $UpdateChildTaskId -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                            #-------------Capture the error object-------------
                            if ($ErrorObjects) {
                                $host.ui.RawUI.ForegroundColor = "Red"
                                Write-Output ("{0}: Has Errors Posting" -f $objChildCardName)
                                $Errors.add([PSCustomObject]@{
                                    'Message' = $ErrorObjects
                                    'Card'    = $objChild
                                })
                            }
                        }
                    }

                    #-------------Post Comments-------------
                    if ($objChildCardComment) { 
                        Write-Output ("Updating Comments on: {0}" -f $objChildCardName)
                        foreach ($CardComment in $objChildCardComment) {
                            $CreateBody = New-Object System.Collections.ArrayList
                            $Create = New-Object System.Collections.ArrayList
                            $CardComment = $CardComment -replace "`n", '<br>' -replace "`r", '<br>' -replace '    ' , '&emsp;'
                            #-------------Assign Variables to objects-------------
                            $CommentData = @{'op' = 'add'; 'path' = '/fields/System.History'; 'from' = 'null'; 'value' = $CardComment }
                            [void]$Create.add($CommentData)
                            #-------------Assign objects to array-------------
                            [void]$CreateBody.add($Create)
                            #-------------Format array to JSON-------------
                            $Body = $CreateBody | ConvertTo-Json -Depth 100
                            #-------------Update PBI With Trello Comments-------------
                            $PostChildTaskId = $PostChildTask.id
                            $UpdateChildTaskId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostChildTaskId + '?api-version=7.0'
                            $UpdateChildTask = Invoke-RestMethod -Uri $UpdateChildTaskId -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                            #-------------Capture the error object-------------
                            if ($ErrorObjects) {
                                $host.ui.RawUI.ForegroundColor = "Red"
                                Write-Output ("{0}: Has Errors Posting" -f $objChildCardName)
                                $Errors.add([PSCustomObject]@{
                                    'Message' = $ErrorObjects
                                    'Card'    = $objChild
                                })
                            }
                        }
                    }

                    #-------------Post Checklists-------------
                    if ($objChildCardChecklists) {
                        Write-Output ("Updating Checklists on: {0}" -f $objChildCardName)
                        $CardChecklistGroup = @()
                        $CreateBody = New-Object System.Collections.ArrayList
                        $Create = New-Object System.Collections.ArrayList 
                        $objChildCardChecklists | ForEach-Object {
                            $CardChecklist = $_
                            $CardChecklistName = $CardChecklist.name
                            $objChildChecklistItem = @()
                            $CardChecklist.checklistitems | ForEach-Object {
                                $ChecklistItem = $_
                                $name = $ChecklistItem.name
                                $ChildTaskItem = $NonBlankCards | Where-Object { $name -contains $_.CardShortURL } | Select-Object CardName
                                if ($ChildTaskItem) {
                                    if ($ChecklistItem.state -eq 'complete') {
                                        $objChildChecklistItem += '<li>' + '<s>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChildTaskItem.CardName + '</b>' + ' (' + '<i>' + $ChecklistItem.name + '</i>' + ')' + '</s>' + '</li>'
                                    }
                                    else {
                                        $objChildChecklistItem += '<li>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChildTaskItem.CardName + '</b>' + ' (' + '<i>' + $ChecklistItem.name + '</i>' + ')' + '</li>'
                                    }
                                }
                                else {
                                    if ($ChecklistItem.state -eq 'complete') {
                                        $objChildChecklistItem += '<li>' + '<s>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChecklistItem.name + '</b>' + '</s>' + '</li>'
                                    }
                                    else {
                                        $objChildChecklistItem += '<li>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChecklistItem.name + '</b>' + '</li>'
                                    }
                                }
                            }
                            $CardChecklistGroup += '<h3>' + $CardChecklistName + '</h3>' + $objChildChecklistItem
                        }
                        $CheckListData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CheckList'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body> <ul> $CardChecklistGroup </ul> </body>" }
                        [void]$Create.add($CheckListData)
                        #-------------Assign objects to array-------------
                        [void]$CreateBody.add($Create)
                        #-------------Format array to JSON-------------
                        $Body = $CreateBody | ConvertTo-Json -Depth 100
                        #-------------Update PBI With Trello Comments-------------
                        $PostChildTaskId = $PostChildTask.id
                        $UpdateChildTaskId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostChildTaskId + '?api-version=7.0'
                        $UpdateChildTask = Invoke-RestMethod -Uri $UpdateChildTaskId -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                        #-------------Capture the error object-------------
                        if ($ErrorObjects) {
                            $host.ui.RawUI.ForegroundColor = "Red"
                            Write-Output ("{0}: Has Errors Posting" -f $objChildCardName)
                            $Errors.add([PSCustomObject]@{
                                'Message' = $ErrorObjects
                                'Card'    = $objChild
                            })
                        }
                    }

                    #-------------Post Attachments-------------
                    if ($objChildCardAttachment) { 
                        Write-Output ("Uploading Attachments on: {0}" -f $objChildCardName)
                        foreach ($CardAttachment in $objChildCardAttachment | Where-Object { $_ -ne 'image.png' }) {
                            $Attchment = $CardAttachment
                            $Rename = $Attchment.Replace('.', '').replace( '-', '')
                            $CreateBody = New-Object System.Collections.ArrayList
                            $Create = New-Object System.Collections.ArrayList 
                            $objAttachmentFilePath  = $idboard[$objChildBoardId]
                            $objChildAttachment = Get-ChildItem -Path $objAttachmentFilePath
                            $WorkItemId = $PostChildTask.id
                            $objChildAttachmentFilePath = $objChildAttachment | Where-Object { $Rename -Contains ($_.name.Replace('.', '').replace( '-', '')) }
                            if ($objChildAttachmentFilePath) {
                                $FileName = $objChildAttachmentFilePath.name
                                $File = $objChildAttachmentFilePath.FullName
                                $FileUploadUrl = $orgURL + $Project.name + '/_apis/wit/attachments?fileName=' + $FileName + '&api-version=5.0'
                                $Body = [System.IO.File]::ReadAllBytes("$File")
                                $UploadAttachment = Invoke-RestMethod -Uri $FileUploadUrl -Body $Body -Method Post -ContentType 'application/json' -Headers $Header
                                $objChildCardAttachmentUrl = $UploadAttachment.url
                                $UpdateChildTaskId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $WorkItemId + '?api-version=5.0'
                                $Body = "[{`"op`": `"add`",`"path`": `"/relations/-`",`"value`": {`"rel`": `"AttachedFile`",`"url`": `"$objChildCardAttachmentUrl`", `"attributes`": {`"comment`": `"Attachment for the specified work item`"}}}]"
                                $UpdateChildTask = Invoke-RestMethod -Uri $UpdateChildTaskId -Body $Body -Method Patch -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                                #-------------Capture the error object-------------
                                if ($ErrorObjects) {
                                    $host.ui.RawUI.ForegroundColor = "Red"
                                    Write-Output ("{0}: Has Errors Posting" -f $objChildCardName)
                                    $Errors.add([PSCustomObject]@{
                                        'Message' = $ErrorObjects
                                        'Card'    = $objChild
                                    })
                                }
                            }
                        }
                    }

                    #-------------Create Parent Child Relationship-------------
                    $ParentId = $PostCard.id
                    $ChildURL = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostChildTask.id
                    $Relationship = @{'op' = 'add'; 'path' = '/relations/-'; 'value' = @{'rel' = 'System.LinkTypes.Hierarchy-Forward'; 'url' = $ChildURL; 'attributes' = @{'comment' = 'This work item is Child to the specified work item.' } } }
                    $Related = New-Object System.Collections.ArrayList
                    $RelatedCard = New-Object System.Collections.ArrayList
                    [void]$Related.add($Relationship)
                    [void]$RelatedCard.add($Related)
                    $Body = $RelatedCard | ConvertTo-Json -Depth 100
                    $CreateRelationship = $orgURL + $Project.name + '/_apis/wit/workitems/' + $ParentId + '?api-version=7.0'
                    $UpdateCard = Invoke-RestMethod -Uri $CreateRelationship -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                    #-------------Capture the error object-------------
                    if ($ErrorObjects) {
                        $host.ui.RawUI.ForegroundColor = "Red"
                        Write-Output ("{0}: Has Errors Posting" -f $objChildCardName)
                        $Errors.add([PSCustomObject]@{
                            'Message' = $ErrorObjects
                            'Card'    = $objChild
                        })
                    }
                    $host.ui.RawUI.ForegroundColor = "Green"
                    Write-Output ("Creating Parent Child Relationship with {0} and {1}" -f $objCardName,$objChildCardName)

                    #-------------Add to Imported Object-------------
                    $Imported.add([PSCustomObject]@{
                        'Trello' = $objChild
                        'DevOps' = $PostChildTask
                    })
                    #endregion

                    #-------------Create Child Task-------------
                    if ($ChildCardLevel2.ParentCard.cardid -contains $objChildCardLongId) {
                        $host.ui.RawUI.ForegroundColor = "Yellow"
                        Write-Output ("{0} is Child Parent" -f $objChildCardName)
                        $objHasTask += $NonBlankCards | Where-Object { $Imported.Trello.CardID -notcontains $_.CardID} | Where-Object { $objChildCardChecklists.checklistitems.Name -contains $_.cardshorturl }
                        # $Item = $objChildCardDescription -replace "`n", ' ' -replace "`r", ' '-replace "\*", ' ' -replace '<br>', ' '-split ' '
                        # $Item -replace '^(https://trello\.com/c/\w{8}).*$', '$1' | Where-Object { $_ -match '^https://trello\.com/c/\w{8}$' }| ForEach-Object {
                        #     $MatchUrl = $_
                        #     $objHasTask += $NonBlankCards | Where-Object { $MatchUrl -eq $_.CardShortURL }
                        # }
                    }
                    if ($objHasTask) {
                        $objHasTask | ForEach-Object {
                            $objChildTaskCardName = $_.CardName
                            $host.ui.RawUI.ForegroundColor = "Yellow"
                            Write-Output ("{0} is Child Task" -f $objChildTaskCardName)
                            #region #-------------Assign Variables to objects-------------
                            $objChildTask = $_
                            $objChildTaskBoardName = $_.BoardName | Sort-Object | Get-Unique
                            $objChildTaskBoardId = $_.BoardId | Sort-Object | Get-Unique
                            $objChildTaskBoardLongUrl = $_.BoardURL | Sort-Object | Get-Unique
                            $objChildTaskBoardShortUrl = $_.BoardShortURL
                            $objChildTaskBoardList = ($_.Cardlist -replace '/' , '-' -replace ':' , '-' -replace '&' , 'and' -replace "\?" , 'X'  -replace "\+" , 'and' -replace "\#" , 'NUM')
                            $objChildTaskCardLongId = $_.CardID
                            $objChildTaskCardShortId = $_.ShortHandID
                            $objChildTaskCardName = $_.CardName
                            $objChildTaskCardDescription = $_.CardDescription -replace "`n", '<br>' -replace "`r", '<br>' -replace '    ' , '&emsp;' -replace "`”", '"' -replace "`“", '"'
                            $objChildTaskCardComment = $_.Comment
                            $objChildTaskCardAttachment = $_.AttachmentName -replace '^(https://trello\.com/c/\w{8}).*$', '$1'
                            $objChildTaskCardAttachedCard = $null
                            $objChildTaskCardAttachedCard = $NonBlankCards | Where-Object { $objChildTaskCardAttachment -contains $_.CardShortURL }
                            $objChildTaskCardAttachmentUrl = $null
                            $_.AttachmentURL | ForEach-Object { $objChildTaskCardAttachmentUrl += '<li>' + $_ + '</li>' }
                            $objChildTaskCardMembers = $null
                            $_.CardMembers | ForEach-Object { $objChildTaskCardMembers += '<li>' + $_ + '</li>' }
                            $objChildTaskCardLongUrl = $_.CardURL
                            $objChildTaskCardStatus = $_.CardStatus
                            $objChildTaskCardLastActivity = $_.CardLastActivity
                            $objChildTaskCardChecklists = $_.Checklists
                            $objChildTaskCardLabels = $_.CardLabels | Where-Object { $_ -ne $null -and $_ -ne '' }
                            $objChildTaskAttachments = $_.Attachments
                            $objChildTaskCardShortUrl = $_.CardShortURL
                            $objChildTaskAttachedShortUrl = $_.AttachedShortURL
                            $objChildTaskAttachedName = $_.AttachedName
                            $objChildTaskCardHasChild = if ($_ | Where-Object { $objChildTaskCardChecklists.checklistitems.name -Contains $_.CardShortURL }) { $true }else { $false }
                            $objChildTaskCardHasAttachedCard = if ($_ | Where-Object { $objChildTaskCardAttachment -Contains $_.CardShortURL }) { $true }else { $false }
                            #endregion

                            #-------------Create Cards-------------
                            $Create = New-Object System.Collections.ArrayList
                            $CreateBody = New-Object System.Collections.ArrayList

                            #region #-------------Assign Variables to objects-------------
                            $host.ui.RawUI.ForegroundColor = "Blue"
                            $SystemTitleData = $null
                            $SystemTitleData = @{ 'op' = 'add'; 'path' = '/fields/System.Title'; 'from' = 'null'; 'value' = $objChildTaskCardName }
                            [void]$Create.add($SystemTitleData)
                            Write-Output ("Creating System.Title: {0}" -f $objChildTaskCardName)

                            $SystemAreaPathData = $null
                            $SystemAreaPathData = @{ 'op' = 'add'; 'path' = '/fields/System.AreaPath'; 'value' = "\\[Project Name]\\$objChildTaskBoardName\\$objChildTaskBoardList" }
                            [void]$Create.add($SystemAreaPathData)
                            Write-Output ("Creating System.AreaPath: \\[Project Name]\\{0}\\{1}" -f $objChildTaskBoardName,$objChildTaskBoardList)

                            $CardDescriptionData = $null
                            if ($objChildTaskCardDescription ) { 
                                $CardDescriptionData = @{'op' = 'add'; 'path' = '/fields/Custom.CardDescription'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objChildTaskCardDescription</body>" } 
                                [void]$Create.add($CardDescriptionData) 
                                Write-Output ("Createing Custom.CardDescription")
                            }

                            $BoardData = $null
                            $BoardData = @{ 'op' = 'add'; 'path' = '/fields/Custom.Board'; 'from' = 'null'; 'value' = $objChildTaskBoardName }
                            [void]$Create.add($BoardData)
                            Write-Output ("Creating Custom.Board: {0}" -f $objChildTaskBoardName)

                            $BoardListData = $null
                            $BoardListData = @{ 'op' = 'add'; 'path' = '/fields/Custom.BoardList'; 'from' = 'null'; 'value' = $objChildTaskBoardList }
                            [void]$Create.add($BoardListData)
                            Write-Output ("Creating Custom.BoardList: {0}" -f $objChildTaskBoardList)

                            $CardIDData = $null
                            $CardIDData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardID'; 'from' = 'null'; 'value' = $objChildTaskCardShortId }
                            [void]$Create.add($CardIDData)
                            Write-Output ("Creating Custom.CardID: {0}" -f $objChildTaskCardShortId)

                            $CardSNData = $null
                            $CardSNData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardSN'; 'from' = 'null'; 'value' = $objChildTaskCardLongId }
                            [void]$Create.add($CardSNData)
                            Write-Output ("Creating Custom.CardSN: {0}" -f $objChildTaskCardLongId)

                            $CardStatusData = $null
                            if ($objChildTaskCardStatus ) { $CardStatusData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardStatus'; 'from' = 'null'; 'value' = $objChildTaskCardStatus } }
                            if ($CardStatusData ) { 
                                [void]$Create.add($CardStatusData)
                                Write-Output ("Creating Custom.CardStatus: {0}" -f $objCardStatus)
                            }

                            $CardURLData = $null
                            $CardURLData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardURL'; 'from' = 'null'; 'value' = $objChildTaskCardLongUrl }
                            [void]$Create.add($CardURLData)
                            Write-Output ("Creating Custom.CardURLs: {0}" -f $objChildTaskCardLongUrl )

                            $CardMemberData = $null
                            $CardMemberData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CardMember'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objChildTaskCardMembers</body>" }
                            [void]$Create.add($CardMemberData)
                            Write-Output ("Creating Custom.CardMember")

                            $AttachmentNameData = $null
                            $objChildTaskCardAttachedCardName = $null
                            if ($objChildTaskCardAttachedCard) {
                                $objChildTaskCardAttachedCard | ForEach-Object {
                                    $CardAttachedCardURL = $_.cardshorturl
                                    $CardAttachedCardName = $_.CardName
                                    $objChildTaskCardAttachedCardName += '<li>' + $CardAttachedCardName + ' (' + $CardAttachedCardURL + ')' + '</li>' 
                                }
                            }
                            $objChildTaskCardAttachmentName = $null
                            $objChildTaskCardAttachment | Where-Object {$_ -notmatch '^https://trello\.com/c/\w{8}$'} | Where-Object {$_ -ne 'image.png'} | ForEach-Object { $objChildTaskCardAttachmentName += '<li>' + $_ + '</li>' }
                            $objChildTaskCardAttachedCardName += $objChildTaskCardAttachmentName
                            $AttachmentNameData = @{ 'op' = 'add'; 'path' = '/fields/Custom.AttachmentName'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objChildTaskCardAttachedCardName</body>" }
                            [void]$Create.add($AttachmentNameData)
                            Write-Output ("Creating Custom.AttachmentName")

                            $AttachmentURLData = $null
                            $AttachmentURLData = @{ 'op' = 'add'; 'path' = '/fields/Custom.AttachmentURL'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body>$objChildTaskCardAttachmentUrl</body>" }
                            [void]$Create.add($AttachmentURLData)
                            Write-Output ("Creating Custom.AttachmentURL")

                            $HasChildTasksData = $null
                            $HasChildTasksData = @{ 'op' = 'add'; 'path' = '/fields/Custom.HasChildTasks'; 'from' = 'null'; 'value' = $objChildTaskCardHasChild }
                            [void]$Create.add($HasChildTasksData)
                            Write-Output ("Creating Custom.HasChildTasks: {0}" -f $objChildTaskCardHasChild)

                            $HasAttachedCardsData = $null
                            $HasAttachedCardsData = @{ 'op' = 'add'; 'path' = '/fields/Custom.HasAttachedCards'; 'from' = 'null'; 'value' = $objChildTaskCardHasAttachedCard }
                            [void]$Create.add($HasAttachedCardsData)
                            Write-Output ("Creating Custom.HasAttachedCards: {0}" -f $objChildTaskCardHasAttachedCard)

                            $LastActivityDateData = $null
                            $LastActivityDateData = @{ 'op' = 'add'; 'path' = '/fields/Custom.LastActivityDate'; 'from' = 'null'; 'value' = $objChildTaskCardLastActivity }
                            [void]$Create.add($LastActivityDateData)
                            Write-Output ("Creating Custom.LastActivityDate: {0}" -f $objChildTaskCardLastActivity)
                            #endregion

                            #region #-------------Assign objects to array-------------
                            [void]$CreateBody.add($Create)

                            #-------------Format array to JSON-------------
                            $Body = $CreateBody | ConvertTo-Json -Depth 100

                            # #-------------Create Card With Trello Data-------------
                            $CreateChildChildTask = $orgURL + $Project.name + '/_apis/wit/workitems/$Check%20List%20Item?api-version=7.0'
                            $PostChildChildTask = Invoke-RestMethod -Uri $CreateChildChildTask -Body $Body -Method POST -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                            $host.ui.RawUI.ForegroundColor = "Green"
                            Write-Output ("{0}: Posted" -f $objChildTaskCardName)
                            #endregion

                            #-------------Capture the error object-------------
                            if ($ErrorObjects) {
                                $host.ui.RawUI.ForegroundColor = "Red"
                                Write-Output ("{0}: Has Errors Posting" -f $objChildTaskCardName)
                                $Errors.add([PSCustomObject]@{
                                    'Message' = $ErrorObjects
                                    'Card'    = $objChildTask
                                })
                            }else{
                                #region #-------------Update Card-------------
                                $host.ui.RawUI.ForegroundColor = "Blue"
                                #-------------Post Tags-------------
                                if ($objChildTaskCardLabels) {
                                    Write-Output ("Updating Tags on: {0}" -f $objCardName)
                                    foreach ($CardLabels in $objChildTaskCardLabels) {
                                        $CreateBody = New-Object System.Collections.ArrayList
                                        $Create = New-Object System.Collections.ArrayList 
                                        #-------------Assign Variables to objects-------------
                                        $CardLabelsData = @{ 'op' = 'add'; 'path' = '/fields/System.Tags'; 'from' = 'null'; 'value' = $CardLabels }
                                        [void]$Create.add($CardLabelsData)
                                        #-------------Assign objects to array-------------
                                        [void]$CreateBody.add($Create)
                                        #-------------Format array to JSON-------------
                                        $Body = $CreateBody | ConvertTo-Json -Depth 100
                                        #-------------Update PBI With Trello Labels-------------
                                        $PostChildChildTaskId = $PostChildChildTask.id
                                        $UpdateChildChildTaskId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostChildChildTaskId + '?api-version=7.0'
                                        $UpdateChildChildTask = Invoke-RestMethod -Uri $UpdateChildChildTaskId -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                                        $host.ui.RawUI.ForegroundColor = "Green"
                                        Write-Output ("{0}: Posted" -f $objChildTaskCardName)
                                        #-------------Capture the error object-------------
                                        if ($ErrorObjects) {
                                            $host.ui.RawUI.ForegroundColor = "Red"
                                            Write-Output ("{0}: Has Errors Posting" -f $objChildTaskCardName)
                                            $Errors.add([PSCustomObject]@{
                                                'Message' = $ErrorObjects
                                                'Card'    = $objChildTask
                                            })
                                        }
                                    }
                                }

                                #-------------Post Comments-------------
                                if ($objChildTaskCardComment) { 
                                    Write-Output ("Updating Comments on: {0}" -f $objCardName)
                                    foreach ($CardComment in $objChildTaskCardComment) {
                                        $CreateBody = New-Object System.Collections.ArrayList
                                        $Create = New-Object System.Collections.ArrayList
                                        $CardComment = $CardComment -replace "`n", '<br>' -replace "`r", '<br>' -replace '    ' , '&emsp;'
                                        #-------------Assign Variables to objects-------------
                                        $CommentData = @{'op' = 'add'; 'path' = '/fields/System.History'; 'from' = 'null'; 'value' = $CardComment }
                                        [void]$Create.add($CommentData)
                                        #-------------Assign objects to array-------------
                                        [void]$CreateBody.add($Create)
                                        #-------------Format array to JSON-------------
                                        $Body = $CreateBody | ConvertTo-Json -Depth 100
                                        #-------------Update PBI With Trello Comments-------------
                                        $PostChildChildTaskId = $PostChildChildTask.id
                                        $UpdateChildChildTaskId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostChildChildTaskId + '?api-version=7.0'
                                        $UpdateChildChildTask = Invoke-RestMethod -Uri $UpdateChildChildTaskId -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                                        $host.ui.RawUI.ForegroundColor = "Green"
                                        Write-Output ("{0}: Posted" -f $objChildTaskCardName)
                                        #-------------Capture the error object-------------
                                        if ($ErrorObjects) {
                                            $host.ui.RawUI.ForegroundColor = "Red"
                                            Write-Output ("{0}: Has Errors Posting" -f $objChildTaskCardName)
                                            $Errors.add([PSCustomObject]@{
                                                'Message' = $ErrorObjects
                                                'Card'    = $objChildTask
                                            })
                                        }
                                    }
                                }

                                #-------------Post Checklists-------------
                                if ($objChildTaskCardChecklists) {
                                    Write-Output ("Updating Checklists on: {0}" -f $objCardName)
                                    $CardChecklistGroup = @()
                                    $CreateBody = New-Object System.Collections.ArrayList
                                    $Create = New-Object System.Collections.ArrayList 
                                    $objChildTaskCardChecklists | ForEach-Object {
                                        $CardChecklist = $_
                                        $CardChecklistName = $CardChecklist.name
                                        $objChildTaskChecklistItem = @()
                                        $CardChecklist.checklistitems | ForEach-Object {
                                            $ChecklistItem = $_
                                            $name = $ChecklistItem.name
                                            $ChildTaskItem = $NonBlankCards | Where-Object { $name -contains $_.CardShortURL } | Select-Object CardName
                                            if ($ChildTaskItem) {
                                                if ($ChecklistItem.state -eq 'complete') {
                                                    $objChildTaskChecklistItem += '<li>' + '<s>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChildTaskItem.CardName + '</b>' + ' (' + '<i>' + $ChecklistItem.name + '</i>' + ')' + '</s>' + '</li>'
                                                }
                                                else {
                                                    $objChildTaskChecklistItem += '<li>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChildTaskItem.CardName + '</b>' + ' (' + '<i>' + $ChecklistItem.name + '</i>' + ')' + '</li>'
                                                }
                                            }
                                            else {
                                                if ($ChecklistItem.state -eq 'complete') {
                                                    $objChildTaskChecklistItem += '<li>' + '<s>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChecklistItem.name + '</b>' + '</s>' + '</li>'
                                                }
                                                else {
                                                    $objChildTaskChecklistItem += '<li>' + '[' + '<i>' + $ChecklistItem.state + '</i>' + '] ' + '<b>' + $ChecklistItem.name + '</b>' + '</li>'
                                                }
                                            }
                                        }
                                        $CardChecklistGroup += '<h3>' + $CardChecklistName + '</h3>' + $objChildTaskChecklistItem
                                    }
                                    $CheckListData = @{ 'op' = 'add'; 'path' = '/fields/Custom.CheckList'; 'type' = 'html' ; 'from' = 'null'; 'value' = "<body> <ul> $CardChecklistGroup </ul> </body>" }
                                    [void]$Create.add($CheckListData)
                                    #-------------Assign objects to array-------------
                                    [void]$CreateBody.add($Create)
                                    #-------------Format array to JSON-------------
                                    $Body = $CreateBody | ConvertTo-Json -Depth 100
                                    #-------------Update PBI With Trello Comments-------------
                                    $PostChildChildTaskId = $PostChildChildTask.id
                                    $UpdateChildChildTaskId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostChildChildTaskId + '?api-version=7.0'
                                    $UpdateChildChildTask = Invoke-RestMethod -Uri $UpdateChildChildTaskId -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                                    $host.ui.RawUI.ForegroundColor = "Green"
                                    Write-Output ("{0}: Posted" -f $objChildTaskCardName)
                                    #-------------Capture the error object-------------
                                    if ($ErrorObjects) {
                                        $host.ui.RawUI.ForegroundColor = "Red"
                                        Write-Output ("{0}: Has Errors Posting" -f $objChildTaskCardName)
                                        $Errors.add([PSCustomObject]@{
                                            'Message' = $ErrorObjects
                                            'Card'    = $objChildTask
                                        })
                                    }
                                }

                                #-------------Post Attachments-------------
                                if ($objChildTaskCardAttachment) { 
                                    Write-Output ("Uploading Attachments on: {0}" -f $objCardName)
                                    foreach ($CardAttachment in $objChildTaskCardAttachment | Where-Object { $_ -ne 'image.png' }) {
                                        $Attchment = $CardAttachment
                                        $Rename = $Attchment.Replace('.', '').replace( '-', '')
                                        $CreateBody = New-Object System.Collections.ArrayList
                                        $Create = New-Object System.Collections.ArrayList
                                        $objAttachmentFilePath  = $idboard[$objChildTaskBoardId]
                                        $objChildTaskAttachment = Get-ChildItem -Path $objAttachmentFilePath
                                        $WorkItemId = $PostChildChildTask.id
                                        $objChildTaskAttachmentFilePath = $objChildTaskAttachment | Where-Object { $Rename -Contains ($_.name.Replace('.', '').replace( '-', '')) }
                                        if ($objChildTaskAttachmentFilePath) {
                                            $FileName = $objChildTaskAttachmentFilePath.name
                                            $File = $objChildTaskAttachmentFilePath.FullName
                                            $FileUploadUrl = $orgURL + $Project.name + '/_apis/wit/attachments?fileName=' + $FileName + '&api-version=5.0'
                                            $Body = [System.IO.File]::ReadAllBytes("$File")
                                            $UploadAttachment = Invoke-RestMethod -Uri $FileUploadUrl -Body $Body -Method Post -ContentType 'application/json' -Headers $Header
                                            $objChildTaskCardAttachmentUrl = $UploadAttachment.url
                                            $UpdateChildChildTaskId = $orgURL + $Project.name + '/_apis/wit/workitems/' + $WorkItemId + '?api-version=5.0'
                                            $Body = "[{`"op`": `"add`",`"path`": `"/relations/-`",`"value`": {`"rel`": `"AttachedFile`",`"url`": `"$objChildTaskCardAttachmentUrl`", `"attributes`": {`"comment`": `"Attachment for the specified work item`"}}}]"
                                            $UpdateChildChildTask = Invoke-RestMethod -Uri $UpdateChildChildTaskId -Body $Body -Method Patch -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                                            $host.ui.RawUI.ForegroundColor = "Green"
                                            Write-Output ("{0}: Posted" -f $objChildTaskCardName)
                                            #-------------Capture the error object-------------
                                            if ($ErrorObjects) {
                                                $host.ui.RawUI.ForegroundColor = "Red"
                                                Write-Output ("{0}: Has Errors Posting" -f $objChildTaskCardName)
                                                $Errors.add([PSCustomObject]@{
                                                    'Message' = $ErrorObjects
                                                    'Card'    = $objChildTask
                                                })
                                            }
                                        }
                                    }
                                }

                                #-------------Create Parent Child Relationship-------------
                                $ChildParentId = $PostChildTask.id
                                $ChildTaskURL = $orgURL + $Project.name + '/_apis/wit/workitems/' + $PostChildChildTask.id
                                $Relationship = @{'op' = 'add'; 'path' = '/relations/-'; 'value' = @{'rel' = 'System.LinkTypes.Hierarchy-Forward'; 'url' = $ChildTaskURL; 'attributes' = @{'comment' = 'This work item is Child to the specified work item.' } } }
                                $Related = New-Object System.Collections.ArrayList
                                $RelatedCard = New-Object System.Collections.ArrayList
                                [void]$Related.add($Relationship)
                                [void]$RelatedCard.add($Related)
                                $Body = $RelatedCard | ConvertTo-Json -Depth 100
                                $CreateRelationship = $orgURL + $Project.name + '/_apis/wit/workitems/' + $ChildParentId + '?api-version=7.0'
                                $UpdateCard = Invoke-RestMethod -Uri $CreateRelationship -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header -ErrorVariable ErrorObjects
                                $host.ui.RawUI.ForegroundColor = "Green"
                                Write-Output ("{0}: Posted" -f $objChildTaskCardName)
                                #-------------Capture the error object-------------
                                if ($ErrorObjects) {
                                    $host.ui.RawUI.ForegroundColor = "Red"
                                    Write-Output ("{0}: Has Errors Posting" -f $objChildTaskCardName)
                                    $Errors.add([PSCustomObject]@{
                                        'Message' = $ErrorObjects
                                        'Card'    = $objChildTask
                                    })
                                }
                                $host.ui.RawUI.ForegroundColor = "Green"
                                Write-Output ("Creating Parent Child Relationship with {0} and {1}" -f $objChildCardName,$objChildTaskCardName)

                                #-------------Add to Imported Object-------------
                                $Imported.add([PSCustomObject]@{
                                    'Trello' = $objChildTask
                                    'DevOps' = $PostChildChildTask
                                })
                                #endregion
                            }
                        }
                    }
                }
            }
        }
    }
}
# Returns the foreground color to it's original state
$host.ui.RawUI.ForegroundColor = $OriginalForeground
#endregion

#region #-------------Create Relationships-------------
$DevOpsRelated = [System.Collections.Generic.List[PSCustomObject]]::new()
$Imported | ForEach-Object {
    $CurrentImport = $_
    $TrelloURL = $_.Trello.CardShortURL
    $TrelloURL | ForEach-Object {
        $DevOpsParent = $_ | Where-Object { $RelatedTrelloCards.CurrentCard.CardShortURL -contains $_ }
        $TrelloParent = $RelatedTrelloCards | Where-Object { $TrelloURL -contains $_.CurrentCard.CardShortURL }
        $TrelloParent | ForEach-Object {
            $TrelloAttachment = $_.RelatedCard
            $DevOpsAttachment = $Imported | Where-Object { $TrelloAttachment.cardshorturl -contains $_.Trello.cardshorturl }
            if ($DevOpsParent) {
                $DevOpsRelated.add([PSCustomObject]@{
                    'TrelloParent'     = $TrelloParent.CurrentCard
                    'DevOpsParent'     = $CurrentImport
                    'TrelloAttachment' = $TrelloAttachment
                    'DevOpsAttachment' = $DevOpsAttachment
                })
            }
        }
    }
}
$DevOpsRelated.Count

#-------------Post Relationships-------------
$DevOpsRelated | ForEach-Object {
    $ParentURL = $null
    $AttachmentURL = $null
    $ParentURL = $_.DevOpsParent.DevOps.url
    $AttachmentURL = $_.DevOpsAttachment.DevOps.url
    $devopsP = $_.DevOpsParent.Trello.cardname
    $devopsR = $_.DevOpsAttachment.Trello.cardname
    if(!($AttachmentURL -eq $null)){
        $Body = "[{`"op`": `"add`",`"path`": `"/relations/-`",`"value`": {`"rel`": `"System.LinkTypes.Related`",`"url`": `"$ParentURL`", `"attributes`": {`"comment`": `"This work item is related to the specified work item based on Attachments.`"}}},{`"op`": `"add`",`"path`": `"/fields/Custom.IsAttachedCard`",`"value`": `"$true`"}]"
        $api = '?api-version=7.0'
        $CreateRelationship = $AttachmentURL + $api
        $UpdatePBI = Invoke-RestMethod -Uri $CreateRelationship -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header
        Write-Output ("{0}" -f $CreateRelationship)
        Write-Host ("{0}" -f $devopsP ) -ForegroundColor Green -NoNewline
        Write-Host (" Related to ") -ForegroundColor Yellow -NoNewline
        Write-Host ("{0}" -f $devopsR ) -ForegroundColor Blue
    }
}
#endregion

#region #-------------image.png solution-------------
#-------------Import Objects-------------
#Only if exported your objects to return to later
# $Imported = Import-Clixml "C:\Users\[USER]\Desktop\TrelloDevops2Impoted.xml"
# $ImagePNGCard = Import-Clixml "C:\Users\[USER]\Desktop\TrelloImagePngCards.xml"
# $imagepng = Import-Clixml "C:\Users\[USER]\Desktop\imagepng.xml"

#-------------Required Trello Information-------------
$TrelloKey = "[TrelloKey]"
$TrelloToken = "[TrelloToken]"
$TrelloHeader = @{"Authorization" = "OAuth oauth_consumer_key=`"$TrelloKey`", oauth_token=`"$TrelloToken`""}
$TrelloURL = 'https://api.trello.com/1/cards/'
$TrelloAttachmentEndpoint = '/attachments'

#-------------image.png Download and Upload-------------
$Imported | ForEach-Object {
    $DevOpsCard = $null
    $CurrentImport = $_
    $TrelloID = $_.Trello.CardID
    $DevOpsCard = $_ | Where-Object { $imagepng.CardID -contains $_.Trello.CardID }
    if ($DevOpsCard) {
        $TrelloUri = $TrelloURL + $DevOpsCard.Trello.CardID + $TrelloAttachmentEndpoint
        $TrelloCard = Invoke-RestMethod -Uri $TrelloUri -Method Get -Headers $TrelloHeader
        $TrelloCard | ForEach-Object {
            $objImagePNG = $_ | Where { $_.name -eq "image.png" }
            if ($objImagePNG){
                $TrelloDownload = $objImagePNG.URL
                $TrelloOutfile = "C:\Users\[USER]\Downloads\TrelloDownloads\" + $objImagePNG.id + ".image.png"
                Invoke-WebRequest -Uri $TrelloDownload -OutFile $TrelloOutfile -Headers $TrelloHeader
                $WorkItemId = $CurrentImport.DevOps.id
                $FileName = $objImagePNG.id + ".image.png"
                $FileUploadUrl = $DevOpsURL + $TrelloArchive.name + '/_apis/wit/attachments?fileName=' + $FileName + '&api-version=5.0'
                $DevOpsBody = [System.IO.File]::ReadAllBytes("$TrelloOutfile")
                $UploadAttachment = Invoke-RestMethod -Uri $FileUploadUrl -Body $DevOpsBody -Method Post -ContentType 'application/json' -Headers $DevOpsHeader
                $objCardAttachmentUrl = $UploadAttachment.url
                $UpdateCardId = $DevOpsURL + $TrelloArchive.name + '/_apis/wit/workitems/' + $WorkItemId + '?api-version=5.0'
                $DevOpsBody = "[{`"op`": `"add`",`"path`": `"/relations/-`",`"value`": {`"rel`": `"AttachedFile`",`"url`": `"$objCardAttachmentUrl`", `"attributes`": {`"comment`": `"Attachment for the specified work item`"}}}]"
                $UpdateCard = Invoke-RestMethod -Uri $UpdateCardId -Body $DevOpsBody -Method Patch -ContentType 'application/json-patch+json' -Headers $DevOpsHeader 
            }
        }
    }
}
#endregion
