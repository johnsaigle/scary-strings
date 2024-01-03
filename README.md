# :scream: Scary Strings! :scream:

**Flag potentially dangerous API calls** in source code, a.k.a. lines containing **_scary strings_** from a security perspective!

## Overview
This repository contains a list of strings (usually function names) that are relevant to security auditing, usually because
they perform a sensitive operation like changing the state of a database or accessing the filesystem.

In addition to technology-specific wordlists, there `comments` folder contains strings likely to be related to
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

<!-- To update:
:r!tree wordlists
-->
```
wordlists
├── blockchain
│   └── all
├── comments
│   ├── all
│   ├── derogatory
│   ├── security
│   └── todo
├── cosmossdk
│   ├── abci
│   ├── module-auth
│   ├── module-authz
│   ├── module-bank
│   ├── module-group
│   └── module-staking
├── cryptography
│   └── all
├── go
│   ├── all
│   ├── cryptography
│   ├── db-access
│   ├── deprecated
│   ├── err
│   ├── randomness
│   └── unsafe
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
├── rust
│   ├── all
│   ├── clone
│   ├── panic-macros
│   ├── randomness
│   ├── resource-exhaustion
│   ├── slices
│   ├── unsafe
│   ├── unwrap
│   └── vectors
├── secrets
│   ├── all
│   ├── api-keys
│   └── public-keys
├── solana
│   └── all
└── solidity
    └── all

16 directories, 65 files
```

## Sources

Most of the entries in the wordlists come from my work experience as a security engineer
and penetration tester. References for some of these choices can be found in the git commit
history as well as the project's GitHub Issues.

For many programming of the supported programming languages, the lists come from well-known hacking books
listed below. Note that these books were published in 2011 so some of the information may be dated.

- The [Web Application Hacker's Handbook](http://mdsec.net/wahh/).
- [The Art of Software Security Assessment](https://www.oreilly.com/library/view/the-art-of/0321444426/).

## Similar projects

- [SecLists](https://github.com/danielmiessler/SecLists)
- [Assetnote Wordlists](https://wordlists.assetnote.io/)
- [fuzz.txt](https://github.com/Bo0oM/fuzz.txt)
- [FuzzDB](https://github.com/fuzzdb-project/fuzzdb)
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings)
