// Let's create a new variable that averages the ratings that are available for each acommodation
gen avg_rating = (rating1 + rating2 + star_rating)/3
replace avg_rating = rating1 if rating2 == . & star_rating == .
replace avg_rating = rating2 if rating1 == . & star_rating == .
replace avg_rating = star_rating if rating1 == . & rating2 == .
replace avg_rating = (star_rating + rating1)/2 if rating2 == . & avg_rating == .
replace avg_rating = (star_rating + rating2)/2 if rating1 == . & avg_rating == .

// Let's compare the average ratings of the hotels in our 4 cities with the help of a graph
gen rd_avg_rating = round(avg_rating / 0.5) * 0.5 //Let's round the numbers for better readabilty 
graph bar (percent), over(rd_avg_rating) over(city) asyvars stack percent ///
	ytitle("Percentage") title("Comparison of Average Ratings by City")
cd ../..
mkdir "media"
cd "media"
graph export "ratings_by_city_graph.png", as(png) replace