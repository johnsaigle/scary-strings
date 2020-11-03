#!/usr/bin/env python3

"""Remove CSV files from project directory."""
import os
path = (os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

delete_list = [f.path for f in os.scandir(path) if f.name.endswith('.csv')]

[os.remove(f) for f in delete_list]
print(f"Deleted {len(delete_list)} CSV files from project root.")