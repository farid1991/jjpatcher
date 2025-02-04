import os
import glob
import shutil
import requests
import zipfile
import subprocess
from bs4 import BeautifulSoup


def rmtree(directory):
    if os.path.exists(directory):
        shutil.rmtree(directory)


def rmfile(file):
    if os.path.exists(file):
        os.remove(file)


def download_file(url, filename):
    response = requests.get(url, stream=True)
    if response.status_code == 200:
        with open(filename, "wb") as file:
            for chunk in response.iter_content(1024):
                file.write(chunk)
        return True
    return False


# Cleanup and prepare directories
rmtree("temp")
rmfile("FASMARM.EXE")
rmfile("FASMARM.ver")
os.mkdir("temp")
os.chdir("temp")

print("Reading FASM downloads list")
fasm_url = "http://flatassembler.net/download.php"
response = requests.get(fasm_url)
if response.status_code != 200:
    raise Exception(f"Can't get {fasm_url} -- {response.status_code}")

dom = BeautifulSoup(response.text, "html.parser")
got_fasm = False

for link in dom.find_all("a", href=True):
    href = link["href"]
    if "fasmw" in href:
        if not href.startswith("http:"):
            href = "http://flatassembler.net/" + href
        print("Downloading fasmw")
        if download_file(href, "fasmw.zip"):
            got_fasm = True
        break

if not got_fasm:
    raise Exception("Can't get fasmw")

print("Downloading fasmarm")
if not download_file(
    "http://arm.flatassembler.net/FASMARM_small.ZIP", "fasmarmsrc.zip"
):
    raise Exception("Can't get fasmarm")

# Extracting archives
with zipfile.ZipFile("fasmw.zip", "r") as zip_ref:
    zip_ref.extractall("fasm")
with zipfile.ZipFile("fasmarmsrc.zip", "r") as zip_ref:
    zip_ref.extractall("fasmarm")

# Applying patches
for patch_file in glob.glob("../*.patch"):
    print(f"Applying patch: {patch_file}")
    subprocess.run(["patch", "-p0", "-i", patch_file], check=True)
    print()

shutil.copytree("fasmarm/source", "fasm/source", dirs_exist_ok=True)
os.chdir("..")

# Compile
print("Compiling")
subprocess.run(
    ["temp/fasm/FASM", "temp/fasm/SOURCE/WIN32/FASMARM.ASM", "FASMARM.EXE"], check=True
)

# Create FASMARM.ver
fasmver = "unknown"
fasmarmver = "unknown"

with open("temp/fasmarm/SOURCE/ARMv8.INC", "r") as fh:
    for line in fh:
        if "ARM_VERSION_STRING equ" in line:
            fasmarmver = line.split('"')[1]
            break

with open("temp/fasm/SOURCE/VERSION.INC", "r") as fh:
    for line in fh:
        if "VERSION_STRING equ" in line:
            fasmver = line.split('"')[1]
            break

with open("FASMARM.ver", "w") as fh:
    fh.write(f"fasm {fasmver}\nfasmarm {fasmarmver}\n")
