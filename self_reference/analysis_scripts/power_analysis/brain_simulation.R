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


# specific starting model parameters
fixed_dose = c(0, -.5, -.5, -.5)
rand_dose <- list(0.5, -0.2, 0.2)

# Residual variance is 1 (so fixed effects are cohen's d)
# http://jakewestfall.org/blog/index.php/2016/03/25/five-different-cohens-d-statistics-for-within-subject-designs/
res = 1

# make initial models 
model_dose <- makeLmer(y ~ group*time + (time|id), fixef=fixed_dose, VarCorr=rand_dose, sigma=res, data=df)


# Correct the alpha level for tests of 2 neural ROIs
n_tests = 2
alpha_level = .05/n_tests

# Dose x Time Interactions  --------------------------------------------------------------------

# For a range of effect sizes, run a power simulation using simr::powerSim()
effect_sizes = seq(from = -1.1, to = -.1, by = .01)
eff_df_dose = data.frame(effect_sizes = effect_sizes)
eff_df_dose$power = NA
eff_df_dose$omega2 = NA

start_time = Sys.time()
for (effect_size in effect_sizes){
  fixef(model_dose)['group30:time'] <- effect_size
  effsize_m = effectsize::omega_squared(model_dose)
  eff_df_dose$omega2[eff_df_dose$effect_sizes == effect_size] = effsize_m$Omega2_partial[effsize_m$Parameter =='group:time']
  sim_treat <- powerSim(model_dose, nsim=iter, test = fixed(xname='group30:time', 't'))
  eff_df_dose$power[eff_df_dose$effect_sizes == effect_size] = sum(sim_treat$pval < alpha_level)
  eff_df_dose$power_uncorrected[eff_df_dose$effect_sizes == effect_size] = sum(sim_treat$pval < .05)

}

# Calculate Run Time
stop_time = Sys.time()
eff_df_dose$runtime = stop_time - start_time
write.csv(eff_df_dose, file = 'brain_power_simulation.csv')
