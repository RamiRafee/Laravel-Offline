
# Preparing Prerequisites

This Section outlines how to prepare all required files and components to install Docker Desktop on a Windows PC **without internet access**. These steps must be completed on an **online PC** and all files must then be transferred (e.g., using a USB drive) to the offline PC.

---

## ✅ 1. Download Docker Desktop Installer

Download the official Docker Desktop installer from:

- [https://docs.docker.com/desktop/install/windows-install/](https://docs.docker.com/desktop/install/windows-install/)

> 🔽 Save the file as: `Docker Desktop Installer.exe`

---

## ✅ 2. Download WSL 2 Components

Docker requires WSL 2. Download the following components:

- **WSL 2 Kernel Update Package**  
  [https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)

> 🔽 Save the file as: `wsl_update_x64.msi`

---

## ✅ 3. Download a Linux Distribution (Optional but Recommended)

If WSL Linux distributions (like Ubuntu) are not already installed on the offline machine, download one manually:

- Use [https://store.rg-adguard.net](https://store.rg-adguard.net)
  - In the dropdown, choose **ProductId**
  - Paste `9PN20MSR04DW` (for Ubuntu 22.04)
  - Select `Slow` or `Retail` ring and click OK
  - Download the `.appx` or `.msixbundle` file
Alternatively, grab a distro from https://apps.microsoft.com/detail/9pn20msr04dw?hl=en-US&gl=AS

> 🔽 Save the file as: `Ubuntu_2204.appx` or similar

---

## ✅ 4. (Optional) Download Additional Dependencies

Some systems may require extra runtime packages. It’s recommended to also download:

- **Visual C++ Redistributable (x64)**  
  [https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist)

- **PowerShell 7 Installer (Optional)**  
  [https://github.com/PowerShell/PowerShell/releases](https://github.com/PowerShell/PowerShell/releases)

---

## ✅ 5. Copy All Files to USB Drive

Create a folder named `docker-offline-installer` and copy all the following:

- `Docker Desktop Installer.exe`
- `wsl_update_x64.msi`
- `Ubuntu_2204.appx` (or your chosen distro)
- `VC_redist.x64.exe` (if downloaded)
- Any additional setup scripts (optional)

> 🛡️ Now you’re ready to plug the USB into the **offline PC** and proceed with installation.

# 🚀 Laravel Docker Offline/Online Setup Guide

## 0️⃣ Prerequisites

- 🐳 **Docker** and **Docker Compose** installed on **both** machines (online & offline).
- 🌐 On the **online machine**, internet access is required to download and build images.
- 🚫 On the **offline machine**, **no internet** is needed.
- 💻 PowerShell (or compatible shell) to run the setup script.
- ⚙️ **Virtualization enabled in BIOS** (see NOTE below).

---

## 1️⃣ What to do on the Online Machine

1. 📂 Clone or copy your Laravel project and Docker setup files.
2. ▶️ Run the PowerShell script (`Setup.ps1`) and choose **online** mode when prompted.
3. 🔄 The script will:
   - 🛠️ Build all necessary Docker images (PHP, Node, Composer, MySQL).
   - 💾 Save these images as `.tar` files ready for transfer.
   - ✏️ Prepare your `.env` file with **local database** configuration.
4. 💽 Copy the entire project folder **including** the `.tar` image files and `Setup.ps1` onto a USB drive.

---

## 2️⃣ What to do on the Offline Machine

1. 📁 Copy the entire project folder from the USB drive to your offline machine.
2. ✅ Ensure Docker and Docker Compose are installed.
3. ▶️ Run the `Setup.ps1` script and choose **offline** mode when prompted.
4. 🔄 The script will:
   - 📥 Load all Docker images from the `.tar` files into Docker.
   - 📝 Update the Laravel `.env` file with your chosen **remote** or **local** database connection.
   - 🚀 Start your Docker containers for the Laravel app, database, and Node environment.
5. 🛠️ You’re all set to develop and run your Laravel project **fully offline**!

---

## 3️⃣ NOTE: Virtualization must be enabled in BIOS

Docker needs virtualization support enabled in your computer’s BIOS/UEFI settings:

- ⚙️ Enable **Intel VT-x** or **AMD-V** under CPU or Advanced BIOS settings.
- 🛑 If disabled, Docker containers may fail to run properly.
- 💡 Check your motherboard or PC manual for instructions on enabling virtualization.

---
# 💡 Another Method with UsbWebServer (Not Recomended)
**UsbWebServer Official Manual**  
  [Read UsbWebServer Official Manual](https://www.usbwebserver.net/downloads/manual.pdf)

If you encounter any issues, please verify Docker installation and virtualization settings before troubleshooting the project.

Happy coding! 🎉🐾

