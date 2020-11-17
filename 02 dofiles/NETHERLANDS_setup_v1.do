clear
*global coviddir "D:/Programs/Dropbox/Dropbox/PROJECT COVID Europe"


cd "$coviddir/01 raw/Netherlands"



**** set up the identfiers
import excel using nuts3.xlsx, first clear
ren NUTS3CODE nuts3_id
ren LAUCODE lau
drop if lau==""

compress
save lau_netherlands.dta, replace

*https://nlcovid-19-esrinl-content.hub.arcgis.com/pages/kaarten
*https://nlcovid-19-esrinl-content.hub.arcgis.com/datasets/covid-19-historische-gegevens-rivm-vlakken

**** get the data
insheet using "https://opendata.arcgis.com/datasets/1365a2d9cb344b67999dd825c99cb1a5_0.csv", clear
save netherlands_raw.dta, replace
export delimited using netherlands_raw.csv, replace delim(;)





drop objectid
drop shape__area shape__length
compress
ren gemeentecode lau

ren meldingen cases
ren ziekenhuisopnamen hospitalized
ren overleden deaths
ren bevolkingsaantal population

merge m:1 lau using lau_netherlands
drop _m


gen year  = substr(datum, 1, 4)
gen month = substr(datum, 6, 2)
gen day   = substr(datum, 9, 2)

destring year month day, replace
drop datum
gen date = mdy(month,day, year)
drop year month day
format date %tdDD-Mon-yyyy


sort lau date

keep lau date nuts3_id cases hospitalized deaths population
order lau date nuts3_id cases hospitalized deaths population


collapse (sum) cases hospitalized deaths population, by(date nuts3_id) cw

sort nuts3_id date
bysort nuts3_id: gen cases_daily = cases - cases[_n-1]
sort nuts3_id date
bysort nuts3_id: gen deaths_daily = deaths - deaths[_n-1]


order date nuts3_id
compress
save "$coviddir/04 master/netherlands_data.dta", replace
export delimited using "$coviddir/04 master/csv/netherlands_data.csv", replace delim(;)



cd "$coviddir"