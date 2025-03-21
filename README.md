# LXD-LXC-Intro
This tutorial is intended for those who want to build their own AI Lab on Linux platform.

## WHY Linux?? WHY LXD-LXC??
- WHY Linux??
  - **盡可能善用免費的開源軟體！** ([節神](https://blog.jason.tools/)銘言：錢能解決的，都不是問題，問題是沒錢！)
  - Linux 的效能，比 Windows 好很多！
  - 一台 Linux 電腦，可以完全免費跑多個 Linux Container，讓一台實體電腦可以發揮出最極致的效用。

- WHY LXD-LXC??
  - 在眾多虛擬機器的方案中，Linux Container 是效能最接近原始 Linux 作業系統的方式。
  - 在眾多 Linux Container 的方案中，LXD-LXC 是進入門檻最低的，只要會了 Linux 的操作，就能輕鬆學會使用 LXD-LXC。
  - LXD-LXC 不只可以讓我們跑 Linux Container，也可以透過 VM 的方式，跑 Windows 等不同的作業系統 (Windows 跑在 Linux 上，比 Windows 直接跑在硬體上，還要穩定。)。
  - 還有其他原因需要用到 LXD-LXC 嗎？<br>
    - 讓線上不容易進行的 Liunx 安裝教學，變得輕鬆與容易。
    - 讓每個教學環境、POC 專案的環境隔離、設定、備份、回復，都輕鬆愉快。<br>
       ![圖片](https://github.com/user-attachments/assets/2d1d494d-3386-4dd7-8041-64d88c1de0db)


---
## 學習目標

- **LXD/LXC 入門：**
  - **1. [安裝與使用 LXD/LXC](https://github.com/robmlee/LXD-LXC-Intro/blob/main/10.%20Install%20LXD-LXC.md)**
  
  - **2. [Using LXD UI to Manage Container/VM](https://github.com/robmlee/LXD-LXC-Intro/blob/main/11.%20Using_LXD_UI.md)**
  (todo)

  - **3. [LXD Backup and Restore Tools](https://github.com/robmlee/LXD-LXC-Intro/blob/main/12.%20LXD_Container_Backup_Restore_Tools.md)**
 
  - **4. [Using Custom Profiles](https://github.com/robmlee/LXD-LXC-Intro/blob/main/13.%20Using_Custom_Profiles.md)**

- **LXD/LXC 應用範例：**
  - **1. [在 RPi 5 上使用 LXD/LXC 建置 Ollama + Open WebUI](https://github.com/robmlee/LXD-LXC-Intro/blob/main/20.%20Install%20Ollama%20and%20OpenWebUI.md#%E5%9C%A8-rpi-5-%E4%B8%8A%E4%BD%BF%E7%94%A8-lxdlxc-%E5%BB%BA%E7%BD%AE-ollama--open-webui)**

  - **2. [在 RPi 5 上使用 LXD/LXC 建置 Agent AI 平台 n8n](https://github.com/robmlee/LXD-LXC-Intro/blob/main/30.%20Install%20n8n.md)**

  - **3. [n8n 與 Ollama 串連](https://github.com/robmlee/LXD-LXC-Intro/blob/main/40.%20Link%20n8n%20node%20to%20Ollama.md)**

---
### Hope this tutorial do help you on learning LXD-LXC.
 
