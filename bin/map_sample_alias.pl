#!/usr/bin/perl -w

=head1 NAME

map_sample_alias.pl

=head1 AUTHOR

Alison Meynert (alison.meynert@igmm.ed.ac.uk)

=head1 DESCRIPTION

Maps the sample name to the sample alias from the EGA samples.csv metadata file
in the runs.csv metadata file.

=cut

use strict;

# Perl
use IO::File;
use Getopt::Long;

my $usage = qq{USAGE:
$0 [--help]
  --input   Input runs.csv file
  --output  Output runs.csv file
  --samples Input samples.csv file
};

my $help = 0;
my $input_file;
my $output_file;
my $samples_file;

GetOptions(
    'help'      => \$help,
    'input=s'   => \$input_file,
    'output=s'  => \$output_file,
    'samples=s' => \$samples_file
) or die $usage;

if ($help || !$input_file || !$output_file || !$samples_file)
{
    print $usage;
    exit(0);
}

my $in_fh = new IO::File;
$in_fh->open($samples_file, "r") or die "Could not open $samples_file\n$!";

my %map;
while (my $line = <$in_fh>)
{
    chomp $line;

    next if ($line =~ /bioSampleId/);

    my @tokens = split(',', $line);
    $tokens[1] =~ s/[\"\']//g;
    $tokens[3] =~ s/[\"\']//g;

    $map{$tokens[3]} = $tokens[1];
}

$in_fh->close();

my $out_fh = new IO::File;
$in_fh->open($input_file, "r") or die "Could not open $input_file\n$!";
$out_fh->open($output_file, "w") or die "Could not open $output_file\n$!";

while (my $line = <$in_fh>)
{
    chomp $line;
    if ($line =~ /checksum/)
    {
	print $out_fh "$line\n";
    }
    else
    {
	my @tokens = split(',', $line);
	$tokens[0] = $map{$tokens[0]};
	printf $out_fh "%s\n", join(",", @tokens);
    }
}

$in_fh->close();
$out_fh->close();
