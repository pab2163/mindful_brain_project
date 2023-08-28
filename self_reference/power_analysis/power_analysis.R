library(tidyverse)
library(simr)
library(EMAtools)
iter = 100
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
fixed_main = c(0, -.5)

rand_dose <- list(0.5, -0.2, 0.2)
rand_main <- list(0.5, -0.2, 0.2)

res = 1

# make initial models 
model_dose <- makeLmer(y ~ group*time + (time|id), fixef=fixed_dose, VarCorr=rand_dose, sigma=res, data=df)
model_main_effect <- makeLmer(y ~ time + (time|id), fixef=fixed_main, VarCorr=rand_main, sigma=res, data=df)

n_tests = 3
alpha_level = .05/n_tests

# Dose --------------------------------------------------------------------

effect_sizes = seq(from = -2, to = 0, by = .1)
eff_df_dose = data.frame(effect_sizes = effect_sizes)
eff_df_dose$power = NA
eff_df_dose$omega2 = NA

for (effect_size in effect_sizes){
  fixef(model_dose)['group30:time'] <- effect_size
  effsize_m = effectsize::omega_squared(model_dose)
  eff_df_dose$omega2[eff_df_dose$effect_sizes == effect_size] = effsize_m$Omega2_partial[effsize_m$Parameter =='group:time']

  sim_treat <- powerSim(model_dose, nsim=iter, test = fixed(xname='group30:time', 't'))
  eff_df_dose$power[eff_df_dose$effect_sizes == effect_size] = sum(sim_treat$pval < alpha_level)
  
}


ggplot(data = eff_df_dose, aes(x = omega2, y = power)) +
  geom_hline(yintercept = 80, lty = 2) +
  geom_line() +
  labs(x = 'Eta2 Effect Size for Group*Time Interaction\nN=90') +
  xlim(0, 0.3)



# Main Effect -------------------------------------------------------------


eff_df_main = data.frame(effect_sizes = effect_sizes)
eff_df_main$power = NA
eff_df_main$omega2 = NA

for (effect_size in effect_sizes){
  fixef(model_main_effect)['time'] <- effect_size
  effsize_m = effectsize::omega_squared(model_main_effect)
  eff_df_main$omega2[eff_df_main$effect_sizes == effect_size] = effsize_m$Omega2_partial[effsize_m$Parameter =='time']
  
  sim_treat <- powerSim(model_main_effect, nsim=iter, test = fixed(xname='time', 't'))
  eff_df_main$power[eff_df_main$effect_sizes == effect_size] = sum(sim_treat$pval < alpha_level)
  
}


ggplot(data = eff_df_main, aes(x = omega2, y = power)) +
  geom_hline(yintercept = 80, lty = 2) +
  geom_line() +
  labs(x = 'Eta2 Effect Size Time Main Effect\nN=90') +
  xlim(0, 0.5)



# See together ------------------------------------------------------------

eff_df_dose$type = 'Group X Time Interaction'
eff_df_main$type = 'Time Main Effect'


eff_df = rbind(eff_df_dose, eff_df_main)

p = ggplot(data = eff_df, aes(x = omega2, y = power/1000, color = type)) +
  geom_point() + 
  geom_hline(yintercept = .8, lty = 2) +
  geom_vline(xintercept = 0.06, lty = 2) +
  geom_vline(xintercept = 0.14, lty = 2) +
  geom_line() +
  labs(x = 'Omega-squared effect size') +
  xlim(0, 0.3)


write.csv(eff_df, file = 'effectsize_df.csv')
ggsave(p, file = 'effectsizeplot.png')

p


p1 = ggplot(data = eff_df, aes(x = -1*effect_sizes, y = power, color = type)) +
  geom_point() + 
  geom_hline(yintercept = 80, lty = 2) +
  geom_vline(xintercept = 0.2, lty = 2) +
  geom_vline(xintercept = 0.5, lty = 2) +
  geom_vline(xintercept = 0.8, lty = 2) +
  geom_line() +
  labs(x = "Effect Size (Cohen's D)")


p1

sim_treat$x

