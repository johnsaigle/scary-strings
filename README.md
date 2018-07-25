# :scream: Scary Strings! :scream:

**Flag potentially dangerous API calls** in source code, a.k.a. lines containing **_scary strings_** from a security perspective!

_Note: Currently only PHP is supported as that is what I mostly develop in, but the code is easily extensible._

Use this tool as a first step during a security audit on your web application's source code!

Flagged lines of code are written to a CSV file so you can track your audit progress!

The list of potentially dangerous API calls comes from the [Web Application Hacker's Handbook](http://mdsec.net/wahh/)!
