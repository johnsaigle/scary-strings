#!/usr/bin/env perl6

#|(Help message will go here.)
unit sub MAIN(
    Str $path-to-directory, 
    $wordlist where { .IO.f // die "file not found in $*CWD"},
    Bool :e(:$no-exclude) = False, #`( -exclude, --exclude, -e, or --e)
    Bool :v(:$verbose) #`( -verbose, --verbose, -v, or --v)
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
    if ! ($path-to-directory.IO ~~ :d) {
        say "$path-to-directory is not a directory.";
        exit;
    }
    my @contents = $wordlist.IO.lines;

    my @folders_to_exclude = [];
    unless $no-exclude {
        @folders_to_exclude = |get-folder-exclusions-by-language('php'), |get-generic-excludes();
    }
    my @files-to-scan = recurse-through-directories(
        $path-to-directory, 
        get-file-extensions-by-language(
            [
                # TODO add more
                'php'
            ]
        ),
        @folders_to_exclude
    );
    @files-to-scan.join("\n").say;

    # echo results to csv file:
    # function name | path to file | line number | line 
}

# Scan dir recursively all files of the given list of extensions.
sub recurse-through-directories(
    Str $path-to-directory, 
    @extensions where Array,
    @excluded-folders where Array,
) {
    return [] if $path-to-directory.IO.basename (elem) @excluded-folders;
    my @scary-files;
    my @cwd-files = dir $path-to-directory;
    for @cwd-files -> $f {
        if ($f.IO ~~ :f) {
            @scary-files.push($f) if $f.extension :parts(0..2) (elem) @extensions;
        }
        # If directory is found, recursively add scary files from that directory.
        if ($f.IO ~~ :d) {
            @scary-files = flat @scary-files, recurse-through-directories(
                $f.path,
                @extensions,
                @excluded-folders
            );
        }
    }
    @scary-files;
}

sub get-file-extensions-by-language(@languages where Array) {
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
    @extensions;
}

# Exclude common 3rd-party folders based on programming language.
sub get-generic-excludes() {
    return get-folder-exclusions-by-language('generic');
}
multi get-folder-exclusions-by-language($language where Str) {
    my @folders = "excludes/$language".IO.lines;
    @folders;
}
multi get-folder-exclusions-by-language(@languages where Array) {
    my @folders;
    for @languages -> $language {
        @folders = flat @folders, get-folder-exclusions-by-language($language);
    }
    @folders;
}
