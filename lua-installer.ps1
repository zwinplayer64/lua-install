$LUA_FORMAT = "https://sourceforge.net/projects/luabinaries/files/{0}/Tools%20Executables/lua-{0}_Win{1}_bin.zip/download"
$USER_AGENT = "Wget"
$IS_ADMIN = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$ARCHITECTURE = if([Environment]::Is64BitOperatingSystem){"64"} else {"32"}
$lua_version = Read-Host "Enter the Lua version"
$out_directory = if($IS_ADMIN) {$env:ProgramFiles+"\Lua"} else {$HOME+"\Lua"}
$env_target = if($IS_ADMIN){[EnvironmentVariableTarget]::Machine}else{[EnvironmentVariableTarget]::User}
Write-Host "Downloading to "$out_directory""
# remove the out directory if it exists already
if (Test-Path $out_directory) {
    Remove-Item -LiteralPath $out_directory -Recurse
}
(New-Item -Path $out_directory -ItemType Directory) | Out-Null
Invoke-WebRequest -UserAgent $USER_AGENT -Uri ($LUA_FORMAT -f $lua_version, $ARCHITECTURE) -OutFile $out_directory"\build.zip"
Expand-Archive -Path $out_directory"\build.zip" -DestinationPath $out_directory
Remove-Item -Path $out_directory"\build.zip" -Force
# Remove the version number from the end (e.g lua51.exe -> lua.exe)
Get-ChildItem $out_directory `
    | ? { $_.Name -notlike "*.dll" } | Rename-Item -NewName { $_.Name -replace '\d+','' }
# Add lua.exe, luac.exe etc. to PATH
if ([Environment]::GetEnvironmentVariable("Path", $env_target) -notlike "*$out_directory*") {
    [Environment]::SetEnvironmentVariable(
        "Path",
        [Environment]::GetEnvironmentVariable("Path", $env_target) + ";$out_directory",
        $env_target)
}