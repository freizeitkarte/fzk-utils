#!/usr/bin/perl
# -----------------------------------------
# Program : sere.pl (Search & Replace)
# Version : siehe Programmausgabe
#
# Copyright (C) 2012 Klaus Tockloth
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Contact (eMail): <freizeitkarte@googlemail.com>
#
# Further information:
#
# Test:
# perl sere.pl -search="1209" -replace="1210" *.html
# -----------------------------------------

use warnings;
use strict;

# General
use English;
use File::Basename;
use Getopt::Long;

my $EMPTY = q{};
my $rc    = 0;

my ( $appbasename, $appdirectory, $appsuffix ) = fileparse ( $0, qr/\.[^.]*/ );
my $appfilename = basename ( $0 );

my $release = '0.4 - 2012/11/23';
printf { *STDOUT } ( "\n$appfilename - Search & Replace Utility, Rel. $release\n" );

# command line parameters
my $help    = $EMPTY;
my $search  = $EMPTY;
my $replace = $EMPTY;
my $overwrite = $EMPTY;

# get the command line parameters
GetOptions ( 'help|h|?' => \$help, 'search=s' => \$search, 'replace=s' => \$replace, 'overwrite' => \$overwrite );

if ( $help || ( $search eq $EMPTY ) || ( $search eq $EMPTY ) || ( $#ARGV < 0 ) ) {
  show_help ();
}

my $found           = 0; 
my $sourcefile      = $EMPTY;
my $destinationfile = $EMPTY;

foreach my $item ( @ARGV ) {
  foreach $sourcefile ( glob ( $item ) ) {
    $found = 0;
    $destinationfile = $sourcefile . '.modified';
    printf { *STDOUT } ( "\n==================================================\n" );
    printf { *STDOUT } ( "Source file        : %s\n", $sourcefile );
    printf { *STDOUT } ( "Destination file   : %s\n", $destinationfile );
    printf { *STDOUT } ( "Regular expression : s#%s#%s#g\n", $search, $replace );
    printf { *STDOUT } ( "==================================================\n\n" );

    open ( my $SOURCE_FILE,      '<', $sourcefile )      or die ( "Error opening sourcefile \"$sourcefile\": $!\n" );
    open ( my $DESTINATION_FILE, '>', $destinationfile ) or die ( "Error opening destinationfile \"$destinationfile\": $!\n" );

    while ( <$SOURCE_FILE> ) {
      if ( $_ =~ m#$search# ) {
        printf { *STDOUT } ( "%s", $_ );

        # Suchen und ersetzen
        $_ =~ s#$search#$replace#g;

        printf { *STDOUT } ( "%s\n", $_ );
        $found = 1;
      }
      printf { $DESTINATION_FILE } ( "%s", $_ );
    }

    close ( $DESTINATION_FILE );
    close ( $SOURCE_FILE );
    
    if ( ! $found ) {
      # Destination file wieder loeschen
      printf { *STDOUT } ( "Nothing done ... destination file unlinked.\n");
      unlink $destinationfile or warn ( "Could not unlink $destinationfile: $!" );
    }
    elsif ( $overwrite ) {
      # Source file umbenennen (-> *.bak)
      my $renamed_sourcefile = $sourcefile . '.bak';
      printf { *STDOUT } ( "Source file renamed (%s -> %s).\n", $sourcefile, $renamed_sourcefile);
      rename $sourcefile, $renamed_sourcefile or warn ( "Could not rename $sourcefile: $!" );

      # Destination file umbenennen
      printf { *STDOUT } ( "Destination file renamed (%s -> %s).\n", $destinationfile, $sourcefile);
      rename $destinationfile, $sourcefile or warn ( "Could not rename $destinationfile: $!" );
    }
  }
}
printf { *STDOUT } ( "\nDone.\n" );


# return codes: successful (0) / not successful (<>0)
exit ( $rc );


# -----------------------------------------
# Show help and exit.
# -----------------------------------------
sub show_help {
  printf { *STDOUT }
    (   "\nCopyright (C) 2012 Klaus Tockloth <freizeitkarte\@googlemail.com>\n"
      . "This program comes with ABSOLUTELY NO WARRANTY. This is free software,\n"
      . "and you are welcome to redistribute it under certain conditions.\n" . "\n"
      . "Benutzung\n"
      . "=========\n"
      . "perl $appfilename -search=\"RegExp\" -replace=\"String\" [-overwrite] Dateien\n"
      . "\n"
      . "Argumente:\n"
      . "-search  = Suchtext (regulaerer Ausdruck)\n"
      . "-replace = Ersatztext (String)\n"
      . "Dateien  = Zu bearbeitende Dateien\n"
      . "\n"
      . "Optionen:\n"
      . "-overwrite = Ausgangsdatei ueberschreiben\n"
      . "\n"
      . "Anmerkungen:\n"
      . "Soll nach Metazeichen gesucht werden, so sind diese mit \\ zu maskieren.\n"
      . "Regular Expression Metazeichen: * + ? . ( ) [ ] { } \\ / | ^ \$\n"
      . "Soll nach Begrenzerzeichen gesucht werden, so sind dieses mit \\ zu maskieren.\n"
      . "Regular Expression Begrenzer: #\n"
      . "\n"
      . "Beispiele\n"
      . "=========\n"
      . "perl $appfilename -search=\"1210\" -replace=\"1211\" *.html\n"
      . "perl $appfilename -search=\"1210\" -replace=\"1211\" *.html *.txt\n"
      . "perl $appfilename -search=\"Ausgabe 12\\.10\" -replace=\"Ausgabe 12.11\" *.html\n"
      . "\n\n" );

  exit ( 1 );
}
