#!/usr/bin/env python3
"""
NetO build helper.

The repository already contains a maintained standalone NetO.lua.
This tool validates that the expected source layout is present and copies the
standalone build into dist/NetO.lua for packaging.
"""

from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
DIST = ROOT / "dist"
SOURCE = ROOT / "NetO.lua"

required = [
    ROOT / "src" / "NetO.lua",
    ROOT / "src" / "core" / "Assembly.lua",
    ROOT / "src" / "core" / "Hidden.lua",
    ROOT / "src" / "core" / "Snapshot.lua",
    ROOT / "src" / "core" / "Tracker.lua",
    ROOT / "src" / "adapters" / "sUNC.lua",
    ROOT / "src" / "adapters" / "Vanilla.lua",
]

missing = [str(path.relative_to(ROOT)) for path in required if not path.exists()]
if missing:
    raise SystemExit("Missing required source files: " + ", ".join(missing))

DIST.mkdir(exist_ok=True)
shutil.copy2(SOURCE, DIST / "NetO.lua")
print("Built dist/NetO.lua")
