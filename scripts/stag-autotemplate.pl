#!/usr/local/bin/perl -w

=head1 NAME 

stag-autotemplate.pl

=head1 SYNOPSIS

  stag-autotemplate.pl -parser XMLAutotemplate -handler ITextWriter file1.txt file2.txt

  stag-autotemplate.pl -parser MyMod::MyParser -handler MyMod::MyWriter file.txt

=head1 DESCRIPTION

script wrapper for the Data::Stag modules

=head1 ARGUMENTS

=cut



use strict;

use Carp;
use Data::Stag qw(:all);
use DBIx::DBStag;
use FileHandle;
use Getopt::Long;

my $parser = "";
my $handler = "";
my $mapf;
my $tosql;
my $toxml;
my $toperl;
my $debug;
my $help;
my @link = ();
my $ofn;
my $no_pp;
my $dir = '.';
my $schema_name;
GetOptions(
           "help|h"=>\$help,
           "parser|format|p=s" => \$parser,
           "handler|writer|w=s" => \$handler,
           "xml"=>\$toxml,
           "perl"=>\$toperl,
           "debug"=>\$debug,
           "link|l=s@"=>\@link,
	   "transform|t=s"=>\$ofn,
	   "schema|s=s"=>\$schema_name,
	   "no_pp|n"=>\$no_pp,
	   "dir|d=s"=>\$dir,
          );
if ($help) {
    system("perldoc $0");
    exit 0;
}

my $db = DBIx::DBStag->new;

if (!$schema_name) {
    print STDERR "You should consider using the -schema|s option to set schema name\n";
}

my $fn = shift @ARGV;
die "max 1 file" if @ARGV;
autotemplate($fn);

sub autotemplate {
    my $fn = shift;
    
    my $tree = 
      Data::Stag->parse($fn, 
                        $parser);
    my $schema = $tree;
    if (!$no_pp) {
	$schema = $tree->autoschema;
    }
    my @tts = $db->autotemplate($schema);
    foreach my $tt (@tts) {
	my $base = $schema_name || 'AUTO';
	my $fn = "$dir/$base-$tt->[0].stg";
	open(F, ">$fn") || die("cannot open $fn");
	$tt->[1] =~ s/\nschema:/\nschema: $schema_name/ if $schema_name;
	print F "$tt->[1]";
	close(F);
    }
}

