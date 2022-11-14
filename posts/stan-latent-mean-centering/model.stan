data{
    int N;
    int M; // Number of respondents

    vector[N] urge_t;
    vector[N] urge_tm1;
    vector[N] dep_t; 
    // array[N] int<lower = 1, upper = M> I; # Error
    int<lower = 1, upper = M> I;
}
parameters{
    // Urge
    real alpha_u0;
    vector[M] alpha_ui_raw;
    real<lower = 0> gamma_au;

    // Depression
    real alpha_d0;
    vector[M] alpha_di_raw;
    real<lower = 0> gamma_ad;

    // Autoregressive effect
    real phi_0;
    vector[M] phi_i_raw;
    real<lower = 0> gamma_f;

    // Effect of depression deviation
    real beta_0;
    vector[M] beta_i_raw;
    real<lower = 0> gamma_b;

    // Residiual sd
    real<lower = 0> sigma_u;
    real<lower = 0> sigma_d;

    // Covariance structure
    // Add in eventually
}
model{
    vector[M] alpha_ui = alpha_u0 + alpha_ui_raw * gamma_au;
    vector[M] alpha_di = alpha_d0 + alpha_di_raw * gamma_ad;
    vector[M] phi_i = phi_0 + phi_i_raw * gamma_f;
    vector[M] beta_i = beta_0 + beta_i_raw * gamma_b;
    vector[N] urge_tm1_center = urge_tm1 - alpha_ui[I];
    vector[N] dep_t_center = dep_t - alpha_di[I];

    // Priors
    alpha_ui_raw ~ normal(0, 1);
    alpha_di_raw ~ normal(0, 1);
    phi_i_raw ~ normal(0, 1);
    beta_i_raw ~ normal(0, 1);

    // Model
    dep_t ~ normal(alpha_di[I], sigma_d);
    urge_t ~ normal(alpha_ui[I] + phi_i[I] .* urge_tm1_center + beta_i[I] .* dep_t_center, sigma_u);
}
generated quantities{
    real alpha_mu = alpha_u0;
    real alpha_var = gamma_au^2;
    real dep_mu = alpha_d0;
    real dep_var = gamma_ad^2;
    real phi_mu = phi_0;
    real phi_var = gamma_f^2;
    real beta_mu = beta_0;
    real beta_var = gamma_b^2;
    real sigma = sigma_u;
}