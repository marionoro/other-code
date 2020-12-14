** Question 1
* The main goal of this analysis is to understand the causes of naming decisions by individuals (in this case focusing on how mass media
* potentially shapes naming decisions). As such, our work here relates to the existing literature on how naming decisions vary
* by race and class, and how those naming differences do or do not lead to causal changes in outcomes for different groups. In
* "Employers' Replies to Racial Names", Bertrand and Mullainathan send resumes to employers that are identical except for the name,
* which in one group is a distinctively white name and the other group is a distinctively black name. They find that white names are
* more likely to get a callback from employers than equivalently qualified resumes with a black name. Another paper in this area is
* "The Causes and Consequences of Distinctively Black Names" by Fryer and Levitt, who analyze the causes of an increase in distinctively black names
* in the black community in the 1970s, how those naming decisions intersect with socioeconomic status, and find that there is "no negative 
* causal impact of having a distinctively Black name on life outcomes". Viewership of certain TV shows can vary significantly by race and
* class, providing a potential mechanism for the development of demographically distinctive names. Our findings here are also potentially important
* given the existing literature on how an individual's name can affect aspects of their life.

* Import data
import excel babynames, firstrow

** Question 2
* Look at data
su
list if _n <= 5
misstable summarize

* ten8081 is marked differently than the other years (Yes/No instead of 1/0). I change that:
gen ten8081fixed = 1 if ten8081 == "Yes"
replace ten8081fixed = 0 if ten8081 == "No"
drop ten8081
gen ten8081 = ten8081fixed
drop ten8081fixed

* If name is outside of top 500 most popular baby names then it has a missing value for that year.
* However, we know that those missing values must be between 0 and the value of the 500th most common name in that year.
* I assign all missing values to have the value of halfway between 0 and the 500th most common value in that year:

forvalues j = 1980/1995{
    egen min_pop`j' = min(pop`j')
    replace pop`j' = 0.5 * min_pop`j' if pop`j' == .
    drop min_pop`j'
}

* Finally, it is worth noting that name popularity is determined by calendar year, but whether or not a name was in a show is by TV Season (e.g. Fall 1990-Spring 1991).
* This creates some arbitrariness when deciding which TV season should go with which calendar year.

** Question 3
corr pop*
* The correlation between the counts of a given name in one year and the following year are always greater than 0.99.
* This is a high correlation.

** Question 4
* I assign the TV show season to the calendar year during its Spring session (e.g. 90-91 is associated with 1991)
forvalues j = 81/95{
    local i = `j'-1
    gen ten19`j' = ten`i'`j'
    drop ten`i'`j'
}

reshape long pop ten, i(name) j(year)

* We do not have TV show observations for 1980, so I drop those values from the dataset:
drop if year == 1980

encode name, gen(name_code)
xtset name_code year
xtreg pop ten i.year, fe

** 4a
* We need to include name fixed effects so that we remove any intrinsic properties of the names from being represented in the TV show dummy coefficient. 
* For example, I would expect names in TV shows to be more common than names that are not in TV shows since TV writers are more likely to give their characters 
* somewhat common names. If there were no fixed effects in the model then the TV show dummy coefficient would be artificially high because it would also include 
* how the popularity of a name affects its likelihood of being in a TV show. Since we are only interested in the causal impact of the TV show on a name’s popularity 
* (and not the reverse effect discussed in the last sentence), we want to include the name fixed effects.

** 4b
* When I perform a regression of popularity on a name being in a TV show, and add name and year fixed effects, I find a coefficient of 98 for the TV show dummy.
* This suggest that a name being in a TV show in a given year is associated with 98 more children being named that name. However, the coefficient is not significant
* at a 0.05 level (P = 0.123), which leads us to not reject the null that being in a TV show has no effect on a name's popularity.