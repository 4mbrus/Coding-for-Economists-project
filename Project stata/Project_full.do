cd "\\tsclient\C\Users\Ambrus\Documents\CEU\Coding for economists\Coding-for-Economists-project\Project stata\Hotels Europe"
ls
cd "clean"
ls
cd ..
cd "raw"
ls
import delimited hotelbookingdata.csv, varnames(1) bindquotes(strict) encoding("Windows-1252") clear //This takes a lot of time
keep if inlist(city_actual, "Bratislava", "Budapest", "Prague", "Warsaw") // I decided to compare hotels in 4 countries which are close to each other geographically, and have had a similar history after 1945

//Lets clean the data

drop if price_night == "price for 4 nights" // It does not make sene to compare prices if the lenght of the stay is not the same
drop price_night //Now every value is the same for this variable, so it does not hold any usefull information for us
drop center1label
//Let's wether we need both of these
gen center1_distance = substr(center1distance,1,3)
gen center2_distance = substr(center2distance,1,3)
destring center1_distance, replace
destring center2_distance, replace
gen dist_dif = center1_distance - center2_distance
sum dist_dif // Based on this I have decided to drop the center2_distance variable because there is not a big difference to center1_distance
drop center2label dist_dif center2_distance center2distance center1distance // I am also dropping the string version of center1distance
rename center1_distance distance2centre
label variable distance2centre "Distance to city center in miles"

gen accom_type = substr(accommodationtype,13,30) //The first 12 letters are irrelevant for us
drop accommodationtype

gen citysame = 1 if s_city == city_actual //These values seem to be the same always, but let's check
sum citysame //They are indeed always the same, so we can drop one of them, and rename the other to "city"
drop citysame city_actual
rename s_city city

drop year // This year is not too important here (If it was 2019 and 2020 it would be relevant, because of COVID)
drop neighbourhood // Unfortunately the encoding of the neighbourhood names is messed up, and we do not really need them, so we drop it

//Make a numerical value out of the guestreviewsrating variable, and unify the naming scheme for the different ratings, add labels if necesarry 
gen rating1 = substr(guestreviewsrating,1,3)
replace rating1 = subinstr(rating1,"/","",.)
replace rating1 = subinstr(rating1,"NA",".",.)
destring rating1, replace
drop guestreviewsrating

label variable rating1 "User rating average out of 5"
rename rating_reviewcount rating1_reviewcount
rename rating2_ta rating2
rename rating2_ta_reviewcount rating2_reviewcount
label variable rating2 "User rating average (tripadvisor, out of 5)"
rename starrating star_rating


// Let's create a new variable that averages the ratings that are available for each acommodation
gen avg_rating = (rating1 + rating2 + star_rating)/3
replace avg_rating = rating1 if rating2 == . & star_rating == .
replace avg_rating = rating2 if rating1 == . & star_rating == .
replace avg_rating = star_rating if rating1 == . & rating2 == .
replace avg_rating = (star_rating + rating1)/2 if rating2 == . & avg_rating == .
replace avg_rating = (star_rating + rating2)/2 if rating1 == . & avg_rating == .

// Let's compare the average ratings of the hotels in our 4 cities
gen rd_avg_rating = round(avg_rating / 0.5) * 0.5 //Let's round the numbers for better readabilty 

graph bar (percent), over(rd_avg_rating) over(city) asyvars stack percent ///
	ytitle("Percentage") title("Comparison of Average Ratings by City")
cd ../..
mkdir "media"
cd "media"
graph export "ratings_by_city_graph.png", as(png) replace





