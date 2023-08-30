library(tidyverse)
library(simr)
iter = 10000
# 2 timepoints: pre/post
time = 0:1

# participants randomized to 15 vs 30 min
group = c('15', '30')

# 90 participants
df = expand.grid(id = 1:45, time =time, group = group)
df = mutate(df, id = ifelse(group == '15', id + 45, id))

df = df %>%
  group_by(id) %>%
  mutate(selfrefchange = rnorm(n=1)) %>%
  ungroup()


# create 15% attrition (MCAR)
df_post=df %>%
  dplyr::filter(time == 1) %>%
  group_by(group) %>%
  top_frac(.85, wt = id)

df = dplyr::filter(df, id %in% df_post$id)

# specific starting model parameters
fixed_selfref_change = c(0, -.5, -.5, -.5, -1)
rand_selfref_change <- list(0.5)

res = 1

# make initial models 
model_selfref_change <- makeLmer(y ~ selfrefchange*time + group + (1|id), fixef=fixed_selfref_change, VarCorr=rand_selfref_change, sigma=res, data=df)

# Correct for 8 comparisons
n_tests = 8
alpha_level = .05/n_tests

# Dose --------------------------------------------------------------------

effect_sizes = seq(from = .01, to = 1.5, by = .01)
eff_df_selfref_change = data.frame(effect_sizes = effect_sizes)
eff_df_selfref_change$power = NA
eff_df_selfref_change$omega2 = NA

start_time = Sys.time()
for (effect_size in effect_sizes){
  fixef(model_selfref_change)['selfrefchange:time'] <- effect_size
  effsize_m = effectsize::omega_squared(model_selfref_change)
  eff_df_selfref_change$omega2[eff_df_selfref_change$effect_sizes == effect_size] = effsize_m$Omega2_partial[effsize_m$Parameter =='selfrefchange:time']

  sim_treat <- powerSim(model_selfref_change, nsim=iter, test = fixed(xname='selfrefchange:time', 't'))
  eff_df_selfref_change$power[eff_df_selfref_change$effect_sizes == effect_size] = sum(sim_treat$pval < alpha_level)
  
}
stop_time = Sys.time()

eff_df_selfref_change$runtime = stop_time - start_time

write.csv(eff_df_selfref_change, file = 'eff_df_selfref_change.csv', row.names = FALSE)