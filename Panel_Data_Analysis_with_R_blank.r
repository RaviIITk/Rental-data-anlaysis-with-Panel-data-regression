## Panel Data Analysis with R

## 1. Set working directory

## 2. Load the library

library(plm)
library(knitr)
library(broom)
library(tidyverse)
library(stargazer)
library(lmtest)
library(gplots)


## 3. Import Dataset (STATA version)
# Rental Data from Wooldridge
#  Indexed by city and year
rental_p <- pdata.frame(RENTAL, index = c("city","year"))
str(RENTAL)
str(rental_p)

## 4. Display the data
head(RENTAL)
head(rental_p)

#  Model lrent~y90+lpop+lavginc+pctstu

## 5. OLS using lm 
ols<- lm(lrent~y90+lpop+lavginc+pctstu,data = RENTAL)
summary(ols)

## 6. OLS using plm
pooled<- plm(lrent~y90+lpop+lavginc+pctstu, data = RENTAL, model ="pooling", index = c("city","year"))
summary(pooled)

#OR use this format
pooled2<- plm(lrent~y90+lpop+lavginc+pctstu, data = rental_p, model ="pooling")
summary(pooled2)



## Results table
stargazer(pooled, type = 'text')
stargazer(pooled2, type = 'text')

## 7. Test for heteroscedasticity
res <- residuals(ols)
yhat <-fitted(ols)
plot(RENTAL$pctstu,res, xlab = "%Student", ylab = "Residuals")
plot(yhat, res, xlab = "Fitted value", ylab = "Residuals" )
## 8. Fixed Effects
# Includes within-entity effects
fe <- plm(lrent~y90+lpop+lavginc+pctstu, data = rental_p, model ="within")
summary(fe)
stargazer(fe, type = 'text')
# Show fixed effects for all 64 cities
fixef(fe)

## 9. Test for FE vs OLS
# Ho: OLS is better than FE, reject at p < 0.05
pFtest(fe,ols)


## 10. Random Effects

# Includes both the within-entity and between-entity effects
re<-plm(lrent~y90+lpop+lavginc+pctstu, data = rental_p, model ="random")
summary(re)
stargazer(re, type = 'text')

## 11. FE VS RE

## Hausman Test Ho: RE is preferred, Ha: FE is preferred (p < 0.05)
phtest(fe,re)


# Beautify / Tabulate result
kable(tidy(phtest(fe,re), caption = "Husman test for the rendom effect"))


## 12. Breusch Pagan Lagrange Multiplier Test Ho: No panel effect, i.e., OLS is better. Ha: RE is better at p <0.05
plmtest(pooled,type = c("bp"))
#plmtest(ols, type=c("bp")) - use PLM package

## 13. Test for cross-sectional dependence [NOTE: Suitable only for macro panels with long time series] [Not suitable for RENTAL dataset]
# Breusch-Pagan LM test of independence and Pasaran CD test, Ho: There is no cross-sectional dependence
pcdtest(fe, test = c("lm"))

pcdtest(fe, test = c("cd"))
## 14. Testing for serial correlation [NOTE: Suitable only for macro panels with long time series] [Not suitable for RENTAL dataset]
# Ho: There is no serial correlation
pbgtest(fe) # not suitable for this data set


## 15. Breusch - Pagan test for heteroscedasticity Ho: Homoscedasticity Ha: Heteroscedasticity
bptest(lrent~y90+lpop+lavginc+pctstu+factor(city),data = rental_p,studentize = F)

plot(rent ~ pop, data=rental_p)
plot(lrent ~ pop, data=rental_p)
plot(lrent ~ lpop, data=rental_p)
plot(rent ~ avginc, data=rental_p)
plot(lrent ~ lavginc, data=rental_p)
plot(rent ~ pctstu, data=rental_p)
plot(lrent ~ pctstu, data=rental_p)
plot(lrent ~ , data=rental_p)
head(rental_p)
m<-cor(RENTAL)
head(round(m,2))




 






