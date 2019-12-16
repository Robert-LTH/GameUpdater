function Get-InstalledEpicGames {
    $KnownEpicGames = @{
        'Fortnite' = 'FortniteGame\Binaries\Win64\FortniteClient-Win64-Shipping_BE.exe'
    }
    $EpicGamesLauncherAppDataPath = Get-ItemProperty -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Epic Games\EpicGamesLauncher" -Name 'AppDataPath' | Select-Object -ExpandProperty AppDataPath
    $BaseEpicPath = Get-Item $EpicGamesLauncherAppDataPath | Select-Object -ExpandProperty Parent | Select-Object -ExpandProperty Parent
    $UnrealLauncherPath = Join-Path -Path $BaseEpicPath.FullName -ChildPath 'UnrealEngineLauncher\LauncherInstalled.dat'

    Get-Content -Path $UnrealLauncherPath -Raw | ConvertFrom-Json | Select-Object -ExpandProperty InstallationList | ForEach-Object {
        if ($_.AppName -in $KnownEpicGames.Keys) {
            "$($_.InstallLocation)\$($KnownEpicGames[$($_.AppName)])"
        }
    }
}
