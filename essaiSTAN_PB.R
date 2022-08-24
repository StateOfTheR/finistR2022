load("resources/data/myOrange.Rdata")


library(rstan)
ourdat <- list(N=nrow(Orange),age=Orange$age,Y=Orange$circumference)
sm <- stan(file = "modnonlin.stan",data=ourdat, verbose=FALSE)

# to retrive the sampled parameters
sm@sim$samples[[1]]$A


library(ggmcmc)
df = ggs(sm)
df2 = dplyr::filter(df,Parameter%in%c("A","B","C","sigma"))
ggplot(df2)+geom_histogram(aes(x=value))+facet_grid(~Parameter)

# generate many plots
ggmcmc(ggs(sm))
       

### modele mixte
ourdat2 <- list(N=nrow(Orange),age=Orange$age,Y=Orange$circumference,tree=as.integer(Orange$Tree),T=length(unique(Orange$Tree)))
smmixte <- stan(file = "modnonlinmixte.stan",data=ourdat2, verbose=FALSE,
                init=rep(list(list(sigma=2,a0=10,b0=100,c0=10,A=rep(10,ourdat2$T),B=rep(50,ourdat2$T),C=rep(20,ourdat2$T))),4))
ggmcmc(ggs(smmixte))

