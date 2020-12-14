use ra_sample_data.dta

** Question 1
summarize
* Max age is 145
drop if age == 120
* One person supposedly has 75 years of education
 drop if education == 75
* One person supposedly spends $100k/mo on the lottery
drop if expend_total == 100000


** Question 2
tab income gender


** Question 3
summarize age, detail
display "The mean age in the sample is " r(mean)


** Question 4
summarize expend_total, detail
* Create Monthly Income
gen month_income = income/12
* Create Expenditure as a share of monthly income (have to divide by $1,000 since expenditure is in dollars and income in thousands of dollars)
gen expend_share = (expend_total/month_income)/1000
summarize expend_share, detail
hist expend_total


** Question 5
forvalues v = 5(5)20{
    gen education_`v' = 0
    replace education_`v' = 1 if education >= `v'
}


** Question 6
corr income_delta expend_delta
* They are positively correlated with a correlation of 0.1888
summarize income_effects_delta_pct
* The mean of this is -1.42, suggesting that individuals expected a -1.42% change in lottery expenditure.
* The expectations and the reality do differ; individuals expected an increase in income to cause them to spend
* less on the lottery, when in fact a greater income is correlated with higher lottery spending.


** Question 7
* Various exploratory ways to look at the relationship between expenditure and income
scatter expend_total month_income
corr expend_total month_income
reg expend_total month_income
outreg2 using seven.doc
reg expend_share month_income
outreg2 using seven.doc, append

reg expend_total month_income risk_seeking
reg expend_total month_income risk_aversion
reg expend_total month_income gamblers_fallacy
reg expend_total month_income overconfidence

* There is a negative relationship between lottery expenditure and income.
* If you regress monthly expenditure on monthly income, the regression coefficient is -0.67, suggesting that
* an increase in monthly income of a $1,000 leads to 67 fewer cents spent on the lottery. However, 
* this relationship is not statistically significant at the 0.05 level (p=0.072). One can create a statistically 
* significant coefficient for monthly income if one adds potentially relevant variables (adding a measure of risk seeking or risk
* aversion makes the income coefficient significant, but adding a measure of overconfidence or the individual's incorrect responses on a test of the gambler's fallacy
* does not). If one instead regresses lottery expenditure as a share of income on income then
* the relationship is strongly significant (P < 0.0005), but suggests that a $1,000 increase in monthly income is only associated with
* a -.16 ppt change in the share of a person's income that goes to the lottery. One tends to hear that lottery contestants are more likely to be poorer,
* so this study provides some evidence to confirm that hypothesis, especially when looking at spending as a share of income, however the relationship 
* between lottery spending and income is less than one might have thought before.


** Question 8
* Regress on just behavioral variables
reg expend_total risk_seeking
outreg2 using eight.doc
reg expend_total risk_aversion
outreg2 using eight.doc,append
reg expend_total seems_fun
outreg2 using eight.doc,append
reg expend_total enjoy_thinking
outreg2 using eight.doc,append
reg expend_total self_control
outreg2 using eight.doc,append
reg expend_total financial_literacy
outreg2 using eight.doc,append
reg expend_total financial_numeracy
outreg2 using eight.doc,append
reg expend_total gamblers_fallacy
outreg2 using eight.doc,append
reg expend_total non_belief_lln
outreg2 using eight.doc,append
reg expend_total ev_miscalculation
outreg2 using eight.doc,append
reg expend_total overconfidence
outreg2 using eight.doc,append
reg expend_total lottery_payout
outreg2 using eight.doc,append
reg expend_total happiness
outreg2 using eight.doc,append
* All bias/preference variables:
reg expend_total risk_seeking risk_aversion seems_fun enjoy_thinking self_control financial_literacy financial_numeracy gamblers_fallacy non_belief_lln ev_miscalculation overconfidence lottery_payout happiness
outreg2 using eight.doc,append