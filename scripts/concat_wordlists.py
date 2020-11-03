#!/usr/bin/env python3

"""Utility script used to generate the 'all' wordlist for each language by
concatenating all the other wordlists together into a single file.
"""
import os

def concatenate_wordlists(path):
    with open(f"{path}/all", "w") as outfile:
        for f in [f.path for f in os.scandir(path) if f.is_file() and f.name != 'all']:
            with open(f, "r") as infile:
                outfile.write(infile.read().strip())
                outfile.write("\n")

path = (os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + f"/wordlists/")
wordlist_dirs = [f.path for f in os.scandir(path) if f.is_dir()]
[concatenate_wordlists(d) for d in wordlist_dirs]