elevation
==========
Collection of scripts around the creation of the elevation maps:

create-elevation-data-bg.bash
-----------------------------
The main worker script, served by the other wrapper scripts

create-elevation-data-fix-poly.bash
-----------------------------------
Loops through all the found *.poly files in the poly subdirectory and creates the needed elevation pbf files using fix node IDs and fix way IDs. Is calling create-elevation-data-bg.bash for executing the real work

create-elevation-data-manual.bash
---------------------------------
Collection wrapper script to call create-elevation-data-bg.bash with specific node IDs and way IDs.
