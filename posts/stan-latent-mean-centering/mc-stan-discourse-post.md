Hi all,

>I am trying to **latent cluster-mean center** my predictors in a multilevel model instead of using the observed means to center them, in order to avoid bias in the resulting parameter estimates. 

(If we're able to solve this, I'd write it up properly and submit to [AMPPS](https://www.psychologicalscience.org/publications/ampps) as a practical tutorial, and I'd be more than happy to have coauthors! 😃 I have a longer blog post draft exploring this, massively WIP but with code and data, [here](https://mvuorre.github.io/posts/stan-latent-mean-centering/))

## Background

The issue relates to centering observed predictor variables in hierarchical models of multiple people's data in order to separate within-people and between-people associations. If one uses the raw values of observed predictors in hierarchical models, the resulting coefficients will be mixtures of within- and between-person associations. This is not optimal because psychologists, like me, like to know what is going on *within a person*. As a solution, psychologists have long known to person-mean center their variables in order to study within-person (causal) processes that are isolated from between-person associations (e.g. [Enders and Tofighi, 2007](https://sci-hub.wf/10.1037/1082-989x.12.2.121)).

However, especially if you have few observations per person, centering on the *observed* mean will bias your parameter estimates, because the actual mean is not an observed thing but rather a latent quantity that should be appropriately estimated. The solution to this, *latent* person-mean centering ([Asparouhov & Muthen, 2010](https://www.tandfonline.com/doi/full/10.1080/10705511.2018.1511375), [McNeish & Hamaker, 2020](https://osf.io/j56bm/download)), is available in the commercial MPlus software. 

The problem with this is, of course, that ~~it's not in Stan~~ ~~it's not in brms~~ most people don't have access to MPlus because it is not FOSS. My goal is to figure out how to latent mean center predictor variables in hierarchical models of longitudinal data with brms, so that the procedure, which provides unbiased estimates, would be available to as many researchers as possible.

## Analysis

Say I have many measurements over time from many individuals on their `urge` to smoke and `dep`ression, and I am interested in how depression and urge to smoke on a previous occasion predict the urge to smoke *within-person*. Here's some data from [McNeish & Hamaker, 2020](https://osf.io/j56bm/download) (my [blog](https://mvuorre.github.io/posts/stan-latent-mean-centering/) code loads and processes this automatically in R if you'd like to follow along):

|person|time|urge|dep|
|---|---|---|---|
|1|1|0.34|0.43|
|1|2|-0.48|-0.68|
|1|3|-4.44|-1.49|
|1|4|-4.19|-0.74|
|1|5|-0.91|-0.52|
|2|1|1.65|0.68|
|2|2|0.31|1.49|
|2|3|0.46|0.03|
|2|4|-1.09|-1.02|
|2|5|1.67|1.07|

(Just showing a few observations for 2 people in that table.) A knee-jerk multilevel model of this is 

$$
\begin{align*}
\text{Urge}_{ti} &\sim N(\mu_{ti}, \sigma^2), \\
\mu_{ti} &= \bar{\alpha} + \alpha_i + (\bar{\varphi}+\varphi_i)\text{Urge}_{(t-1)i} + (\bar{\beta} + \beta_i)\text{Dep}_{ti}, \\
(\alpha_i, \varphi_i, \beta_i) &\sim MVN(\pmb{0}, \Sigma),
\end{align*}
$$ 

where Urge $_{ti}$ is the urge to smoke at time *t* for person *i*. We then have population-level effects (those with bars) and person-specific deviations (without bars). As noted above, if we use the observed Urge $(t-1)_{ti}$ and Depression $_{ti}$, the resulting parameter estimates will be biased. (Specifically, they will suffer from Nickell's (negative bias in autoregressive effects) and Lüdtke's (bias in other time-varying effects) biases [[McNeish & Hamaker, 2020](https://osf.io/j56bm/download)].)

*Latent* mean centering pivots on recognizing that ([McNeish & Hamaker, 2020](https://osf.io/j56bm/download), p. 618)

$$
\begin{align*}
\text{Urge}^n_{(t-1)i} &= \text{Urge}^c_{(t-1)i} + \text{Urge}^b_i, \\
\text{Dep}^n_{ti} &= \text{Dep}^c_{ti} + \text{Dep}^b_i:
\end{align*}
$$

The observed values of urge to smoke (on a previous occasion) and depression are sums of the latent person means (with superscripts b) and their occasion-level deviations (superscripts c).

## Code

In case you didn't notice, I am following the MPlus tutorial of [McNeish & Hamaker, 2020](https://osf.io/j56bm/download), whose MPlus code for this model is here. It is not at all transparent to me, but maybe someone understands it:

![image|690x181, 60%](upload://rrNzklsY4idbAmjiKmC1PtN8m4o.png)
![image|419x499](upload://lAm6hQftuMthJcwuk1oVJECbRQy.png)

I have tried to replicate this in brms with the following code ([see my blog for reproducible code](https://mvuorre.github.io/posts/stan-latent-mean-centering/)):

```r
m4_data <- d %>% 
  # Create lagged variable
  group_by(person) %>% 
  mutate(urge1 = lag(urge)) %>% 
  ungroup()

m4_latent_formula <- bf(
  urge ~ alpha + phi*(urge1 - alpha) + beta*(dep - depb),
  alpha ~ 1 + (1 | person),  # Latent intercept of urge
  # urge1b ~ 1 + (1 | person),  # This is alpha! Weird & awesome (M&H2020 p.618)
  depb ~ 1 + (1 | person),  # Latent mean of depression
  phi ~ 1 + (1 | person),  # Slope of latent mean-person centered lagged urge on urge
  beta ~ 1 + (1 | person),  # Slope of latent mean-person centered depression on urge
  nl = TRUE
) +
  gaussian()

# Hacky way to set some pretty random priors
p <- get_prior(m4_latent_formula, data = m4_data) %>% 
  mutate(
    prior = case_when(
      class == "b" & coef == "Intercept" ~ "normal(0, 0.75)",
      class == "sd" & coef == "Intercept" ~ "student_t(7, 0, 0.5)",
      TRUE ~ prior
    )
  )

m4_latent <- brm(
  m4_latent_formula,
  data = m4_data,
  prior = p,
  control = list(adapt_delta = 0.99),
  file = "m4_latent"
)
```

(I specified the above code based on @martinmodrak's suggestion [here](https://discourse.mc-stan.org/t/modeling-latent-means-in-brms-for-multilevel-group-mean-centering/12642/4). I haven't used 

## Footnote

This issue has been discussed here before, with no resolution:
https://discourse.mc-stan.org/t/treat-the-cluster-mean-of-a-predictor-variable-as-a-latent-variable-hierarchical-linear-models/15001/5

https://discourse.mc-stan.org/t/modeling-latent-means-in-brms-for-multilevel-group-mean-centering/12642/3


