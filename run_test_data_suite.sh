#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -pwd|--password)
      PASSWORD="$2"
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

echo "Password  = ${PASSWORD}"






EXIT_STATUS=0
echo pipenv --rm
pipenv --rm || EXIT_STATUS=$?

echo pipenv --python /usr/bin/python3
pipenv --python 3.9 || EXIT_STATUS_PY=$?
if $EXIT_STATUS_PY; then
    $EXIT_STATUS = EXIT_STATUS_PY
else
    echo pipenv --python /usr/bin/python3 || EXIT_STATUS_PY=$?
    pipenv --python /usr/bin/python3 || EXIT_STATUS_PY=$?
fi
echo pipenv install folio_migration_tools 
pipenv install folio_migration_tools || EXIT_STATUS=$?
echo pipenv run python -m folio_migration_tools -h 
pipenv run python -m folio_migration_tools -h || EXIT_STATUS=$?

echo pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_bibs --base_folder_path ./ --okapi_password ${PASSWORD} 
pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_bibs --base_folder_path ./ --okapi_password ${PASSWORD}|| EXIT_STATUS=$?

echo pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_mfhd --base_folder_path ./ --okapi_password ${PASSWORD}
pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_mfhd --base_folder_path ./ --okapi_password ${PASSWORD}|| EXIT_STATUS=$?

echo pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_csv_holdings --base_folder_path ./ --okapi_password ${PASSWORD}
pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_csv_holdings --base_folder_path ./ --okapi_password ${PASSWORD}|| EXIT_STATUS=$?

echo pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_bibs --base_folder_path ./ --okapi_password ${PASSWORD}
pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_bibs --base_folder_path ./ --okapi_password ${PASSWORD}|| EXIT_STATUS=$?

echo pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_bw_holdings --base_folder_path ./ --okapi_password ${PASSWORD}
pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_bw_holdings --base_folder_path ./ --okapi_password ${PASSWORD}|| EXIT_STATUS=$?

echo pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_mfhd_items --base_folder_path ./ --okapi_password ${PASSWORD}
pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_mfhd_items --base_folder_path ./ --okapi_password ${PASSWORD}|| EXIT_STATUS=$?

echo pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_csv_items --base_folder_path ./ --okapi_password ${PASSWORD}
pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json transform_csv_items --base_folder_path ./ --okapi_password ${PASSWORD}|| EXIT_STATUS=$?

echo pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json user_transform- -base_folder_path ./ --okapi_password ${PASSWORD}
pipenv run python -m folio_migration_tools ./mapping_files/exampleConfiguration.json user_transform --base_folder_path ./ --okapi_password ${PASSWORD}|| EXIT_STATUS=$?

echo Done. Exit status: $EXIT_STATUS

exit $EXIT_STATUS

if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
fi