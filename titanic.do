* This is some basic Stata code creating a predictive model out of the Kaggle Titanic dataset:
* https://www.kaggle.com/c/titanic

cd titanic

import delimited train

* Summarizing missing data
misstable summarize

* Replace missing age values with the mean age
egen missage = mean(age)
replace age = missage if missing(age)
drop missage

* Create Variable for Length of Name
generate name_length = strlen(name)

* Extract letter from cabin code and encode as factor variable
generate cabin_letter = "A" if strpos(cabin,"A")
foreach i in "B" "C" "D" "E" "F" "G" {
    replace cabin_letter = "`i'" if strpos(cabin,"`i'")
}
replace cabin_letter = "Missing" if missing(cabin_letter)
encode cabin_letter, gen(cabin_letter_dummy)
drop cabin_letter

* Create dummy variable for if cabin code is missing or not
generate cabin_code_missing = 1 if missing(cabin)
replace cabin_code_missing = 0 if !missing(cabin)

* Create dummy variable for if ticket code has letter in it.
generate ticket_letter_dummy = 1 if strpos(ticket,"A")
foreach J in "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" {
    replace ticket_letter_dummy = 1 if strpos(cabin,"`J'")
}
replace ticket_letter_dummy = 0 if ticket_letter_dummy==.

* Create dummy variable for sex.
encode sex, gen(sex_dummy)
drop sex

* Mark missing embarked values (only 2) as the modal category. Then encode as factor variable
egen embarked_mode = mode(embarked)
replace embarked = embarked_mode if missing(embarked)
drop embarked_mode
encode embarked, gen(embarked_dummy)
drop embarked

*Drop variables that will not be used
drop name
drop ticket
drop cabin

* Analyze correlations
corr

* Creating a (very overfit) logit regression
logit survived i.sex_dummy i.pclass i.cabin_code_missing age sibsp parch fare i.cabin_letter_dummy i.ticket_letter_dummy i.embarked_dummy name_length
predict yhat_alot

* Some simpler logit regressions with especially significant variables
logit survived i.sex_dummy
predict yhat_sex

logit survived i.sex_dummy i.pclass
predict yhat_sex_class

logit survived i.sex_dummy i.pclass i.cabin_code_missing
predict yhat_sex_class_cabin

* Evaluate predictive performance
estat classification

* Graphical Representations of Different Predictions
sunflower yhat_sex_class_cabin yhat_alot
hist yhat_alot
hist yhat_sex_class_cabin

* Storing a logit regression
logit survived i.sex_dummy i.pclass i.cabin_code_missing
estimates store a1

* Using stored logit regression to predict test set values
clear
import delimited test
* Do all processing to test dataset as was done to training dataset above (not copied here for brevity)
predict yhat_test

* Create histogram of predicted values
hist yhat_test
