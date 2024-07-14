log using "my_log_file.log", text replace
ssc install estout
ssc install outreg2

/* Hackaton analysis */

/* Assumptions: 

Problem statement II

I am assuming that responding yes to the question: "was the (name's) father present during any of
your antenatal visits?" could have an impact on the baby's weight since some women don't go to prenatal
care appointments because the husband does not allowed/think is it not necessary. Hence, hipothecally, having the father involved could change baby's health outcomes. 

H0: answering yes to the respective question does not have a significant impact on the baby's weight. 
H1: aswering yes to the respective question has a significant impact on the baby's weight. */  

use final_dataset.dta, clear

/* checking descriptives */ 

summarize m19,detail
display "coefficient of variation: " (r(sd) / r(mean)) * 100 "%"

/* the mean is 2,8 kg. The min value is 0,5 kg and the max value is 9,9 kg.
the weights of the babies deviate by 573.9934 grams from the mean weight of the babies in the data set.
coefficient of variation = 20.32%. Moderate variability. 
positive skewed: some babies are very heavy and they push the mean to a higher level. The right tail of the
distribution is heavier. 
kurtosis is also very high, indicating extreme values. */ 

/* normality test */ 
 
histogram m19, width(100) frequency
graph export "histogram_dependent.png", as(png) replace
swilk m19

/* variable is not normally distributed. */ 

/* seeing the dataset */ 

describe

/* lets use the Spearman Correlation test, which does not assume normality, to run a simple correlation. */ 

spearman m19 s422

twoway (scatter m19 s422) ///
       (lowess m19 s422), ///
       title("Spearman Correlation (Birth Weights and Father Presence)") ///
       ytitle("Birth Weight") ///
       xtitle("Father Present (Yes = 1, No = 0)")

/* we cannot reject the null. Hence, there is not enough evidence to say that the presence of the 
father in the prenatal appointment is correlated with the baby weight.  */ 

/* Lets run the more robust model, with the other variables.*/ 

/* checking vif */ 

regress m19 v012 v013 v024 v025 v106 v190a v444 sb21 sb57 sm327 v131 v463a b0 m14 s414 s422
vif

/* removed one of the age variables.*/ 

/* Model 1

rreg m19 v012 v024 v025 v106 v190a v444 sb21 sb57 sm327 v131 v463a b0 m14 s414 s422

i am using rreg which is a command for a robust regression, since the dependent variable is not parametric. 
the mom's age is predicting the baby weight (v012).
educational level is predicting the weight of the newborn (v106).
if the child is a twin or not is predicting the weight of the newborn (b0). 
s414, v463a and sb57 have been ommited. */ 

/* Model 2

/* testing with only s414 */

rreg m19 v012 v024 v025 v106 v190a v444 sb21 sm327 v131 b0 m14 s414 s422

the significant variables dont change, s414 still omiited. */ 

/* Model 3

/* testing with only v463a */

rreg m19 v012 v024 v025 v106 v190a v444 sb21 sm327 v131 b0 m14 v463a s422

the mom's age is predicting the baby weight (v012).
educational level is predicting the weight of the newborn (v106).
if the child is a twin is ommited (b0). 
if the mom smokes is predicting the babys weight (v463a) but the variable is positive and this is weird.
maybe it is because this variable is highly skewed, the yes category is very underrepresented. Cannot use. */

/* Model 4

/* testing with only sb57 */

rreg m19 v012 v024 v025 v106 v190a v444 sb21 sm327 v131 b0 m14 sb57 s422

ommited due to multicolinearity */ 

/* Final Model */ 
	
/* Important: this panel includes the 2020 year, which is a very disruptive year. 
I am generating a variable on this. 
I also removed sm327 due to so many missing values.
setting v131 as a categorical variable with caste being my baseline.  */  

gen pandemic = (v007 == 2020)

rreg m19 s422 v012 v024 v025 v106 v190a v444 sb21 i.v131 b0 m14 pandemic
predict yhat, xb
twoway (scatter m19 s422) (line yhat s422, sort), ///
       title("Estimated Relationship (Birth Weight and Presence of the Father)") ///
       ytitle("Birth Weight (grams)") ///
       xtitle("Presence of the Father (1 = Yes, 0 = No)") ///
       legend(label(1 "Birth Weight in grams") label(2 "Fitted values")) ///
       yscale(range(0 10000)) ///
       xscale(range(0 1))
graph export "birth_weight_father_presence.png", as(png) replace


/* Initially, this graph is telling us that the relationship in question is weak or almost non-existent. 
The red lines, which indicate the predicted values, are almost horizontal. 
The babies weight are all concentrated between 2000 and 4000 grams, with some outliers, indicated by the isolated blue data points. */

/* Interpreting the coefficients: 

- Said yes to the question:  was (name's) father present during (any of) your antenatal visits? 

Accordinging to my sample, the presence of the father during antenatal visits is associated with a decrease in birth weight by approximately 26,47 grams compared to when the father was not present, holding all other factors constant.

This result could be due to multiple reasons:

- Stressful factors. Being in a controlling relationship, lacking autonomy, can disrupt stress levels and undermine
the mom's health outcomes. 
-  Compensatory behaviour: the presence of a father could be common in problematic pregnancies, where birth weights are generally lower. 
- Healthcare access issues overall and social norms: being accompanied by the husband may be associated with limited access to other health services and a low number of prenatal visits in the first place due to patriarchal social norms and lack of autonomy. 

- Age of the mom (v012)

According to my sample, for each additional year of maternal age, the birth weight increases
by approximately 5,55 grams, holding the other factors constant.

- Type of residence (v025)

Accordinging to my sample, living in an urban area is associated with a decrease in birth weight by approximately 54,8 grams compared to living in a rural area, holding other variables constant.

This could make sense in the India case due to environmental pollution in the urban area. 
Environmental pollution is also a predicter of the birth weight in the medical literature. 

- Educational levels (v106)

According to my sample, each additional educational level is associated with an increase in the birth weight by approximately 37,9 grams. 

From 0 to 1: the birth weight increases in 37,9 grams.

From 0 to 2: the birth weight increases in 75,8 grams (37,9*2). 

From 0 to 3: the birth weigh increases in 113,7 grams (37,9*3).

- Wealth index (v190a)

According to my sample, an increase in the wealth index is associated with an increase in birth weight by approximately 28,5 grams for each unit increase in the wealth index category, holding all other variables constant.
Higher wealth index categories (richer, richest) are associated with higher birth weights. Specifically, each step up in the wealth index category (from poorest to poorer, poorer to middle, middle to richer, and richer to richest) is associated with an average increase in birth weight of approximately 28.51 grams. 

- Ethnicity (v131)

Being part of a tribe is associated with an increase in birth weight of approximately 146,8 grams compared to being part of a caste (the reference category), holding all other factors constant.

- If the child is a twin (b0).

Accordingly to my sample, being a twin is associated with an decrease in the birth weight by approximately  348,9 grams.

- The pandemic

The pandemic is also predicting the birth weights. Birth weights in the year 2020 are, on average, 41,86 grams lower compared to other years. This effect is statistically significant (p = 0.040), likely due to the disruptions caused by the COVID-19 pandemic. */ 

/* Creating tables */

label variable m19 "Birth Weight in grams"
label variable s422 "Presence of the Father in antenatal visits"
label variable v012 "Maternal Age"
label variable v024 "State"
label variable v025 "Type of residence (urban/rural)"
label variable v106 "Education Level"
label variable v190a "Wealth Index (urban/rural)"
label variable v444 "BMI (accordingly to WHO)"
label variable sb21 "Pre-pregnancy Condition"
label variable v131 "Ethnicity"
label variable b0 "Is a twin or not"
label variable m14 "Antenatal Visits"
label variable pandemic "Effects of the Pandemic 2020"

rreg m19 s422 v012 v024 v025 v106 v190a v444 sb21 i.v131 b0 m14 pandemic

outreg2 using "regression_results.doc", replace ///
    title("Robust Regression Results") ///
    label addstat(N, e(N), r2, e(r2)) ///
    keep(m19 s422 v012 v024 v025 v106 v190a v444 sb21 i.v131 b0 m14 pandemic) ///
    ctitle(Coef. p-value)

log close 

