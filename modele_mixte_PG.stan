//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N_samples;
  int<lower=0> N_trees;
  matrix[N_samples, N_trees] Y;
  vector[N_samples] age;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  vector<lower=30>[N_trees] A;
  vector<lower=200>[N_trees] B;
  vector<lower=30>[N_trees] C;
  real<lower=0> sigma;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  A ~ normal(100, 10);
  B ~ normal(800, 30);
  C ~ normal(100, 10);
  sigma ~ inv_gamma(3, 1);
  for(j in 1:N_trees){
    for(i in 1:N_samples){
      Y[i, j] ~ normal(A[j] / (1 + exp(- (age[i] - B[j]) / C[j])), sigma);
    }
  }
}

