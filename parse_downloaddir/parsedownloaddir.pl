use strict;
use warnings;
use LWP::Simple;
use Getopt::Long;

# Default Downloadurl to use
my $url = 'http://download.freizeitkarte-osm.de/garmin/latest/';

my $flag_createhtml = "";

GetOptions ( 
    "html"    =>    \$flag_createhtml,
    "url=s"   =>    \$url,
) or die("Error in comand line arguments\n");    
    

my %mapinfo = ();
my %allmaps = ();
#my @maptypes = ( "gmaparchive", "gmapfullinstaller", "gmapinstaller", "gmapsupp", "imagedir", "installer" );
my @maptypes = ( "gmaparchive", "gmapfullinstaller", "gmapinstaller", "gmapsupp", "imagedir", "installer" );

my %maptype_info = (
        'gmaparchive' => { 
          'de'  => { 
            'os'            => 'Apple Mac OS X',
            'link'          => 'GMAP Archiv f&uuml;r Garmin BaseCamp',
          },
          'en'  => {
            'os'            => 'Apple Mac OS X',
            'link'          => 'GMAP Archive for Garmin BaseCamp',
          },
          'zip'             => '"Freizeitkarte_" . $mapinfo{$mapinfo_entry}{\'map\'} . "_" .$mapinfo{$mapinfo_entry}{\'lang\'} . ".gmap.zip"',
        },                       
        'gmapfullinstaller' => { 
          'de'  => { 
            'os'            => 'Microsoft Windows',
            'link'          => 'GMAP Installationsarchiv (komplett) f&uuml;r Garmin BaseCamp',
          },
          'en'  => {
            'os'            => 'Microsoft Windows',
            'link'          => 'GMAP Install Archive (full) for Garmin BaseCamp',
          },
          'zip'             => '"GMAP_Installer_Freizeitkarte_" . $mapinfo{$mapinfo_entry}{\'map\'} . "_" .$mapinfo{$mapinfo_entry}{\'lang\'} . "_full.zip"',
        },                       
        'gmapinstaller' => { 
          'de'  => { 
            'os'            => 'Microsoft Windows',
            'link'          => 'GMAP Installer f&uuml;r Garmin BaseCamp',
          },
          'en'  => {
            'os'            => 'Microsoft Windows',
            'link'          => 'GMAP Installer for Garmin BaseCamp',
          },
          'zip'             => '"GMAP_Installer_Freizeitkarte_" . $mapinfo{$mapinfo_entry}{\'map\'} . "_" .$mapinfo{$mapinfo_entry}{\'lang\'} . ".zip"',
        },                       
        'gmapsupp' => { 
          'de'  => { 
            'os'            => 'Garmin GPS-Ger&auml;t',
            'link'          => 'Installationsimage f&uuml;r Micro-SD-Karte',
          },
          'en'  => {
            'os'            => 'Garmin GPS-device',
            'link'          => 'Install image for micro SD card',
          },
          'zip'             => '$mapinfo{$mapinfo_entry}{\'map\'} . "_" .$mapinfo{$mapinfo_entry}{\'lang\'} . "_gmapsupp.img.zip"',
        },                       
        'imagedir' => { 
          'de'  => { 
            'os'            => 'Alle Betriebssysteme',
            'link'          => 'Imageverzeichnis f&uuml;r QLandkarte',
          },
          'en'  => {
            'os'            => 'All operating systems',
            'link'          => 'Image folder for QLandkarte',
          },
          'zip'             => '"Freizeitkarte_" . $mapinfo{$mapinfo_entry}{\'map\'} . "_" .$mapinfo{$mapinfo_entry}{\'lang\'} . ".Images.zip"',
        },                       
        'installer' => { 
          'de'  => { 
            'os'            => 'Microsoft Windows',
            'link'          => 'Legacy Installer f&uuml;r Garmin BaseCamp',
          },
          'en'  => {
            'os'            => 'Microsoft Windows',
            'link'          => 'Legacy Installer for Garmin BaseCamp',
          },
          'zip'             => '"Install_Freizeitkarte_" . $mapinfo{$mapinfo_entry}{\'map\'} . "_" .$mapinfo{$mapinfo_entry}{\'lang\'} . ".zip"',
        },                       
); 

# Define titles for languages
my %map_languages = (
       'de'  => {
          'de'                 => 'Deutsch',
          'en'                 => 'German',
       },
       'en'  => {
          'de'                 => 'Englisch',
          'en'                 => 'English',
       },
       'fr'  => {
          'de'                 => 'Franz&ouml;sisch',
          'en'                 => 'French',
       },
       'it'  => {
          'de'                 => 'Italienisch',
          'en'                 => 'Italian',
       },
       'nl'  => {
          'de'                 => 'Niederl&auml;ndisch',
          'en'                 => 'Dutch',
       },
       'pl'  => {
          'de'                 => 'Polnisch',
          'en'                 => 'Polish',
       },
       'pt'  => {
          'de'                 => 'Portugiesisch',
          'en'                 => 'Portuguese',
       },
       'ru'  => {
          'de'                 => 'Russisch',
          'en'                 => 'Russian',
       },
);

# Map definitions for html output
my %map_definitions = (
        'ALPS' => { 
          'de'  => { 
            'title'         => 'Alpen',
            'title_long'    => 'Alpen [Schweiz (CHE), &Ouml;sterreich (AUT), Slowenien (SVN)]',
          },
          'en'  => {
            'title'         => 'Wider Area Alps',
            'title_long'    => 'Wider Area Alps [Switzerland (CHE), Austria (AUT), Slovenia (SVN)]',
          },
        },                       
        'AUT' => {               
          'de'  => { 
            'title'         => '&Ouml;sterreich',
          },
          'en'  => {
            'title'         => 'Austria',
          },
        },                       
        'AUT+' => {              
          'de'  => { 
            'title'         => '&Ouml;sterreich+',
          },
          'en'  => {
            'title'         => 'Austria+',
          },
        },                       
        'AZORES' => {               
          'de'  => { 
            'title'         => 'Azoren',
          },
          'en'  => {
            'title'         => 'Azores',
          },
        },                       
        'BALKAN' => {            
          'de'  => { 
            'title'         => 'Balkan',
          },
          'en'  => {
            'title'         => 'Balkan',
          },
        },                       
        'BEL' => {               
          'de'  => { 
            'title'         => 'Belgien',
          },
          'en'  => {
            'title'         => 'Belgium',
          },
        },                       
        'BEL_NLD_LUX' => {               
          'de'  => { 
            'title'         => 'BeNeLux-Staaten',
            'title_long'    => 'Belgien (BEL), Niederlande (NLD), Luxembourg (LUX) [BeNeLux-Staaten]',
          },
          'en'  => {
            'title'         => 'BeNeLux States',
            'title_long'    => 'Belgium (BEL), Netherlands (NLD), Luxembourg (LUX) [BeNeLux States]',
          },
        },                       
        'BGR' => {               
          'de'  => { 
            'title'         => 'Bulgarien',
          },
          'en'  => {
            'title'         => 'Bulgaria',
          },
        },                       
        'BLR' => {               
          'de'  => { 
            'title'         => 'Wei&szlig;russland',
          },
          'en'  => {
            'title'         => 'Belarus',
          },
        },                       
        'CARPATHIAN' => {               
          'de'  => { 
            'title'         => 'Karpaten',
          },
          'en'  => {
            'title'         => 'Carpathians',
          },
        },                       
        'CHE' => {               
          'de'  => { 
            'title'         => 'Schweiz',
          },
          'en'  => {
            'title'         => 'Switzerland',
          },
        },                       
        'CHE+' => {               
          'de'  => { 
            'title'         => 'Schweiz+',
          },
          'en'  => {
            'title'         => 'Switzerland+',
          },
        },                       
        'CYP' => {               
          'de'  => { 
            'title'         => 'Zypern',
          },
          'en'  => {
            'title'         => 'Cyprus',
          },
        },                       
        'CZE' => {               
          'de'  => { 
            'title'         => 'Tschechien',
          },
          'en'  => {
            'title'         => 'Czech Republic',
          },
        },                       
        'DEU' => {               
          'de'  => { 
            'title'         => 'Deutschland',
          },
          'en'  => {
            'title'         => 'Germany',
          },
        },                       
        'DEU+' => {               
          'de'  => { 
            'title'         => 'Deutschland+',
          },
          'en'  => {
            'title'         => 'Germany+',
          },
        },                       
        'DNK' => {               
          'de'  => { 
            'title'         => 'D&auml;nemark',
          },
          'en'  => {
            'title'         => 'Denmark',
          },
        },                       
        'DNK_NOR_SWE_FIN' => {               
          'de'  => { 
            'title'         => 'Skandinavische &amp; Baltische Staaten',
            'title_long'    => 'D&auml;nemark (DNK), Norwegen (NOR), Schweden (SWE), Finnland (FIN) [Skandinavische Staaten] Russische Exklave Kaliningrad, Litauen (LTU), Lettland (LVA), Estland (EST) [Baltische Staaten]',
          },
          'en'  => {
            'title'         => 'Scandinavian &amp; Baltic States',
            'title_long'    => 'Denmark (DNK), Norway (NOR), Sweden (SWE), Finland (FIN) [Scandinavian states] Russian Exclave Kaliningrad, Lithuania (LTU), Latvia (LVA), Estonia (EST) [Baltic states]',
          },
        },                       
        'ESP' => {               
          'de'  => { 
            'title'         => 'Spanien',
          },
          'en'  => {
            'title'         => 'Spain',
          },
        },                       
        'ESP_CANARIAS' => {               
          'de'  => { 
            'title'         => 'Kanarische Inseln',
          },
          'en'  => {
            'title'         => 'Canary Islands',
          },
        },                       
        'ESP_PRT' => {               
          'de'  => { 
            'title'         => 'Spanien &amp; Portugal',
            'title_long'    => 'Spanien (ESP), Portugal (PRT) [Iberische Halbinsel, Pyren&auml;en, Balearen]',
          },
          'en'  => {
            'title'         => 'Spain &amp; Portugal',
            'title_long'    => 'Spain (ESP), Portugal (PRT) [Iberian Peninsula, Pyrenees, Balearics]',
          },
        },                       
        'EST' => {               
          'de'  => { 
            'title'         => 'Estland',
          },
          'en'  => {
            'title'         => 'Estonia',
          },
        },                       
        'FIN' => {               
          'de'  => { 
            'title'         => 'Finnland',
          },
          'en'  => {
            'title'         => 'Finland',
          },
        },                       
        'FRA' => {               
          'de'  => { 
            'title'         => 'Frankreich',
          },
          'en'  => {
            'title'         => 'France',
          },
        },                       
        'FRA+' => {               
          'de'  => { 
            'title'         => 'Frankreich+',
          },
          'en'  => {
            'title'         => 'France+',
          },
        },                       
        'GBR' => {               
          'de'  => { 
            'title'         => 'Grossbritannien',
          },
          'en'  => {
            'title'         => 'Great Britain',
          },
        },                       
        'GBR_IRL' => {               
          'de'  => { 
            'title'         => 'Grossbritannien &amp; Irland',
            'title_long'    => 'Vereinigtes K&ouml;nigreich Gro&szlig;britannien und Nordirland (GBR), Irland (IRL), F&auml;r&ouml;er (FRO)',
          },
          'en'  => {
            'title'         => 'UK &amp; Ireland',
            'title_long'    => 'United Kingdom (GBR), Ireland (IRL), Faroe Islands (FRO)',
          },
        },                       
        'GRC' => {               
          'de'  => { 
            'title'         => 'Griechenland',
          },
          'en'  => {
            'title'         => 'Greece',
          },
        },                       
        'HRV' => {               
          'de'  => { 
            'title'         => 'Kroatien',
          },
          'en'  => {
            'title'         => 'Croatia',
          },
        },                       
        'HUN' => {               
          'de'  => { 
            'title'         => 'Ungarn',
          },
          'en'  => {
            'title'         => 'Hungary',
          },
        },                       
        'IRL' => {               
          'de'  => { 
            'title'         => 'Irland',
          },
          'en'  => {
            'title'         => 'Ireland',
          },
        },                       
        'ISL' => {               
          'de'  => { 
            'title'         => 'Island',
          },
          'en'  => {
            'title'         => 'Iceland',
          },
        },                       
        'ITA' => {               
          'de'  => { 
            'title'         => 'Italien',
          },
          'en'  => {
            'title'         => 'Italy',
          },
        },                       
        'ITA+' => {               
          'de'  => { 
            'title'         => 'Italien+',
          },
          'en'  => {
            'title'         => 'Italy+',
          },
        },                       
        'LTU' => {               
          'de'  => { 
            'title'         => 'Litauen',
          },
          'en'  => {
            'title'         => 'Lithuania',
          },
        },                       
        'LUX' => {               
          'de'  => { 
            'title'         => 'Luxemburg',
          },
          'en'  => {
            'title'         => 'Luxembourg',
          },
        },                       
        'LVA' => {               
          'de'  => { 
            'title'         => 'Lettland',
          },
          'en'  => {
            'title'         => 'Latvia',
          },
        },                       
        'MLT' => {               
          'de'  => { 
            'title'         => 'Malta',
          },
          'en'  => {
            'title'         => 'Malta',
          },
        },                       
        'NLD' => {               
          'de'  => { 
            'title'         => 'Niederlande',
          },
          'en'  => {
            'title'         => 'Netherlands',
          },
        },                       
        'NOR' => {               
          'de'  => { 
            'title'         => 'Norwegen',
          },
          'en'  => {
            'title'         => 'Norway',
          },
        },                       
        'POL' => {               
          'de'  => { 
            'title'         => 'Polen',
          },
          'en'  => {
            'title'         => 'Poland',
          },
        },                       
        'PRT' => {               
          'de'  => { 
            'title'         => 'Portugal',
          },
          'en'  => {
            'title'         => 'Portugal',
          },
        },                       
        'PYRENEES' => {               
          'de'  => { 
            'title'         => 'Pyren&auml;en',
          },
          'en'  => {
            'title'         => 'Pyrenees',
          },
        },                       
        'ROU' => {               
          'de'  => { 
            'title'         => 'Rum&auml;nien',
          },
          'en'  => {
            'title'         => 'Romania',
          },
        },                       
        'SRB' => {               
          'de'  => { 
            'title'         => 'Serbien',
          },
          'en'  => {
            'title'         => 'Serbia',
          },
        },                       
        'SVK' => {               
          'de'  => { 
            'title'         => 'Slowakei',
          },
          'en'  => {
            'title'         => 'Slovakia',
          },
        },                       
        'SVN' => {               
          'de'  => { 
            'title'         => 'Slowenien',
          },
          'en'  => {
            'title'         => 'Slovenia',
          },
        },                       
        'SWE' => {               
          'de'  => { 
            'title'         => 'Schweden',
          },
          'en'  => {
            'title'         => 'Sweden',
          },
        },                       
        'TUR' => {               
          'de'  => { 
            'title'         => 'T&uuml;rkei',
          },
          'en'  => {
            'title'         => 'Turkey',
          },
        },                       
);
 
# Get the URL or die
# -------------------
my $content = get $url;
  die "Couldn't get $url" unless defined $content;


# Walk through the web content: filter out only links to zip files
# ----------------------------------------------------------------
foreach my $contentline ( split /\n/, $content) {
  if ( $contentline =~ /<a href="(.*\.zip)">.*<\/a>/ ) {

    my $zipfile = $1;
    
    my $MAP = "";
    my $LANG = "";
    my $KEY = "";
    my $TYPE = "";
    my $SIZE = "";
    
    # Categorize the zip file and get MAP and LANG
    # --------------------------------------------
    # gmapsupp
    if ( $zipfile =~ /(.*)_([a-z][a-z])_gmapsupp\.img\.zip/ ) {
        $TYPE = "gmapsupp";    
    }
    # ImageDir
    elsif ( $zipfile =~ /Freizeitkarte_(.*)_([a-z][a-z])\.Images\.zip/ ) {
        $TYPE = "imagedir";    
    }
    # gmap archive
    elsif ( $zipfile =~ /Freizeitkarte_(.*)_([a-z][a-z])\.gmap\.zip/ ) {
        $TYPE = "gmaparchive";    
    }
    # GMAP Installer
    elsif ( $zipfile =~ /GMAP_Installer_Freizeitkarte_(.*)_([a-z][a-z])\.zip/ ) {
        $TYPE = "gmapinstaller";    
    }
    # GMAP Full Installer
    elsif ( $zipfile =~ /GMAP_Installer_Freizeitkarte_(.*)_([a-z][a-z])_full\.zip/ ) {
        $TYPE = "gmapfullinstaller";    
    }
    # Old Installer
    elsif ( $zipfile =~ /Install_Freizeitkarte_(.*)_([a-z][a-z])\.zip/ ) {
        $TYPE = "installer";    
    }
    else {
      print "WARNING: uncategorized file $zipfile\n";
      next;
    } # end if (categorization)
    
    # create the key
    $MAP  = $1;
    $LANG = $2;
    $KEY = "$MAP" . "_" . "$LANG";    
  
    # assign the values if something is found
    $mapinfo{$KEY}{"map"} = $MAP;
    $mapinfo{$KEY}{"lang"} = $LANG;
    $mapinfo{$KEY}{"$TYPE"} = $zipfile;
    
    # Let's get the size
    if ( $contentline =~ /.*\.Images\.zip.*> *(\d*\.?\d+)([KMG])<\/td>/ ) {
      #print "$1 $2 - ";
      
      my $sizevalue = $1;
      my $sizeunit = $2;
      
      if ( $sizeunit eq "M" ) {
        $sizevalue = int(int($sizevalue + 0.9)/10 + 0.9)*10;
      }
      
      $SIZE = "$sizevalue $sizeunit" . "B";
      $mapinfo{$KEY}{"size"} = $SIZE;
      #print "$SIZE\n";
    }

  } # end if contains href
} # foreach $contentline


# Walk through mapinfo, fill out more variables and warn about missing maptypes
# -----------------------------------------------------------------------------
foreach my $mapinfo_entry (sort keys %mapinfo) {
  
#  my $headerprinted = 0;
  
  foreach my $maptype (@maptypes) {
    
    # fill out allmaps hash
    $allmaps{$mapinfo{$mapinfo_entry}{'map'}} = "1";
    
    # Check for missing maptype
    unless ( $mapinfo{$mapinfo_entry}{$maptype} ) {

      # Header already printed ?     
#      if ( $headerprinted eq "0" ) {
#        print "\n";
#        print "$mapinfo{$mapinfo_entry}{'map'} $mapinfo{$mapinfo_entry}{'lang'} ($mapinfo{$mapinfo_entry}{'size'})\n";
#        print "-----------------------------------------------------\n";
#        $headerprinted = 1;
#      } # end if header printed
      
      # Print out warning and fill out zipfile variable for later changing
      printf( "%-17s - %-4s: WARNING: Missing maptype: %s\n",$mapinfo{$mapinfo_entry}{'map'}, $mapinfo{$mapinfo_entry}{'lang'}, $maptype);
      $mapinfo{$mapinfo_entry}{$maptype} = eval ( $maptype_info{$maptype}{'zip'});
      
    } # unless maptype exists
    
  } # foreach $maptype
  
} # foreach $mapinfo_entry

# Empty line
print "\n";

# Print out new undefined maps and fill out missing long titles
# -------------------------------------------------------------
# Check for missing definitions
foreach my $singlemap (sort keys %allmaps) {
  # Check for missing definitions
  unless ( $map_definitions{$singlemap}{'de'}{'title'} ) {
    print "WARNING: No titles defined for map: $singlemap\n";
  }
  # fill out 'missing' long titles
  unless ( $map_definitions{$singlemap}{'de'}{'title_long'} ) {
    $map_definitions{$singlemap}{'de'}{'title_long'} = $map_definitions{$singlemap}{'de'}{'title'};
  }
  unless ( $map_definitions{$singlemap}{'en'}{'title_long'} ) {
    $map_definitions{$singlemap}{'en'}{'title_long'} = $map_definitions{$singlemap}{'en'}{'title'};
  }
}

# Create the html scriptlets
# --------------------------
if ( $flag_createhtml ) {
  print "\n\n";
  # Loop through the html page languages
  foreach my $htmllang ( qw/de en/ ) {
    
    print "\n\n";
    
    # Loop through all maps
    foreach my $mapkey (sort keys %mapinfo) {
  
      print "\n\n";
          
      # used html parts
      my $html_span = '<span style="margin-left: 20px">';
      my $html_url  = 'http://download.freizeitkarte-osm.de/garmin/latest/';
  
  
      # Map Header: Map & Language
      print "<h3>$map_definitions{ $mapinfo{$mapkey}{'map'} }{$htmllang}{'title_long'}</h3>\n";
      print "<h4>$map_languages{ $mapinfo{$mapkey}{'lang'} }{$htmllang}</h4>\n";
  
      foreach my $actualtype ( qw/gmapsupp gmapfullinstaller gmaparchive imagedir/ ) {
        
        # Map Type / Size & Link
        print "$maptype_info{$actualtype}{$htmllang}{'os'}: ($mapinfo{$mapkey}{'size'})<br>\n"; 
        print "$html_span<a href=\"$html_url$mapinfo{$mapkey}{$actualtype}\">$map_definitions{ $mapinfo{$mapkey}{'map'} }{$htmllang}{'title'} - $maptype_info{$actualtype}{$htmllang}{'link'}</a><p>\n";      
        
      } # foreach $actualtype
          
    } # foreach $mapkey
  } # foreach $htmllang

} # if $flag_createhtml
