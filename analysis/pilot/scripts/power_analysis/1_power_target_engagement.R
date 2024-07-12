library(Matrix)
library(tidyverse)
library(simr)
library(ggrepel)
library(EMAtools)
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
fixed_main = c(0, -.5, 0)
rand_main <- list(0.5, -0.2, 0.2)

# Residual variance is 1 (so fixed effects are cohen's d)
res = 1

# make initial models 
model_main_effect <- makeLmer(y ~ time + mean_fd + (time|id), fixef=fixed_main, VarCorr=rand_main, sigma=res, data=df)
cohens_d_ematools = EMAtools::lme.dscore(mod = model_main_effect, data = model_main_effect@frame, type = 'lme4')[1, 3]

# Main Effect -------------------------------------------------------------
effect_sizes = seq(from = -.7, to = -.1, by = .01)
eff_df_main = data.frame(effect_size_cohens_d = effect_sizes)
eff_df_main$cohens_d_ematools = NA
eff_df_main$power = NA
eff_df_main$omega2 = NA

start_time = Sys.time()

for (effect_size in effect_sizes){
  #fixef(model_main_effect)['time'] <- effect_size
  fixed_main = c(0, effect_size, 0)
  model_main_effect <- makeLmer(y ~ time + mean_fd + (time|id), fixef=fixed_main, VarCorr=rand_main, sigma=res, data=df)
  effsize_m = effectsize::omega_squared(model_main_effect)
  eff_df_main$cohens_d_ematools[eff_df_main$effect_size_cohens_d == effect_size] = 
    EMAtools::lme.dscore(mod = model_main_effect, data = model_main_effect@frame, type = 'lme4')[1, 3]
  eff_df_main$omega2[eff_df_main$effect_size_cohens_d == effect_size] = effsize_m$Omega2_partial[effsize_m$Parameter =='time']
  sim_treat <- powerSim(model_main_effect, nsim=iter, test = fixed(xname='time', 't'))
  eff_df_main$power[eff_df_main$effect_size_cohens_d == effect_size] = sum(sim_treat$pval < .05)/iter
}


stop_time = Sys.time()

eff_df_main$runtime = stop_time - start_time
write.csv(eff_df_main, file = 'powersims_target_engagement.csv')

