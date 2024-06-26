:ToIncludeFiles foreach ($file in (Get-ChildItem -Path "$PSScriptRoot" -Filter "*-*.ps1" -Recurse)) {
    if ($file.Extension -ne '.ps1')      { continue }  # Skip if the extension is not .ps1
    foreach ($exclusion in '\.[^\.]+\.ps1$') {
        if (-not $exclusion) { continue }
        if ($file.Name -match $exclusion) {
            continue ToIncludeFiles  # Skip excluded files
        }
    }     
    . $file.FullName
}

$myModule = $MyInvocation.MyCommand.ScriptBlock.Module
$ExecutionContext.SessionState.PSVariable.Set($myModule.Name, $myModule)
$myModule.pstypenames.insert(0, $myModule.Name)

$newDriveSplat = @{PSProvider='FileSystem';ErrorAction='Ignore';Scope='Global'}
New-PSDrive -Name $MyModule.Name -Root ($MyModule | Split-Path) @newDriveSplat

if ($home) {
    $myMyModule = "My$($myModule.Name)"
    $myMyModuleRoot = Join-Path $home $myMyModule
    if (Test-Path $myMyModuleRoot) {
        New-PSDrive -Name $myMyModule -Root $myMyModuleRoot @newDriveSplat
    }
}

Export-ModuleMember -Function *-* -Alias * -Variable $myModule.Name
