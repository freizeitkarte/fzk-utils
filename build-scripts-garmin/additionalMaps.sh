RAM=3096
cd $1

# Armenien
perl ./mt.pl --ram=${RAM} pmd ARM
perl ./mt.pl --ram=${RAM} bml ARM
perl ./mt.pl --ram=${RAM} zip ARM

# Central America
perl ./mt.pl --ram=${RAM} pmd CENTRAL_AMERICA
perl ./mt.pl --ram=${RAM} bml CENTRAL_AMERICA
perl ./mt.pl --ram=${RAM} zip CENTRAL_AMERICA

# Zypern
perl ./mt.pl --ram=${RAM} pmd CYP
perl ./mt.pl --ram=${RAM} bml CYP
perl ./mt.pl --ram=${RAM} zip CYP

# Georgien
perl ./mt.pl --ram=${RAM} pmd GEO
perl ./mt.pl --ram=${RAM} bml GEO
perl ./mt.pl --ram=${RAM} zip GEO

# US Regionen
perl ./mt.pl --ram=${RAM} pmd US_ALASKA
perl ./mt.pl --ram=${RAM} bml US_ALASKA
perl ./mt.pl --ram=${RAM} zip US_ALASKA
perl ./mt.pl --ram=${RAM} pmd US_HAWAII
perl ./mt.pl --ram=${RAM} bml US_HAWAII
perl ./mt.pl --ram=${RAM} zip US_HAWAII
perl ./mt.pl --ram=${RAM} pmd US_MIDWEST
perl ./mt.pl --ram=${RAM} bml US_MIDWEST
perl ./mt.pl --ram=${RAM} zip US_MIDWEST
perl ./mt.pl --ram=${RAM} pmd US_NORTHEAST
perl ./mt.pl --ram=${RAM} bml US_NORTHEAST
perl ./mt.pl --ram=${RAM} zip US_NORTHEAST
perl ./mt.pl --ram=${RAM} pmd US_PACIFIC
perl ./mt.pl --ram=${RAM} bml US_PACIFIC
perl ./mt.pl --ram=${RAM} zip US_PACIFIC
perl ./mt.pl --ram=${RAM} pmd US_SOUTH
perl ./mt.pl --ram=${RAM} bml US_SOUTH
perl ./mt.pl --ram=${RAM} zip US_SOUTH
perl ./mt.pl --ram=${RAM} pmd US_WEST
perl ./mt.pl --ram=${RAM} bml US_WEST
perl ./mt.pl --ram=${RAM} zip US_WEST
