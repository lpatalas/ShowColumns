---
external help file: ShowColumns-help.xml
Module Name: ShowColumns
online version:
schema: 2.0.0
---

# Show-ChildItemColumns

## SYNOPSIS

Calls `Get-ChildItem` with specified parameters and displays results in columns. Can be aliased as `ls` to use as drop-in replacement for `gci`/`dir`/`ls` in interactive sessions.

## SYNTAX

### LiteralItems
```
Show-ChildItemColumns -LiteralPath <String> [[-Filter] <String>] [-Include <String[]>] [-Exclude <String[]>]
 [-Recurse] [-Depth <UInt32>] [-Force]
 [-Attributes <System.Management.Automation.FlagsExpression`1[System.IO.FileAttributes]>] [-FollowSymlink]
 [-Directory] [-File] [-Hidden] [-ReadOnly] [-System] [<CommonParameters>]
```

### Items
```
Show-ChildItemColumns [[-Path] <String[]>] [[-Filter] <String>] [-Include <String[]>] [-Exclude <String[]>]
 [-Recurse] [-Depth <UInt32>] [-Force]
 [-Attributes <System.Management.Automation.FlagsExpression`1[System.IO.FileAttributes]>] [-FollowSymlink]
 [-Directory] [-File] [-Hidden] [-ReadOnly] [-System] [<CommonParameters>]
```

## DESCRIPTION

Calls `Get-ChildItem` with specified parameters and displays results in columns. Can be aliased as `ls` to use as drop-in replacement for `gci`/`dir`/`ls` in interactive sessions.

All parameters are exactly the same as for `Get-ChildItem` cmdlet and are passed as is. For their description look at `Get-Help Get-ChildItem` or `Get-Help Get-ChildItem -Parameter <parameterName>`.

By default this cmdlet displays value of `PSChildName` property or if it is missing - `Name` property. Items are grouped by `PSParentPath` property. This allows it to work with not only file system but also other PS providers like `alias:`, `HKLM:`/`HKCU:`, etc.

## EXAMPLES

### Example 1

Display names of items in current directory in columns.

```powershell
PS C:\Example> ls

file01.txt file03.txt file05.txt file07.txt file09.txt file11.txt file13.txt file15.txt file17.txt file19.txt
file02.txt file04.txt file06.txt file08.txt file10.txt file12.txt file14.txt file16.txt file18.txt file20.txt
```

### Example 2

Display items in all subdirectories recursively.

```powershell
PS C:\Example> ls -Recurse

C:\Example
subdir1/ subdir2/ file20.md

C:\Example\subdir1
file01.txt file02.txt file03.md file04.md file05.md file06.txt file07.txt file08.md file09.txt

C:\Example\subdir2
file10.md file11.md file12.txt file13.txt file14.txt file15.md file16.txt file17.md file18.md file19.md
```

## PARAMETERS

### -Attributes

See `Get-Help Get-ChildItem -Parameter Attributes`.

```yaml
Type: System.Management.Automation.FlagsExpression`1[System.IO.FileAttributes]
Parameter Sets: (All)
Aliases:
Accepted values: ReadOnly, Hidden, System, Directory, Archive, Device, Normal, Temporary, SparseFile, ReparsePoint, Compressed, Offline, NotContentIndexed, Encrypted, IntegrityStream, NoScrubData

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Depth

See `Get-Help Get-ChildItem -Parameter Depth`.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Directory

See `Get-Help Get-ChildItem -Parameter Directory`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ad, d

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Exclude

See `Get-Help Get-ChildItem -Parameter Exclude`.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -File

See `Get-Help Get-ChildItem -Parameter File`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: af

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter

See `Get-Help Get-ChildItem -Parameter Filter`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FollowSymlink

See `Get-Help Get-ChildItem -Parameter FollowSymlink`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

See `Get-Help Get-ChildItem -Parameter Force`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hidden

See `Get-Help Get-ChildItem -Parameter Hidden`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ah, h

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include

See `Get-Help Get-ChildItem -Parameter Include`.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralPath

See `Get-Help Get-ChildItem -Parameter LiteralPath`.

```yaml
Type: String
Parameter Sets: LiteralItems
Aliases: PSPath

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path

See `Get-Help Get-ChildItem -Parameter Path`.

```yaml
Type: String[]
Parameter Sets: Items
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ReadOnly

See `Get-Help Get-ChildItem -Parameter ReadOnly`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: ar

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse

See `Get-Help Get-ChildItem -Parameter Recurse`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: s

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -System

See `Get-Help Get-ChildItem -Parameter System`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: as

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.String[]

## OUTPUTS

### System.Object

This cmdlet returns no output.

## NOTES

## RELATED LINKS
