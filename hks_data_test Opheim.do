cd "C:\Users\paulo\Documents\RA and Fellowship Applications\Data_Tests\data_task_packet_2020"

* Question 1
use datatask_main_2020, clear

replace prov_id = subinstr(prov_id, " ", "", .)
replace prov_id = lower(prov_id)
merge m:1 prov_id using datatask_treat_2020
* It doesn't successfully merge all lines.

* Question 2
* I am assuming that this dataset contains every hospital in the US (that assumption is needed to calculate the Saidin Index)

gen saidin = 0
forvalues i = 1/31 {
    gen a_`i' = 0
    forvalues t = 2001/2010 {
    sum tech_`i' if year == `t'
    replace a_`i' if year == `t' = 1 - (1/r(N)) * r(sum)
    }
    replace saidin = saidin + a_`i' * tech_`i'
    drop a_`i'
}

save merged_plus_saidin

* Question 3
*a
hist saidin
mean(saidin)
su(saidin)
* The distribution of Saidin scores is right-skewed, with the mean
* score across all time periods being 2.7 but the maximum value being 21.5.

*b
forvalues i = 0/1 {
    su saidin if teach == `i'
    su saidin if govt == `i'
    su saidin if nonprof == `i'
}

* Teaching hospitals have the highest average Saidin score (6.6) of any
* grouping (yes/no nonprofit, govt, or teaching) in the dataset. There is
* a large gap between the teaching hosptital average and the average for other
* groupings, although nonprofit hospitals have the second highest average score
* with 3.1. Hospitals that are not non-profit have the lowest average with 2.0.

* c
cor beds saidin
* Yes there is a positive correlation (0.54) between bed count and Saidin score.

* Problem 4
encode prov_id, gen(prov_cat)
ssc d parmest
ssc install parmest
ssc d descsave
ssc install descsave

xtset prov_cat year
xtreg saidin ib2004.year i.treat#i.year, fe
parmest, label norestore escal(N)
list parm estimate min95 max95
drop if strpos(parm, "0b")
drop if strpos(parm, "cons")
drop label stderr dof t p es_1
save blabla
use blabla, clear
drop in 11/20
gen year = 2000 + _n
gen cr_mean = estimate
drop parm estimate min95 max95
save year_coef
use blabla, clear
drop in 1/10
gen year = 2000 + _n
gen tr_effect = estimate
gen tr_lo = min95
gen tr_hi = max95
drop parm estimate min95 max95
save interaction

use year_coef, clear
merge 1:1 year using interaction
drop _merge
gen tr_mean = tr_effect + cr_mean

save opheim_paul_estimates

* Problem 5
twoway (line cr_mean year) (line tr_mean year)

* 6
* a
* The MMA treatment does seem to lead to increased technological adoption in
* hospitals that received the treatment. The coefficient for beta starts negative in 2001
* and then increases after 2004, the treatment period, until it is about equal to 0 at
* the end of the dataset in 2010. This suggests that hospitals that received the treatment
* had lower Saidin scores than those that did not, but the treatment helped them increase their
* access to technology.

* While this does not provide some evidence of the above statement, I am not that confident
* in the results. The beta coefficient starts to increase from its low value in 2003 (before the
* treatment took effect), suggesting that the MMA-treated hospitals were starting to narrow 
* the gap with non-treated hospitals before the treatment took effect. Just looking at the results
* of the diff-in-diff, I think that this analysis provided some evidence that MMA funding increased
* technological adoption in hospitals that received it, but it is not very strong evidence for that claim.

* b
* One threat for identification with a diff-in-diff model is that the treated and non-treated group shared
* a common trend before the treatment occurred. As discussed in part a, this is not quite met. A common trend
* assumption would require the beta coefficients to be roughly equivalent in 2001,2002, and 2003, and only start
* to change in 2004 or later. However, the coefficient notably increased in 2003 (-4.5 to -3.8), which violates
* a common trend assumption.