# # Simple XC8 build script
# param(
#     [string]$ProjectFolder = "labs/Bit_banging.X"
# )

# Write-Host "Building project in: $ProjectFolder"

# # Get project path
# $folderPath = Resolve-Path $ProjectFolder

# # Create dist folder
# $dist = Join-Path $folderPath "dist"
# if (!(Test-Path $dist)) {
#     New-Item -Path $dist -ItemType Directory | Out-Null
# }

# # Find C files
# $srcs = Get-ChildItem -Path $folderPath -Filter "*.c" | ForEach-Object { $_.FullName }

# # Output file
# $outHex = Join-Path $dist "main.hex"

# # Compiler
# $compiler = "C:\Program Files\Microchip\xc8\v3.00\bin\xc8-cc.exe"

# # Arguments
# $args = @(
#     "-mcpu=18F4580",
#     "-mreserve=rom@0x0:0x5FF", 
#     "-mreserve=rom@0x17F0:0x17FF",
#     '-I"C:\Program Files\Microchip\xc8\v3.00\pic\include"',
#     '-I"C:\Program Files\Microchip\xc8\v3.00\pic\include\proc"'
# ) + $srcs + @("-o", $outHex)

# Write-Host "Running XC8 compiler..."
# & $compiler @args

# if (Test-Path $outHex) {
#     Write-Host "SUCCESS: HEX file created" -ForegroundColor Green
# } else {
#     Write-Host "BUILD FAILED" -ForegroundColor Red
#     exit 1
# }

# Simple XC8 build script
param(
    [string]$ProjectFolder = "labs/Bit_banging.X"
)

Write-Host "Building project in: $ProjectFolder"

# Get project path
$folderPath = Resolve-Path $ProjectFolder

# Create dist folder
$dist = Join-Path $folderPath "dist"
if (!(Test-Path $dist)) {
    New-Item -Path $dist -ItemType Directory | Out-Null
}

# Find C files
$srcs = Get-ChildItem -Path $folderPath -Filter "*.c" | ForEach-Object { $_.FullName }

# Output file
$outHex = Join-Path $dist "main.hex"

# Compiler
$compiler = "C:\Program Files\Microchip\xc8\v3.00\bin\xc8-cc.exe"

# Arguments
$args = @(
    "-mcpu=18F4580",
    "-mreserve=rom@0x0:0x5FF", 
    "-mreserve=rom@0x17F0:0x17FF",
    '-I"C:\Program Files\Microchip\xc8\v3.00\pic\include"',
    '-I"C:\Program Files\Microchip\xc8\v3.00\pic\include\proc"'
) + $srcs + @("-o", $outHex)

# Remove old hex file if it exists
if (Test-Path $outHex) {
    Remove-Item $outHex -Force
}

Write-Host "Running XC8 compiler..."
& $compiler @args

# Check if compiler succeeded by looking for new hex file
if (Test-Path $outHex) {
    $fullPath = (Resolve-Path $outHex).Path -replace '\\', '/'
    Write-Host "SUCCESS: HEX file created" -ForegroundColor Green
    Write-Host "HEX file: $fullPath" -ForegroundColor Cyan
} else {
    Write-Host "FAILURE: No HEX file generated" -ForegroundColor Red
    exit 1
}