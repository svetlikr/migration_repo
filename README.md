# Migration Repo template
This repo is a template repository for the files needed for migrating Inventory data from a source system into FOLIO 

TLDR; Create a new private repository based on this template. Clone it and then run create_folder_structure.sh 

- [Supported migration tasks](#supported-migration-tasks)
- [FOLIO Inventory data migration process](#folio-inventory-data-migration-process)
- [Mapping files](#mapping-files)
  * [What file is needed for what objects?](#what-file-is-needed-for-what-objects-)
  * [marc-instance-mapping-rules.json](#marc-instance-mapping-rulesjson)
  * [mfhd_rules.json](#mfhd-rulesjson)
  * [holdings_mapping.json](#holdings-mappingjson)
  * [item_mapping.json](#item-mappingjson)
    + [Fallback values in reference data mapping](#fallback-values-in-reference-data-mapping)
  * [locations.tsv](#locationstsv)
  * [material_types.tsv](#material-typestsv)
  * [loan_types.tsv](#loan-typestsv)
  * [call_number_type_mapping.tsv](#call-number-type-mappingtsv)
  * [statcodes.tsv](#statcodestsv)
  * [item_statuses.tsv](#item-statusestsv)
  * [post_loan_migration_statuses.tsv](#post-loan-migration-statusestsv)
- [Example Records](#example-records)
  * [Result files](#result-files)
  * [HRID handling](#hrid-handling)
    + [Current implementation:](#current-implementation-)
  * [Relevant FOLIO community documentation](#relevant-folio-community-documentation)
- [Perform a test migration](#perform-a-test-migration)
  * [Before you begin](#before-you-begin)
  * [Transform bibs](#transform-bibs)
    + [Configuration](#configuration)
    + [Explanation of parameters](#explanation-of-parameters)
    + [Syntax to run](#syntax-to-run)
  * [Post tranformed Instances and SRS records](#post-tranformed-instances-and-srs-records)
    + [Configuration](#configuration-1)
    + [Explanation of parameters](#explanation-of-parameters-1)
    + [Syntax to run](#syntax-to-run-1)
  * [Transform MFHD records to holdings and SRS holdings](#transform-mfhd-records-to-holdings-and-srs-holdings)
    + [Configuration](#configuration-2)
    + [Explanation of parameters](#explanation-of-parameters-2)
    + [Syntax to run](#syntax-to-run-2)
  * [Post tranformed MFHDs and Holdingsrecords to FOLIO](#post-tranformed-mfhds-and-holdingsrecords-to-folio)
    + [Configuration](#configuration-3)
    + [Explanation of parameters](#explanation-of-parameters-3)
    + [Syntax to run](#syntax-to-run-3)
  * [Transform CSV/TSV files into Holdingsrecords](#transform-csv-tsv-files-into-holdingsrecords)
    + [Configuration](#configuration-4)
    + [Explanation of parameters](#explanation-of-parameters-4)
    + [Syntax to run](#syntax-to-run-4)
  * [Post trasformed Holdingsrecords to FOLIO](#post-trasformed-holdingsrecords-to-folio)
  * [Transform CSV/TSV files into Items](#transform-csv-tsv-files-into-items)
    + [Configuration](#configuration-5)
    + [Explanation of parameters](#explanation-of-parameters-5)
    + [Syntax to run](#syntax-to-run-5)
  * [Post transformed Items to FOLIO](#post-transformed-items-to-folio)
  * [Transform CSV/TSV files into FOLIO users](#transform-csv-tsv-files-into-folio-users)
    + [Configuration](#configuration-6)
    + [Explanation of parameters](#explanation-of-parameters-6)
    + [Syntax to run](#syntax-to-run-6)
  * [Post transformed users to FOLIO](#post-transformed-users-to-folio)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>



# Supported migration tasks
* Batch Poster (BatchPoster) - Post generated objects to FOLIO
* Bibs Transformer (BibsTransformer) - Transform MARC21 Bib records to FOLIO Instances and SRS records
* Holdings CSV Transformer (HoldingsCsvTransformer) - Creates FOLIO holdingsrecords from a TSV or CSV File
* Holdings MARC transformer (HoldingsMarcTransformer) - Transforms MARC21 MFHD records into FOLIO Holdings and SRS records
* Items Transformer (ItemsTransformer) - Creates FOLIO Items from a TSV or CSV File
* User Transformer (UserTransformer) - Creates FOLIO Users from a TSV or CSV File

# FOLIO Inventory data migration process
This repository template plays a vital part in a process together with other repos allowing you to perform data migrations from a legacy ILS into FOLIO. 

The program you will need to run the process is [FOLIO Migration Tools](https://github.com/FOLIO-FSE/folio_migration_tools). This is a Python program, not yet on PyPi, so you will need to clone it.

The toolkit requires you to run the transformation an data loading in sequence, and each step relies on previous migrations steps, like the existance of a map file with legacy system IDs and their FOLIO equivalents. 
The below picture shows the proposed migration steps for legacy objects into FOLIO:
![image](https://user-images.githubusercontent.com/1894384/139079124-b31b716f-281b-4784-b73e-a4567ee3e097.png)

# Mapping files
The repo contains the following mapping files in the Mapping files folder.
There is a web tool that helps you crate the mapping files for certain objects available at https://data-mapping-file-creator.folio.ebsco.com/data_mapping_creation

## What file is needed for what objects?
File\Process | Bibs->Instances | Holdings (from MARC/MFHD) | Holdings (from item tsv/csv) | Items  | Open Loans  | Users   
------------ | ------------- | ------------- | ------------- | ------------- | ------------- | -------------   
marc-instance-mapping-rules.json  | yes | no | no | no |   no    |   no
mfhd_rules.json  | no | yes | no | no |  no   |   no
item_mapping.json  | no | no | no | yes |  no   |   no
holdings_mapping.json  | no | no | yes |  no   |   no
locations.tsv  | no | yes | yes | yes |  no   |   no
temp_locations.tsv  | no | no | no | optional |  no   |   no
material_types.tsv  | no | no | no |  yes   |   no
loan_types.tsv  | no | no | no | yes |  no   |   no
temp_loan_types.tsv  | no | no | no | optional |  no   |   no
call_number_type_mapping.tsv  | no | no | optional | optional |  no   |   no
statcodes.tsv  | no | no | optional | optional |  no   |   no
item_statuses.tsv | no | no | no | optional    |  no   |   no
post_loan_migration_statuses.tsv | no | no | no | no    |  optional  |   no
patron_types.tsv | no | no | no | no    |  no  |   yes
user_mapping.json | no | no | no | no    |  no  |   yes
department_mapping.tsv | no | no | no | no    |  no  |   yes


## marc-instance-mapping-rules.json
These are the mapping rules from MARC21 bib records to FOLIO instances. The rules are stored in the tenant, but it is good practice to keep them under version control so you can maintain the customizations as the mapping rules evolve.For more information on syntax etc, read the [documentation](https://github.com/folio-org/mod-source-record-manager/blob/master/RuleProcessorApi.md).

## mfhd_rules.json
This file is built out according to the [mapping rules for bibs](https://github.com/folio-org/mod-source-record-manager/blob/master/RuleProcessorApi.md). The conditions are different, and not well documented at this point. Look at the example file and refer to the mappinrules documentation 

## holdings_mapping.json
Just as the item_mapping.json and the user mapping files, these files are esiest to create using the [data-mapping-file-creator tool](https://data-mapping-file-creator.folio.ebsco.com/data_mapping_creation)
You base the mapping on the same item export as you use for the items.

## item_mapping.json
This is a mapping file for the items. The process assumes you have the item data in a CSV/TSV format. 
The structure of the file is dependant on the the column names in the TSV file. For example, if you have a file that looks like this:
... | Z30_BARCODE | Z30_CALL_NO | Z30_DESCRIPTION |  ... 
------------ | ------------- | ------------- | ------------- | -------------
 ... | 123456790 | Some call number | some note  | ...
 


Your map should look like this:
```
...
{
    "folio_field": "barcode",
    "legacy_field": "Z30_BARCODE",
    "value":"",
    "description": ""
},
{
    "folio_field": "itemLevelCallNumber",
    "legacy_field": "Z30_CALL_NO",
    "value":"",
    "description": ""
}, 
{
    "folio_field": "notes[0].itemNoteTypeId",
    "legacy_field": "Z30_DESCRIPTION",
    "value": "c7bc292c-a318-43d3-9b03-7a40dfba046a",
    "description": ""
},
{
    "folio_field": "notes[0].staffOnly",
    "legacy_field": "Z30_DESCRIPTION",
    "value": false,
    "description": ""
},
{
    "folio_field": "notes[0].note",
    "legacy_field": "Z30_DESCRIPTION",
    "value": false,
    "description": ""
},
...
```
The resulting FOLIO Item would look like this:
```
{
	...
	"barcode": "123456790",
	"itemLevelCallNumber": "Some call number"
	"notes":[{
			"staffOnly": false,
			"note": "some note",
			"itemNoteTypeId": "c7bc292c-a318-43d3-9b03-7a40dfba046a"			
		}],
	...
}
```
### Fallback values in reference data mapping
All mapping files (locations.tsv, material_types.tsv, locations.tsv etc) have a mechanism that allows you to add * to legacy fields in a row, and add the falback value from folio in the folio_code/folio_name column. If the mapping fails, the script will assign this value to the records created. Good practice is to have migration-specific value as a falback value to be able to locate the records in FOLIO


## locations.tsv
These mappings allow for some complexity. These are the mappings of the legacy and FOLIO locations. The file must be structured like this:
 folio_code | legacy_code | Z30_COLLECTION 
------------ | ------------- | -------------
 AFA | AFAS | AFAS   
 AFA  |  * |  *    
 
The legacy_code part is needed for both Holdings migratiom. For Item migration, the source fields can be used (Z30_COLLECTION in this case). You can add as many source fields as you like for the Items

## material_types.tsv
These mappings allow for some complexity. The first column name is fixed, since that is the target material type in FOLIO. Then you add the column names from the Item export TSV. For each column added, the values in them must match. At least one value per column must match. Se loan_types.tsv for complex examples
 folio_name | Z30_MATERIAL 
------------ | ------------- 
 Audiocassette | ACASS
 Audiocassette | *

## loan_types.tsv
These mappings allow for some complexity. The first column name is fixed, since that is the target loan type in FOLIO. Then you add the column names from the Item export TSV. For each column added, the values in them must match. At least one value per column must match

 folio_name | Z30_SUB_LIBRARY | Z30_ITEM_STATUS 
------------ | ------------- | -------------
 Non-circulating | UMDUB | 02
 Non-circulating | * | *   

## call_number_type_mapping.tsv
These mappings allow for some complexity eventhough not needed. 
 folio_name | Z30_CALL_NO_TYPE 
------------ | -------------
Dewey Decimal classification | 8
Unmapped | *   

## statcodes.tsv
In order to map one statistical code to the FOLIO UUID, you need this map, and the field mapped in the item_mappings.json. These mappings allow for some complexity even though not needed. This mapping does not allow for default values. Any record without the field will not get one assigned.
 folio_code | Z30_STAT_CODE 
------------ | -------------
married_with_children | 8
happily_ever_after | 9

## item_statuses.tsv	
The handling of Item statuses is a bit of a project of its own, since not all statuses in legacy systems will have their equivalents in FOLIO. This mapping allows you to point one legacy status to a FOLIO status. If not status map is supplied, the status will be set to available.
legacy_code | folio_name 
------------ | -------------
checked_out | Checked out
available | Available
lost | Aged to lost

## post_loan_migration_statuses.tsv
This is not yet a mapping file per se, but it is used to substitute the values in the next_item_status column in the legacy open loans file.
Leave the statuses you do not want the loans migration process to migrate empty and replace the legacy statuses you want to apply with the correct FOLIO ones.

# Example Records
In the [example records folder](https://github.com/FOLIO-FSE/migration_repo_template/tree/main/example_files), you will find example source records and example results from after a transformation
## Result files
The following table outlines the result records and their use and role
 File | Content | Use for 
------------ | ------------- | ------------- 
folio_holdings.json | FOLIO Holdings records in json format. One per row in the file | To be loaded into FOLIO using the batch APIs
folio_instances.json | FOLIO Instance records in json format. One per row in the file | To be loaded into FOLIO using the batch APIs
folio_items.json |FOLIO Item records in json format. One per row in the file | To be loaded into FOLIO using the batch APIs
holdings_id_map.json | A json map from legacy Holdings Id to the ID of the created FOLIO Holdings record | To be used in subsequent transformation steps 
holdings_transformation_report.md | A file containing various breakdowns of the transformation. Also contains errors to be fixed by the library | Create list of cleaning tasks, mapping refinement
instance_id_map.json | A json map from legacy Bib Id to the ID of the created FOLIO Instance record. Relies on the "ILS Flavour" parameter in the main_bibs.py scripts | To be used in subsequent transformation steps 
instance_transformation_report.md | A file containing various breakdowns of the transformation. Also contains errors to be fixed by the library | Create list of cleaning tasks, mapping refinement
item_id_map.json | A json map from legacy Item Id to the ID of the created FOLIO Item record | To be used in subsequent transformation steps 
item_transform_errors.tsv | A TSV file with errors and data issues together with the row number or id for the Item | To be used in fixing of data issues 
items_transformation_report.md | A file containing various breakdowns of the transformation. Also contains errors to be fixed by the library | Create list of cleaning tasks, mapping refinement
marc_xml_dump.xml | A MARCXML dump of the bib records, with the proper 001:s and 999 fields added | For pre-loading a Discovery system.
srs.json | FOLIO SRS records in json format. One per row in the file | To be loaded into FOLIO using the batch APIs



## HRID handling
### Current implementation:   
Download the HRID handling settings from the tenant. 
**If there are HRID handling in the mapping rules:**
- The HRID is set on the Instance
- The 001 in the MARC21 record (bound for SRS) is replaced with this HRID.

**If the mapping-rules specify no HRID handling or the field designated for HRID contains no value:**
- The HRID is being constructed from the HRID settings
- Pad the number in the HRID Settings so length is 11
- A new 035 field is created and populated with the value from 001
- The 001 in the MARC21 record (bound for SRS) is replaced with this HRID.


## Relevant FOLIO community documentation
* [Instance Metadata Elements](https://docs.google.com/spreadsheets/d/1RCZyXUA5rK47wZqfFPbiRM0xnw8WnMCcmlttT7B3VlI/edit#gid=952741439)
* [Recommended MARC mapping to Inventory Instances](https://docs.google.com/spreadsheets/d/11lGBiPoetHuC3u-onVVLN4Mj5KtVHqJaQe4RqCxgGzo/edit#gid=1891035698)
* [Recommended MFHD to Inventory Holdings mapping ](https://docs.google.com/spreadsheets/d/1ac95azO1R41_PGkeLhc6uybAKcfpe6XLyd9-F4jqoTo/edit#gid=301923972)
* [Holdingsrecord JSON Schema](https://github.com/folio-org/mod-inventory-storage/blob/master/ramls/holdingsrecord.json)
* [FOLIO Instance storage JSON Schema](https://github.com/folio-org/mod-inventory-storage/blob/master/ramls/instance.json)
* [FOLIO Intance (BL) JSON Schema](https://github.com/folio-org/mod-inventory/blob/master/ramls/instance.json)
* [Inventory elements - Beta](https://docs.google.com/spreadsheets/d/1RCZyXUA5rK47wZqfFPbiRM0xnw8WnMCcmlttT7B3VlI/edit#gid=901484405)
* [MARC Mappings Information](https://wiki.folio.org/display/FOLIOtips/MARC+Mappings+Information)

# Perform a test migration
The mapping files and example data in this repo will enable you perform a migration against the latest FOLIO bugfest enironment. Everything is configured except for the missing FOLIO user password.
This step-by-step guide will take you through the steps involved. If there are no more steps, we are still working on these example records

## Before you begin
* Move everything under the example_data folder into the data folder.
* Setup pipenv using either the Pipfile or the requirements.txt

## Transform bibs
### Configuration
This configuration piece in the configuration file determines the behaviour
```
 {
    "name": "transform_bibs",
    "migrationTaskType": "BibsTransformer",
    "useTenantMappingRules": true,
    "ilsFlavour": "tag001",
    "tags_to_delete": [
        "841",
        "852"
    ],
    "files": [
        {
            "file_name": "bibs.mrc",
            "suppressed": false
        }
    ]
}
```

### Explanation of parameters
| Parameter  | Possible values  | Explanation  | 
| ------------- | ------------- | ------------- |
| Name  | Any string  | The name of this task. Created files will have this as part of their names.  |
| migrationTaskType  | Any of the [avialable migration tasks]()  | The type of migration task you want to run  |
| useTenantMappingRules  | true  | Placeholder for option to use an external rules file  |
| ilsFlavour  | any of "aleph", "voyager", "sierra", "millennium", "koha", "tag907y", "tag001", "tagf990a"  | Used to point scripts to the correct legacy identifier and other ILS-specific things  |
| tags_to_delete  | any string  | Tags with these names will be deleted (after transformation) and not get stored in SRS  |
| files  | Objects with filename and boolean  | Filename of the MARC21 file in the data/instances folder- Suppressed tells script to mark records as suppressedFromDiscovery  |



### Syntax to run
``` 
 pipenv run python main.py PATH_TO_migration_repo_template/mapping_files/exampleConfiguration.json transform_bibs --base_folder PATH_TO_migration_repo_template/

```
## Post tranformed Instances and SRS records 
### Configuration
These configuration pieces in the configuration file determines the behaviour
```
{
    "name": "post_bibs",
    "migrationTaskType": "BatchPoster",
    "objectType": "Instances",
    "batchSize": 250,
    "file": {
        "file_name": "folio_instances_test_run_transform_bibs.json"
    }
},
{
    "name": "post_srs_bibs",
    "migrationTaskType": "BatchPoster",
    "objectType": "SRS",
    "batchSize": 250,
    "file": {
        "file_name": "folio_srs_instances_test_run_transform_bibs.json"
    }
}
```

### Explanation of parameters
| Parameter  | Possible values  | Explanation  | 
| ------------- | ------------- | ------------- |
| Name  | Any string  | The name of this task. Created files will have this as part of their names.  |
| migrationTaskType  | Any of the [avialable migration tasks]()  | The type of migration task you want to run  |
| objectType  | Any of "Extradata", "Items", "Holdings", "Instances", "SRS", "Users" | Type of object to post  |
| batchSize  | integer  | The number of records per batch to post. If the API does not allow batch posting, this number will be ignored  |
| file.filename  | Any string  | Name of file to post, located in the results folder  |

### Syntax to run
``` 
 pipenv run python main.py PATH_TO_migration_repo_template/mapping_files/exampleConfiguration.json post_bibs --base_folder PATH_TO_migration_repo_template/

  pipenv run python main.py PATH_TO_migration_repo_template/mapping_files/exampleConfiguration.json post_srs_bibs --base_folder PATH_TO_migration_repo_template/

```

## Transform MFHD records to holdings and SRS holdings 
### Configuration
This configuration piece in the configuration file determines the behaviour
```
{
    "name": "transform_mfhd",
    "migrationTaskType": "HoldingsMarcTransformer",
    "legacyIdMarcPath": "001",
    "mfhdMappingFileName": "mfhd_rules.json",
    "locationMapFileName": "locations.tsv",
    "defaultCallNumberTypeName": "Library of Congress classification",
    "fallbackHoldingsTypeId": "03c9c400-b9e3-4a07-ac0e-05ab470233ed",
    "useTenantMappingRules": false,
    "hridHandling": "default",
    "createSourceRecords": true,
    "files": [
        {
            "file_name": "holding.mrc",
            "suppressed": false
        }
    ]
}
```
### Explanation of parameters
| Parameter  | Possible values  | Explanation  | 
| ------------- | ------------- | ------------- |
| Name  | Any string  | The name of this task. Created files will have this as part of their names.  |
| migrationTaskType  | Any of the [avialable migration tasks]()  | The type of migration task you want to run  |
| legacyIdMarcPath  | A marc field followed by an optional subfield delimited by a $ | used to locate the legacy identifier for this record. Examles : "001", "951$c"  |
| mfhdMappingFileName  | Any string  | location of the MFHD rules in the mapping_files folder  |
| locationMapFileName  | Any string   | Location of the Location mapping file in the mapping_files folder  |
| defaultCallNumberTypeName  | Any call number name from FOLIO   | Used for fallback mapping for callnumbers  |
| fallbackHoldingsTypeId  | A uuid  | Fallback holdings type if mapping does not work  |
| useTenantMappingRules  | false | boolean (true/false) NOT YET IMPLEMENTED.  |
| hridHandling  | "default" or "preserve001"  | If default, HRIDs will be generated according to the FOLIO settings. If preserve001, the 001s will be used as hrids if possible or fallback to default settings  |
| createSourceRecords  | boolean (true/false)  |   |
| files  | Objects with filename and boolean  | Filename of the MARC21 file in the data/instances folder- Suppressed tells script to mark records as suppressedFromDiscovery  |

### Syntax to run
``` 
pipenv run python main.py PATH_TO_migration_repo_template/mapping_files/exampleConfiguration.json transform_mfhd --base_folder PATH_TO_migration_repo_template/
```

## Post tranformed MFHDs and Holdingsrecords to FOLIO 
### Configuration
These configuration pieces in the configuration file determines the behaviour
```
{
    "name": "post_holdingsrecords_from_mfhd",
    "migrationTaskType": "BatchPoster",
    "objectType": "Holdings",
    "batchSize": 250,
    "file": {
        "file_name": "folio_holdings_test_run_transform_mfhd.json"
    }
},
{
    "name": "post_srs_mfhds",
    "migrationTaskType": "BatchPoster",
    "objectType": "SRS",
    "batchSize": 250,
    "file": {
        "file_name": "folio_srs_holdings_test_run_transform_mfhd.json"
    }
}
```

### Explanation of parameters
| Parameter  | Possible values  | Explanation  | 
| ------------- | ------------- | ------------- |
| Name  | Any string  | The name of this task. Created files will have this as part of their names.  |
| migrationTaskType  | Any of the [avialable migration tasks]()  | The type of migration task you want to run  |
| objectType  | Any of "Extradata", "Items", "Holdings", "Instances", "SRS", "Users" | Type of object to post  |
| batchSize  | integer  | The number of records per batch to post. If the API does not allow batch posting, this number will be ignored  |
| file.filename  | Any string  | Name of file to post, located in the results folder  |

### Syntax to run
``` 
pipenv run python main.py PATH_TO_migration_repo_template/mapping_files/exampleConfiguration.json post_holdingsrecords_from_mfhd --base_folder PATH_TO_migration_repo_template/

pipenv run python main.py PATH_TO_migration_repo_template/mapping_files/exampleConfiguration.json post_srs_mfhds --base_folder PATH_TO_migration_repo_template/
```


## Transform CSV/TSV files into Holdingsrecords
### Configuration
These configuration pieces in the configuration file determines the behaviour
```
{
    "name": "transform_csv_holdings",
    "migrationTaskType": "HoldingsCsvTransformer",
    "holdingsMapFileName": "holdingsrecord_mapping.json",
    "locationMapFileName": "locations.tsv",
    "defaultCallNumberTypeName": "Library of Congress classification",
    "callNumberTypeMapFileName": "call_number_type_mapping.tsv",
    "previouslyGeneratedHoldingsFiles": [
        "folio_holdings_test_run_transform_mfhd"
    ],
    "holdingsMergeCriteria": [
        "instanceId",
        "permanentLocationId",
        "callNumber"
    ],
    "fallbackHoldingsTypeId": "03c9c400-b9e3-4a07-ac0e-05ab470233ed",
    "files": [
        {
            "file_name": "csv_items.tsv"
        }
    ]
}
```
### Explanation of parameters
| Parameter  | Possible values  | Explanation  | 
| ------------- | ------------- | ------------- |
| Name  | Any string  | The name of this task. Created files will have this as part of their names.  |
| migrationTaskType  | Any of the [avialable migration tasks]()  | The type of migration task you want to run  |
| holdingsMapFileName  | Any string  | location of the mapping file in the mapping_files folder  |
| locationMapFileName  | Any string   | Location of the Location mapping file in the mapping_files folder  |
| defaultCallNumberTypeName | any string | Name of callnumber in FOLIO used as a  fallback | 
| callNumberTypeMapFileName  | Any string  | location of the mapping file in the mapping_files folder  |
| previouslyGeneratedHoldingsFiles  |   |  |
| holdingsMergeCriteria  | A list of strings with the names of [holdingsrecord](https://github.com/folio-org/mod-inventory-storage/blob/master/ramls/holdingsrecord.json) properties (on the same level) | Used to group indivitual rows into Holdings records. Proposed setting is ["instanceId", "permanentLocationId", "callNumber"] |
|  fallbackHoldingsTypeId | uuid string  | The fallback/default holdingstype UUID |
| createSourceRecords  | boolean (true/false)  |   |
| files  | Objects with filename and boolean  | Filename of the MARC21 file in the data/instances folder- Suppressed tells script to mark records as suppressedFromDiscovery  |

### Syntax to run
``` 
pipenv run python main.py PATH_TO_migration_repo_template/mapping_files/exampleConfiguration.json transform_mfhd --base_folder PATH_TO_migration_repo_template/
```
## Post trasformed Holdingsrecords to FOLIO
See documentation for posting above

## Transform CSV/TSV files into Items
### Configuration
These configuration pieces in the configuration file determines the behaviour
```
{
    "name": "transform_csv_items",
    "migrationTaskType": "ItemsTransformer",    
    "itemsMappingFileName": "item_mapping_for_csv_items.json",
    "locationMapFileName": "locations.tsv",
    "callNumberTypeMapFileName": "call_number_type_mapping.tsv",
    "materialTypesMapFileName": "material_types_csv.tsv",
    "loanTypesMapFileName": "loan_types_csv.tsv",
    "itemStatusesMapFileName": "item_statuses.tsv",
    "files": [
        {
            "file_name": "csv_items.tsv"
        }
    ]
}
```
### Explanation of parameters
| Parameter  | Possible values  | Explanation  | 
| ------------- | ------------- | ------------- |
| Name  | Any string  | The name of this task. Created files will have this as part of their names.  |
| migrationTaskType  | Any of the [avialable migration tasks]()  | The type of migration task you want to run  |
| itemsMappingFileName  | Any string  | location of the mapping file in the mapping_files folder  |
| locationMapFileName  | Any string   | Location of the Location mapping file in the mapping_files folder  |
| callNumberTypeMapFileName  | Any string   | location of the mapping file in the mapping_files folder  |
| materialTypesMapFileName  | Any string   | location of the mapping file in the mapping_files folder  |
| loanTypesMapFileName  | Any string   | location of the mapping file in the mapping_files folder  |
| itemStatusesMapFileName  | Any string   | location of the mapping file in the mapping_files folder  |
| files  | Objects with filename and boolean  | Filename of the MARC21 file in the data/instances folder- Suppressed tells script to mark records as suppressedFromDiscovery  |

### Syntax to run
``` 
pipenv run python main.py PATH_TO_migration_repo_template/mapping_files/exampleConfiguration.json transform_csv_items --base_folder PATH_TO_migration_repo_template/
```

## Post transformed Items to FOLIO
See documentation for posting above

## Transform CSV/TSV files into FOLIO users
### Configuration
These configuration pieces in the configuration file determines the behaviour
```
{
    "name": "user_transform",
    "migrationTaskType": "UserTransformer",
    "groupMapPath": "user_groups.tsv",
    "userMappingFileName": "user_mapping.json",
    "useGroupMap": true,
    "userFile": {
        "file_name": "staff.tsv"
    }
}
```
### Explanation of parameters
| Parameter  | Possible values  | Explanation  | 
| ------------- | ------------- | ------------- |
| Name  | Any string  | The name of this task. Created files will have this as part of their names.  |
| migrationTaskType  | Any of the [avialable migration tasks]()  | The type of migration task you want to run  |
| userMappingFileName  | Any string  | location of the mapping file in the mapping_files folder  |
| groupMapPath  | Any string   | Location of the user group mapping file in the mapping_files folder  |
| useGroupMap  | boolean   | Use the above group map file or use code-to-code direct mapping  |
| userFile.file_name  | Any string  | name of csv/tsv file of legacy users in the data/users folder |


### Syntax to run
``` 
pipenv run python main.py PATH_TO_migration_repo_template/mapping_files/exampleConfiguration.json user_transform --base_folder PATH_TO_migration_repo_template/
```

## Post transformed users to FOLIO
See documentation for posting above
