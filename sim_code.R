# Study how correlation between coverage propensity (CP) and response propensity (RP) affects response rate (RR)
# Survey A -- correlation bw CP, RP exists
# Survey B -- increase in CP
# compare coverage rate (CR) and RR in two surveys

# rm(list=ls())

setwd("C:\\Users\\stephnie\\Dropbox\\papers\\TSE15 Nonresponse Undercoverage\\simulations\\")

require(MASS)
require(sampling)
require(doBy)
require(foreign)

set.seed(20150215)

popobs <- 1000000
sampobs <- 1000
sims <- 1000

# make pop data frame
pop.fn <- function(corr, cpincrease, bx, bz, gx, gz) {
  # corr -- correlation between CPa, CPb (correlation in continuous variables)
  # cpincrease -- how much CPs increase in survey B compared to survey A
  # bx -- coeff on X in reg to create Y
  # bz -- coeff on Z in reg to create Y
  # gx -- coeff on X in reg to create CP
  # gz -- coeff on Z in reg to create RP
  
  # draw X,Z from multivar normal
  sigma <- matrix(c(1, corr, corr, 1), nrow=2, ncol=2)
  dt <- data.frame(mvrnorm(n = popobs, c(0,0), sigma))
  names(dt) <- c("x", "z")
  
  # make CPs and RP
  dt$cpa <- exp(1+gx*dt$x)/(1+exp(1+gx*dt$x))
  dt$cpb <- exp(1+gx*dt$x+cpincrease)/(1+exp(1+gx*dt$x+cpincrease))
  dt$rpa <- exp(1+gz*dt$z)/(1+exp(1+gz*dt$z))
  
  # make Y -- check error term here
  dt$y <- 10 + bx*dt$x + bz*dt$z + rnorm(popobs)
  
  dt
}

# select samples and aggregate over them
samp.fn <- function(popdata) {
  # corr -- correlation between CPa, CPb (correlation in continuous variables)
  # cpincrease -- how much CPs increase in survey B compared to survey A
  # bx -- coeff on X in reg to create Y
  # bz -- coeff on Z in reg to create Y
  # gx -- coeff on X in reg to create CP
  # gz -- coeff on Z in reg to create RP
  
  
  # to store results of all the samples on this pop
  samp.results <- data.frame()
  
  for (s in 1:sims) {
    
    samp <- popdata[srswor(sampobs, popobs)==1,]
    
    samp$crand <- runif(sampobs)
    samp$cova <- as.numeric((samp$crand < samp$cpa))
    samp$covb <- as.numeric((samp$crand < samp$cpb))
    samp$rrand <- runif(sampobs)
    samp$respa <- as.numeric((samp$rrand < samp$rpa))
    samp$respa[samp$cova == 0] <- NA    # response should be missing if not covered
    samp$respb <- as.numeric((samp$rrand < samp$rpa))
    samp$respb[samp$covb == 0] <- NA    # response should be missing if not covered
    
    # get y values observed in survey A, survey B
    
    # delete y when not covered or nonresponder
    samp$ya <- samp$y
    samp$ya[samp$cova == 0] <- NA    # ya should be missing if not covered
    samp$ya[samp$respa == 0] <- NA    # ya should be missing if nonresponder
    
    samp$yb <- samp$y
    samp$yb[samp$covb == 0] <- NA    # ya should be missing if not covered
    samp$yb[samp$respb == 0] <- NA    # ya should be missing if nonresponder
    
    samp.corr <- cor(samp,use="pairwise.complete.obs")
    
    samp.results <- rbind(samp.results,
                          cbind(summaryBy(cova + covb + respa + respb + ya + yb ~ 1, FUN=c(mean), data=samp, na.rm=TRUE),
                                samp.corr[13,3],samp.corr[14,4],samp.corr[13,5],samp.corr[14,5]))
  }
  
  sapply(samp.results, mean)
}     

# create population according to parameters and send to sample.fn
# return results for this pop
sim.fn <- function(ps) {
  # make population according to these settings
  popdt <- pop.fn(ps[1,1], ps[1,2], ps[1,3],ps[1,4],ps[1,5],ps[1,6])
  
  corr <- cor(popdt, use="pairwise.complete.obs")
  
  c(ps[1,], mean(popdt$y), samp.fn(popdt), corr[3,5], corr[4,5], corr[3,4])
}


# set up list of all possible combos of parameters
i <- 1
p <- list()

# p1: corr -- correlation between CPa, CPb (correlation in continuous variables)
# p2: cpincrease -- how much CPs increase in survey B compared to survey A
# p3: bx -- coeff on X in reg to create Y
# p4: bz -- coeff on Z in reg to create Y
# p5: gx -- coeff on X in reg to create CP
# p6: gz -- coeff on Z in reg to create RP
for (p1 in c(0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1)) {
  for (p2 in seq(1,10, by = 1)) {
    for (p3 in c(-2,-.2,.2,2)) {
      for (p4 in c(-2,-.2,.2,2))  {
        for (p5 in c(.2,2))  {
          for (p6 in c(.2,2))  {
            
            p[[i]] = cbind(p1,p2,p3,p4,p5,p6)
            
            i <- i+1
          }
        }
      }
    }
  }
}

# apply sim.fn to list of all parameter combos
# returns results matrix for all combox
results <- sapply(p, FUN=sim.fn)

# make results matrix pretty
results <- as.data.frame(t(results))
names(results) <- c("p1","p2","p3","p4","p5","p6", "y.mean",
                        "cova.mean","covb.mean","respa.mean","respb.mean","ya.mean","yb.mean",
                        "corr_cpa_y","corr_cpb_y","corr_rpa_y","corr_rpb_y",                 
                        "corr_cpa_rpa","corr_cpb_rpa","corr_cpa_cpb")



# save results data frame, as R and Stata
save(results, file="results11.Rdata")
write.dta(results, file="results11.dta")

save.image(file="sims11.RData")
