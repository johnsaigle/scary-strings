# Scan a directory for php files containing potentially dangerous API calls.
# For use when performing security audits on an application's source code.

# This project is free software operating under the GNU GPLv3.0 licence.
#!/usr/bin/perl -w
use strict;
use warnings;
use File::Find ();
use File::Basename;
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

my ($wordfile, $verbose); #command line params
my @files_to_scan;

sub begins_with
{
    return substr($_[0], 0, length($_[1])) eq $_[1];
}

sub make_array_from_file
{
    my $file = shift;
    my @arr;
    open my $fh, "<", $file or die "Could not open $file";
    while (my $line = <$fh>) {
        chomp($line);
        push (@arr, $line);
    }
    return (\@arr);
}

sub search_file_for_scary_strings {
    my $name = shift; # name of file to analyze
    my $function_names_ref = shift;
    my @function_names = @$function_names_ref;
    my $basename = File::Basename::basename($name);
    my @output_lines; #container to hold output before printing

    print "Looking in $basename for scary strings... " if $verbose;
    open my $file, "<", $name or die "$!";
    while (my $line = <$file>) {
        # trim whitespace on both sides
        $line =~ s/^\s+|\s+$//g;
        # quick check to see if this line not worth analyzing
        next if (begins_with($line, "/*") || begins_with($line, "*") || begins_with($line, "//") || begins_with($line, "}"));
        # iterate over array and print the line nubmer where matches are found
        for my $function_name (@function_names) {
            if ($function_name) {
                if ($line =~ /$function_name\(.*\)/) {
                    my $output_line = join("\t", $basename, $function_name, $., $line, "\n");
                    push (@output_lines, $output_line);
                }
            }
        }
    }
    # Print extra verbose info
    if (@output_lines) {
        my $count = @output_lines;
        print "Found $count potentially dangerous function calls.\n" if $verbose;
        foreach my $row (@output_lines) {
            print $row;
        }
        return 1;
    } else {
        print "All clear.\n" if $verbose;
        return 0;
    }
}

sub wanted {
    /(\.php|\.class\.inc)$/ &&
    push @files_to_scan, $name;
}

sub usage {
    die "Usage: $0 SOURCE -w(ordlist) WORD_LIST -v(erbose)\n";
}

# ============== Begin program execution ============== #

# Get command line params
GetOptions(
    'wordlist|w=s' => \$wordfile,
    'verbose|v' => \$verbose,
) or usage();

# Quit if source file not specified
my $source = $ARGV[0];
usage() unless $source;

# Quit if source file type is invalid
die "$source is neither a file nor a directory.\n" unless (-T $source or -d $source);
# Quit if wordlist file type is invalid
if ($wordfile) {
    die "Wordlist file type is invalid.\n" unless (-T $wordfile);
} else {
    $wordfile = './wordlists/php/all.txt';
    print 'Using words/php/all.txt as word list.', "\n";
}


# Header
print '===>>>>>   PHP SCARY STRINGS   <<<<<===', "\n";
print "\t", 'Source code analysis tool, Copyright (C) 2017 by John Saigle', "\n";
print "\t", 'Analyse PHP source code for potentially dangerous APIs, or "scary strings"!', "\n";
print "\t", 'This is free software. <https://github.com/johnsaigle/scary-strings>', "\n";


# populate array based on file contents
my ($function_names_ref) = make_array_from_file($wordfile);

my $matches_found = 0;
if (-T $source) {
    search_file_for_scary_strings($source, $function_names_ref);
}
elsif (-d $source) {
    print "Scanning $source for PHP files... " if $verbose;
    # Traverse desired filesystems
    File::Find::find({wanted => \&wanted}, $source );

    die "No php files found in $source.\n" unless @files_to_scan;

    my $num_files = scalar @files_to_scan;
    print "Found $num_files.", "\n" if $verbose;
    foreach (@files_to_scan) {
        $matches_found = 1 if search_file_for_scary_strings($_, $function_names_ref);
    }
    print "No scary strings found in the file(s)!\n" unless $matches_found;
} 
else {
    usage();
}
