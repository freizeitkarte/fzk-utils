#!/usr/bin/perl
# ---------------------------------------
#
# Programm : Purge-Images (purge_images.pl)
# Version  : 0.1.0 - 2014/04/24
# Version  : 0.1.1 - 2014/05/03 Hilfetext angepasst
# Autor    : Klaus Tockloth
#
# Anmerkungen:
# - Quellprogramm formatiert mit Perltidy
# - Quellprogramm geprueft mit PerlCritic
#
# Testaufrufe:
# perl purge_images.pl  -imagedir="/Users/Klaus/freizeitkarte-osm.de/images/*"  "/Users/Klaus/freizeitkarte-osm.de/*"  "/Users/Klaus/freizeitkarte-osm.de/en/*"  "/Users/Klaus/freizeitkarte-osm.de/de/*"
# perl purge_images.pl  -imagedir="/Users/Klaus/freizeitkarte-osm.de/android/images/*"  "/Users/Klaus/freizeitkarte-osm.de/android/*"  "/Users/Klaus/freizeitkarte-osm.de/android/de/*"
#
# perl purge_images.pl  -imagedir="/Users/Klaus/freizeitkarte-osm.de-20140424/images/*"  "/Users/Klaus/freizeitkarte-osm.de-20140424/*"  "/Users/Klaus/freizeitkarte-osm.de-20140424/en/*"  "/Users/Klaus/freizeitkarte-osm.de-20140424/de/*"
# perl purge_images.pl  -imagedir="/Users/Klaus/freizeitkarte-osm.de-20140424/android/images/*"  "/Users/Klaus/freizeitkarte-osm.de-20140424/android/*"  "/Users/Klaus/freizeitkarte-osm.de-20140424/android/de/*"
# ---------------------------------------

# generelle Module
use strict;
use warnings;
use English qw( -no_match_vars );
use 5.010;

# spezielle Module
use Cwd;
use File::Basename;
use File::Spec;
use Getopt::Long;

# Konstanten
my $EMPTY = q{};

# Programm-Startup
my ( $appbasename, $appdirectory, $appsuffix ) = fileparse ( $PROGRAM_NAME, qr/\.[^.]*/ );
my $programm_name      = basename ( $PROGRAM_NAME );
my $programm_info      = "Bereinigung nicht referenzierter Images";
my $programm_version   = '0.1.1 - 2014/05/03';
my $programm_directory = getcwd ();

printf {*STDOUT} ( "\n$programm_name - $programm_info, Rel. $programm_version\n" );

# Kommandozeilenparameter einlesen
my $help     = $EMPTY;
my $imagedir = $EMPTY;
GetOptions ( 'h|?' => \$help, 'imagedir=s' => \$imagedir, );

# auf korrekten Programmaufruf pruefen
if ( $help || ( $imagedir eq $EMPTY ) || ( $#ARGV < 0 ) ) {
    show_help ();
}

my @image_filenames = glob ( $imagedir );
my @html_lines;

my $name_ausgabedatei = $appbasename . '.sh';
open ( my $AUSGABEDATEI, '>', $name_ausgabedatei ) or die ( "Error opening destinationfile \"$name_ausgabedatei\": $OS_ERROR\n" );

printf {$AUSGABEDATEI} ( "#!/bin/sh\n" );
printf {$AUSGABEDATEI} ( "#\n" );
printf {$AUSGABEDATEI} ( "# generiert: %s\n", scalar ( localtime ( time () ) ) );
printf {$AUSGABEDATEI} ( "#\n\n" );
printf {$AUSGABEDATEI} ( "# Einlesen der (HTML-)Dateien in denen nach Images gesucht wird ...\n" );

# Daten aller Dateien einlesen
foreach my $item ( @ARGV ) {
    foreach my $filename ( glob ( $item ) ) {
        printf {$AUSGABEDATEI} ( "# %s\n", $filename );
        open ( my $EINGABEDATEI, '<', $filename ) or die ( "Error opening output file \"$filename\": $OS_ERROR\n" );
        while ( <$EINGABEDATEI> ) {
            # Datei | Zeile | Inhalt
            my $zeile = sprintf ( "%s | %s | %s", $filename, $INPUT_LINE_NUMBER, $_ );
            push @html_lines, $zeile;
        }
        close ( $EINGABEDATEI ) or die ( "Error closing output file \"$filename\": $OS_ERROR\n" );
    }
}
printf {$AUSGABEDATEI} ( "\necho Removing images ...\n\n" );

# mit einfachem grep nach Imagename suchen
my $found = 0;
foreach my $filename ( @image_filenames ) {
    my ( $volume, $directories, $imagename ) = File::Spec->splitpath ( $filename );
    printf {$AUSGABEDATEI} ( "# Nach Image <%s> suchen ...\n", $imagename );
    $found = 0;
    foreach my $html_line ( @html_lines ) {
        if ( $html_line =~ m|$imagename| ) {
            chomp $html_line;
            printf {$AUSGABEDATEI} ( "# %s\n", $html_line );
            $found++;
        }
    }
    if ( $found ) {
        printf {$AUSGABEDATEI} ( "# Image %dx gefunden\n\n", $found );
    }
    else {
        printf {$AUSGABEDATEI} ( "# Image %dx gefunden\n", $found );
        printf {$AUSGABEDATEI} ( "rm -fv '%s'\n\n",        $filename );
    }
}
close ( $AUSGABEDATEI ) or die ( "Error closing output file \"$name_ausgabedatei\": $OS_ERROR\n" );

printf {*STDOUT} ( "\nErgebnisdatei <$name_ausgabedatei> erzeugt.\n\n" );

exit ( 0 );


# -----------------------------------------
# Show help and exit.
# -----------------------------------------
sub show_help {
    printf {*STDOUT}
        (   "\nBenutzung\n"
          . "=========\n"
          . "perl $programm_name -image=\"Verzeichnis/Maske\" Dateien \n\n"
          . "Argumente:\n"
          . "-imagedir  = Verzeichnis und Maske der Imagedateien\n"
          . "Dateien    = zu verifizierende Dateien (html, css, ...)\n\n"
          . "Beispiele\n"
          . "=========\n"
          . "perl $programm_name  -imagedir=\"~/freizeitkarte-osm.de/android/images/*\"  \"~/freizeitkarte-osm.de/android/*\"  \"~/freizeitkarte-osm.de/android/de/*\"\n"
          . "perl $programm_name  -imagedir=\"~/freizeitkarte-osm.de/images/*\"  \"~/freizeitkarte-osm.de/*\"  \"~/freizeitkarte-osm.de/en/*\"  \"~/freizeitkarte-osm.de/de/*\"\n"
          . "\n" );

    exit ( 1 );
}
