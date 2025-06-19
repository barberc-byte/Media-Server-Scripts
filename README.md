# Media Server Scripts 🎬📁

This repository contains PowerShell scripts I've written to automate and maintain my personal media server. These help manage HEVC encoding, remove unwanted files, and organize content efficiently.

## 🔧 Scripts

| Script Name                      | Description                                         |
|----------------------------------|-----------------------------------------------------|
| `SmartHEVCEncode_CPU.ps1`        | Re-encodes video files to H.265 (HEVC) using CPU.   |
| `Movies Folders.ps1`             | Cleans and standardizes movie folder structures.    |
| `Tv Shows unwanted files.ps1`    | Deletes sample files, nfo, extras, etc.             |

## 🗂 Folder Structure

- `scripts/encoding`: Encoding-related automation
- `scripts/cleanup`: File/folder cleanup tasks
- `docs/`: Optional extended documentation

## 🛠 Requirements

- PowerShell 5.x+
- FFmpeg (for encoding)
- Basic understanding of media library structure

## 🚀 How to Use

Each script is self-contained. You can run them via PowerShell like this:

```powershell
.\scripts\cleanup\Movies Folders.ps1
