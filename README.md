# Media Server Scripts 🎬📁

This repository contains PowerShell scripts I've written to automate and maintain my personal media server. These help manage HEVC encoding, remove unwanted files, and organize content efficiently.

## 🔧 Scripts

| Script Name                      | Description                                         |
|----------------------------------|-----------------------------------------------------|
| `SmartHEVCEncode_CPU.ps1`        | Re-encodes video files to H.265 (HEVC) using CPU.   |
| `Movies Folders.ps1`             | Cleans and standardizes movie folder structures.    |
| `Tv Shows unwanted files.ps1`    | Deletes sample files, nfo, extras, etc.             |
| `ChangingRecentlyAdded.py`       | Python utility that updates Plex addedAt timestamps based on labels you apply.            |



## 🧠 Plex Metadata Tools (Python)

This section includes a Python script that automatically updates the **addedAt** timestamp for Plex items based on labels you apply. It helps reorganize “Recently Added,” repair metadata order, or intentionally surface items without modifying any files.

### 📄 Script: `update_addedAt.py`

### 🔍 What This Script Does

* Connects to Plex using a long-lived **X-Plex-Token**
* Scans all movie and TV show libraries
* Finds items with the labels:

  * `HOTFOR48H`
  * `ADDED1MONTHAGO`
* Updates their `addedAt` timestamp to:

  * **+48 hours** (pushes item to the top of "Recently Added")
  * **−30 days** (pushes item down the list)
* Removes the label after applying the change
* Does not touch music or photos

This makes it a completely non-destructive way to re-sort Plex without modifying any media files.

---

### 🛠 Requirements

* Python 3.8+
* `plexapi`

Install with:

```bash
pip install plexapi
```

You’ll also need a **long-lived Plex token**, which you can find by inspecting any network call in the Plex Web UI (`X-Plex-Token`).

---

Add in your Plex IP and token to the script

### 🚀 Running the Script

```bash
python ChangingRecentlyAdded.py
```

You’ll see a clean log output showing:

* which items were found
* what their new timestamps are
* which labels were removed
* any errors (bad token, wrong URL, etc.)

---

### 🏷 Triggering Updates with Labels

To mark an item for update:

1. Open the movie/episode in Plex
2. Add the label:

   * `HOTFOR48H` → sets addedAt 48 hours in the future
   * `ADDED1MONTHAGO` → sets addedAt 30 days in the past

Run the script when you're ready, and it will process everything at once.

---

### 📌 Useful For

* Rebuilding Recently Added after migrating your libraries
* Fixing items Plex added out of order
* Pushing a show to the top without touching files
* Making older episodes “disappear” from the front page
* Metadata cleanup during reorganizations

---

If you want, I can also create a standalone `docs/update_addedAt.md` with extended examples and token-finding instructions.


