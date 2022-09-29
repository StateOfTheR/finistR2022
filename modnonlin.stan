// to be inputted b the user
data {
  int<lower=0> n;
  vector[n] y;
  vector[n] age;
}

// parameters to be sampled
parameters {
  real A;
  real B;
  real C;
  real<lower=0> sigma;
}


transformed parameters{
   vector[n] mu;
 for (i in 1:n)
  mu[i] = (A)/(1+exp(-(age[i]- B)/(C)));
}

// model for the likelihood and the priors
model {
  for (i in 1:n)
     y[i] ~ normal(mu[i], sigma);
  A ~ normal(0,100);
  B ~ normal(0,100);
  C ~ normal(0,100);
}

