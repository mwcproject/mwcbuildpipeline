
Perform local Windows build using mwcbuildpipeline
==================================================

The scripts and files in the mwcbuildpipeline repository can be used to create a local build of MWC Qt Wallet. The following information will help guide you in setting up a Windows build on your local Windows machine. The following steps were tested on a machine running Windows 10 Pro.

## Prerequisites
* Visual Studio 2019 Community Edition (or Enterprise Edition, if you own it)
  * https://visualstudio.microsoft.com/downloads/
* Git (windows 64-bit)
  * https://git-scm.com/downloads
* Git for Windows (includes bash terminal emulator)
  * https://gitforwindows.org/
* Chocolatey
  * https://chocolatey.org/install
  * Download and install but wait to finish setup below once Powershell is running.
* NSIS (Nullsoft Scriptable Install System)
  * https://nsis.sourceforge.io/Download

## Environment Check
* Ensure Powershell for Windows is enabled
  * In the Windows bottom tool bar search box type:
    * control panel
  * Open the Control Panel application
  * Select: Programs and Features
  * In the left hand task window select: Turn Windows features on or off
  * Scroll down and check Windows Powershell 2.0
  * Click OK
* Start up a git bash terminal window as administrator
  * In the Windows bottom tool bar search box type: bash
  * You should see Git Bash listed.
  * Select: run as administrator
* Run Powershell in the git bash terminal window
  * Type: powershell
  * If Windows Powershell does not start, or comes up wihtout a prompt, disable then then re-enable Windows Powershell using the control panel. Then re-open your git bash terminal window and try running powershell again.
* Ensure your path environment variable is set up correctly for the prerequisite applications.
  * Type: which makensis
  * Type: which make
  * Type: which choco
  * Type: which git
* If which cannot find any of the above executables, ensure the user or system PATH environment variable contains the application directory or application bin directory for the executable in question.
  * Open the Control Panel app (see above where we have done this once before)
  * Select: System
  * Select: Advanced Settings
  * Add appropriate path to PATH environment variable
* Finish Chocolately Setup
  * In the powershell window
    * Type: Get-ExecutionPolicy
    * If it returns 'Restricted', then run:
      * Set-ExecutionPolicy AllSigned
    * Copy the following command string into your powershell window and run it:
      * Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

## Build MWC Qt Wallet
### Set up the build directory:
* git clone https://github.com/mwcproject/mwcbuildpipeline
* cd mwcbuildpipeline
* .\setup_windows.bat
  * sets up Qt
  * installs rust
  * installs llvm
  * installs openssl

### Install additional tools needed to build:
* choco install -y make
* choco install -y vim
* refreshenv

Note: The first time you set up your Windows build environment by running set_windows.bat, you should restart your computer as openssl will probably require it. After rebooting, open your git bash terminal window again, run Powershell in it, and cd into the mwcbuildpipeline directory.

### Edit (with vim) build-qt-wallet-windows.bat
  * Add the following line above the line: set RUSTFLAGS=-Ctarget-cpu=%CPU_CORE%
    * set CPU_CORE=x86-64

You should end up with the following in build-qt-wallet-windows.bat
* set CPU_CORE=x86-64
* set RUSTFLAGS=-Ctarget-cpu=%CPU_CORE%

### Start the build:
* .\build-qt-wallet-windows.bat \<date\>.\<build_number\>

For example: .\build-qt-wallet-windows.bat 20201127.1

The build script clones each of the MWC repositories needed to build MWC Qt Wallet and builds them.<br/>

The final installation file for MWC Qt Wallet will be located in:<br/>
* mwcbuildpipeline/target/nsis

The installation file will be named:<br/>
* mwc-qt-wallet-\<version\>.\<date\>.\<build\>-win64-setup.exe


