*Author: Savannah Daines
*Purpose: DMAV course project 1


*************************** SECTION 1 **********************************

*See word document assignment report for introduction text



*************************** SECTION 2 **********************************


******** Labeling 

* Label Dataset
label data "ANSUR II exploratory data analysis dataset"

* Label Variables and Variable Levels according to MRF pdf: 

** Label categorical labels
label variable subjectnumericrace "Self-reported Race(s)
label define subjectnumericrace_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Native American" 6 "Pacific Islander" 8 "Other"
label values subjectnumericrace subjectnumericrace_lbl

label variable dodrace "Department of Defense Self-reported Single Race"
label variable subjectnumericrace "Self-reported Race(s)"
label define dodrace_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Native American" 6 "Pacific Islander" 8 "Other"
label values dodrace dodrace_lbl

** Label numerical labels 
label variable ethnicity "Self-reported ethnicity"
label variable gender "Binary Gender Category"
label variable age "Age (years)"
label variable component "Component of the Army"
label variable branch "Branch of the Army"
label variable writingpreference "Preferred Writing Hand"
label variable installation "U.S. Army Installation Location of Measurement"
label variable test_date "Date of Measurement Tests"
label variable weightlbs "Self Reported Weight (lbs)"
label variable heightin "Self-reported Height (in)"
label variable weightlbs "Self-reported Weight (lbs)"
label variable thumbtipreach "Thumbtip Reach (mm)"
label variable span "Span (mm)"
label variable footlength "Foot Length (mm)"
label variable kneeheightmidpatella "Knee Height, Midpatella (mm)"
label variable waistheightomphalion "Waist Height (Omphalion) (mm)"
label variable functionalleglength "Functional Leg Length (mm)"
label variable cervicaleheight "Cervical Height (mm)"
label variable trochanterionheight "Trochanterion Height (mm)"
label variable stature "Stature (mm)"
label variable waistcircumference "Waist Circumference (Omphalion) (mm)"
label variable chestcircumference "Chest Circumference (mm)"
label variable bicristalbreadth "Bicristal Breadth (mm)"
label variable hipbreadth "Hip Breadth (mm)"
label variable hipbreadthsitting "Hip Breadth Sitting (mm)"
label variable weightkg "Weight (kg)"
label variable date "Date of Measurement"
label variable strdate "Date of Measurement"

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v1.dta"




******** Initial exploration 

codebook // explore variables 

tab1 subjectnumericrace dodrace ethnicity gender branch writingpreference installation /// one way tabs of categorical variables 


sum age weightlbs heightin thumbtipreach span footlength kneeheightmidpatella waistheightomphalion functionalleglength cervicaleheight trochanterionheight stature waistcircumference chestcircumference bicristalbreadth hipbreadth hipbreadthsitting weightkg, detail /// look at percentiles & distribution of continous variables

/*Notes on findings from initial exploration: 
- 
- Some extrme outliers in weightkg
- self reported weight has some 0's
- Age range includes 17
- subjectnumericrace has coding errors - numbers outside of 1-8 that are not one of the 3 negatives
- Ethnicity has a lot of missing
- Writing preference has some inconsistencies in the string entries
- Date has a lot of missing
- Some extreme outliers in thumbtipreach*/




******** Unique key creation 

gen id = _n // assign unique sequential number to each observation

label variable id "Unique Observation ID"   // add label 

isid id // check uniquness and all are unique 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v2.dta" // save




******** Recdoing missing values 

mvdecode _all, mv(-77=.a \ -88=.b \ -99=.c) // change the negative values to special missing for all numeric variables; used AI (ChatGPT) to assist with this code identification 

/* Key - per the assignment instructions
.a = -77 = not recorded
.b = - 88 = refused measurement
.c = -99 = unknown missing */

summarize, detail // check the smallest number to see if these negatives got coded right; everything looks good

* Add labels to the special missing values, reasons for missing are defined by the assignment instructions and with details listed above in the key

label define misslbl ///
.a "Not Recorded" ///
.b "Refused Measurement" ///
.c "Unknown Missing" 

foreach var of varlist _all {
    capture confirm numeric variable `var'
    if !_rc {
        label values `var' misslbl
    }
} // attach the labels

tab stature, missing // check to make sure labels were added; used AI (ChatGPT) to assist with this code identification

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v3.dta" 



******** Change units of measure

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v4_mm_measures.dta" 

* MM measures to cm 
** Conversion loop 
foreach var in thumbtipreach span footlength kneeheightmidpatella waistheightomphalion functionalleglength cervicaleheight trochanterionheight stature waistcircumference chestcircumference bicristalbreadth hipbreadth hipbreadthsitting {
    replace `var' = `var' / 10 if `var' < .
} // changes all the variables from mm to cm 

tab stature, missing // check to special missing values; used AI (ChatGPT) to assist with this code identification

** Fix all the labels to account for change to cm 
label variable thumbtipreach "Thumbtip Reach (cm)"
label variable span "Span (cm)"
label variable footlength "Foot Length (cm)"
label variable kneeheightmidpatella "Knee Height, Midpatella (cm)"
label variable waistheightomphalion "Waist Height (Omphalion) (cm)"
label variable functionalleglength "Functional Leg Length (cm)"
label variable cervicaleheight "Cervical Height (cm)"
label variable trochanterionheight "Trochanterion Height (cm)"
label variable stature "Stature (cm)"
label variable waistcircumference "Waist Circumference (Omphalion) (cm)"
label variable chestcircumference "Chest Circumference (cm)"
label variable bicristalbreadth "Bicristal Breadth (cm)"
label variable hipbreadth "Hip Breadth (cm)"
label variable hipbreadthsitting "Hip Breadth Sitting (cm)"
label variable weightkg "Measured Weight (kg)"

* Inches to cm 
replace heightin = heightin * 2.54 if heightin < . // change from in to cm // used 2.54 cm is 1 inch conversion 
rename heightin heightcm // rename 
label variable heightcm "Self-reported Height (cm)" // relabel 

tab heightcm, missing  // check missing

sum // check to make sure conversion worked 

* Lbs to kg 
replace weightlbs = weightlbs / 2.205 if weightlbs < . // change from lbs to kg // used 2.205 kg is 1 lb conversion factor 
rename weightlbs weightkg_selfreport // rename 
label variable weightkg_selfreport "Self-reported Weight (kg)" // relabel 

sum // check to make sure conversion worked 


save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v5.dta"




******** Inspecting all variables for suspect/unreasonable values and addressing them with either special missing values or flag

* Special Missing Values (SMV) Key

/* 
.a = -77 = not recorded
.b = - 88 = refused measurement
.c = -99 = unknown missing
.d = value is a zero, which is biologically impossible 
.e = suspiciously small (but not a zero) - see cutpoints for specific variables 
.f = suspiciously large - see cutpoints for specific variables */

* Additions to SMV 

label define misslbl ///
.d "Value Recorded as 0" ///
.e "Suspiciously Small Non-Zero" ///
.f "Suspiciously large", add // add labels to the new special missing values


save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v6.dta"


* Variable inspection 

***** AGE ***** 

sum age, detail // looks good but wil need to drop the underage subjects later
tab age  // looks good but wil need to drop the underage subjects later


***** SELF-REPORTED WEIGHT (KG) ***** 

sum weightkg_selfreport, detail // inspect distribution
recode weightkg_selfreport (0=.d) // address zeros 
tab weightkg_selfreport, missing // check 
graph box weightkg_selfreport
sum weightkg_selfreport, detail

* All remaining values are biologically plausible, though there are some suspicious values that will be flagged. Army enlistment standards are used as contextual cutoffs for flagging per Army website numbers.  (https://www.goarmy.com/how-to-join/requirements). Additionally, soldiers are assessed every 6 months with a weight screening per this document (https://www.army.mil/e2/downloads/rv7/r2/policydocs/r600_9.pdf). Because none of the weights are biologically impossible and there could be some underlying medical issue driving a signficant weight change and are also self reported, this supports an argument for flags rather than recoding to missing.  
* Per Army website:
* Maximum weight for tallest/oldest males = 250 lbs (113.398 kg)
* Maximum weight for tallest/oldest females = 236 lbs (107.048 kg)
* Minimum weight = 91 lbs (41.2769 kg) for both genders.

* Flag creation 
gen flag_weightkg_selfreport = 0 // create flag variable and start everything at 0

replace flag_weightkg_selfreport = 1 if weightkg_selfreport < . & ///
((gender == "Male" & (weightkg_selfreport > 113.398 | weightkg_selfreport < 41.2769)) | ///
(gender == "Female" & (weightkg_selfreport > 107.048 | weightkg_selfreport < 41.2769)))
replace flag_weightkg_selfreport = . if missing(weightkg_selfreport) // I decided that if smv are retained in the original, then just have a generic missing is okay for the flag

tab flag_weightkg_selfreport, missing // check flag distribution

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v7.dta", replace


*****  SELF-REPORTED HEIGHT (CM) ***** 

sum heightcm, detail  // inspect distribution

* Per Army enlistment standards (https://www.goarmy.com/how-to-join/requirements):
* Minimum height for both  male/female = 58 inches (147.32 cm)
* Maximum height for both male/female = 80 inches (203.2 cm)

/*Based on the count ouputs comparing self reported vs. measured height as well as the distribution of the data, it could be possible that someone made a typo in recording the self reported height, they were considering height with shoes on or off, lack basic common sense about what is a realistic height, or maybe have some kind of injury like a concussion that is impairing their reasoning ability. Since this is a self reported measure, no values will changed to missing. Instead, a flag variable using the website's height ranges will be created to make note of these values. */

count if heightcm > 203.2 & heightcm < . // equals 7 
count if (heightcm > 203.2 & heightcm < .) & (stature > 203.2 & stature < .) // equals 0 

* Flag creation 
gen flag_heightcm = 0 // create flag variable and start everything at 0
replace flag_heightcm = 1 if (heightcm < . ) & (heightcm > 203.2 | heightcm < 147.32)
replace flag_heightcm = . if missing(heightcm)

tab flag_heightcm, missing // check flag distribution

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v8.dta"


*****  THUMBTIP REACH (CM) ***** 

sum thumbtipreach, detail // check out distrubition 
graph box thumbtipreach // 

* There are some biologically implausible values that should be changed to missing.

replace thumbtipreach = .f if (thumbtipreach > 150  & thumbtipreach < .) // replace with missing value with the cut off for being biologically too large and also considered the distrubution with extreme outliers

tab thumbtipreach, missing // check work 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v9.dta"


***** SPAN (CM) ***** 

sum span, detail // look at distribution 
graph box span

sum stature, detail // look at distribution of stature and compare it to span since the two measures are typically very close to each other.

* Everything seems biologiclaly plasuable. No flags/special missing values needed 


*****  Footlength (CM) ***** 

sum footlength, detail // look at distribution 

summarize footlength if gender == "Male", detail // look at distribution by gender
graph box footlength if gender == "Male"
summarize footlength if gender == "Female", detail // look at distribution by gender
graph box footlength if gender == "Female"

* There are some smaller and larger foot lengths (for females the range length equates to about size 3/4 womens shoe to size 12/13 and for males size 3/4 to size 15/16 on various brand sizing charts). There could be some kind of data entry error but they are not biologically impossible. Therefore, values outside of common retail size ranges will be flagged but not recoded to missing. 

* Hoka shoe sizing was used for determining common retail sizes and foot length (https://www.hoka.com/en/us/sizing-information.html). For men, this was below a size 5 (23 cm foot length) or greater than size 15 (31.5 cm foot length). For wommen, this was below a size 5 (22 cm foot length) or greater than size 12 (27.9 cm foot length). The size 5 and 12/15 cut off was made because that is the size range of Hoka shoes and also fit well with the distrubution. 

* Flag creation 
gen flag_footlength = 0 // create flag variale 

replace flag_footlength = 1 if footlength < . & ///
((gender == "Male" & (footlength > 31.5 | footlength < 23)) | ///
(gender == "Female" & (footlength > 27.9 | footlength < 22)))
replace flag_footlength = . if missing(footlength)

tab flag_footlength, missing // check flag distribution

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v10.dta" 


***** STATURE (CM) ***** 

sum stature, detail

*Per the Army website (https://www.goarmy.com/how-to-join/requirements) 58 inches (147.32 cm) and 80 inches (203.2 cm) are the max and min heights for both males and females. There are no values above the max. There are 15 values below the min. It could be possible that these subjects had some kind of injury that decreased their stature, so these will be flagged with a flag variable. 

count if stature < 147.32 
count if (stature > 203.2 & stature < .) 

* Flag creation 
gen flag_stature = 0 // create flag 
replace flag_stature = 1 if stature < 147.32
replace flag_stature = . if missing(stature)

tab flag_stature, missing // flag numbers check out 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v11.dta"


*****  kneeheightmidpatella (CM) ***** 

sum kneeheightmidpatella, detail  // look at distribution 
graph box kneeheightmidpatella

twoway scatter kneeheightmidpatella stature // look at relative to stature 

* compared min and max as a proportion to the min and max of stature and it seems biologically reasonable

* no concerns for suspicious values here 


*****  waistheightomphalion (CM)***** 

sum waistheightomphalion, detail // look at distribution 
graph box waistheightomphalion
twoway scatter waistheightomphalion stature // look at relative to stature 

* Compared min and max as a proportion to the min and max of stature and it seems biologically reasonable

* no concerns for suspicious values here 


*****  functionalleglength (CM) ***** 

sum functionalleglength, detail // look at distribution 
graph box functionalleglength
twoway scatter functionalleglength stature // look at relative to stature

* Also compared min and max as a proportion to the min and max of stature and it seems biologically reasonable

* no concerns for suspicious values here 


****** cervicaleheight (CM) ********

sum cervicaleheight, detail // look at distribution 
graph box cervicaleheight
twoway scatter functionalleglength stature // look at relative to stature 

* Also compared min and max as a proportion to the min and max of stature and it seems biologically reasonable

* no concerns for suspicious values here 


*****  trochanterionheight (CM) ***** 

sum trochanterionheight, detail // look at distribution 
graph box trochanterionheight
twoway scatter functionalleglength stature // look at relative to stature 

* compared min and max as a proportion to the min and max of stature and it seems biologically reasonable

* no concerns for suspicious values here 


*****  waistcircumference (CM) ***** 

summ waistcircumference, detail // check distrubition 

summ waistcircumference if gender == "Male", detail // check distrubition by gender
summ waistcircumference if gender == "Female", detail 

twoway scatter waistcircumference  weightkg_selfreport // look to see if there is anything substantially deviated from a connection to waist to also explore suspicous values 

graph box waistcircumference if gender == "Male"
graph box waistcircumference if gender == "Female"

* All values are biologically plausible, but there a some larger values that would likely not meet body composition standards but they could still be possibile for circumstances such as being temporarily noncompliant or medicallly exempt. Therefore, flag variables will be created based on cutpoints for the 1st and 99th percentile for both genders. 

* Flag creation 

gen flag_waistcircumference = 0 // create flag variable and start everything at 0

replace flag_waistcircumference = 1 if waistcircumference < . & ///
((gender == "Male" & (waistcircumference > 121.4 | waistcircumference < 72.5)) | ///
(gender == "Female" & (waistcircumference > 111.3 | waistcircumference < 66.5)))
replace flag_waistcircumference = . if missing(waistcircumference) 

tab flag_waistcircumference, missing // check flag distribution

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v13.dta"


*****  chestcircumference (CM) ***** 

summ chestcircumference if gender == "Male", detail  // check distrubition 
summ chestcircumference if gender == "Female", detail  // check distrubition 

* All values are biologically plausible. There are some that could suggest a very slim individual or possibly masectomy or extreme amounts of muscle + leanness (to still meet body composition requirements), though it could still be possible. Therefore, no flags will be created. 


*****  bicristalbreadth (CM) ***** 

summ bicristalbreadth if gender == "Male", detail  // check distrubition 
summ bicristalbreadth if gender == "Female", detail  // check distrubition 

* All values are biologically plausible. There are some extremes, but still realistic possibibilities. Therefore, no flags will be created. 


*****  hipbreadth (CM) ***** 

summ hipbreadth if gender == "Male", detail  // check distrubition 
summ hipbreadth if gender == "Female", detail  // check distrubition 

* All values are biologically plausible. There are some extremes, but still realistic possibibilities. Therefore, no flags will be created. 


****** hipbreadthsitting (CM) ********

summ hipbreadthsitting if gender == "Male", detail  // check distrubition 
summ hipbreadthsitting if gender == "Female", detail  // check distrubition 

* All values are biologically plausible. There are some extremes, but still realistic possibibilities. Therefore, no flags will be created. 


*****  weightkg (CM) ***** 

summ weightkg if gender == "Male", detail  // check distrubition 
summ weightkg if gender == "Female", detail  // check distrubition 

* Explore some high values 
count if weightkg > 400 & weightkg < . // count is 39 
count if weightkg > 200 & weightkg < . // count is 39 
count if weightkg > 150 & weightkg < . // count is 39 

** The count if 39 for all three of the kg checks above. It is biologically implausible that someone weights more tahn 400 kg. Therefore, these values will be set as special missing values. 

* Set to missing 
replace weightkg = .f if (weightkg > 400  & weightkg < .) // replace with missing value with the cut off for being biologically too large 

tab weightkg, missing // check work

summ weightkg if gender == "Male", detail  // check distrubition 
summ weightkg if gender == "Female", detail  // check distrubition

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v14.dta"


*****  subjectnumericrace ***** 

tab subjectnumericrace // the pdf manual reports there should only be races 1-8. There are numerous races listed as greater than. These will recoded to smv. 

***Special Missing Values Key ***

/* 
.a = -77 = not recorded
.b = - 88 = refused measurement
.c = -99 = unknown missing
.d = value is a zero, which is biologically impossible 
.e = suspiciously small (but not a zero) - see cutpoints for specific variables 
.f = suspiciously large - see cutpoints for specific variables 
.g = invalid value number per pdf manual */

* Additions to the key and labeling 

label define misslbl ///
.g "Invalid Value per pdf Manual" , add /// add labels to the new special missing values

replace subjectnumericrace = .g if subjectnumericrace > 8 & subjectnumericrace < . // create the smv 
tab subjectnumericrace, missing // check 

label define subjectnumericrace_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Native American" 6 "Pacific Islander" 8 "Other" /// add labels

label values subjectnumericrace subjectnumericrace_lbl /// add labels

tab subjectnumericrace, missing // checked 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v16.dta"


****** dodrace ******

tab dodrace, missing /// check for missing/weird things

label define dodrace_lbl 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Native American" 6 "Pacific Islander" 8 "Other" /// add labels

label values dodrace dodrace_lbl /// add labels

tab dodrace, missing /// check for missing/weird things

replace dodrace = .g if dodrace == 7 // 7 is not a valid option per pdf 

tab dodrace, missing // checked

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v17.dta"


****** ethnicity ******

tab ethnicity, missing /// check for missing/weird things

* Address potential spaces or capitlization issues
replace ethnicity = trim(ethnicity) // remove trailing/leading spaces if there; used CHATGPT to identify code
replace ethnicity = lower(ethnicity) // put all in lowercase; used CHATGPT to identify code

tab ethnicity, missing // check for weird stuff like unknown, n/a, numbers, nonsensical responses, blanks, etc

count if ethnicity == "" // count blanks // numerous found

* Create a flag for blanks
gen flag_ethnicity_missing = 0 // create flag for missing ethncity since no smv for string 
replace flag_ethnicity_missing = 1 if ethnicity == ""

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v18.dta"


****** gender ******

tab gender, missing // looks good 


****** component ******

tab component, missing // looks good 


****** branch ******

tab branch, missing // looks good 


****** writingpreference ******

tab writingpreference, missing

* per the pdf options include Writing Preference; "Right hand", "Left hand", or "Either hand (No preference)" . Therefore, the 25 "Either han" will be replaced with "Either hand (No preference)" per below: 

replace writingpreference = "Either hand (No preference)" if writingpreference == "Either han"

tab writingpreference, missing // check 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v19.dta"


****** installation ******

tab installation, missing // looks good 


****** test_date ******

tab test_date, missing // looks good, all within correct dates


****** date ******

tab date, missing 

* there are many missing values recorded as . and will be changed to smv 

***Special Missing Values Key ***

/* 
.a = -77 = not recorded
.b = - 88 = refused measurement
.c = -99 = unknown missing
.d = value is a zero, which is biologically impossible 
.e = suspiciously small (but not a zero) - see cutpoints for specific variables 
.f = suspiciously large - see cutpoints for specific variables 
.g = invalid value number per pdf manual 
.h = recorded as . in the dataset */

*Additions to key 

label define misslbl ///
.h "Recorded as . in the Dataset", add /// add labels to the new special missing values

replace date = .h if date == .

tab date, missing // check work


****** strdate ******

tab strdate, missing // numerous blanks exist 

gen flag_strdate_missing = 0 // create flag for missing ethncity since no smv for string 
replace flag_strdate_missing = 1 if strdate == ""


* Label all the new flag varibles 

label variable flag_weightkg_selfreport "Suspicious Self-reported Weight (kg)"
label variable flag_heightcm "Suspicious Self-reported Height (cm)"
label variable flag_footlength "Suspicious Foot Length (cm)"
label variable flag_stature "Suspicious Stature (cm)"
label variable flag_waistcircumference "Suspicious Waist Circumference (Omphalion) (cm)"
label variable flag_ethnicity_missing "Flag for Blank Self-reported Ethnicity "
label variable flag_strdate_missing "Flag for Blank String Date"

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v20.dta"


* Remove underage 

** The military approval for this evaluation allowed only those who were of legal age (18) to participate

count if age < 18 // there are 2 subjects underage
drop if age < 18 // drop 
count if age < 18  // check 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v21.dta"




******** Identify and address duplicates (part one) *****

duplicates report // check exact duplicates // there are none 

* Explore possibilities of combinations of matching variables: 

duplicates report component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch // output says there are 1842 observations that are duplicate pairs for these variables 

duplicates report component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch date // output says there are 0 observations that are duplicate pairs for these variables, which is the same as above except for date. It would be extremely unlikely that these would be different individuals based on this and it is likely they are the same individuals but a different date of measurement. These will be flagged and addressed below. 

duplicates tag component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch, gen(flag_duplicates1) // create flag for the duplicate situation above 

tab flag_duplicates1 // check flag 

label variable flag_duplicates1 "Flag for duplicates1"  // label flag 

browse if flag_duplicates1 > 0 // explore what these duplicates look like across other variables, good to continue 


* Pull out the duplicates1 
keep if flag_duplicates1 > 0 //  get just the duplicattes 
save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/duplicates1_records.dta" // save duplicates1 dataset 

use "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v21.dta" // go back to full dataset 

duplicates tag component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch, gen(flag_duplicates1) // add flag again for the duplicate situation above 

tab flag_duplicates1 // check flag 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v22.dta"

* Stata keeps the first observation in sort order, so we need to sort: 

gsort component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch -date // sort left to right/bring the "identical" measures together, have the dated sorted in desecending order so that the newest data is first; // used CHATGPT to help identify code

browse if flag_duplicates1 > 0 // check to see if sorting worked. Looks like the "duplicates" have an .h 

count if flag_duplicates1 > 0 & date == .h // this equals 921, which is consistent with the 1842 duplicate observations above. 

* Drop the observations with a .h for date so that that we keep the observation with the most recent valid date. The valid date comes first in my current sort order and no duplicate pair for this flag_duplicates1 have 2 valid dates. Therefore, I can proceed with dropping.  

duplicates drop component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch, force // drop 

browse if flag_duplicates1 > 0 // check work 
count if flag_duplicates1 > 0 // check work - 921 so it looks good 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v23.dta"



tab gender // check # of observations. We now have 6,108. The combined ansur2 dataset for males and females should have 6,068. 


* Explore where the other duplicates might have come from: 

** remove one variable at a time from above duplicate identification and get counts  

duplicates report component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch // 0 

duplicates report component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation date // 0 

duplicates report component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting branch date //

duplicates report component gender age stature weightkg waistcircumference hipbreadth installation branch date // 0 

duplicates report component gender age stature weightkg waistcircumference hipbreadthsitting installation branch date // 0 

duplicates report component gender age stature weightkg hipbreadth hipbreadthsitting installation branch date // 0 

duplicates report component gender age stature waistcircumference hipbreadth hipbreadthsitting installation branch date // 0 

duplicates report component gender age weightkg waistcircumference hipbreadth hipbreadthsitting installation branch date // 0 

duplicates report component age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch date // 0 

duplicates report component gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch date //

duplicates report gender age stature weightkg waistcircumference hipbreadth hipbreadthsitting installation branch // 0 

*Explore other combinations of matches

duplicates report installation branch gender age stature weightkg date

duplicates report installation branch gender age stature

duplicates report installation branch gender age stature date

duplicates report installation branch gender age stature date footlength

** Possible duplicates will be relevaluated again if any potential patterns in data that suggest duplicates are discovered. 


******** Create BMI variables 

* Create Continous BMI 

** First we neeed to convert stature to meters. I will create a new variable in m: 

gen stature_m = . // create stature in m variable 
replace stature_m = stature/100 if stature < . 
summ stature stature_m // check work 
tab stature, missing // check work 
label variable stature_m "Stature (m)" // label 

** bmi formula is weight in weight in kg/ height in meters squared. This formula is applied below in the creation of the bmi variable. 

gen bmi = . // create bmi variable 
replace bmi = .i if (missing(weightkg) | missing(stature_m))
replace bmi = weightkg/(stature_m^2) if (weightkg < . & stature_m < .)
summ bmi, detail // check work 
misstable summarize bmi // make sure missing was protected 
label variable bmi "Body Mass Index" // label 

* I need to have a smv for bmi if missing weightkg or missing stature_m: 

***Special Missing Values Key ***

/* 
.a = -77 = not recorded
.b = - 88 = refused measurement
.c = -99 = unknown missing
.d = value is a zero, which is biologically impossible 
.e = suspiciously small (but not a zero) - see cutpoints for specific variables 
.f = suspiciously large - see cutpoints for specific variables 
.g = invalid value number per pdf manual 
.h = recorded as . in the dataset
.i = missing weightkg or missing stature_m for bmi variables */

* Additions to spv 

label define misslbl ///
.i "Missing weightkg or missing stature_m for bmi variables", add /// add labels to the new special missing values

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v24.dta"


** Create Categorical BMI 
	  
gen bmi_cat = . // creates new variable 

replace bmi_cat = 1 if bmi <18.5 & bmi < .
replace bmi_cat = 2 if bmi >=18.5 & bmi <25
replace bmi_cat = 3 if bmi >=25 & bmi <30
replace bmi_cat = 4 if bmi >=30 & bmi < . // protects missing values 
replace bmi_cat = .i if bmi ==.i // missing weightkg or missing stature_m

tab bmi_cat, missing //  looks good 

* Add labels 

label variable bmi_cat "Body Mass Index Category Classifications" // label variable 

label define bmi_cat_lbl 1 "Underweight" 2 "Healthy Weight" 3 "Overweight" 4 "Obese" .i "missing weightkg or missing stature_m" // creates label set
label values bmi_cat bmi_cat_lbl  // attaches label set to variable 
tab bmi_cat, missing // check labels // all labels look good 
describe bmi_cat // check labels // all labels look good

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v25.dta"


** Check BMI for suspects and potentially needing flags 

summ bmi, detail //
histogram bmi // none of the values are biologically implausiable. Some are potentially really thin at a level of some kind of medical or mental health condition, but still possible. There are also some larger bmi values, which considering soldiers may be much more muscular, they are not overly suspicious. Therefore, flags will be for those that are underweight (BMI less than 18.5) and in the Obese II or greater category (BMI greater than 35). This appears to align well with the histogram distribution for flagging extreme values. 

gen flag_bmi = 0 // create flag variable 
replace flag_bmi = 1 if (bmi < 18.5 | bmi > 35) & bmi < .
replace flag_bmi = . if bmi >= .
label variable flag_bmi "Suspicious BMI"

browse if flag_bmi > 0 // check looks good 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v26.dta"



******** Identify and address duplicates (part two) *****

* in browsing the dataset with the flag_bmi > 0, I noticed there may be some potentially duplicates with one observation have a suspiously large weightkg. These also had an .h for the date in the large value. 

* Tested various combinations of measurements (direclty measured) and variables that should not change if duplicates. The combination included all direclty measured variables with the exception of weight. This is the duplicates report with the variables determined to reflect duplication (leaves out weightkg)

duplicates report gender age component branch installation thumbtipreach span footlength waistheightomphalion functionalleglength cervicaleheight trochanterionheight stature waistcircumference chestcircumference bicristalbreadth hipbreadth hipbreadthsitting

**  Tag these duplicates 
duplicates tag gender age component branch installation thumbtipreach span footlength waistheightomphalion functionalleglength cervicaleheight trochanterionheight stature waistcircumference chestcircumference bicristalbreadth hipbreadth hipbreadthsitting, generate(dup2)

rename dup2 flag_duplicates_weighterror // rename 

**  Sort the dataset to for how I would go about dealing with the weightkg duplicates and also include date in desending order since I noticed the .h in the suspect weightkg value.  

gsort gender component branch installation thumbtipreach span footlength waistheightomphalion functionalleglength cervicaleheight trochanterionheight stature waistcircumference chestcircumference bicristalbreadth hipbreadth hipbreadthsitting age kneeheightmidpatella weightkg -date // used CHATGPT to help identify code

browse if flag_duplicates_weighterror > 0 

count if flag_duplicates_weighterror > 0 
count if flag_duplicates_weighterror > 0 & date == .h // tsting my theory of the .h with dates and the suspect weightkg values 
count if flag_duplicates_weighterror > 0 & weightkg == .f
count if flag_duplicates_weighterror > 0 & date == .h & weightkg == .f 

** Based on the matching measured anthropometrics, browsing,  and counts, these are duplicates that should be pulled out. 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v27.dta"

** Pull out the flag_duplicates_weighterror
keep if flag_duplicates_weighterror > 0 //  get just the duplicattes 
save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/duplicates_weighterror_records.dta" // save duplicates_weighterror dataset 

use "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v27.dta" //  go back to full dataset 

* Stata keeps the first observation in sort order.
gsort gender age component branch installation thumbtipreach span footlength waistheightomphalion functionalleglength cervicaleheight trochanterionheight stature waistcircumference chestcircumference bicristalbreadth hipbreadth hipbreadthsitting -weightkg // sort left to right/bring the "identical" measures together, have the weight sorted in desecending order so that the valid weight is first; used CHATGPT to help identify code

browse if flag_duplicates_weighterror > 0 // check to see if sorting worked. 

count if flag_duplicates_weighterror > 0 & weightkg == .f // this equals 39, which is consistent with my assessment above

* I want to drop the ones with observations with a .f for weightkg so that that we keep the observation with not suspicous weightkg and also a valid date  

duplicates drop gender age component branch installation thumbtipreach span footlength waistheightomphalion functionalleglength cervicaleheight trochanterionheight stature waistcircumference chestcircumference bicristalbreadth hipbreadth hipbreadthsitting, force // drop 

browse if flag_duplicates_weighterror > 0 // check work - valid date there
count if flag_duplicates_weighterror > 0 // check work 39 - so it looks good 

label variable flag_duplicates_weighterror "duplicates due to suspicious weightkg"

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v28.dta"

** Look for any remaining duplicates

tab gender, missing // there are 6,069 observations. This means we have one duplicate based on the orginal dataset numbers.  

* Explore possibilities: 

tab date, missing /// there are 3 observations with .h (meaning this was recorded as . in the dataset ; because the other identified duplicates also have this .h issue, these should be explored in more detail to see if the extra observation can be identified). 

browse if date == .h // there is one observation that is missing all measured anthrometrics. This is subject ID 6516. 

browse if gender == "Male" & component == "Regular Army" & branch == "Combat Arms" & writingpreference == "Right hand" & installation == "Fort Blis" & age == 44 & dodrace == "White" & subjectnumericrace == "White" // these are the datapoints (with the exception of self reported height and weight) we have on subject ID 6516. I browsed the dataset to look if there are any subjects with these values that self reported the same height and weight. There is one subject that fits this, which is subject 825. Therefore, I conclude that this subject 6516 is the remaining duplicate measure and will be pulled out as a duplicate because it has no (incomplete) anthrometric measures. 

* Create flag for this duplicate. 
gen flag_duplicates_incomplete = 0 // create flag variable and start everything at 0
replace flag_duplicates_incomplete = 1 if (id == 6516) | (id == 825)
browse if flag_duplicates_incomplete > 0 // check to make sure they are right ones 

* duplicate dropping pre save 
save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v29.dta"

*Pull out the flag_duplicates_incomplete
keep if flag_duplicates_incomplete > 0 //  get just the duplicattes 
save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/duplicates_incomplete.dta" // save duplicates_incomplete dataset 

use "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v29.dta" //  go back to full dataset 

*drop the duplicate 
drop if id == 6516 // drop the incomplete duplicate 
browse if flag_duplicates_incomplete > 0 // check to make sure it got dropped right 

label variable flag_duplicates_incomplete "Flag for last duplicate with an incomplete measurement assessment" 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v30.dta"

tab gender, missing /// we are at 6,068 observations, which is what we should have based on the offical ANSURII pdf documentation! 


******** Check bmi_cat for suspects and potentially needing flags 

tab bmi_cat, missing


*Apply the smae flags from the bmi continous variable since those should be the same. 

gen flag_bmi_cat = 0 // create flag variable 
replace flag_bmi_cat = 1 if (bmi < 18.5 | bmi > 35) & bmi < .
replace flag_bmi_cat = . if bmi >= .
label variable flag_bmi_cat "Suspicious BMI Category (based on BMI number)"

count if if flag_bmi > 0 
count if if bmi_cat > 0 // both the categorical and continuous match in counts 
browse if flag_bmi_cat > 0 // check looks good 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v31.dta"


******** Create Season Variable 

* Create a variable that indicates the season the measurements were made.

**look at date variables to figure out an approach. 
describe date // long storge,  %tdD_m_Y 
tab date, missing // 2 missing values (.h)
describe strdate // 2 blank 

*extract month from date; since date is already in a stata daily date format no conversion is needed. 

gen month = month(date)

replace month = .h if missing(date)

tab month, missing // looks good 

label variable month "month"

*create season variable and add labels 

gen season = .

replace season = 1 if inlist(month, 12, 1, 2)
replace season = 2 if inlist(month, 3, 4, 5)
replace season = 3 if inlist(month, 6, 7, 8)
replace season = 4 if inlist(month, 9, 10, 11)
replace season = .h if missing(date) // used ChatGPT to help identify code

label define season_lbl ///
1 "Winter" ///
2 "Spring" ///
3 "Summer" ///
4 "Fall" ///
.h "Missing date"

label values season season_lbl
label variable season "Season of Measurement"


tab season, missing // looks good 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v32.dta"



******** Create Numerical Categorical Variable for Gender 

*look at variables to figure out an approach. 
describe gender // string 
tab gender, missing //1985 female, 4083 male 

*change from string to numeric categorical 
encode gender, generate(gender_cat) label(gender_catlbl) // used ChatGPT to help identify code

rename gender_cat gender_num_cat // rename 

label variable gender_num_cat "Binary Gender Numeric Categorical" // label 

summ gender_num_cat, detail // checked to make sure just ones and twos there as
tab gender_num_cat, missing // labels are there, the male and female total match the string gender variable numbers. No flags or suspect things. 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v33.dta"



***** Create Numerical Categorical Variable for Preferred Hand 

*look at variables to figure out an approach
describe writingpreference // string

tab writingpreference, missing // 62 either, 656 left hand, 5350 right hand 

*change from string to numeric categorical 
encode writingpreference, generate(writingpreference_num_cat) label(writingpreference_num_cat) // used ChatGPT to help identify code

label variable writingpreference_num_cat "Preferred Writing Hand Numeric Categorical" // label 

summ writingpreference_num_cat, detail // checked to make sure there are just 1-3 as there should be 
tab writingpreference_num_cat, missing // labels are there, totals match the string numbers. No flags or suspect things. 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v34.dta"



***** Body Type Categories creation 

*Explore distrubtions of anthropometrics across males and females. 

sum thumbtipreach footlength kneeheightmidpatella waistheightomphalion functionalleglength cervicaleheight trochanterionheight stature waistcircumference chestcircumference bicristalbreadth hipbreadth hipbreadthsitting weightkg if gender_num_cat == 1, detail // female distrubtions 

sum thumbtipreach footlength kneeheightmidpatella waistheightomphalion functionalleglength cervicaleheight trochanterionheight stature waistcircumference chestcircumference bicristalbreadth hipbreadth hipbreadthsitting weightkg if gender_num_cat == 2, detail // male distrubtions 

/*Given the military context of the dataset, I determined it would be best to come up with a classification that is provides meaningful information of body structure types in terms of factors that would be important for military operations. With this in mind, I created three overarching indexes for the algorithm that focus on mass relative to height, vertical body proportions, and body breadth/robustness index. These indexes will provide meaningful information related to military factors like plane/vehicle clearance or weight fit, clothing and other gear fit, mobility potential, fit within tight spaces, capacity for carrying heavy things, and potential strength-mass tradeoffs of different personnel that might be important for specific missions. Rather than using general civilian references for determining cutpoints for the different indexes, I used the tertiles for each gender within the dataset to provide a more meaningful assessment/comparison in the context of the army and get about the same number of subjects for each index. Indexes were then used to categorize body types based on build and frame. 

**** INDEXES 

* Index 1: Mass Index 
- Use MHR, which is a new variable created, representing Mass Height Ratio, which is calulcated as weightkg / stature_m
- Classify into low, medium, and high based on tertiles for male and female using 1, 2, 3 for low, medium, and high 

* Index 2: Vertical Proportion Index 
- Use LSR, which is a new variable created, representing Functional Leg Length Stature Ratio, which is calulcated as functionalleglength / stature_m
- Classify into short-legged, balanced, and long-legged based on on tertiles for male and female using 1, 2, 3 for short-legged, balanced, and long-legged

* Index 3: Robustness Index 
- Use TSR, which is new variable created, represented Trunk Stature Ratio, which is calculculated as waistcircumference / stature_m
- Classify into narrow, average, and broad based on on tertiles for male and female using 1, 2, 3 for narrow, average, and broad */

**** CREATE INDEXES AND DETERMINE TERTILES 

* Check to see if any missing values across variables 
tab weightkg, missing
tab stature_m, missing
tab waistcircumference, missing
tab functionalleglength, missing // there are no missing values any of these measures 


* Create new variables 

** mhr (see INDEXES section above for more info)
gen mhr = . // create variable 
replace mhr = weightkg/(stature_m) if (weightkg < . & stature_m < .)
summ mhr, detail // check work 
label variable mhr "Mass Height Ratio" // label 

** lsr (see INDEXES section above for more info)
gen lsr = . // create variable 
replace lsr = functionalleglength /(stature_m) if (functionalleglength < . & stature_m < .)
summ lsr, detail // check work 
label variable lsr "Functional Leg Length Stature Ratio" // label 

** tsr (see INDEXES section above for more info)
gen tsr = . // create variable 
replace tsr = waistcircumference/(stature_m) if (waistcircumference < . & stature_m < .)
summ tsr, detail // check work 
label variable tsr "Trunk Stature Ratio" // label 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v35.dta"


* Create tertile variables by sex 

ssc install egenmore // install needed feature // identified by Chat GPT

** mhr 

bysort gender_num_cat: egen mhr_tert = xtile(mhr), nq(3) // split data into lowest third, middle third, and highest third values for each sex // used ChatGPT to help identify code

label define mhr_tert_lbl 1 "Low" 2 "Medium" 3 "High" // add all the labels 
label values mhr_tert mhr_tert_lbl
label var mhr_tert "mhr Tertile (Sex-specific)"

tab gender_num_cat mhr_tert, row // every looks good, tertiles are there and there are 33.30-33.35% in each group. 


** lsr

bysort gender_num_cat: egen lsr_tert = xtile(lsr), nq(3) // split data into lowest third, middle third, and highest third values for each sex // used ChatGPT to help identify code

label define lsr_tert_lbl 1 "Compact" 2 "Proportional" 3 "Elongated" // add all the labels 
label values lsr_tert lsr_tert_lbl
label var lsr_tert "lsr Tertile (Sex-specific)"

tab gender_num_cat lsr_tert, row // every looks good, tertiles are there and there are 33.30-33.35% in each group. 


** tsr

bysort gender_num_cat: egen tsr_tert = xtile(tsr), nq(3) // split data into lowest third, middle third, and highest third values for each sex // used ChatGPT to help identify code

label define tsr_tert_lbl 1 "Narrow" 2 "Average" 3 "Broad" // add all the labels 
label values tsr_tert tsr_tert_lbl
label var tsr_tert "tsr Tertile (Sex-specific)"

tab gender_num_cat mhr_tert, row // every looks good, tertiles are there and there are 33.30-33.35% in each group. 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v36.dta"


**** Create the body types based on indexes and body type variable ****

/* I defined body types as based on 1) Build and 2) Vertical Proportion. I determined to have 9 body types. Since there are 27 possible combinations and the instructions say to have between 3-6 but Dr. Vanderslice said we could have more if it was meaningful, this number struck an appropriate balance of not collapsing into too few of groups to not have it be as meaningful/making clear distinctions but also not going overboard in the number of groups. 

1) Build was defined first and applied across all vertical proportion groups. I derived build categories from 
sex-specific tertiles of HMR and TSR as follows:

- Light: mhr_tert == 1 AND tsr_tert == 1 
  (lowest tertile of mass and narrowest trunk relative to stature)

- Robust: mhr_tert == 3 OR tsr_tert == 3 
  (highest tertile of mass and/or broadest trunk)

- Intermediate: all other combinations of mhr_tert and tsr_tert 
  (neither Light nor Robust)

2) Vertical Proportion was defined using sex-specific tertiles of LSR as follows:

- Compact: lsr_tert == 1 
  (lower vertical proportion)

- Proportional: lsr_tert == 2 
  (mid-range vertical proportion)

- Elongated:  lsr_tert == 3 → Elongated 
  (higher vertical proportion)

Body type was then defined Vertical Proportion × Build combinations, which created nine categories:

Compact-Light
Compact-Intermediate
Compact-Robust

Proportional-Light
Proportional-Intermediate
Proportional-Robust

Elongated-Light
Elongated-Intermediate
Elongated-Robust
*/

**** Create body types

* check to see if there are missing values 
count if mhr_tert >= .
count if lsr_tert >= .
count if tsr_tert >= . // each of these 3 variables do not have missing values, so I do not need to worry about protecting missing values as I create body types. 

** create the build variable 

gen build = . // create variable 

replace build = 1 if mhr_tert==1 & tsr_tert==1 // light 
replace build = 3 if mhr_tert==3 | tsr_tert==3 // robust 
replace build = 2 if build== . // intermediate (all other combinations)

***  Add labels 
label define buildlbl ///
1 "Light" ///
2 "Intermediate" ///
3 "Robust"

label values build buildlbl
label variable build "Build (Light / Intermediate / Robust)"

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v37.dta"

** create body types and labels based on build and vertical proportion

gen bodytype = . // create variable 

*compact (lsr_tert == 1)
replace bodytype = 1 if lsr_tert==1 & build==1 // Compact-Light
replace bodytype = 2 if lsr_tert==1 & build==2 // Compact-Intermediate
replace bodytype = 3 if lsr_tert==1 & build==3 // Compact-Robust

*proportional (lsr_tert == 2)
replace bodytype = 4 if lsr_tert==2 & build==1 // Proportional-Light
replace bodytype = 5 if lsr_tert==2 & build==2 // Proportional-Intermediate
replace bodytype = 6 if lsr_tert==2 & build==3 // Proportional-Robust

*elongated (lsr_tert == 3)
replace bodytype = 7 if lsr_tert==3 & build==1 // Elongated-Light
replace bodytype = 8 if lsr_tert==3 & build==2 // Elongated-Intermediate
replace bodytype = 9 if lsr_tert==3 & build==3 // Elongated-Robust

***  Add labels 
label define bodylbl ///
1 "Compact-Light" ///
2 "Compact-Intermediate" ///
3 "Compact-Robust" ///
4 "Proportional-Light" ///
5 "Proportional-Intermediate" ///
6 "Proportional-Robust" ///
7 "Elongated-Light" ///
8 "Elongated-Intermediate" ///
9 "Elongated-Robust"

label values bodytype bodylbl
label variable bodytype "Body Type (Vertical Proportion x Build)"

** checks 
count if missing(bodytype)
tab bodytype
tab gender_num_cat bodytype, row // everything looks good

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v38.dta"


******** Categorical Unisex T Shirt Size 

* Unisex 3600 t shirt size chart from Next Level Apparel (https://www.nextlevelapparel.com/cdn/shop/files/3600-WEBSITE-SPEC_e289f037-f085-4819-b229-eb662191ea49.pdf?v=9763116909218305737)

/* Size chart conversions: 

1) Original flat chest width (inches)from website above:

XS  = 17.5
S   = 19
M   = 20.5
L   = 22
XL  = 24
2XL = 26
3XL = 28
4XL = 30
5XL = 32
6XL = 34

2) Conversion from flat width (half circumference) to full chest circumference. I multiplied by 2 to get the full chest circumference.

XS  = 17.5 × 2 = 35 
S   = 19   × 2 = 38
M   = 20.5 × 2 = 41
L   = 22   × 2 = 44
XL  = 24   × 2 = 48
2XL = 26   × 2 = 52
3XL = 28   × 2 = 56
4XL = 30   × 2 = 60
5XL = 32   × 2 = 64
6XL = 34   × 2 = 68

3) Convert inches to cm to match database. 1 inch = 2.540 cm, so I multlpied by 2.540 and rounded to 3 decimal places.

Full chest circumference (cm):

XS  = 35 × 2.54 = 88.900 cm
S   = 38 × 2.54 = 96.520 cm
M   = 41 × 2.54 = 104.140 cm
L   = 44 × 2.54 = 111.760 cm
XL  = 48 × 2.54 = 121.920 cm
2XL = 52 × 2.54 = 132.080 cm
3XL = 56 × 2.54 = 142.240 cm
4XL = 60 × 2.54 = 152.400 cm
5XL = 64 × 2.54 = 162.560 cm
6XL = 68 × 2.54 = 172.720 cm

4) Logic for determining the best likely sizes: Give each subject the smallest shirt size that has a shirt full chest circumference that is greater to or equal their 
measured chest circumference (shirt chest cirumference is not smaller than the subject's chest circumference). */

* Create the t shirt size variable 

sum chestcircumference // the range is 69-146.9, so we only need to use sizes XS to 4XL

count if chestcircumference >= . // there are no missing values, so I do not need to worry about protecting missing values

gen tshirtsize = . // create variable

replace tshirtsize = 1 if chestcircumference <= 88.900
replace tshirtsize = 2 if chestcircumference > 88.900  & chestcircumference <= 96.520
replace tshirtsize = 3 if chestcircumference > 96.520  & chestcircumference <= 104.140
replace tshirtsize = 4 if chestcircumference > 104.140 & chestcircumference <= 111.760
replace tshirtsize = 5 if chestcircumference > 111.760 & chestcircumference <= 121.920
replace tshirtsize = 6 if chestcircumference > 121.920 & chestcircumference <= 132.080
replace tshirtsize = 7 if chestcircumference > 132.080 & chestcircumference <= 142.240
replace tshirtsize = 8 if chestcircumference > 142.240

* Add labels 
label define shirtsizelbl ///
1 "XS" ///
2 "S" ///
3 "M" ///
4 "L" ///
5 "XL" ///
6 "2XL" ///
7 "3XL" ///
8 "4XL"

label values tshirtsize shirtsizelbl
label variable tshirtsize "Estimated Unisex T-Shirt Size (Next Level 3600)"

* Checks 
tab tshirtsize
tab gender_num_cat tshirtsize, row // checks out with females having more smaller sizes
count if missing(tshirtsize) //everything looks good 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v39.dta"


*************************** SECTION 3 **********************************

******** Create a table with  statistics describing the anthropometric measures of the entire sample

* generate table with mean, sd, min, and max and have it columns and 3 decimal points

tabstat ///
stature ///
heightcm ///
weightkg ///
weightkg_selfreport ///
cervicaleheight ///
waistheightomphalion ///
span ///
thumbtipreach ///
chestcircumference ///
waistcircumference ///
trochanterionheight ///
kneeheightmidpatella ///
functionalleglength ///
bicristalbreadth ///
hipbreadth ///
hipbreadthsitting ///
footlength ///
, statistics(mean sd min max) ///
columns(statistics) ///
format(%9.3f) ///
save 

putexcel set "Anthropometric_Summary.xlsx", replace /// 
putexcel A1 = matrix(r(StatTotal)'), names /// put into excel starting in cell A1 and transpose for the correct layout // used ChatGPT to help identify code

*** Create a table with the number of missing values and suspicious values for each of the anthropometric measures listed above 

misstable summarize /// check to see anthropometric variables that have missing values
stature ///
heightcm ///
weightkg ///
weightkg_selfreport /// this is the only one that has a missing value. It has 1 observation missing. 
cervicaleheight ///
waistheightomphalion ///
span ///
thumbtipreach ///
chestcircumference ///
waistcircumference ///
trochanterionheight ///
kneeheightmidpatella ///
functionalleglength ///
bicristalbreadth ///
hipbreadth ///
hipbreadthsitting ///
footlength 

codebook /// double check that none are missing 
stature ///
heightcm ///
weightkg ///
weightkg_selfreport ///
cervicaleheight ///
waistheightomphalion ///
span ///
thumbtipreach ///
chestcircumference ///
waistcircumference ///
trochanterionheight ///
kneeheightmidpatella ///
functionalleglength ///
bicristalbreadth ///
hipbreadth ///
hipbreadthsitting ///
footlength

** Get count for suspicious values (only need to look at flag variables because that is the only way I identfied suspicious values)

count if flag_weightkg_selfreport > 0 // = 107 
count if flag_heightcm > 0 // = 14
count if flag_footlength > 0 // = 36
count if flag_stature > 0 // = 15
count if flag_waistcircumference > 0 // = 125


******** Figure for the differences in % of total height attributable to the height to hip by sex

* The formula for this figure is percent hip to height = trochanterion height / stature multiplied by 100. Trochanterion height is height to the hip. 

** Create new variable 

gen pct_height_to_hip = (trochanterionheight / stature) * 100 // create new variable with formula describe above
label variable pct_height_to_hip "% of Total Height to Hip" // label 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v40.dta"

** Create figure 

by gender_num_cat, sort: summarize pct_height_to_hip, detail // explore descriptive stats of the new variable by gender 

***  Box plot 
graph box pct_height_to_hip, over(gender_num_cat) /// box plots by gender
asyvars /// allow for changing colors of each box/markers
box(1, fcolor(cranberry) lcolor(cranberry)) /// change colors
box(2, fcolor(navy) lcolor(navy)) /// 
marker(1, mcolor(cranberry)) /// change colors
marker(2, mcolor(navy)) ///
plotregion(lcolor(black) lwidth(medium)) /// graph border and formatting
graphregion(color(white)) /// change background color 
b1title(Gender, size(large) color(black) margin(t=1)) ///  adds formatted title 
ytitle("% of Total Height Attributable to Hip Height", size(medium) margin(t=2)) ///  labels and formats y axis title
ylabel(45(2)57, format(%4.1f) labsize(large) tlwidth(medium) nogrid) /// sets axis ticks, labels, and formatting; removes grid marks
name(fig3_1, replace) // names and saves


*** Bar chart 

collapse /// collapse to mean, SD, and N by gender // used ChatGPT to help identify code
    (mean) mean_pct = pct_height_to_hip ///
    (sd)   sd_pct   = pct_height_to_hip ///
    (count) n_pct   = pct_height_to_hip, ///
    by(gender_num_cat) 

gen upper = mean_pct + sd_pct
gen lower = mean_pct - sd_pct

twoway /// get bar graph
(bar mean_pct gender_num_cat if gender_num_cat==1, /// add female
barwidth(.8) fcolor(cranberry) lcolor(cranberry)) /// formatting 
(bar mean_pct gender_num_cat if gender_num_cat==2, /// add male 
barwidth(.8) fcolor(navy) lcolor(navy)) /// formatting 
(rcap upper lower gender_num_cat, /// add bars 
lcolor(black) lwidth(medium)), /// formatting 
xlabel(1 "Female" 2 "Male", nogrid) /// formatting 
ytitle("% of Total Height Attributable to Hip Height") /// formatting 
ylabel(49.5(0.5)53.5, format(%4.1f) nogrid) /// formatting 
graphregion(color(white)) /// formatting 
plotregion(lcolor(black)) /// formatting 
name(fig_3_2, replace)

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/Figre 3.2.dta"
file /Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/Figre 3.2.dta saved

   
   
*************************** SECTION 4 *********************************

 use "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v40.dta"
(ANSUR II exploratory data analysis dataset)

**** Correlation between measures of stature 

****** Analysis 

corr /// 
stature ///
kneeheightmidpatella ///
cervicaleheight ///
trochanterionheight ///
waistheightomphalion ///
functionalleglength ///
footlength ///
thumbtipreach ///
span


             |  stature kneehe~a cervic~t trocha~t waisth~n functi~h footle~h thumbt~h
-------------+------------------------------------------------------------------------
     stature |   1.0000
kneeheight~a |   0.8894   1.0000
cervicaleh~t |   0.9912   0.9030   1.0000
trochanter~t |   0.8772   0.9255   0.8880   1.0000
waistheigh~n |   0.9367   0.9134   0.9414   0.9118   1.0000
functional~h |   0.8877   0.8759   0.9022   0.8655   0.8787   1.0000
  footlength |   0.8448   0.8077   0.8503   0.7695   0.8068   0.8003   1.0000
thumbtipre~h |   0.8060   0.7945   0.8250   0.7771   0.7815   0.8320   0.7873   1.0000
        span |   0.8988   0.8732   0.9079   0.8594   0.8835   0.8720   0.8627   0.8811

             |     span
-------------+---------
        span |   1.0000
		
		
*The two highest correlated are 1) stature & cervicalheight and 2) stature & waistheightomphalion


********  Figures

* 1) stature & cervicalheight

twoway ///
(scatter stature cervicaleheight, /// do a scatterplot 
msymbol(circle) /// formatting 
msize(vsmall) /// formatting
mcolor(teal%10)) /// formatting
(lfit stature cervicaleheight, /// add best fit line
lcolor(black) /// formatting
lwidth(medium)), /// formatting
xscale(range(115 175)) /// formatting
xlabel(115(10)175, format(%4.0f) labsize(medium) tlwidth(medium) nogrid) ///
yscale(range(140 200)) /// formatting
ylabel(140(10)200, format(%4.0f) labsize(medium) tlwidth(medium) nogrid) ///
xtitle("Cervicale Height (cm)") /// formatting
ytitle("Stature (cm)") /// formatting
plotregion(lcolor(black) lwidth(medium)) /// formatting
graphregion(color(white) lcolor(black) lwidth(medium)) /// formatting
legend (off) /// formatting
name(fig_4_1, replace)

pwcorr stature cervicaleheight, sig // get p value // used ChatGPT to help identify code

** add r with GUI r=0.991 and also change color of best fit line with GUI

*** Dealing with overplotting - hexplot creation 

hexplot stature cervicaleheight, ///
bins(55) ///
color(viridis) ///
xlabel(115(10)175, labsize(medium) tlwidth(medium) nogrid) ///
ylabel(140(10)200, format(%4.0f) labsize(medium) tlwidth(medium) nogrid) ///
levels(7) ///
plotregion(lcolor(black) lwidth(medium)) ///
graphregion(color(white) lcolor(black) lwidth(medium)) ///
name(fig_4_2, replace)


**** Correlation between stature/other measures by sex

** full sample 

corr ///  corrlation for anthro stature measures
stature ///
kneeheightmidpatella ///
cervicaleheight ///
trochanterionheight ///
waistheightomphalion ///
functionalleglength ///
footlength ///
thumbtipreach ///
span 

     |  stature kneehe~a cervic~t trocha~t waisth~n functi~h footle~h thumbt~h     span
-------------+---------------------------------------------------------------------------------
     stature |   1.0000
kneeheight~a |   0.8894   1.0000
cervicaleh~t |   0.9912   0.9030   1.0000
trochanter~t |   0.8772   0.9255   0.8880   1.0000
waistheigh~n |   0.9367   0.9134   0.9414   0.9118   1.0000
functional~h |   0.8877   0.8759   0.9022   0.8655   0.8787   1.0000
  footlength |   0.8448   0.8077   0.8503   0.7695   0.8068   0.8003   1.0000
thumbtipre~h |   0.8060   0.7945   0.8250   0.7771   0.7815   0.8320   0.7873   1.0000
        span |   0.8988   0.8732   0.9079   0.8594   0.8835   0.8720   0.8627   0.8811   1.0000



** female 

corr ///  corrlation for anthro stature measures
stature ///
kneeheightmidpatella ///
cervicaleheight ///
trochanterionheight ///
waistheightomphalion ///
functionalleglength ///
footlength ///
thumbtipreach ///
span if gender_num_cat==1 // female 


             |  stature kneehe~a cervic~t trocha~t waisth~n functi~h footle~h thumbt~h
-------------+------------------------------------------------------------------------
     stature |   1.0000
kneeheight~a |   0.8432   1.0000
cervicaleh~t |   0.9843   0.8664   1.0000
trochanter~t |   0.8578   0.9168   0.8786   1.0000
waistheigh~n |   0.9088   0.8802   0.9234   0.8897   1.0000
functional~h |   0.8323   0.8341   0.8497   0.8484   0.8289   1.0000
  footlength |   0.7219   0.7315   0.7262   0.7184   0.7016   0.7124   1.0000
thumbtipre~h |   0.6710   0.6853   0.6904   0.6935   0.6573   0.7338   0.6535   1.0000
        span |   0.8190   0.8319   0.8309   0.8423   0.8284   0.8132   0.7726   0.8064

             |     span
-------------+---------
        span |   1.0000

* the highest correlations are still between  1) stature & cervicalheight and 2) stature & waistheightomphalion
		
		
** Male 

corr /// corrlation for anthro stature measures
stature ///
kneeheightmidpatella ///
cervicaleheight ///
trochanterionheight ///
waistheightomphalion ///
functionalleglength ///
footlength ///
thumbtipreach ///
span if gender_num_cat==2 // male

             |  stature kneehe~a cervic~t trocha~t waisth~n functi~h footle~h thumbt~h
-------------+------------------------------------------------------------------------
     stature |   1.0000
kneeheight~a |   0.8334   1.0000
cervicaleh~t |   0.9841   0.8572   1.0000
trochanter~t |   0.8501   0.8981   0.8698   1.0000
waistheigh~n |   0.9085   0.8701   0.9157   0.8843   1.0000
functional~h |   0.8179   0.8084   0.8458   0.8114   0.8125   1.0000
  footlength |   0.7181   0.6925   0.7253   0.6758   0.6931   0.6608   1.0000
thumbtipre~h |   0.6912   0.6981   0.7263   0.6997   0.6759   0.7462   0.6524   1.0000
        span |   0.8230   0.8000   0.8386   0.8135   0.8178   0.7894   0.7492   0.8119

             |     span
-------------+---------
        span |   1.0000


* the highest correlations are still between  1) stature & cervicalheight and 2) stature & waistheightomphalion


******* Compare the self-reported weight to the measured weight. 

* Create difference variabel 

*** want the difference to represent: Reported − Measured, so a negative value is underreproted and positive value is overeported 

gen diff_weight = weightkg_selfreport - weightkg // create 

label variable diff_weight "Self-reported − Measured Weight (kg)" //label 

summ diff_weight, detail // look at distribution 

* Figures

** Box
graph box diff_weight, horizontal /// creates horizontal box plot
box(1, fcolor(teal) lcolor(teal)) /// changes box fill and ouline color 
marker(1, mcolor(teal%55)) /// sets outlier/outside points color
plotregion(lstyle(box) lcolor(black) lwidth(large)) /// graph border and formatting 
graphregion(color(white)) /// chanes background color 
ytitle("Weight Reporting Bias (Self-reported - Measured kg)") ///
ylabel(-50(10)70, format(%4.0f) labsize(large) tlwidth(medium) nogrid) // Sets axis ticks, labels, and formatting; removes grid marks
name(fig_4_3, replace)

** Hexplot 
hexplot diff_weight weightkg, ///
bins(50) ///
color(viridis) ///
xlabel(40(10)140, labsize(medium) tlwidth(medium) nogrid) ///
 ylabel(-50(10)70, format(%4.0f) labsize(medium) tlwidth(medium) nogrid) ///
ytitle("Weight Reporting Bias (Self-reported - Measured kg)") ///
plotregion(lcolor(black) lwidth(medium)) ///
graphregion(color(white) lcolor(black) lwidth(medium)) ///
aspectratio(1) ///
levels(7) ///
addplot( ///
function y = 0, ///
range(35 145) ///
lcolor(red) ///
lwidth(medium)) ///
name(fig_4_4, replace)


******* Extent to which the difference between reported and measured weight varies by sex.

bysort gender_num_cat: summ diff_weight, detail
 // distriubtion // used ChatGPT to help identify code
 
-> gender_num_cat = Female

                         diff_weight
-------------------------------------------------------------
      Percentiles      Smallest
 1%    -8.575512      -43.40794
 5%    -5.037643      -15.89977
10%     -3.59819      -14.83765       Obs               1,985
25%     -1.92041      -13.99705       Sum of wgt.       1,985

50%    -.5950127                      Mean          -.8584035
                        Largest       Std. dev.      2.647028
75%     .5315208       7.296371
90%     1.685032       7.969391       Variance       7.006757
95%     2.559635       14.40295       Skewness      -2.657758
99%     4.607708       16.09319       Kurtosis       39.94133

---------------------------------------------------------------------------------------------
-> gender_num_cat = Male

                         diff_weight
-------------------------------------------------------------
      Percentiles      Smallest
 1%    -8.921318      -48.27007
 5%    -4.926758      -45.51338
10%     -3.29705      -44.68526       Obs               4,082
25%    -1.526299      -22.19116       Sum of wgt.       4,082

50%    -.0646286                      Mean          -.2365261
                        Largest       Std. dev.      3.190103
75%     1.329933       10.70295
90%     2.802948       11.30726       Variance       10.17675
95%     3.835373       17.90023       Skewness      -.4637308
99%     6.332649        66.1263       Kurtosis       81.85347


tabstat diff_weight, by(gender_num_cat) stat(mean sd) // get summary table with mean and sd // used ChatGPT to help identify code


gender_num_cat |      Mean        SD
---------------+--------------------
        Female | -.8584035  2.647028
          Male | -.2365261  3.190103
---------------+--------------------
         Total | -.4399918  3.037008
------------------------------------

**create bar chart 

collapse /// collapse to mean, SD, and N by gender // used ChatGPT to help identify code
    (mean) mean_diff_weight = diff_weight ///
    (sd)   sd_diff_weight = diff_weight ///
    (count) n_diff_weight = diff_weight, ///
    by(gender_num_cat)

gen upper = mean_diff_weight + sd_diff_weight // used ChatGPT to help identify code
gen lower = mean_diff_weight - sd_diff_weight // used ChatGPT to help identify code

twoway /// get bar graph
(bar mean_diff_weight gender_num_cat if gender_num_cat==1, /// females
barwidth(.8) fcolor(cranberry) lcolor(cranberry)) /// formatting 
(bar mean_diff_weight gender_num_cat if gender_num_cat==2, /// males 
barwidth(.8) fcolor(navy) lcolor(navy)) /// formatting 
(rcap upper lower gender_num_cat, /// // used ChatGPT to help identify code
lcolor(black) lwidth(medium)), ///    formatting 
xlabel(1 "Female" 2 "Male", nogrid noticks) /// formatting 
ytitle("Weight Reporting Bias (Self-reported - Measured kg)") /// formatting 
ylabel(-3.5(1)3.5, format(%4.1f) nogrid) /// formatting 
yline(0, lpattern(shortdash) lcolor(lightgrey) lwidth(thin)) /// formatting 
graphregion(color(white)) /// formatting 
plotregion(lcolor(black)) /// formatting 
name(fig_4_5, replace)

** explore bias in more depth 

ttest diff_weight, by(gender_num_cat) // t test for signficance 

Two-sample t test with equal variances
------------------------------------------------------------------------------
   Group |     Obs        Mean    Std. err.   Std. dev.   [95% conf. interval]
---------+--------------------------------------------------------------------
  Female |   1,985   -.8584035    .0594126    2.647028   -.9749211   -.7418859
    Male |   4,082   -.2365261    .0499308    3.190103   -.3344176   -.1386345
---------+--------------------------------------------------------------------
Combined |   6,067   -.4399918    .0389905    3.037008   -.5164271   -.3635566
---------+--------------------------------------------------------------------
    diff |           -.6218774    .0827252               -.7840483   -.4597066
------------------------------------------------------------------------------
    diff = mean(Female) - mean(Male)                              t =  -7.5174
H0: diff = 0                                     Degrees of freedom =     6065

    Ha: diff < 0                 Ha: diff != 0                 Ha: diff > 0
 Pr(T < t) = 0.0000         Pr(|T| > |t|) = 0.0000          Pr(T > t) = 1.0000


reg diff_weight i.gender_num_cat // used ChatGPT to help identify code

   Source |       SS           df       MS      Number of obs   =     6,067
-------------+----------------------------------   F(1, 6065)      =     56.51
       Model |   516.49856         1   516.49856   Prob > F        =    0.0000
    Residual |  55432.7427     6,065  9.13977621   R-squared       =    0.0092
-------------+----------------------------------   Adj R-squared   =    0.0091
       Total |  55949.2413     6,066  9.22341597   Root MSE        =    3.0232

--------------------------------------------------------------------------------
   diff_weight | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
---------------+----------------------------------------------------------------
gender_num_cat |
         Male  |   .6218774   .0827252     7.52   0.000     .4597066    .7840483
         _cons |  -.8584035   .0678559   -12.65   0.000    -.9914251   -.7253819

 
* Odds ratio

gen underreport = diff_weight < 0 // create variable where 1 = underreported, 0 accurate or overreported

label variable underreport "Underreported Weight (Self-reported < Measured)" // label 
label define underlbl 0 "No" 1 "Yes"
label values underreport underlbl
tab underreport // check labels

tab underreport gender_num_cat, col // check 

logistic underreport i.gender_num_cat // get odds ratio / i means treat like a categorical variable // used ChatGPT to help identify code

Logistic regression                                     Number of obs =  6,068
                                                        LR chi2(1)    =  89.94
                                                        Prob > chi2   = 0.0000
Log likelihood = -4122.8655                             Pseudo R2     = 0.0108

--------------------------------------------------------------------------------
   underreport | Odds ratio   Std. err.      z    P>|z|     [95% conf. interval]
---------------+----------------------------------------------------------------
gender_num_cat |
         Male  |   .5891406    .033187    -9.39   0.000     .5275573    .6579126
         _cons |   1.795775   .0840907    12.50   0.000     1.638297    1.968389
--------------------------------------------------------------------------------
Note: _cons estimates baseline odds.

// so OR (male) 0.589, 95% CI 0.528 – 0.658, p < 0.001 // so males less likely to underreport


******* Compare the self-reported height to the measured height. 

* Create difference variabel 

*** want the difference to represent: Reported − Measured, so a negative value is underreproted and positive value is overvierported 

gen diff_height = heightcm - stature // create  variable 

label variable diff_height "Self-Reported Height − Stature (cm)" // label 

summ diff_height, detail // look at distribution 

** Figures 

* Box 
graph box diff_height, horizontal /// creates horizontal box plot
box(1, fcolor(teal) lcolor(teal)) /// changes box fill and ouline color 
marker(1, mcolor(teal%55)) /// sets outlier/outside points color
plotregion(lstyle(box) lcolor(black) lwidth(large)) /// graph border and formatting 
graphregion(color(white)) /// chanes background color 
ytitle("Height Reporting Bias (Self-reported - Measured cm)") ///
ylabel(-30(10)70, format(%4.0f) labsize(large) tlwidth(medium) nogrid) // Sets axis ticks, labels, and formatting; removes grid marks
name(fig_4_6, replace)

* Hex plot 
hexplot diff_weight stature, ///
bins(50) ///
color(viridis) ///
xlabel(140(10)200, labsize(medium) tlwidth(medium) nogrid) ///
 ylabel(-50(10)70, format(%4.0f) labsize(medium) tlwidth(medium) nogrid) ///
ytitle("Height Reporting Bias (Self-reported - Measured cm)") ///
xtitle("Measured Height (cm)") ///
plotregion(lcolor(black) lwidth(medium)) ///
graphregion(color(white) lcolor(black) lwidth(medium)) ///
aspectratio(1) ///
levels(7) ///
addplot( /// used ChatGPT to help identify code
function y = 0, ///
range(140 200) ///
lcolor(red) ///
lwidth(medium)) ///
name(fig_4_7, replace)

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v41.dta"


******** Relationship between derived `body type' and weight/BMI 

* a) Compare the distributions of weight and BMI for each of the body types you created in 1e above. Describe your findings in a paragraph with a figure and/or table. Focus on how well your body types describe differences in weight and obesity.* 

*** distributions 
tabstat weightkg bmi, by(bodytype) stat(mean sd) // exploratory

graph box bmi, over(bodytype) // exploratory
graph box weightkg, over(bodytype) // exploratory

tabstat weightkg bmi, by(bodytype) stat(mean sd p25 p50 p75 n) // exploratory // used ChatGPT to help identify code

**Figure for weight 
vioplot weightkg, over(bodytype) ///
ytitle("Weight (kg)") ///
graphregion(color(white)) ///
plotregion(lcolor(black) lwidth(thin)) ///
graphregion(color(white) lcolor(black) lwidth(thin)) /// 
ylabel(40(20)140, format(%4.0f) labsize(medium) tlwidth(thin) nogrid) ///
xlabel(, angle(45) labgap(2) labsize(small) tlwidth(thin) nogrid) /// used ChatGPT to help identify code
xsize(80) ysize(60) ///
bar(color(black)) density(color(teal%50)) line(color(teal)) median(color(red)) ///
name(fig_4_8, replace)


**Figure for bmi continous
vioplot bmi, over(bodytype) ///
ytitle("Body Mass Index (BMI)") ///
graphregion(color(white)) ///
plotregion(lcolor(black) lwidth(thin)) ///
graphregion(color(white) lcolor(black) lwidth(thin)) /// 
ylabel(15(5)45, format(%4.0f) labsize(medium) tlwidth(thin) nogrid) ///
xlabel(, angle(45) labgap(2) labsize(small) tlwidth(thin) nogrid) /// used ChatGPT to help identify code
xsize(80) ysize(60) ///
bar(color(black)) density(color(teal%50)) line(color(teal)) median(color(red)) ///
name(fig_4_9, replace)


**Differences for BMI categorical /obesity

tab bodytype bmi_cat, row nofreq // get table; used ChatGPT to help identify code


*************************** SECTION 5 **********************************


** Characterize the association of BMI and age (continuous variables), stratified by sex. Present with figure and table

* Table

reg bmi age if gender_num_cat == 1 // female regression 

      Source |       SS           df       MS      Number of obs   =     1,985
-------------+----------------------------------   F(1, 1983)      =    137.57
       Model |  1569.98189         1  1569.98189   Prob > F        =    0.0000
    Residual |  22630.6643     1,983   11.412337   R-squared       =    0.0649
-------------+----------------------------------   Adj R-squared   =    0.0644
       Total |  24200.6462     1,984  12.1979064   Root MSE        =    3.3782

------------------------------------------------------------------------------
         bmi | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         age |    .106792    .009105    11.73   0.000     .0889357    .1246483
       _cons |   22.40447   .2742748    81.69   0.000     21.86657    22.94237
------------------------------------------------------------------------------


reg bmi age if gender_num_cat == 2 // male regression 

     Source |       SS           df       MS      Number of obs   =     4,083
-------------+----------------------------------   F(1, 4081)      =    333.46
       Model |  5032.80109         1  5032.80109   Prob > F        =    0.0000
    Residual |  61593.2659     4,081  15.0926895   R-squared       =    0.0755
-------------+----------------------------------   Adj R-squared   =    0.0753
       Total |   66626.067     4,082  16.3219174   Root MSE        =    3.8849

------------------------------------------------------------------------------
         bmi | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
         age |   .1260303   .0069017    18.26   0.000     .1124992    .1395613
       _cons |   23.88325   .2168704   110.13   0.000     23.45807    24.30844
------------------------------------------------------------------------------


* Figure 

** Option 1
twoway ///
(scatter bmi age if gender_num_cat==1, ///
	msymbol(circle) msize(vsmall) mcolor(cranberry%10)) ///
	(lfit bmi age if gender_num_cat==1, lcolor(cranberry)) /// female;  used ChatGPT to help identify code
(scatter bmi age if gender_num_cat==2, /// male 
	msymbol(circle) msize(vsmall) mcolor(navy%10)) ///
	(lfit bmi age if gender_num_cat==2, lcolor(navy)), /// used ChatGPT to help identify code
by(gender_num_cat, col(2) note("") ixaxes iyaxes) /// used ChatGPT to help identify code
xtitle("Age (years)") ///
xscale(range(18 60)) /// adjusts x axis to 0-75
xlabel(18(4)60, grid glcolor(white)labsize(medium) tlwidth(medium) nogrid) /// sets tick marks; start(unit increase)end, also formats 
ylabel(15(5)45, format(%4.0f)labsize(medium) tlwidth(medium) nogrid) /// sets tick marks and formats labels 
ytitle("BMI (kg/m²)") ///
xsize(12) ysize(5) ///
plotregion(lcolor(black) lwidth(medium)) ///
graphregion(color(white) lcolor(black) lwidth(medium)) ///
legend (off) ///
name(fig5_1, replace)

** Option 2 (size differences)
twoway ///  used ChatGPT to help identify code
(scatter bmi age if gender_num_cat==1, ///
	msymbol(circle) msize(vsmall) mcolor(cranberry%10)) ///
	(lfit bmi age if gender_num_cat==1, lcolor(cranberry)) ///
(scatter bmi age if gender_num_cat==2, ///
	msymbol(circle) msize(vsmall) mcolor(navy%10)) ///
	(lfit bmi age if gender_num_cat==2, lcolor(navy)), ///
by(gender_num_cat, col(1) note("") ixaxes iyaxes) ///
xtitle("Age (years)") ///
xscale(range(18 60)) /// adjusts x axis to 0-75
xlabel(18(4)60, labsize(medium) tlwidth(medium) nogrid noticks) /// sets tick marks; start(unit increase)end, also formats 
ylabel(15(5)45, format(%4.0f)labsize(medium) tlwidth(medium) nogrid noticks) /// sets tick marks and formats labels 
ytitle("BMI (kg/m²)") ///
xsize(10) ysize(15) ///
plotregion(lcolor(black) lwidth(medium)) ///
graphregion(color(white) lcolor(black) lwidth(medium)) ///
name(fig5_1a, replace)

** Get r and p values to add through the GUI
pwcorr bmi age if gender_num_cat==1, sig // get r and p value female
           |      bmi      age
-------------+------------------
         bmi |   1.0000 
             |
             |
         age |   0.2547   1.0000 
             |   0.0000

			 
pwcorr bmi age if gender_num_cat==2, sig // get r and p value male 


             |      bmi      age
-------------+------------------
         bmi |   1.0000 
             |
             |
         age |   0.2748   1.0000 
             |   0.0000
             

			 
******** Characterize the association of BMI and age, stratified by sex, using categorical measures BM and age. 

*** Variable creation 
gen age_num_cat = . // create numerical categorical variable for age 
replace age_num_cat = 1 if age >=18 & age <=24 // Use NCHS standard age categories 
replace age_num_cat = 2 if age >=25 & age <=44
replace age_num_cat = 3 if age >=45 & age <=64
replace age_num_cat = 4 if age >=65

label define age_num_catlbl 1 "18–24 years" 2 "25–44" 3 "45–64" 4 "65+" // label 
label values age_num_cat age_num_catlbl
label variable age_num_cat "NCHS standard age categories"

tab age_num_cat // check 

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v42.dta"

*** Table
tab bmi_cat age_num_cat if gender_num_cat==1, col chi2 // get frequencies and count and chi square for females // used ChatGPT to help identify code

tab bmi_cat age_num_cat if gender_num_cat==2, col chi2 // get frequencies and count and chi square for males // used ChatGPT to help identify code


tab bmi_cat age_num_cat if gender_num_cat==1, chi2 V // get cramer's v // used ChatGPT to help identify code

tab bmi_cat age_num_cat if gender_num_cat==2, chi2 V // get cramer's v // used ChatGPT to help identify code

*** Figure

graph bar (count), /// bar char
over(bmi_cat) /// break it down by bmi category  
over(age_num_cat) /// include a physi
stack asyvars /// make it stacked
percentages /// show percentages 
by(gender_num_cat, col(1)) /// include male and female, 1 column format
bar(1, color(stc1)) /// adjust colors of bmi categories
bar(2, color(stc3)) /// 
bar(3, color(stc4)) /// 
bar(4, color(stc2)) /// 
blabel(bar, color(black) format(%6.2f) suffix("%") position(center) size (medsmall)) /// adjust percent formatting in bars // used ChatGPT to help identify code
ytitle(Percent) /// title y axis 
ylabel(0(25)100, nogrid) /// change y axis ticks and remove gridlines 
plotregion(lcolor(black) lwidth(thin)) /// add border
name(fig5_2, replace) // names and saves 



*** Missing labels: 

label variable obese "Not obese or obese"

save "/Users/savannahdaines/Desktop/DMAP/Assignments/Project 1/Datasets/ansur2allV2_v43.dta"
