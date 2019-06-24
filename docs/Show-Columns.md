---
external help file: ShowColumns.dll-Help.xml
Module Name: ShowColumns
online version: https://github.com/lpatalas/ShowColumns/blob/master/docs/Show-Columns.md
schema: 2.0.0
---

# Show-Columns

## SYNOPSIS

Displays one property of input objects in autosized columns with optional grouping and styling based on object properties.

## SYNTAX

```
Show-Columns -InputObject <PSObject> [-GroupBy <Object>] -Property <Object> [-GroupHeaderStyle <Object>]
 [-ItemStyle <Object>] [-MinimumColumnCount <Int32>] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet displays input items in columns with optional grouping and styling based on object properties. Each item is displayed as single string which can be either value of any input object property or can be calculated dynamically for each object by user-defined expression.

Column widths are calculated based on lengths of displayed labels. Number of columns is calculated so that as much items as possible fit on screen. `MinimumColumnCount` parameter can be specified to limit the number of columns even if some items are longer than available width for given column count. Not fitting items will have ellipsis added.

Items can be grouped by using `GroupBy` parameter. This command assumes that input is already correctly sorted by this value. If the items are not sorted you can either call `Sort-Object` before passing them to this cmdlet or display them as is but then some group headers will be displayed several times which can be desired or not depending on circumstances.

Colors and text decoration can be specified both for group headers using `GroupHeaderStyle` parameter as well as for individual items using `ItemStyle` parameter.

## EXAMPLES

### Example 1

Display names of items in current directory in columns.

```powershell
PS C:\Example> Get-ChildItem . | Show-Columns -Property Name

file01.txt file03.txt file05.txt file07.txt file09.txt file11.txt file13.txt file15.txt file17.txt file19.txt
file02.txt file04.txt file06.txt file08.txt file10.txt file12.txt file14.txt file16.txt file18.txt file20.txt
```

### Example 2

Display approved verbs grouped by verb group.

```powershell
PS C:\Example> Get-Verb | Show-Columns -Property Verb -GroupBy Group

Common
Add   Copy  Find   Hide Move Optimize Redo   Reset  Select Skip  Switch Watch
Clear Enter Format Join New  Push     Remove Resize Set    Split Undo
Close Exit  Get    Lock Open Pop      Rename Search Show   Step  Unlock

Communications
Connect Disconnect Read Receive Send Write

Data
Backup     Compress    ConvertTo Expand Import     Merge Publish Sync
Checkpoint Convert     Dismount  Export Initialize Mount Restore Unpublish
Compare    ConvertFrom Edit      Group  Limit      Out   Save    Update

Diagnostic
Debug Measure Ping Repair Resolve Test Trace

Lifecycle
Approve Build    Confirm Deploy  Enable  Invoke   Request Resume Stop   Suspend   Unregister
Assert  Complete Deny    Disable Install Register Restart Start  Submit Uninstall Wait

Other
Use

Security
Block Grant Protect Revoke Unblock Unprotect
```

### Example 3

Display items in current directory grouped by custom expression.

```powershell
PS C:\Example> Get-ChildItem | Show-Columns -Property Name -GroupBy { "Group: " + $_.Name.Substring(0,5) }

Group: file0
file01.txt file02.txt file03.txt file04.txt file05.txt file06.txt file07.txt file08.txt file09.txt

Group: file1
file10.txt file11.txt file12.txt file13.txt file14.txt file15.txt file16.txt file17.txt file18.txt file19.txt

Group: file2
file20.txt
```

### Example 4

Displays grouped items in current directory with custom text styles.

```powershell
PS C:\Example> Get-ChildItem `
    | Show-Columns `
        -Property Name `
        -GroupBy { "Group: " + $_.Name.Substring(0,5) } `
        -ItemStyle { if ($_.Extension -eq '.md') { 'Blue' } else { 'Gray' } } `
        -GroupHeaderStyle @{ Foreground = 'Yellow'; Underline = $true }

Group: file0
file01.txt file02.txt file03.txt file04.txt file05.txt file06.txt file07.txt file08.txt file09.txt

Group: file1
file10.txt file11.txt file12.txt file13.txt file14.txt file15.txt file16.txt file17.txt file18.txt file19.txt

Group: file2
file20.txt
```

## PARAMETERS

### -GroupBy

If specified then input objects are grouped based on the value of this property. This command assumes that input is already correctly sorted by this value.

It can be:

* Property name `[String]` - Objects are grouped by property with given name. Example: `Show-Columns -GroupBy 'GroupName'`.
* Expression `[ScriptBlock]` - Objects are grouped by value returned from given script block. Input object can be accessed inside script block by using `$_` automatic variable. Returned value can be of any type not only `string`. Example: `Show-Columns -GroupBy { Convert-Path $_.PSParentPath }`.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GroupHeaderStyle

Defines text color and decoration for group headers.

It can be:

* Console color name `[String]` - foreground is set to given color. Example: `Show-Columns -GroupHeaderStyle 'Yellow'`.
* Console color `[ConsoleColor]` - foreground is set to given `ConsoleColor`. Example: `Show-Columns -GroupHeaderStyle ([ConsoleColor]::Yellow)`.
* Text style `[Hashtable]` - text style is defined by `Foreground`, `Background` and `Underline` keys in given hashtable. Example: `Show-Columns -GroupHeaderStyle @{ Foreground = 'Red'; Background = 'Gray'; Underline = $true }`.
* Script block `[ScriptBlock]` - expression that received input object as `$_` automatic variable and returns one of above values to set item style. Example: `Show-Columns -GroupHeaderStyle { if ($_.GroupName.Length -gt 10) { 'Red' } else { 'Blue' } }`.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject

Input object that should be displayed.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ItemStyle

Defines text color and decoration for displayed items.

It can be:

* Console color name `[String]` - foreground is set to given color. Example: `Show-Columns -ItemStyle 'Yellow'`.
* Console color `[ConsoleColor]` - foreground is set to given `ConsoleColor`. Example: `Show-Columns -ItemStyle ([ConsoleColor]::Yellow)`.
* Text style `[Hashtable]` - text style is defined by `Foreground`, `Background` and `Underline` keys in given hashtable. Example: `Show-Columns -ItemStyle @{ Foreground = 'Red'; Background = 'Gray'; Underline = $true }`.
* Script block `[ScriptBlock]` - expression that received input object as `$_` automatic variable and returns one of above values to set item style. Example: `Show-Columns -ItemStyle { if ($_.PSIsContainer) { 'Blue' } else { 'Gray' } }`.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinimumColumnCount

Defines minimum number of columns that will be displayed even if some items are longer than available column width. Labels longer than column width will have ellipsis added.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Property

Specifies property or dynamically calculated value that will be used as object labels.

It can be:

* Property name `[String]` - Value of given property is displayed. Example: `Show-Columns -Property 'Name'`.
* Expression `[ScriptBlock]` - Value returned from given script block is displayed. Input object can be accessed inside script block by using `$_` automatic variable. If returned value is not of type `String` then `ToString()` method is called on it to get actual label.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Management.Automation.PSObject

You can pipe any object into this command.

## OUTPUTS

### System.Object

This command returns no output.

## NOTES

## RELATED LINKS
