# :scream: Scary Strings! :scream:

> **Usage**: `perl scary-strings.pl <source_directory> -w(ordlist) WORDLIST -v(erbose)`

**Flag potentially dangerous API calls** in PHP code, a.k.a. lines containing **_scary strings_** from a security perspective!

Use this tool as a first step during a security audit on your web application's source code!

Flagged lines of code are printed in a tab-delimited format and can thus be easily imported into a spreadsheet!

The list of potentially dangerous API calls comes from the [Web Application Hacker's Handbook](http://mdsec.net/wahh/)!
