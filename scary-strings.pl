# Scan a directory for php files containing potentially dangerous API calls.
# For use when performing security audits on an application's source code.

# This project is free software operating using the GNUv43
#!/usr/bin/perl -w
use strict;
use warnings;
use File::Find ();
use File::Basename;
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

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
    print "Looking in $basename for scary strings... \n";
    open my $file, "<", $name or die "$!";
    while (my $line = <$file>) {
        # trim whitespace on both sides
        $line =~ s/^\s+|\s+$//g;
        # quick check to see if this line not worth analyzing
        next if (begins_with($line, "/*") || begins_with($line, "*") || begins_with($line, "//") || begins_with($line, "}"));
        # iterate over array and print the line nubmer where matches are found
        for my $function_name (@file_access_strings) {
            if ($line =~ /$function_name\(.*\)/) {
                print join("\t", $basename, $function_name, $., $line), "\n"; 
                $count++;
            }
        }
    }
    if ($count) {
        print "Found $count potentially dangerous function calls.\n";
    }
}
sub wanted {
    /(\.php|\.class\.inc)$/ &&
    push @files_to_scan, $name;
}

# ============== Begin program execution ============== #

my $source = $ARGV[0];
my $num_args = $#ARGV + 1;
if ($num_args < 1) {
    print $num_args;
    print "Usage: $0 <source_directory> [wordlist]\n";
    exit;
}

print '===>>>>>   PHP SCARY STRINGS   <<<<<===', "\n";
print "\t", 'Source code analysis tool, Copyright (C) 2017 by John Saigle', "\n";
print "\t", 'Analyse PHP source code for potentially dangerous APIs, or "scary strings"!', "\n";
print 'This is free software.', "\n";

if (-T $source) {
    search_file_for_scary_strings($source);
}
elsif (-d $source) {
    print "Scanning $source for PHP files... "; 
    # Traverse desired filesystems
    File::Find::find({wanted => \&wanted}, $source );

    die "No php files found in $source.\n" unless @files_to_scan;

    my $num_files = scalar @files_to_scan;
    print "Found: ($num_files).", "\n";
    foreach (@files_to_scan) {
        search_file_for_scary_strings($_);
    }
} else {
    die "$source is neither a file nor a directory. Exiting.\n";
}
