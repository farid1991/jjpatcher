# A2 Runtime Patcher Build Script
This batch script automates the process of assembling `arm.bin` payload for `jjpatcher`.

`jjpatcher` is java applet to patch **Sony Ericsson A2 firmware**.

## Features
- Builds `arm.bin` for multiple targets using **FASMARM**.
- Automatically creates build directories.
- Packages the compiled `arm.bin` into a `Patcher.jar` file for each target.

## Prerequisites
Ensure you have the following installed and configured:
- **FASMARM** Placed in `fasmarm/` (build using `fasmarmbuilder.py`)
- **Python 3.x** for build `FASMARM` (Flat Assembler for ARM)
- **Java Development Kit (JDK)** for unpack and repack `Patcher.jar`
- **Windows OS**

## Target Devices
The script currently supports the following targets:
- **J10_R7CA061**
- **J20_R7CA064**
- **J108_R7EA011**
- **U10_R7AA071**
- **U10_R7BA084**
- **U100_R7AA076**
- **W20_R7DA062**
- **W705_R1GA031**
- **W995_R1HA035**

## Usage
1. Run the script:
   ```
   build.bat
   ```
2. The compiled binaries and patched JARs will be stored in the `build/` directory under respective target folders.

## Output
Each target directory inside `build/` will contain:
- `arm.bin` – Compiled ARM binary payload
- `Patcher.jar` – Patched `jjpatcher` with new `arm.bin`
- `Patcher.jad` – `jjpatcher` descriptor file

## Instalation
For more information, visit the following link:  
[MobileFree Forum - a2 runtime patcher](https://mobilefree.justdanpo.ru/newbb_plus/viewtopic.php?topic_id=3591)

## Post Install
Patch `jab3b4ded00cb34b3cc77a6699f87ac10753fa701.b` created by `jjpatcher` using [bpatch](https://github.com/farid1991/bpatch)

## Copyright
- `jjpatcher 0.4` [(c) den_po](https://github.com/justdanpo)
- `arm.bin` [(c) IronMaster](https://github.com/IronMaster)