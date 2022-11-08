# Code downloaded from
# https://quantscience.rbind.io/2020/02/04/bayesian-mlm-with-group-mean-centering/#group-mean-centering-treating-group-means-as-latent-variables
# Downloaded 2022-11-08
data { 
  int<lower=1> N;  // total number of observations 
  int<lower=1> J;  // number of clusters
  int<lower=1, upper=J> gid[N]; 
  vector[N] y;  // response variable 
  int<lower=1> K;  // number of population-level effects 
  matrix[N, K] X;  // population-level design matrix 
  int<lower=1> q;  // index of which column needs group mean centering
} 
transformed data { 
  int Kc = K - 1; 
  matrix[N, K - 1] Xc;  // centered version of X 
  vector[K - 1] means_X;  // column means of X before centering
  vector[N] xc;  // the column of X to be decomposed
  for (i in 2:K) { 
    means_X[i - 1] = mean(X[, i]); 
    Xc[, i - 1] = X[, i] - means_X[i - 1]; 
  } 
  xc = Xc[, q - 1];
} 
parameters { 
  vector[Kc] b;  // population-level effects at level-1
  real bm;  // population-level effects at level-2
  real b0;  // intercept (with centered variables)
  real<lower=0> sigma_y;  // residual SD 
  real<lower=0> tau_y;  // group-level standard deviations 
  vector[J] eta_y;  // normalized group-level effects of y
  real<lower=0> sigma_x;  // residual SD 
  real<lower=0> tau_x;  // group-level standard deviations 
  vector[J] eta_x;  // normalized latent group means of x
} 
transformed parameters { 
  // group means for x
  vector[J] theta_x = tau_x * eta_x;  // group means of x
  // group-level effects 
  vector[J] theta_y = b0 + tau_y * eta_y + bm * theta_x;  // group intercepts of y
  matrix[N, K - 1] Xw_c = Xc;  // copy the predictor matrix
  Xw_c[ , q - 1] = xc - theta_x[gid];  // group mean centering
} 
model {
  // prior specifications 
  b ~ normal(0, 10); 
  bm ~ normal(0, 10); 
  sigma_y ~ student_t(3, 0, 10); 
  tau_y ~ student_t(3, 0, 10); 
  eta_y ~ std_normal(); 
  sigma_x ~ student_t(3, 0, 10); 
  tau_x ~ student_t(3, 0, 10); 
  eta_x ~ std_normal(); 
  xc ~ normal(theta_x[gid], sigma_x);  // prior for lv-1 predictor
  // likelihood contribution 
  y ~ normal(theta_y[gid] + Xw_c * b, sigma_y); 
} 
generated quantities {
  // contextual effect
  real b_contextual = bm - b[q - 1];
}