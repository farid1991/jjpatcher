@echo off
setlocal enabledelayedexpansion

:: Define targets here
set TARGETS=J10_R7CA061 J20_R7CA064 J108_R7EA011 U10_R7AA071 U10_R7BA084 U100_R7AA076 W20_R7DA062 W705_R1GA031 W995_R1HA035

for %%T in (%TARGETS%) do (
    echo Building for %%T...
    mkdir "build\%%T" 2>nul
    set target=%%T
    "fasmarm\FASMARM.EXE" arm.asm "build\%%T\arm.bin"
    if errorlevel 1 (
        echo Failed to build for %%T
        pause
        exit /b 1
    )

    :: Create a patched JAR for each target
    echo Creating %%T Patcher.jar...
    copy /Y "patcher\Patcher.jar" "build\%%T\Patcher.jar" >nul
    copy /Y "patcher\Patcher.jad" "build\%%T\Patcher.jad" >nul
    jar uf "build\%%T\Patcher.jar" -C "build\%%T" arm.bin
    echo done
)

echo Build and packaging completed successfully!
pause
