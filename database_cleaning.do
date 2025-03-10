#### Hackaton work

## cleaning database


### COUPLE RECORDS

### filtering the dataset
use IACR7EFL.DTA, clear

keep caseid v007 v012 v013 sb57 sb21 v444 v106 v025 v024 v190a sm327

## smokes cigarretes is mv463a
## m14 does not exist
## s414 does not exist
## s422 does not exist
## b0 does not exist
## b4 does not exist

## saving the new data for couples record

save "filtered_couple_record.dta", replace

### BIRTHS RECORDS

use IABR7EFL.DTA, clear

### filtering the dataset

keep caseid v007 v012 v013 sb57 sb21 v444 v463a m14 s414 s422 b0 v106 b4 v025 v024 v190a v131 m19 m19a s434 s435 s437

## saving the new data for births record

save "filtered_births_record.dta", replace

## checking duplicates

use "filtered_births_record.dta", clear
duplicates report caseid
duplicates drop caseid, force
save "filtered_births_record.dta", replace

## merging 

use "filtered_couple_record.dta", clear
merge 1:1 caseid using "filtered_births_record.dta", keepusing(m19 m19a v463a m14 s414 s422 b0 v131 s434 s435)
keep if _merge == 3
drop _merge
drop if b0 == 3


## dropping missing values 

drop if m19 == 9996 | m19 == 9998 | m19 == .
drop if missing(s422)

save "final_dataset.dta", replace
