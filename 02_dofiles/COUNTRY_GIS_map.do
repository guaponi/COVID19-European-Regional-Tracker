clear
global coviddir "D:/Programs/Dropbox/Dropbox/PROJECT COVID Europe"


cd "$coviddir/03_GIS"



use nuts3_mix, clear

		
*** merge with the datafile
	merge 1:m nuts_id using "$coviddir/04_master/EUROPE_COVID19_master.dta"

	egen tag = tag(nuts_id)

		list nuts_id  if tag==1 & _m==1
		list nuts_id  if tag==1 & _m==2

		drop _m



*** drop dates for which countries are missing data points

drop tag



*** drop all the days when no cases exist
bysort nuts0_id date: egen total = sum(cases_daily)
drop if total == 0
drop total

*** this is just for maps to label them as "No Cases"
recode cases_daily 		(0=.)  
recode cases_daily_pop 	(0=.)  






*** generate a variable for the last observation for each country
gen last = .
levelsof nuts0_id, local(lvls)
foreach x of local lvls {
display "`x'"
	qui summ date if nuts0_id=="`x'"
	qui replace last  = 1 if date==`r(max)' &   nuts0_id=="`x'"
}



**** graphs below

local date: display %tdd_m_yy date(c(current_date), "DMY")
display "`date'"

local date2 = subinstr(trim("`date'"), " ", "_", .)
display "`date2'"



format cases_daily		%9.0f
format cases_daily_pop 	%9.2f	


summ date
	local ldate = `r(max)'
	local ldate : di %tdd_m_yy `ldate'



***** graph of last reported daily cases

colorpalette viridis, n(10) reverse nograph
local colors `r(p)'

spmap cases_daily using "nuts3_mix_shp.dta" if last==1, ///
id(_ID) cln(10)  fcolor("`colors'")  /// 
	ocolor(gs6 ..) osize(vvthin ..) ///
	ndfcolor(gs14) ndocolor(gs4 ..) ndsize(*0.1 ..) ndlabel("No cases on the last reported date") ///
		legend(pos(10) size(*1) symx(*0.8) symy(*0.8) forcesize) legstyle(2)   ///		
		polygon(data("nuts0_shp") ocolor(black) osize(vthin) legenda(on) legl("Regions")) ///
		title("{fontface Arial Bold: COVID-19 daily regional cases in Europe (`ldate')}", size(*0.7)) ///
		note("Map layer: Eurostat GISCO 2016 NUTS layers. Data source: Misc. Data is at NUTS-3 level except for Poland and Greece.", size(tiny))
		
		graph export "../05_figures/COVID19_EUROPE_cases.png", replace wid(2000)


		
		
		
***** graph of last reported daily cases per 10k population


colorpalette viridis, n(10) reverse nograph
local colors `r(p)'

spmap cases_daily_pop using "nuts3_mix_shp.dta" if last==1, ///
id(_ID) cln(10)  fcolor("`colors'")  /// //  clm(custom) clbreaks(0(5)45) 
	ocolor(gs6 ..) osize(vvthin ..) ///
	ndfcolor(gs14) ndocolor(gs4 ..) ndsize(*0.1 ..) ndlabel("No cases on the last reported date") ///
		legend(pos(10) size(*1) symx(*0.8) symy(*0.8) forcesize) legstyle(2)   ///		
		polygon(data("nuts0_shp") ocolor(black) osize(vthin) legenda(on) legl("Regions")) ///
		title("{fontface Arial Bold: COVID-19 new cases per 10,000 pop (`ldate')}", size(*0.7)) ///
		note("Map layer: Eurostat GISCO 2016 NUTS layers. Data: Misc sources. Data is at NUTS-3 level except for Poland and Greece.", size(tiny))
			
		graph export "../05_figures/COVID19_EUROPE_casespop.png", replace wid(2000)
		
		
	
***** country specific graphs below



levelsof nuts0_id, local(cntry)

foreach x of local cntry {

display "`x'"

	preserve
	
		keep if nuts0_id=="`x'"
		sort _ID

		summ date
			local ldate1 = `r(max)'
			local ldate2 : di %tdd_m_yy `ldate1'

		colorpalette viridis, n(7) reverse nograph
		local colors `r(p)'

			spmap cases_daily_pop using "nuts3_shp_`x'.dta" if date==`ldate1', ///
			id(_ID) cln(6)  fcolor("`colors'")  /// //  clm(custom) clbreaks(0(5)45) 
				ocolor(gs6 ..) osize(vthin ..) ///
				ndfcolor(gs14) ndocolor(gs4 ..) ndsize(*0.1 ..) ndlabel("No cases") ///
					legend(pos(10) size(*1) symx(*0.8) symy(*0.8) forcesize) legstyle(2)   ///		
					polygon(data("nuts1_shp_`x'") ocolor(black) osize(vthin) legenda(on) legl("Regions")) ///
					label(data("nuts_label_`x'") x(_CX) y(_CY) label(nuts_name) size(*0.5 ..) length(30)) ///
					title("{fontface Arial Bold: COVID-19 new cases per 10,000 pop - `x' (`ldate2')}", size(*0.7)) ///
					note("Map layer: Eurostat GISCO 2016 NUTS layers.", size(tiny))

			graph export "../05_figures/covid19_`x'.png", replace wid(2000)

	restore	
	
	}


/***** test stuff below



		keep if nuts0_id=="EL"
		sort _ID

		summ date
			local ldate1 = `r(max)'
			local ldate2 : di %tdd_m_yy `ldate1'

		colorpalette viridis, n(7) reverse nograph
		local colors `r(p)'
		
		
		summ date
		
			spmap cases_daily_pop using "nuts3_shp_EL.dta" if date==`r(max)', ///
			id(_ID) cln(6)  fcolor("`colors'")  /// //  clm(custom) clbreaks(0(5)45) 
				ocolor(gs6 ..) osize(vthin ..) ///
				ndfcolor(gs14) ndocolor(gs4 ..) ndsize(*0.1 ..) ndlabel("No cases") ///
					legend(pos(10) size(*1) symx(*0.8) symy(*0.8) forcesize) legstyle(2)   ///
					polygon(data("nuts1_shp_EL") ocolor(black) osize(vthin) legenda(on) legl("Regions")) 		///
					label(data("nuts_label_EL") x(_CX) y(_CY) label(nuts_name) size(*0.5 ..) length(30)) 
					
					
					///
					title("{fontface Arial Bold: COVID-19 new cases per 10,000 pop - `x' (`ldate2')}", size(*0.7)) ///
					note("Map layer: Eurostat GISCO 2016 NUTS layers.", size(tiny))
	