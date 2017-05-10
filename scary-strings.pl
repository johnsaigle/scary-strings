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

my ($wordlist, $verbose);
my @files_to_scan;
my @file_access_strings = (
    'fopen',
    'readfile',
    'file',
    'fpassthru',
    'gzopen',
    'gzfile',
    'gzpassthru',
    'readgzfile',
    'copy',
    'rename',
    'rmdir',
    'mkdir',
    'unlink',
    'file_get_contents',
    'file_put_contents',
    'parse_ini_file'
);
my @db_access_strings = (
    'mysql_query',
    'mssql_query',
    'pg_query'
);
my @dynamic_code_execution_strings = (
    'eval',
    'call_user_func',
    'call_user_func_array',
    'call_user_method',
    'call_user_method_array',
    'create_function'
);

my @os_command_execution_strings = (
    'exec',
    'passthru',
    'popen',
    'proc_open',
    'shell_exec',
    'system'
    #TODO: include backtick regex?
);
my @url_redirection_strings = (
    'http_redirect',
    'header',
    'HttpMessage::setResponseCode',
    'HttpMessage::setHeaders',
    'setResponseCode',
    'setHeaders'
);
my @socket_strings = (
    'socket_create',
    'socket_connect',
    'socket_write',
    'socket_send',
    'socket_recv',
    'fsockopen',
    'pfsockopen'
);
sub begins_with
{
    return substr($_[0], 0, length($_[1])) eq $_[1];
}
sub search_file_for_scary_strings {
    my $name = shift;
    my $count = 0;
    my $basename = File::Basename::basename($name);
    my @output_lines;
    print "Looking in $basename for scary strings... " if $verbose;
    open my $file, "<", $name or die "$!";
    while (my $line = <$file>) {
        # trim whitespace on both sides
        $line =~ s/^\s+|\s+$//g;
        # quick check to see if this line not worth analyzing
        next if (begins_with($line, "/*") || begins_with($line, "*") || begins_with($line, "//") || begins_with($line, "}"));
        # iterate over array and print the line nubmer where matches are found
        for my $function_name (@file_access_strings) {
            if ($line =~ /$function_name\(.*\)/) {
                my $output_line = join("\t", $basename, $function_name, $., $line, "\n");
                push (@output_lines, $output_line);
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
    } else {
        print "All clear.\n" if $verbose;
    }
}
sub wanted {
    /(\.php|\.class\.inc)$/ &&
    push @files_to_scan, $name;
}

# ============== Begin program execution ============== #

# Print usage if incorrect input
my $num_args = $#ARGV + 1;
if ($num_args < 1) {
    print $num_args;
    print "Usage: $0 <source_directory> [wordlist] [-v(erbose)]\n";
    exit;
}

# Get command line params
GetOptions(
    'wordlist|w=s' => \$wordlist,
    'verbose|v' => \$verbose,
) or die "Usage: $0 -w(ordlist) WORDLIST -v(erbose)\n";

# Quit if wordlist file type is invalid
if ($wordlist) {
    die "Wordlist file type is invalid.\n" unless (-T $wordlist);
} 

my $source = $ARGV[0];
# Quit if source file type is invalid
die "$source is neither a file nor a directory.\n" unless (-T $source or -d $source);

# Header
print '===>>>>>   PHP SCARY STRINGS   <<<<<===', "\n";
print "\t", 'Source code analysis tool, Copyright (C) 2017 by John Saigle', "\n";
print "\t", 'Analyse PHP source code for potentially dangerous APIs, or "scary strings"!', "\n";
print "\t", 'This is free software.', "\n";


if (-T $source) {
    search_file_for_scary_strings($source);
}
elsif (-d $source) {
    print "Scanning $source for PHP files... " if $verbose;
    # Traverse desired filesystems
    File::Find::find({wanted => \&wanted}, $source );

    die "No php files found in $source.\n" unless @files_to_scan;

    my $num_files = scalar @files_to_scan;
    print "Found $num_files.", "\n" if $verbose;
    foreach (@files_to_scan) {
        search_file_for_scary_strings($_);
    }
} else {
    die 
}
