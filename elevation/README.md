# elevation
Collection of scripts around the creation of the elevation maps:

## Scripts for creation of contour lines

### create-elevation-data-bg.bash
The main worker script, served by the other wrapper scripts, now supporting new pyhgtmap (https://github.com/agrenott/pyhgtmap)

### create-elevation-data-fix-poly.bash
Loops through all the found *.poly files in the poly.work subdirectory and creates the needed elevation pbf files using fix node IDs and fix way IDs. Is calling create-elevation-data-bg.bash for executing the real work

### create-elevation-data-manual.bash
Collection wrapper script to call create-elevation-data-bg.bash with specific node IDs and way IDs.

### create-elevation-data-bg-geotif.bash
(wip, possibly containing bugs and probably not used in the future)
Needed if we feed geotif files directly on the command line

### create-elevation-data-bg-hgt.bash
(wip, possibly containing bugs and probably not used in the future)
Needed if we feed hgt files directly on the command line

## Other scripts

### check-view3-dem-hgt.bash
(needs some updates)
Crosschecking pbf info files and DEM directory for missing hgt files

### convert-srtm1-tif-hgt.bash
SRTM1 v3.0 is downloaded as geotif. This basic script helps with the conversion from *.tif to *.hgt for DEM hillshading. Attention: rudimentary script, no error checking/handling. Use with caution.

### elevation\download-view3-hgt.bash
Was used to download view3 hgt files for having source data for DEM hillshading. Possibly needed in future with adaptions for other sources

## Installation/Configuration of pyhgtmap
1. Installation according to https://github.com/agrenott/pyhgtmap into venv (either from pypi or direct github)
2. for downloads of sonn1 or sonn3 data: Create API client OAuth secret, as mentioned in https://github.com/agrenott/pyhgtmap and https://docs.iterative.ai/PyDrive2/quickstart/. Important: Choose Desktop Application. When running it the first time (run pyhgtmap manually) you have finish the authentication by following the on screen instructions. The results are written into ~/.pyhgtmap.
3. for SRTM downloads you have to register for the https://earthexplorer.usgs.gov/ and run pyhgtmap first time manually with --earthexplorer-user=EARTHEXPLORER_USERNAME and  --earthexplorer-password=EARTHEXPLORER_PASSWORD. The authentication credentials will then be saved into ~/.pyhgtmap/.pyhgtmaprc

