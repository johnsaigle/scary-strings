#!/usr/bin/env perl6

sub MAIN(
    Str $path_to_directory, 
    Str $wordlist = 'wordlists/php/all.txt', 
    Str $verbose = ''
) {
    # Print header
    say '===>>>>>   PHP SCARY STRINGS   <<<<<===', "\n";
    say "Source code analysis tool, Copyright (C) 2017 by John Saigle";
    say "Analyse source code for potentially dangerous APIs, or 'scary strings'!";
    say "This is free software. <https://github.com/johnsaigle/scary-strings>";

    if ! ($wordlist.IO ~~ :f) {
        say "$wordlist is not a file.";
        exit;
    }
    if ! ($path_to_directory.IO ~~ :d) {
        say "$path_to_directory is not a directory.";
        exit;
    }
    my @contents = $wordlist.IO.lines;

    say recurse_through_directories(
        $path_to_directory, 
        get_file_extensions_by_language(['php'])
    );



    # scan dir recursively for instances of the word

    # echo results to csv file:
    # function name | path to file | line number | line 
}

sub recurse_through_directories(Str $path_to_directory, @extensions where Array) {
    my @scary_files;
    my @cwd_files = dir $path_to_directory;
    for @cwd_files -> $f {
        @scary_files.push($f) if $f.extension :parts(0..2) (elem) @extensions;
    }
    return @scary_files;
}

sub get_file_extensions_by_language(@languages where Array) {
    # Associte file extensions with languages. Only search these files
    # for scary strings
    my @extensions;
    for @languages -> $language {
        given $language.lc {
            # TODO Add more languages
            when 'php' {
                @extensions.push('php', 'class.inc');
            }
        }
    }
    say @extensions;
    @extensions;
}
