# GPU Cache Cleaner

> [!WARNING]
> **DISCLAIMER:** This script is **NOT** an official tool provided by Bohemia Interactive, AMD, NVIDIA, Microsoft, or any other organization. This is a community-created utility provided "as-is." 
> 
> **USE AT YOUR OWN RISK.** The author is not responsible for any system instability, data loss, or software conflicts. It is recommended to create a System Restore point before running scripts that modify system files.

---

## 🚀 Features
- **UAC Self-Elevation:** Automatically requests Administrator privileges to handle protected system folders.
- **Service Management:** Safely stops and restarts NVIDIA Container services to unlock "in-use" shader files.
- **Deep Clean:** Purges DirectX (D3D), OpenGL, NVIDIA/AMD caches, and Windows Temp/Prefetch folders.
- **Logging:** Generates a detailed `GPU_Cleanup_Log.txt` on your Desktop for transparency and troubleshooting.

## 🛠 Usage (Standard Version)
This version provides visual feedback in a console window.

1. Download `ClearGPU.ps1` and `ClearGPU.bat` and keep them in the same folder.
2. Run **`ClearGPU.bat`**.
3. Accept the UAC prompt.
4. Review the console output to see which files were cleared and which were "In Use" (skipped).
5. **Pro-Tip:** Press `Win + Ctrl + Shift + B` after the script finishes to manually refresh the Windows driver stack.

---

## 🤫 Silent Mode (Advanced)
For users who want to run the cleanup without a console window appearing.

> [!TIP]
> **Stream Deck Users:** Silent Mode is ideal for initiating a cleanup via an **Elgato Stream Deck**. By mapping `RunHidden.bat` to a button, you can purge your caches mid-session without a command prompt window interrupting your gameplay or stream.

> [!CAUTION]
> **TEST FIRST:** It is highly recommended to run the **Standard Version** at least once before using Silent Mode. This ensures you can verify the script works correctly on your hardware before hiding the process.

### How to use Silent Mode:
1. Ensure `ClearGPUSilent.ps1` and `RunHidden.bat` are in the same folder.
2. Run **`RunHidden.bat`**. 
3. After accepting the UAC prompt, the script will execute entirely in the background.
4. To verify the cleanup finished, check the timestamp in `GPU_Cleanup_Log.txt` on your Desktop.

---

## 📝 License
Distributed under the MIT License. See `LICENSE` for more information.