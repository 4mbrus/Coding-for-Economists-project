cd "\\tsclient\C\Users\Ambrus\Documents\CEU\Coding for economists\Project stata\Hotels Europe"
ls
cd "clean"
ls
cd ..
cd "raw"
ls
import delimited hotelbookingdata.csv //This takes a lot of time
//Lets make this dataset more manageable by making it smaller
drop if price_night == "price for 4 nights" // It does not make sene to compare prices if the lenght of the stay is not the same
drop price_night //Now every value is the same for this variable, so it does not hold any usefull information for us
drop center1label
keep if inlist(city_actual, "Bratislava", "Budapest", "Prague", "Warsaw") // I decided to compare hotels in 4 countries which are close to each other geographically, and have had a similar history after 1945

//Let's wether we need both of these
gen center1_distance = substr(center1distance,1,3)
gen center2_distance = substr(center2distance,1,3)
destring center1_distance, replace
destring center2_distance, replace
sum center1_distance center2_distance
gen dist_dif = center1_distance - center2_distance // Based on this I have decided to drop the center2_distance variable because there is not a big difference to center1_distance
drop dist_dif center2_distance center2distance center1distance // I am also dropping the string version of center1distance

rename center1_distance distance2centre
label variable center1_distance "Distance to city center in miles"

gen accom_type = substr(accommodationtype,13,30)
drop accommodationtype