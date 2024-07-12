library(tidyverse)
library(simr)
library(ggrepel)
iter = 10000
# 2 timepoints: pre/post
time = 0:1

# 2 runs per timepoint
run = 1:2

# participants randomized to 15 vs 30 min
group = c('15', '30')

# 90 participants
df = expand.grid(id = 1:45, time =time, run = run, group = group)
df = mutate(df, id = ifelse(group == '15', id + 45, id))

# create 15% attrition (MCAR)
df_post=df %>%
  dplyr::filter(time == 1) %>%
  group_by(group) %>%
  top_frac(.85, wt = id)

df = rbind(df_post, dplyr::filter(df, time == 0))

df = df %>%
  group_by(id) %>%
  mutate(head_motion_intercept = rnorm(n=1)) %>%
  ungroup() %>%
  mutate(mean_fd = rnorm(n = nrow(.), mean = head_motion_intercept, sd = .5))

# specific starting model parameters
fixed_dose = c(0, -.5, -.5, -.5, 0)
rand_dose <- list(0.5)

# Residual variance is 1 (so fixed effects are cohen's d)
res = 1

# make initial models 
model_dose <- makeLmer(y ~ group*time + mean_fd + (1|id), fixef=fixed_dose, VarCorr=rand_dose, sigma=res, data=df)

# Dose --------------------------------------------------------------------

effect_sizes = seq(from = -1.1, to = -.1, by = .01)
eff_df_dose = data.frame(effect_size_cohens_d = effect_sizes)
eff_df_dose$power = NA
eff_df_dose$omega2 = NA

start_time = Sys.time()
for (effect_size in effect_sizes){
  fixef(model_dose)['group30:time'] <- effect_size
  effsize_m = effectsize::omega_squared(model_dose)
  eff_df_dose$omega2[eff_df_dose$effect_size_cohens_d == effect_size] = effsize_m$Omega2_partial[effsize_m$Parameter =='group:time']

  sim_treat <- powerSim(model_dose, nsim=iter, test = fixed(xname='group30:time', 't'))
  eff_df_dose$power[eff_df_dose$effect_size_cohens_d == effect_size] = sum(sim_treat$pval < .05)

  
}

stop_time = Sys.time()

eff_df_dose$runtime = stop_time - start_time


write.csv(eff_df_dose, file = 'powersims_dose_fx_no_random_slopes.csv')
