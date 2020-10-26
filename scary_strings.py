#!/usr/bin/env python3
import argparse
import datetime
import re
import os

from halo import Halo


def build_list_of_file_extensions(language):
    filepath = os.path.dirname(os.path.abspath(
        __file__)) + f"/extensions/{language}"
    with open(filepath, 'r') as f:
        return list(map(str.strip, f.readlines()))


def build_list_of_files_to_scan(folder, extensions):
    return [os.path.join(root, filename)
            for root, dirs, files in os.walk(folder)
            for filename in files if filename.endswith(tuple(extensions))]


def scan_file(filepath, function_names, language):
    lines = []
    with open(filepath, 'r', encoding='utf8') as f:
        lines = list(map(str.strip, f.read().splitlines()))
    num_lines = len(lines)

    output = []
    for line_number, haystack in zip(range(0, num_lines), lines):

        for needle in function_names:
            # Add an opening bracket to match on function calls only
            pattern = f"{needle}\("
            match = re.search(pattern, haystack)

            if language == 'php':
                """A special consideration is made for PHP superglobals. They aren't really functions
                (or, at least, the syntax does not match function syntax) so we need to build a regex
                that will match on square brackets instead of round parentheses.
                """
                suplerglobal_pattern = f"{needle}\["
                match = re.search(pattern, haystack) or re.search(
                    suplerglobal_pattern, haystack)

            if match:
                output.append(
                    ','.join(
                        list(map(str, [needle, line_number, haystack, filepath]))))

    return output


# args: Path, wordlist, exclude, verbose
parser = argparse.ArgumentParser(description='Spooky, scary strings')
parser.add_argument('language', metavar='language',
                    help='The programming language to examine. Supported: PHP, Python')
# TODO This can probably be default to ALL for supported languages
parser.add_argument('wordlist', metavar='wordlist',
                    help='Text file containing a list of dangerous strings')
parser.add_argument('path', metavar='path',
                    help='The directory containing files to scan')
parser.add_argument('--outfile', metavar='outfile', default=f'scarystrings-{datetime.datetime.now()}.csv', nargs='?',
                    help='The file into which the results will be written.')
args = parser.parse_args()

# Print header
print('😱 😱 😱 S C A R Y  *  S T R I N G S 😱 😱 😱')
print("Source code analysis tool, Copyright (C) 2020 by John Saigle")
print("Analyse source code for potentially dangerous APIs, or 'scary strings'!")
print("This is free software. <https://github.com/johnsaigle/scary-strings>\n")

# Build scary string list
function_names = []
with open(args.wordlist, 'r') as word_file:
    function_names = word_file.read().splitlines()

language = args.language.lower()

if len(function_names) == 0:
    raise SystemExit('ERROR: Wordlist file is empty')

# Get a list of files to examine
files_to_scan = build_list_of_files_to_scan(
    args.path, build_list_of_file_extensions(args.language))

print(f"Found {len(files_to_scan)} files. Starting scan...")
with Halo(spinner='dots'):
    result = [scan_file(file_to_scan, function_names, language)
              for file_to_scan in files_to_scan]

# flatten result
flat_list = [item for sublist in result for item in sublist]

if len(flat_list) == 0:
    exit("Scan complete. No scary strings found!")

print(f"Scan complete. Writing results to {args.outfile}")

with open(args.outfile, 'w') as out:
    out.write(
        ",".join(['Function Name', 'Line Number', 'Line/This ', 'Filepath']))
    out.write("\n")
    out.write("\n".join(flat_list))
