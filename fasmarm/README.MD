# FASMARM Builder

This script automates the process of downloading, patching(SE-specific modifications), and compiling **FASMARM**, The  **FASMARM** package is a free ARM cross-assembler add-on for  **FASM**.

## Prerequisites

Make sure you have the following installed:

- **Python 3.x**
- **`requests`**, **`beautifulsoup4`**, **`shutil`**, **`zipfile`**, and **`subprocess`** modules (install dependencies if needed)
- **GNU Patch** (for applying patches)

- Install dependencies:
   ```
   pip install -r requirements.txt
   ```

## Usage

Run the script with:

```
python fasmarmbuilder.py
```

### Output

- **`FASMARM.EXE`** – The compiled FASMARM binary
- **`FASMARM.ver`** – Contains version details of FASM and FASMARM


## License

This project is open-source and follows the license of **`Flat Assembler`** (**`FASM`** and **`FASMARM`**).

## Credits

- **Flat Assembler (FASM)**: [flatassembler.net](https://flatassembler.net/)
- **FASMARM**: [arm.flatassembler.net](http://arm.flatassembler.net/)

