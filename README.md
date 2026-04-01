# PA1 - Alpine PV Project

Repository für das Alpine PV Projekt - Analyse und Modeling für Photovoltaik-Potenzial in den Alpen.

## Projektstruktur

- **projekt final/**: Finales Projektverzeichnis mit Code, Notebooks und Outputs
- **alten_notebooks/**: Archivierte Notebooks aus früheren Versionen
- **Mögliche_neue_Notebooks/**: Notebooks in Planung oder Entwicklung

## Voraussetzungen

### Miniconda installieren

Falls Miniconda/Anaconda noch nicht installiert ist:

1. **Download**: https://docs.conda.io/projects/miniconda/en/latest/
2. **Installer ausführen** - Standardeinstellungen sind OK
3. **Terminal neu starten** oder PowerShell neu öffnen
4. **Testen**:
   ```powershell
   conda --version
   ```

> **Hinweis für Windows**: Bei Installation wird oft gefragt "Add Miniconda to PATH" - **JA ankreuzen**, damit `conda` Befehle überall verfügbar sind.

## Schnelleinstieg

### 1. Repository clonen

```bash
git clone <repository-url>
cd PA1Git
```

### 2. Conda Environment erstellen

```bash
# Environment aus environment.yml erstellen
conda env create -f environment.yml

# Environment aktivieren
conda activate alpine_pv
```

**Falls Update nötig**: `conda env update -f environment.yml --prune`

### 3. Datensätze von Teams herunterladen

Die Datensätze sind zu groß für GitHub und müssen vom Teams-Ordner `Data` kopiert werden:

```bash
# Kompletten 'data' Ordner von Teams downloaden
# und hierher kopieren:
#   PA1Git/projekt final/data/
```

Nach dem Setup sollte die Struktur so aussehen:
```
projekt final/
├── data/           # ← von Teams kopiert
│   ├── raw/
│   ├── processed/
│   └── validation/
├── notebooks/
├── src/
├── config/
└── outputs/
```

### 4. Projekt starten

Environment muss aktiviert sein:

```powershell
# Falls nicht bereits aktiviert:
conda activate alpine_pv

# Jupyter starten
cd projekt\ final
jupyter lab
# oder: jupyter notebook
```

## Anforderungen

- **Miniconda/Anaconda** (siehe Installationsanleitung oben)
- Python 3.11 (wird durch environment.yml automatisch installiert)
- ~3-5 GB freier Speicherplatz für Datensätze
- Git für Versionskontrolle

Alle Python-Dependencies sind in `environment.yml` definiert und werden durch `conda env create` automatisch installiert.

## Lizenz

Siehe CITATION.cff für die vollständigen Lizenzinformationen.

## Autoren


