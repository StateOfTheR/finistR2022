rm(list=ls())
library(tidyverse)
library(torch)



        #### Load the data
 


## We will just consider 2 classes of the Iris dataset (versicolor and virginica)
data("iris")
xtrain <- iris[51:150,1:4] %>% 
  {cbind(Intercept=rep(1,100),.)} %>% ## Add a column for the intercept
  as.matrix %>% ## Transform into matrix to be passed to torch
  torch_tensor
ytrain <- (iris[51:150,5]!="versicolor") %>% as.numeric %>% torch_tensor



        #### Perform a classic GLM analysis



## GLM
GLM <- glm(Species ~ ., data = iris[51:150,],family = "binomial")
Coefs <- GLM$coefficients



        #### Define the loss function



## First define the parameter
theta <- rep(0,ncol(xtrain)) %>% ## Initial value 
  torch_tensor(.,requires_grad = TRUE) ## Must track gradient to perform GD!

logistic_loss <- function(theta, x, y){
  ## Compute x_i*\theta
  odds <- torch_matmul(x, theta)
  log_lik <- torch_dot(y, odds) - torch_sum(torch_log(1 + torch_exp(odds)))
  return(-log_lik)
}

## Check
logistic_loss(theta, xtrain, ytrain)



        #### Gradient descent loop



## Define the optimization setting
# Choose the optimization procedure
theta_optimizer <- optim_adam(theta)
# Provide the number of iterations
num_iterations <- 100

## Create a vector to store the evoluation of the LogLik at each step
loss_vector <- vector("numeric", length = num_iterations)

## Write the loop
for (i in 1:num_iterations) {
  ## Set the derivatives at 0
  theta_optimizer$zero_grad()
  ## Forward
  loss <- logistic_loss(theta, xtrain, ytrain)
  ## Backward
  loss$backward()
  ## Update parameter
  theta_optimizer$step()
  ## Store the current loss for graphical display
  loss_vector[i] <- loss %>% as.numeric()
}

## Check the LogLik
plot(loss_vector)
plot(Coefs, as.numeric(theta))



        #### Refinement: optimization with lbfgs



theta.lbfgs <- rep(0,ncol(xtrain)) %>% ## Initial value 
  torch_tensor(.,requires_grad = TRUE)
theta_optimizer.lbfgs <- optim_lbfgs(theta.lbfgs)
loss_vector.lbfgs <- vector("numeric", length = num_iterations)

calc_loss <- function() {
  
  theta_optimizer.lbfgs$zero_grad()
  value <- logistic_loss(theta.lbfgs, xtrain, ytrain)
  value$backward()
  value
  
}

for (i in 1:10) {
  cat("Iteration: ", i, "\n")
  loss_vector.lbfgs[i] <- logistic_loss(theta.lbfgs, xtrain, ytrain) %>% as.numeric()
  theta_optimizer.lbfgs$step(calc_loss)
}

## Check the LogLik
plot(loss_vector.lbfgs)
plot(Coefs, as.numeric(theta.lbfgs))


        
        #### Neural network version

