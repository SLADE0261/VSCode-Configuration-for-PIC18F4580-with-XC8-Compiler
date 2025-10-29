# VSCode Configuration for PIC18F4580 with XC8 Compiler

This repository contains VSCode configuration files for developing and building projects for the **PIC18F4580** microcontroller using the **Microchip XC8** compiler, without requiring MPLAB X IDE.

## Features

- **IntelliSense Support**: Full code completion and syntax highlighting for PIC18F4580
- **Build Automation**: One-click build using VSCode tasks
- **MPLAB-Compatible**: Uses the same compiler flags and memory reservations as MPLAB X
- **Multi-file Support**: Automatically compiles all `.c` files in your project folder

## Prerequisites

- **VSCode**: [Download here](https://code.visualstudio.com/)
- **Microchip XC8 Compiler v3.00**: [Download here](https://www.microchip.com/en-us/tools-resources/develop/mplab-xc-compilers)
- **Windows OS**: Scripts are configured for Windows (PowerShell)

## File Structure

```
.vscode/
├── build-xc8.ps1              # PowerShell build script
├── c_cpp_properties.json      # IntelliSense configuration
├── settings.json              # VSCode workspace settings
└── tasks.json                 # Build task definition
```

## Configuration Details

### Memory Reservations for PIC18F4580

The build configuration includes two critical memory reservation directives:

```powershell
-mreserve=rom@0x0:0x5FF
-mreserve=rom@0x17F0:0x17FF
```

**Why these reservations?**

1. **`-mreserve=rom@0x0:0x5FF`** (0x000 to 0x5FF)
   - Reserves the **bootloader region** (addresses 0x000 - 0x5FF, 1536 bytes)
   - This is the standard bootloader memory space for PIC18F4580
   - Prevents your application code from overwriting the bootloader
   - Essential if you're using a bootloader for USB/UART programming

2. **`-mreserve=rom@0x17F0:0x17FF`** (0x17F0 to 0x17FF)
   - Reserves the **device ID and configuration words** region
   - Contains chip identification and configuration bits
   - Located at the end of program memory (PIC18F4580 has 32KB = 0x8000 bytes)
   - Configuration bits are actually at 0x300000-0x30000D, but this reserves high memory area

> **Note**: If you're **not using a bootloader**, you can remove the first reservation directive to use the full program memory starting from address 0x000.

### Include Paths

The configuration uses standard XC8 include directories:
- `C:/Program Files/Microchip/xc8/v3.00/pic/include` - Standard C libraries
- `C:/Program Files/Microchip/xc8/v3.00/pic/include/proc` - Processor-specific headers (like `pic18f4580.h`)

## Setup Instructions

### 1. Install XC8 Compiler

Download and install XC8 v3.00 from Microchip's website. The default installation path is:
```
C:\Program Files\Microchip\xc8\v3.00\
```

### 2. Update File Paths

If your XC8 compiler is installed in a **different location**, you'll need to update the paths in these files:

#### **`build-xc8.ps1`**
```powershell
# Line 24: Update compiler path
$compiler = "C:\Program Files\Microchip\xc8\v3.00\bin\xc8-cc.exe"

# Lines 30-31: Update include paths
'-I"C:\Program Files\Microchip\xc8\v3.00\pic\include"',
'-I"C:\Program Files\Microchip\xc8\v3.00\pic\include\proc"'
```

#### **`c_cpp_properties.json`**
```json
"includePath": [
    "${workspaceFolder}/**",
    "C:/Program Files/Microchip/xc8/v3.00/pic/include",
    "C:/Program Files/Microchip/xc8/v3.00/pic/include/c99",
    "C:/Program Files/Microchip/xc8/v3.00/pic/include/proc"
]
```

#### **`settings.json`**
```json
"mplab.clangd.path": "c:\\Program Files\\Microchip\\xc8\\v3.00\\bin\\xc8-clangd.exe"
```

### 3. Copy Configuration Files

1. Copy the `.vscode` folder to the **root of your workspace**
2. Your project structure should look like:
   ```
   your-workspace/
   ├── .vscode/
   │   ├── build-xc8.ps1
   │   ├── c_cpp_properties.json
   │   ├── settings.json
   │   └── tasks.json
   ├── labs/
   │   └── Bit_banging.X/
   │       ├── main.c
   │       └── other_files.c
   └── Class work/
   ```

## Usage

### Building Your Project

1. Press **`Ctrl + Shift + B`** (or `Cmd + Shift + B` on Mac)
2. Enter your project folder path when prompted (e.g., `labs/Bit_banging.X`)
3. The script will:
   - Find all `.c` files in the folder
   - Create a `dist` folder
   - Compile and generate `main.hex` in the `dist` folder

### Build Output

After successful compilation, you'll see:
```
Building project in: labs/Bit_banging.X
Running XC8 compiler...
SUCCESS: HEX file created
HEX file: C:/path/to/your/project/labs/Bit_banging.X/dist/main.hex
```

The generated `.hex` file can be programmed to your PIC18F4580 using:
- PICkit3/PICkit4
- ICD3/ICD4
- MPLAB IPE (Integrated Programming Environment)

## Troubleshooting

### PowerShell Execution Policy Error
If you get an execution policy error, run VSCode as Administrator or run:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Compiler Not Found
Verify the compiler exists:
```powershell
Test-Path "C:\Program Files\Microchip\xc8\v3.00\bin\xc8-cc.exe"
```

### IntelliSense Not Working
1. Reload VSCode window (`Ctrl + Shift + P` → "Reload Window")
2. Verify include paths in `c_cpp_properties.json`
3. Check that `xc8-clangd.exe` path is correct

## Compiler Flags Explained

| Flag | Purpose |
|------|---------|
| `-mcpu=18F4580` | Target microcontroller |
| `-mreserve=rom@0x0:0x5FF` | Reserve bootloader region |
| `-mreserve=rom@0x17F0:0x17FF` | Reserve config/ID region |
| `-I"path"` | Include directory for headers |
| `-o file.hex` | Output HEX file path |

## Future Improvements

### Using Makefiles

Currently, the build process uses PowerShell scripts. For **faster compilation** and better dependency management, consider migrating to **Makefiles**:

**Benefits of Makefiles:**
- **Incremental compilation**: Only recompile changed files
- **Faster builds**: Significant speed improvement for large projects
- **Dependency tracking**: Automatically rebuild when headers change
- **Cross-platform**: Works on Windows (with Make), Linux, and macOS
- **Standard build tool**: More portable and widely understood

**Example Makefile structure:**
```makefile
CC = xc8-cc
MCU = 18F4580
CFLAGS = -mcpu=$(MCU) -mreserve=rom@0x0:0x5FF -mreserve=rom@0x17F0:0x17FF
INCLUDES = -I"path/to/include"

SRCS = $(wildcard *.c)
OBJS = $(SRCS:.c=.p1)
TARGET = dist/main.hex

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@

%.p1: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
```

To implement Makefiles, you would need:
1. Install **GNU Make** for Windows (via MinGW, Cygwin, or Chocolatey)
2. Create a `Makefile` in each project folder
3. Update `tasks.json` to call `make` instead of PowerShell script

## License

This configuration is provided as-is for educational and development purposes.

## Contributing

Feel free to submit issues or pull requests to improve these configurations!

---

**Happy Coding with PIC18F4580! 🚀**