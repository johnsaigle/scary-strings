# :scream: Scary Strings! :scream:

**Flag potentially dangerous API calls** in source code, a.k.a. lines containing **_scary strings_** from a security perspective!

Use this tool as a first step during a security audit on your web application's source code!

Flagged lines of code are written to a CSV file so you can track your audit progress!

The list of potentially dangerous API calls comes primarily from the [Web Application Hacker's Handbook](http://mdsec.net/wahh/).

The basic lists from this book have been modified and augmented by adding function calls and other scary strings that I've
found in my experience as well as from blog posts.

## Usage

Make sure `pipenv` is installed, then run `pipenv shell`.

### Example 1: Scanning a PHP project for all dangerous function calls

```bash
./scary-strings php wordlists/php/all /path/to/php/project
```

### Example 2: Scan a Python project for object serialization functions

```bash
./scary-strings python wordlists/python/object_serialization /path/to/python/project
```

## Languages Currently Supported

- PHP
- Python (limited wordlists)
