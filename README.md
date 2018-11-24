# ShowColumns

`ShowColumns` is a module that displays items on screen in columns.

## Features

- Automatic calculation of column widths based on available screen width
- Ability to display any property either by name or using arbitrary expression
- Ability to group items by property value or expression
- Ability to configure colors based on input objects

### Grouping

`Get-ChildItem . | Show-Columns -Property Name -GroupBy { Convert-Path $_.PSParentPath }`

```
C:\Projects\GitHub\ShowColumns
build/ src/ tests/ .editorconfig .gitattributes .gitignore LICENSE.txt README.md ShowColumns.sln

C:\Projects\GitHub\ShowColumns\build
output/ .gitignore Build-Module.ps1

C:\Projects\GitHub\ShowColumns\src
bin/ Commands/ obj/ Show-ChildItemColumns.ps1 ShowColumns.csproj ShowColumns.csproj.user ShowColumns.psd1 ShowColumns.psm1

C:\Projects\GitHub\ShowColumns\tests
bin/ obj/ Properties/ Run.ps1 ShowColumns.Tests.csproj ShowColumns.Tests.csproj.user
```
