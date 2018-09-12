#!/usr/bin/env perl6

#TODO write detailed help info.
#|(Help message will go here.)
unit sub MAIN(
    Str $path-to-directory where { .IO.d // die "directory not found"},
    $wordlist where { .IO.f // die "file not found in $*CWD"},
    Bool :e(:$no-exclude) = False, #`( -exclude, --exclude, -e, or --e)
    Bool :v(:$verbose) #`( -verbose, --verbose, -v, or --v)
) {
    # Print header
    say '===>>>>>   SCARY STRINGS   <<<<<===', "\n";
    say "Source code analysis tool, Copyright (C) 2017 by John Saigle";
    say "Analyse source code for potentially dangerous APIs, or 'scary strings'!";
    say "This is free software. <https://github.com/johnsaigle/scary-strings>";

    if ! ($path-to-directory.IO ~~ :d) {
        note "$path-to-directory is not a directory.";
        exit;
    }
    # Read scary strings from wordlist file.
    my @function-names = $wordlist.IO.lines;

    # Generate list of files to scan.
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
    # Find matches
    my @output = ['Function Name,Line Number,Line,File'];
    my $num-files = @files-to-scan.elems;
    print "\nScanning $num-files file";
    print 's' if $num-files > 1;
    say "...";
    # TODO can this be more efficient?
    for @files-to-scan -> $file {
        my @results = scan-file-for-scary-strings($file, @function-names);
        say "\t* Found {@results.elems} scary strings." if @results.elems;
        @output = |@output, |@results;
    }
    # Write results to output csv
    # TODO make customizable
    if @output.elems === 1 {
        say "No scary strings found!";
        exit;
    }
    my $output-file = 'results.csv';
    spurt $output-file, @output.join("\n");
    say "\nResults written to [$output-file].";
}

sub scan-file-for-scary-strings($file where IO::Path, @function-names where Array) {
    say "---> [$file]";
=begin comment
        Perl6 will crash with malformed UTF-8 chars. I don't know a way to open
        a file using that .IO.lines method while also specifying an encoding.
        So instead the file is slurped and then manually chunked.
=end comment
    my $contents = slurp $file, enc => 'utf8-c8';
    my @lines = $contents.split("\n");
    my $num-lines = @lines.elems;
    # Warn user when a very big file is being scanned.
    my $a-lot-of-lines = 1000;
    if $num-lines > $a-lot-of-lines {
        say "\t--> This file contains $num-lines lines. This might take a while..." 
    }
    my @output;
    # Iterate over all lines in the files and search for matching funciton calls
    for @lines.kv -> $line-number, $l {
        my $line = $l.trim;
        # skip check if the line is a comment
        next if skippable($line);
        for @function-names -> $scary-string {
            # Check-match returns an empty string on failure
            if $line ~~ /$scary-string(\[|\()/ {
                # Join info together for csv printing
                @output.push(
                    [
                        $scary-string,
                        $line-number,
                        $line,
                        $file
                    ].join(',')
                );
            }
        }
    }
    return @output;
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

# Checks if a string is a code comment or just whitespace.
sub skippable($line where Str) {
    return True if $line.starts-with('//')
        || $line.starts-with('*')
        || $line.starts-with('/*')
        || $line.starts-with('*/')
        || $line.starts-with('#')
        || $line.starts-with("\n");
    return False;
}
