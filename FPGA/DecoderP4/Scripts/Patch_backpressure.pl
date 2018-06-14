#!/usr/bin/perl

# Connect backpressure to the FEC module.

use strict;
use warnings;
use Getopt::Std;

my %options=();
getopts("i:d:p:t:m:", \%options);

my $File_name;
if (defined $options{i}) {
  $File_name = $options{i};
} else {
  die 'Need to specify -i (input file, usually XilinxSwitch.v)';
}

my $Delay;
if (defined $options{d}) {
  $Delay = $options{d};
  if ($Delay <= 0) {
    die '-d parameter must be greater than 0';
  }
} else {
  die 'Need to specify -d (delay, e.g., 3)';
}

my $Prefix;
if (defined $options{p}) {
  $Prefix = $options{p};
} else {
  die 'Need to specify -p (prefix for elements added by this script)';
}

my $ModuleType;
if (defined $options{t}) {
  $ModuleType = $options{t};
} else {
  die 'Need to specify -t ("type" of the module we are interested in)';
}

my $ModuleName;
if (defined $options{m}) {
  $ModuleName = $options{m};
} else {
  die 'Need to specify -m (name of the module we are interested in)';
}

open(my $Input_file, '<', $File_name)
  or die 'Could not open "$File_name".';

# Find the signals that connect to the packet input and output of the ${ModuleType} module.

my $Inside_module = 0;
my $Packet_input;
my $Packet_output;
while (my $Line = <$Input_file>)
{
  $Line =~ s/^\s+|\s+$//g;
  
  $Inside_module = 1 if ($Line eq "${ModuleName}");
  $Inside_module = 0 if ($Line eq ");");

  my @Tokens = split /\s+/, $Line;
  $Packet_input = $Tokens[2] if ($Inside_module && $Tokens[0] eq ".packet_in_packet_in_DAT");
  $Packet_output = $Tokens[2] if ($Inside_module && $Tokens[0] eq ".packet_out_packet_out_DAT");
}

die 'Cannot find ".packet_in_packet_in_DAT" port of "${ModuleType}" module.' if (!defined $Packet_input);
die 'Cannot find ".packet_out_packet_out_DAT" port of "${ModuleType}" module.' if (!defined $Packet_output);

# Find the modules that are immediately upstream and downstream on the packet bus with respect to
# the ${ModuleName} module.

seek $Input_file, 0, 0;

my $Module_name;
my $Last_line;
my $Input_module;
my $Output_module;
while (my $Line = <$Input_file>)
{
  $Line =~ s/^\s+|\s+$//g;

  if (!$Inside_module)
  {
    $Module_name = $Last_line;
    $Last_line = $Line;
  }

  $Inside_module = 1 if ($Line eq "(");
  $Inside_module = 0 if ($Line eq ");");

  my @Tokens = split /\s+/, $Line;
  if ($Inside_module && $Module_name ne "${ModuleType}" && $#Tokens >= 2)
  {
    $Input_module = $Module_name if ($Tokens[2] eq $Packet_input);
    $Output_module = $Module_name if ($Tokens[2] eq $Packet_output);
  }
}

die 'Cannot find source module of packet bus to "${ModuleType}" module.' if (!defined $Input_module);
die 'Cannot find destination module of packet bus to "${ModuleType}" module.' if (!defined $Output_module);

# Locate the end of the signal declarations.

seek $Input_file, 0, 0;

my $Line_number = 1;
my $End_of_decl;
while (my $Line = <$Input_file>)
{
  $Line =~ s/^\s+|\s+$//g;

  my @Tokens = split /\s+/, $Line;
  $End_of_decl = $Line_number if ($#Tokens > 0 && ($Tokens[0] eq "wire" || $Tokens[0] eq "reg"));

  $Line_number++;
}

die 'Cannot find the last declaration.' if (!defined $End_of_decl);

# Locate the first argument of the ${ModuleType} module instantiation and the lines with the ports that
# produce and consume the backpressure connected to the ${ModuleType} module.

seek $Input_file, 0, 0;

$Line_number = 1;
my $Start_of_FEC;
my $Back_pres_source;
my $Back_pres_dest;
while (my $Line = <$Input_file>)
{
  $Line =~ s/^\s+|\s+$//g;

  my @Tokens = split /\s+/, $Line;

  if (!$Inside_module)
  {
    $Module_name = $Last_line;
    $Last_line = $Line;
  }

  $Inside_module = 1 if ($Line eq "(");
  $Inside_module = 0 if ($Line eq ");");

  $Start_of_FEC = $Line_number if ($Inside_module && $Line eq "(" && $Module_name eq "${ModuleName}");
  $Back_pres_dest = $Line_number if ($Inside_module && $Module_name eq $Input_module && $#Tokens > 0 && $Tokens[0] eq ".backpressure_in" );
  $Back_pres_source = $Line_number if ($Inside_module && $Module_name eq $Output_module && $#Tokens > 0 && $Tokens[0] eq ".backpressure_out" );

  $Line_number++;
}

die 'Cannot find the first argument of the "${ModuleType}" module.' if (!defined $Start_of_FEC);
die 'Cannot find the source of the backpressure for the "${ModuleType}" module.' if (!defined $Back_pres_source);
die 'Cannot find the destination of the backpressure for the "${ModuleType}" module.' if (!defined $Back_pres_dest);

# Generate the output file.

seek $Input_file, 0, 0;

$Line_number = 1;
while (my $Line = <$Input_file>)
{
  my @Tokens = split /\s+/, $Line;

  if ($Line_number == $Back_pres_source)
  {
    print "\t.backpressure_out\t( ${Prefix}_backpressure_in ),\n";
  }
  elsif ($Line_number == $Back_pres_dest)
  {
    print "\t.backpressure_in\t( ${Prefix}_backpressure_out_${Delay} ),\n";
  }
  else
  {
    print "$Line";
  }

  if ($Line_number == $End_of_decl)
  {
    print "wire ${Prefix}_backpressure_in ;\n";
    for (my $i = 1; $i <= $Delay; $i++) {
      print "reg ${Prefix}_backpressure_in_${i} ;\n";
    }
    print "wire ${Prefix}_backpressure_out ;\n";
    for (my $i = 1; $i <= $Delay; $i++) {
      print "reg ${Prefix}_backpressure_out_${i} ;\n";
    }
    print "\n";
    print "always @( posedge clk_line ) begin\n";
    print "\tif ( clk_line_rst_high ) begin\n";
    for (my $i = 1; $i <= $Delay; $i++) {
      print "\t\t${Prefix}_backpressure_in_${i} <= 0 ;\n";
    }
    print "\tend\n";
    print "\telse  begin\n";
    print "\t\t${Prefix}_backpressure_in_1 <= ${Prefix}_backpressure_in ;\n";
    for (my $i = 1; $i < $Delay; $i++) {
      my $iplus1 = $i + 1;
      print "\t\t${Prefix}_backpressure_in_${iplus1} <= ${Prefix}_backpressure_in_${i} ;\n";
    }
    print "\tend\n";
    print "end\n";
    print "\n";
    print "always @( posedge clk_line ) begin\n";
    print "\tif ( clk_line_rst_high ) begin\n";
    for (my $i = 1; $i <= $Delay; $i++) {
      print "\t\t${Prefix}_backpressure_out_${i} <= 0 ;\n";
    }
    print "\tend\n";
    print "\telse  begin\n";
    print "\t\t${Prefix}_backpressure_out_1 <= ${Prefix}_backpressure_out ;\n";
    for (my $i = 1; $i < $Delay; $i++) {
      my $iplus1 = $i + 1;
      print "\t\t${Prefix}_backpressure_out_${iplus1} <= ${Prefix}_backpressure_out_${i} ;\n";
    }
    print "\tend\n";
    print "end\n";
  }

  if ($Line_number == $Start_of_FEC)
  {
    print "\t.backpressure_in\t( ${Prefix}_backpressure_in_${Delay} ),\n";
    print "\t.backpressure_out\t( ${Prefix}_backpressure_out ),\n";
  }

  $Line_number++;
}

