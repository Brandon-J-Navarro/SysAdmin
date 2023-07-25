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
    Name: DevOpsAPI.ps1
    Requires: 
    Major Release History:
        04/21/2023  - Initial Creation.
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
#-------------Required Informations-------------
$orgURL = 'https://[Orgnization].[DevOpsURl].com/[COLLECTIONNAME]/'
$PersonalToken = '[PersonalToken]'
$Token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($PersonalToken)"))
$Header = @{authorization = "Basic $Token" }

#-------------Get Projects-------------
$Projects = $orgURL + '_apis/projects?api-version=7.0'
$GetProjects = Invoke-RestMethod -Uri $Projects -Method GET -ContentType 'application/json' -Headers $Header
$Project = $GetProjects.value | Where-Object name -EQ '[Project Name]' | Select-Object name

#-------------Get Work Types-------------
$GetWorkTypes = $orgURL + $Project.name + '/_apis/wit/workitemtypes?api-version=7.0'
$WorkItemsTypes = Invoke-RestMethod -Uri $GetWorkTypes -Method GET -ContentType 'application/json' -Headers $Header

#-------------Get Work Categories-------------
$GetWorkCategories = $orgURL + $Project.name + '/_apis/wit/workitemtypecategories?api-version=7.0'
$WorkCategories = Invoke-RestMethod -Uri $GetWorkCategories -Method GET -ContentType 'application/json' -Headers $Header

#-------------Get Work Item-------------
$Workitem = $orgURL + $Project.name + '/_apis/wit/workitems/[NUMBER]?api-version=7.0'
$Item = Invoke-RestMethod -Uri $Workitem -Method Get -ContentType 'application/json' -Headers $Header

#-------------Get PBIs-------------
$apiendpoint = '/_apis/wit/workitems/'
$apiversion = '?api-version=7.0'
$count = [NUMBER]..[RANGE]
$Items = @()
$count | ForEach-Object {
    $id = $_
    $Workitem = $orgURL + $Project.name + $apiendpoint + $id + $apiversion
    $Items += @(Invoke-RestMethod -Uri $Workitem -Method Get -ContentType 'application/json' -Headers $Header)
}

#-------------Create Test Task-------------
$TaskCreate = $orgURL + $Project.name + '/_apis/wit/workitems/$Task?api-version=7.0'
$body = @'
[
    {
        "op": "add",
        "path": "/fields/System.Title",
        "from": null,
        "value": "Sample task"
    }
]
'@ 
$Task = Invoke-RestMethod -Uri $TaskCreate -Body $body -Method get -ContentType 'application/json' -Headers $Header

#-------------Update Test Task-------------
$body = @'
[
    {
        "op": "replace",
        "path": "/fields/System.Title",
        "value": "Sample task Test"
    },
    {
        "op": "add",
        "path": "/fields/System.Description",
        "value": "Test Description"
    },
    {
        "op": "add",
        "path": "/fields/System.History",
        "value": "Test Disscussion"
    },
    {
        "op": "add",
        "path": "/fields/Microsoft.VSTS.Common.AcceptanceCriteria",
        "type": "html",
        "value": "Test Acceptance Criteria"
    },
    {
        "op": "add",
        "path": "/relations/-",
        "value": {
            "rel": "System.LinkTypes.Related",
            "url": "https://[Orgnization].[DevOpsURl].com/[COLLECTIONNAME]/[PROJECTNAME]/_apis/wit/workItems/[NUMBER]"
        }
    }
]
'@ 
$UpdateTask = = $orgURL + $Project.name + '/_apis/wit/workitems/[NUMBER]?api-version=7.0'
$Task = Invoke-RestMethod -Uri $UpdateTask -Body $body -Method Patch -ContentType 'application/json-patch+json' -Headers $Header

#-------------Create Test PBI-------------
$body = @'
[
    {
        "op": "add",
        "path": "/fields/System.Title",
        "from": null,
        "value": "Test Title"
    },
    {
        "op": "add",
        "path": "/fields/System.Description",
        "from": null,
        "value": "Test Description"
    },
    {
        "op": "add",
        "path": "/fields/System.AreaPath",
        "value": "[PROJECT]\\[AREA]\\[SUBAREA]"
    },
    {
        "op": "add",
        "path": "/fields/System.History",
        "from": null,
        "value": "Test History"
    },
    {
        "op": "add",
        "path": "/fields/Microsoft.VSTS.Common.AcceptanceCriteria",
        "type": "html",
        "value": "<body>test<br>test2</body>"
    }
]
'@
#Need to find the required information to set "AreaPath"
#System ID Cannot be Set or Changed

$body = @'
[
    {
        "op": "add",
        "path": "/fields/System.Title",
        "from": null,
        "value": "Test Title"
    },
    {
        "op": "add",
        "path": "/fields/System.AreaPath",
        "value": "[PROJECT]\\[AREA]\\[SUBAREA]"
    }
]
'@
$CreatePBI = $orgURL + $Project.name + '/_apis/wit/workitems/$Product%20Backlog%20Item?api-version=7.0'
$PBI = Invoke-RestMethod -Uri $CreatePBI -Body $body -Method POST -ContentType 'application/json-patch+json' -Headers $Header

#-------------Create Test PBI With Data-------------
$body = @"
[
    {
        "op": "add",
        "path": "/fields/System.Title",
        "from": null,
        "value": "$SystemTitle"
    },
    {
        "op": "add",
        "path": "/fields/System.Description",
        "from": null,
        "value": "$CardDescription"
    },
    {
        "op": "add",
        "path": "/fields/System.AreaPath",
        "value": "[PROJECT]\\$SystemAreaPath"
    },
    {
        "op": "add",
        "path": "/fields/System.History",
        "from": null,
        "value": "$SystemHistory"
    },
    {
        "op": "add",
        "path": "/fields/Microsoft.VSTS.Common.AcceptanceCriteria",
        "type": "html",
        "value": "<body>Card Id: $SystemId<br>Card SN: $CardID<br>Card Attachment Name: $CardAttachmentName</body>"
    }
]
"@
$CreatePBI = $orgURL + $Project.name + '/_apis/wit/workitems/$Product%20Backlog%20Item?api-version=7.0'
$PBI = Invoke-RestMethod -Uri $CreatePBI -Body $body -Method POST -ContentType 'application/json-patch+json' -Headers $Header

#-------------Create Project Area-------------
$Body = @'
{
    "name": "testAreaPath",
    "path": "\\testAreaPath"
}
'@
$CreateArea = $orgURL + $Project.name + '/_apis/wit/classificationnodes/areas?api-version=7.0'
$Area = Invoke-RestMethod -Uri $CreateArea -Body $body -Method POST -ContentType 'application/json' -Headers $Header


$SystemAreaPath | ForEach-Object {
    $BoardName = $_
    $Body = @"
{
    "name": "$BoardName",
    "path": "\\$BoardName"
}
"@
    $CreateArea = $orgURL + $TrelloArchive.name + '/_apis/wit/classificationnodes/areas?api-version=7.0'
    $Area = Invoke-RestMethod -Uri $CreateArea -Body $body -Method POST -ContentType 'application/json' -Headers $Header
}

#-------------Create Related Relationships-------------
$Body = @'
[
    {
        "op": "add",
        "path": "/relations/-",
        "value": {
            "rel": "System.LinkTypes.Related",
            "url": "https://[Orgnization].[DevOpsURl].com/[COLLECTIONNAME]/[PROJECT]/_apis/wit/workitems/[NUMBER1]",
            "attributes": {
                "comment": "This work item is related to the specified work item."
            }
        }
    }
]
'@
$CreateRelationship = $orgURL + $Project.name + '/_apis/wit/workitems/[NUMBER2]?api-version=7.0'
$UpdatePBI = Invoke-RestMethod -Uri $CreateRelationship -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header

$Body = @'
[
    {
        "op": "add",
        "path": "/relations/-",
        "value": {
            "rel": "System.LinkTypes.Related",
            "url": "https://[Orgnization].[DevOpsURl].com/[COLLECTIONNAME]/[PROJECT]/_apis/wit/workitems/[NUMBER2]",
            "attributes": {
                "comment": "This work item is related to the specified work item."
            }
        }
    }
]
'@
$CreateRelationship = $orgURL + $Project.name + '/_apis/wit/workitems/[NUMBER1]?api-version=7.0'
$UpdatePBI = Invoke-RestMethod -Uri $CreateRelationship -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header

#-------------Create Tags-------------
@{
    op    = 'add'
    path  = '/fields/System.Tags'
    value = 'Your Tag'
}

#-------------Create Parent-Child Relationships-------------
#System.LinkTypes.Hierarchy-Forward for Opposite order
$ParentURL = $orgURL + $Project.name + '/_apis/wit/workitems/' + $ParentId
$Body = @"
[
    {
        "op": "add",
        "path": "/relations/-",
        "value": {
            "rel": "System.LinkTypes.Hierarchy-Reverse",
            "url": "$ParentURL",
            "attributes": {
                "comment": "This work item is related to the specified work item."
            }
        }
    }
]
"@
$CreateRelationship = $orgURL + $Project.name + '/_apis/wit/workitems/[NUMBER]?api-version=7.0'
$UpdatePBI = Invoke-RestMethod -Uri $CreateRelationship -Body $Body -Method PATCH -ContentType 'application/json-patch+json' -Headers $Header
