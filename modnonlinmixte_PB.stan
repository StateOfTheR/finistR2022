// to be inputted by the user
data {
  int<lower=0> T; //nb of trees
  int<lower=0> N;
  vector[N] Y;
  vector[N] age;
  int tree[N];
}

// sampled parameters 
parameters {
  vector[T] A;
  vector[T] B;
  vector[T] C;
  real<lower=0> sigma;
  real<lower=0> a0;
  real<lower=0> b0;
  real<lower=0> c0;
  real<lower=0> siga;
  real<lower=0> sigb;
  real<lower=0> sigc;
}


model {
   vector[N] mu;
 for (i in 1:N)
  mu[i] = (A[tree[i]])/(1+exp(-(age[i]- B[tree[i]])/(C[tree[i]])));
  for (i in 1:N)
     Y[i] ~ normal(mu[i], sigma);
  for (i in 1:T){
  A[i] ~ normal(a0,siga);
  B[i] ~ normal(b0,sigb);
  C[i] ~ normal(c0,sigc);}
  sigma ~ exponential(1);

}

