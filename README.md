# 💾 Disk Monitor

Egyszerű tárhely-figyelő rendszer: PowerShell script + statikus HTML dashboard.

## Mappaszerkezet

```
PowerShell_Healthcenter/
├── files/
│   ├── index.html               ← Dashboard (böngészőben megnyitni)
│   └── json/                    ← Ide kerülnek a riportok
│       ├── index.json           ← Manifest (automatikusan generálódik)
│       ├── WS-BUDAPEST-01.json  ← Minta riportok
│       ├── SRV-DB-PROD.json
│       └── SRV-FILES-02.json
├── Collect-DiskInfo.ps1         ← Futtatni minden gépen
├── Generate-Index.ps1           ← Kézi index.json frissítés (opcionális)
└── README.md
```

## Használat

### 1. Adatgyűjtés (minden gépen)
```powershell
.\Collect-DiskInfo.ps1
```
A script a `C:\Users\Fiok_1\Downloads\PowerShell_Healthcenter\files\json\` mappába
menti a `GÉPNÉV.json` fájlt, és **automatikusan frissíti az `index.json`-t** is.

Opcionálisan megadhatsz más kimeneti mappát:
```powershell
.\Collect-DiskInfo.ps1 -OutputFolder "\\fileserver\reports\json"
```

### 2. Dashboard megnyitása
Nyisd meg a `files\index.html` fájlt böngészőben.

> ⚠️ Közvetlenül fájlként (`file://`) megnyitva a böngésző CORS
> szabályai blokkolhatják a JSON betöltést.
> Használj egy egyszerű webszervert:
> ```powershell
> cd C:\Users\Fiok_1\Downloads\PowerShell_Healthcenter\files
> python -m http.server 8080
> # vagy Node.js:  npx serve .
> ```
> Majd nyisd meg: `http://localhost:8080`

### 3. Kézi manifest frissítés (opcionális)
Ha kézzel másolsz JSON-t a mappába (script futtatása nélkül):
```powershell
.\Generate-Index.ps1
```

## JSON séma

```json
{
  "computerName": "GÉPNÉV",
  "collectedAt":  "2026-05-06 14:32:10",
  "drives": [
    {
      "letter":      "C:",
      "type":        "Local Disk",
      "label":       "Windows",
      "fileSystem":  "NTFS",
      "totalBytes":  512110190592,
      "usedBytes":   389445959680,
      "freeBytes":   122664230912,
      "usedPercent": 76.1
    }
  ]
}
```

## Színkódok

| Foglaltság | Szín   | Jelentés        |
|-----------|--------|-----------------|
| 0–74%     | 🟢 Zöld  | Rendben         |
| 75–89%    | 🟡 Sárga | Figyelmeztetés  |
| 90–100%   | 🔴 Piros | Kritikus        |

A kártyák a kritikusság szerint rendeződnek: a piros státuszú gépek felül jelennek meg.
