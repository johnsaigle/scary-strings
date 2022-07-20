# :scream: Scary Strings! :scream:

**Flag potentially dangerous API calls** in source code, a.k.a. lines containing **_scary strings_** from a security perspective!

## Overview
Use this tool as a first step during a security audit on your web application's source code!

The list of potentially dangerous API calls comes primarily from:

- The [Web Application Hacker's Handbook](http://mdsec.net/wahh/).
- The Art of Software Security Assessment

The basic lists from this book have been modified and augmented by adding function calls and other scary strings that I've
found in my experience as well as from blog posts.

## Supported languages

The wordlists for PHP and Python are more or less worked out and robust. The other languages are works-in-progress
either because they're less my area of expertise or I haven't made the time to flesh them out.

In addition to language-specific wordlists, there `comments` folder contains strings likely to be related to
developer notes left in source code. These are always a great place to look into when searching for vulnerabilities!

## History

This project used to be a source code scanner written in Perl6/Raku/Camilla, 
then I rewrote it in Python, and then I realized that clever usage of `grep` (or `rg`) 
basically does the same thing my tool was doing.

As a result I decided to archive the code part and convert this into a wordlists repository
similar to projects like Dan Miessler's [SecLists](https://github.com/danielmiessler/SecLists)
