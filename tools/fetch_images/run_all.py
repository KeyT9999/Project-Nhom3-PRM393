"""
Master script to collect, process, and structure all product images for SmartStore.
Runs in order:
  1. copy_existing.py
  2. fetch_apple.py
  3. fetch_samsung.py
  4. fetch_xiaomi.py
  5. fetch_oppo.py
  6. generate_sources_csv.py
"""
import subprocess
import sys
import os

scripts = [
    "copy_existing.py",
    "fetch_apple.py",
    "fetch_samsung.py",
    "fetch_xiaomi.py",
    "fetch_oppo.py",
    "generate_sources_csv.py"
]

script_dir = os.path.dirname(os.path.abspath(__file__))

print("Starting complete product images fetch workflow...")
for s in scripts:
    path = os.path.join(script_dir, s)
    print(f"\n==========================================")
    print(f"Running: {s}")
    print(f"==========================================")
    res = subprocess.run([sys.executable, path], cwd=os.path.dirname(script_dir))
    if res.returncode != 0:
        print(f"Error running {s}, exited with code {res.returncode}")
        sys.exit(res.returncode)

print("\nAll product images fetched and SOURCES.csv successfully generated!")
