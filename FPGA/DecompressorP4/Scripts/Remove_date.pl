#!/usr/bin/perl

# Remove file modification dates from patch.

use strict;
use warnings;

my $File_name = "Patches/Encoder.patch";
open(my $Input_file, '<', $File_name)
  or die 'Could not open "$File_name".';
my @Input;
while (my $Line = <$Input_file>)
{
  push @Input, $Line;
}
close $Input_file;

my @Sections;
my $Changes = 0;
my $Number = 0;
foreach my $Line (@Input)
{
  if ($Line =~ /^@@ /)
  {
    pop @Sections if (!$Changes);
    push @Sections, $Number;
    $Changes = 0;
  }
  $Changes = 1 if ($Line =~ /^[-+][^-+]/ && $Line !~ /^.\/\/ File created on/);
  $Number++;
}

my $Output = 1;
$Number = 0;
foreach my $Line (@Input)
{
  if ($Line =~ /^@@ /)
  {
    $Output = 1;
    my $Expected = $Sections[0];
    $Output = 0 if ($Expected != $Number);
    shift @Sections if ($Expected == $Number);
  }
  print $Line if ($Output || $Line =~ /^(\+\+\+|---|[^+\-@ ])/);
  $Number++;
}

