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
    my @function-names = $wordlist.IO.lines;

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
    # CSV file headers
    my @output = ['Function Name,Line Number,Line,File'];
    say "Scanning {@files-to-scan.elems} files...";
    # TODO can this be more efficient?
    my $a-lot-of-lines = 500;
    for @files-to-scan -> $file {
        say "--> $file";
=begin comment
        Perl6 will crash with malformed UTF-8 chars. I don't know a way to open
        a file using that .IO.lines method while also specifying an encoding.
        So instead the file is slurped and then manually chunked.
=end comment
        my $contents = slurp $file, enc => 'utf8-c8';
        my @lines = $contents.split("\n");
        my $num-lines = @lines.elems;
        if $num-lines > $a-lot-of-lines {
            # Warn user when a very big file is being scanned.
            say "\t--> This file contains $num-lines lines. This might take a while..." 
        }
        for @lines.kv -> $line-number, $l {
            my $line = $l.trim;
            # skip check if the line is a comment
            next if skippable($line);
            for @function-names -> $function-name {
                # Match when we find a function name followed by an opening
                # parenthesis (in the case of a function call) or an opening
                # square bracket (in the case of PHP superglobal use).
                if $line ~~ /$function-name(\[|\()/ {
                    # Join info together for csv printing
                    @output.push(
                        [
                            $function-name,
                            $line-number,
                            $line,
                            $file
                        ].join(',')
                    );
                }
            }
        }
    }
    # TODO make customizable
    my $output-file = 'results.csv';
    spurt $output-file, @output.join("\n");
    say "Results written to $output-file.";
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
    say "Folders are ";
    say @folders;
    @folders;
}

# Checks if a string is a code comment or just whitespace.
sub skippable($line where Str) {
    return True if $line.starts-with('//')
        || $line.starts-with('*')
        || $line.starts-with('/*')
        || $line.starts-with('*/')
        || $line.starts-with('#')
        || $line ~~ /[\\n\\t]+/;
    return False;
}
