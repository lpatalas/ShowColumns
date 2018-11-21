Describe 'Example test' {
    It 'should work' {
        1 | Should -Be 1
    }
}

Describe 'Show-Columns' {
    It 'should not produce any output when input is empty' {
        $output = @() | Show-Columns -Property Name 6>&1
        $output | Should -BeNullOrEmpty
    }

    It 'should list items on single line without any grouping' {
        $items = @(
            @{ Name = 'First' }
            @{ Name = 'Second' }
            @{ Name = 'Third' }
        )

        $output = $items | Show-Columns -Property Name 6>&1
        $output | Should -Be 'First Second Third'
    }

    It 'should list correctly display items in columns' {
        $items = @(1..100 | ForEach-Object {
            @{ Name = "item$_" }
        })
        
        $output = $items | Show-Columns -Property Name 6>&1
        $output | Should -Be 'item1 item2 item3'
    }
}
