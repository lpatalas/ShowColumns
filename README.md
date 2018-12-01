# ShowColumns

`ShowColumns` provides prettier `Get-ChildItem` replacement and ability to display lists of objects in columns.

Available cmdlets are:

* `Show-Columns` - displays any data piped into it in columns with auto-calculated widths.
* `Show-ChildItemColumns` - invokes `Get-ChildItem` with given parameters and displays results using `Show-Columns`.

![Example](./docs/images/animated_example.gif "Example")

## Installation

Install module from PowerShell Gallery:

```
Install-Module ShowColumns -Scope CurrentUser
```

Then import module in your PowerShell profile and overwrite `ls` alias:

```
Import-Module ShowColumns
Set-Alias ls Show-ChildItemColumns -Option AllScope
```

## Features

- Automatic calculation of column widths based on available screen space
- Ability to display any property either by name or using arbitrary expression
- Ability to group items by property value or expression
- Ability to configure colors and text decoration based on input objects
- Drop-in replacement for `Get-ChildItem` cmdlet for convenient use

## Documentation

See [docs/ShowColumns.md](docs/ShowColumns.md) for module documentation.
