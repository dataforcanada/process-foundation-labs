#!/bin/bash

# TODO
# Create GeoParquet, every column should have best data type and columns should
# be standardized/consistent with naming in process-statcan-data

SCRATCH_FOLDER="${HOME}/tmp/dataforcanada/process-foundation-dev"
DATASET_ID="ca_statcan_open_database_of_buildings_2025-04-15"
OUTPUT_GEOPACKAGE="${SCRATCH_FOLDER}/${DATASET_ID}/${DATASET_ID}.gpkg"
OUTPUT_FLATGEOBUF="${SCRATCH_FOLDER}/${DATASET_ID}/${DATASET_ID}.fgb"

FIRST=true
for FILE in ${SCRATCH_FOLDER}/${DATASET_ID}/ODB*.gpkg; do
    if [ "${FILE}" == "${OUTPUT_GEOPACKAGE}" ]; then
        continue;
    fi
    if [ "${FIRST}" = true ]; then
        echo "Creating ${OUTPUT_GEOPACKAGE} with ${FILE}"
        ogr2ogr -f "GPKG" "${OUTPUT_GEOPACKAGE}" "${FILE}" -nln "${DATASET_ID}" -nlt PROMOTE_TO_MULTI
        FIRST=false
    else
        echo "Merging ${FILE} into ${DATASET_ID}" 
        ogr2ogr -f "GPKG" -update -append "${OUTPUT_GEOPACKAGE}" "${FILE}" -nln "${DATASET_ID}" -nlt PROMOTE_TO_MULTI
    fi
done

echo "Creating ${OUTPUT_FLATGEOBUF} from ${OUTPUT_GEOPACKAGE}"
ogr2ogr -f FlatGeobuf \
    -progress \
    -t_srs EPSG:4326 \
    -nlt "MULTIPOLYGON2D" \
    -lco "TITLE=Open Database of Buildings (ODB) - Statistics Canada / Base de données ouverte sur les bâtiments (BDOB) - Statistique Canada" \
    -lco "DESCRIPTION=Harmonized building footprints and attributes across Canada, optimized for cloud-native GIS workflows. / Empreintes et attributs de bâtiments harmonisés à l'échelle du Canada, optimisés pour les flux de travail SIG infonuagiques" \
    "${OUTPUT_FLATGEOBUF}" \
    "${OUTPUT_GEOPACKAGE}"

