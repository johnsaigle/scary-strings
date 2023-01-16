# :scream: Scary Strings! :scream:

**Flag potentially dangerous API calls** in source code, a.k.a. lines containing **_scary strings_** from a security perspective!

## Overview
This repository contains a list of strings (usually function names) that are relevant to security auditing, usually because
they perform a sensitive operation like changing the state of a database or accessing the filesystem.

In addition to language-specific wordlists, there `comments` folder contains strings likely to be related to
developer notes left in source code.

### For Hackers
Search for these strings and generate ideas for hacking. Maybe you can spot where the database is being modified and work
your way backward to finding a SQL injection. Maybe a 'TODO' message reveals a bug that the devs didn't fix. The possibilities
are endless. Save yourself time and repetitive-stress injury by jumping to the dangerous parts of the app. This collection
of wordlists will show you all thermal exhaust ports on the Death Star so you don't have to explore the whole thing.

### For Developers
Scanning for these strings is a good way to improve the security of your app. Typically there are good practices and patterns
for doing things safely according to the language you're using. If you can verify that such function calls are handled safely, 
great! Your app is more secure than when you started.

### Wordlists

```
wordlists
├── comments
│   ├── all
│   ├── derogatory
│   ├── security
│   └── todo
├── cryptography
│   └── all
├── go
│   ├── all
│   ├── cryptography
│   ├── deprecated
│   ├── err
│   └── randomness
├── java
│   ├── db_access
│   ├── file_access
│   ├── file_inclusion
│   ├── os_command_execution
│   └── url_redirect
├── javascript
│   ├── all
│   ├── deprecated
│   ├── dom-xss
│   ├── generic
│   ├── randomness
│   ├── react
│   └── redos
├── linters
│   └── all
├── perl
│   └── all
├── php
│   ├── all
│   ├── db_access
│   ├── dynamic_code_execution
│   ├── file_access
│   ├── file_inclusion
│   ├── os_command_execution
│   ├── randomness
│   ├── redos
│   ├── serialization
│   ├── sockets
│   ├── superglobals
│   ├── url_redirection
│   └── xxe
├── python
│   ├── all
│   ├── bypass
│   ├── object_serialization
│   ├── os_command_execution
│   └── string_formatting
└── rust
    ├── all
    ├── clone
    ├── panic-macros
    ├── resource-exhaustion
    ├── slices
    ├── unsafe
    ├── unwrap
    └── vectors
```

## References
The list of potentially dangerous API calls comes primarily from:

- The [Web Application Hacker's Handbook](http://mdsec.net/wahh/).
- The Art of Software Security Assessment

The basic lists from this book have been modified and augmented by adding function calls and other scary strings that I've
found in my experience as well as from blog posts.

## Supported languages

The wordlists for PHP and Python are more or less worked out and robust. The other languages are works-in-progress
either because they're less my area of expertise or I haven't made the time to flesh them out.

## Similar projects

- [SecLists](https://github.com/danielmiessler/SecLists)
- [Assetnote Wordlists](https://wordlists.assetnote.io/)
- [fuzz.txt](https://github.com/Bo0oM/fuzz.txt)
- [FuzzDB](https://github.com/fuzzdb-project/fuzzdb)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)

## History

This project used to be a source code scanner written in Perl6/Raku/Camilla, 
then I rewrote it in Python, and then I realized that clever usage of `grep` (or `rg`) 
basically does the same thing my tool was doing.

As a result I decided to archive the code part and convert this into a wordlists repository
similar to other well-known projects in the hacking world. 
