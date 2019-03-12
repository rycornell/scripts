param(
    [string]$SrcDir,
    [string]$TargetDir
)

# copy all files that can be safely overwritten

$folders = @('Drivers', 'Keywords', 'Object Repository', 'Scripts', 'settings', 'Test Cases', 'Test Listeners', 'Tools')

foreach ($folder in $folders)
{
    Write-Host "Updating $folder"

    xcopy "$SrcDir\$folder" "$TargetDir\$folder\" /s /y /q

    Write-Host
}

# Profile files cannot be safely overwritten.  We must update the contents of the file by matching variable names.

Write-Host Updating Profiles

foreach ($profile in Get-ChildItem -Path "$SrcDir\Profiles" -File)
{
    Write-Host

    $src = $profile.FullName
    $target = "$TargetDir\Profiles\$profile"

    if (Test-Path $target)
    {
        Write-Host Updating $profile.BaseName profile...
        
        $srcXml = [xml](Get-Content $src)
        $targetXml = [xml](Get-Content $target)

        foreach ($srcVar in $srcXml.GlobalVariableEntities.GlobalVariableEntity)
        {
            $targetVar = $targetXml.GlobalVariableEntities.GlobalVariableEntity | Where-Object { $_.name.ToLower().Trim() -eq $srcVar.name.ToLower().Trim() } | Select-Object
            if ($targetVar)
            {
                Write-Host Updating variable $targetVar.name
                $targetVar.initValue = $srcVar.initValue
            }
            else
            {
                Write-Host Creating variable $srcVar.name
                $newVar = $targetXml.ImportNode($srcVar, $true)
                $targetXml.GlobalVariableEntities.AppendChild($newVar) | Out-Null
            }
        }

        $targetXml.Save($target)

        Write-Host $profile.BaseName profile updated
    }
    else
    {
        Write-Host Creating $profile.BaseName profile

        copy "$src" "$target"
    }    
}