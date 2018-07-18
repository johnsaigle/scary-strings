#!/usr/bin/env perl6

sub MAIN(
    Str $path_to_directory, 
    Str $wordlist = 'wordlists/php/all.txt', 
    @exclude where Array = [
        'vendor', 
        '.git',
        '.git-rewrite',
        '.phan'
    ], #TODO Probably more dirs to exclude.
    Str $verbose = ''
) {
    # Print header
    say '===>>>>>   SCARY STRINGS   <<<<<===', "\n";
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

    my @files_to_scan = recurse_through_directories(
        $path_to_directory, 
        get_file_extensions_by_language(
            [
                # TODO add more
                'php'
            ]
        ),
        @exclude
    );
    @files_to_scan.join("\n").say;




    # echo results to csv file:
    # function name | path to file | line number | line 
}

# Scan dir recursively all files of the given list of extensions.
sub recurse_through_directories(
    Str $path_to_directory, 
    @extensions where Array,
    @excluded_folders where Array,
) {
    return [] if $path_to_directory.IO.basename (elem) @excluded_folders;
    my @scary_files;
    my @cwd_files = dir $path_to_directory;
    for @cwd_files -> $f {
        if ($f.IO ~~ :f) {
            @scary_files.push($f) if $f.extension :parts(0..2) (elem) @extensions;
        }
        # If directory is found, recursively add scary files from that directory.
        if ($f.IO ~~ :d) {
            @scary_files = flat @scary_files, recurse_through_directories(
                $f.path,
                @extensions,
                @excluded_folders
            );
        }
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
