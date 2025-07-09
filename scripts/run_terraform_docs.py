#!/usr/bin/env python3

import subprocess
import pathlib

config_path = pathlib.Path(__file__).resolve().parents[1] / ".terraform-docs.yml"
module_dirs = {
    str(p.parent)
    for p in pathlib.Path("modules").rglob("*.tf")
}

for module_dir in sorted(module_dirs):
    print(f"Running terraform-docs in {module_dir}")
    subprocess.run([
        "terraform-docs", "--config", str(config_path), module_dir
    ], check=True)