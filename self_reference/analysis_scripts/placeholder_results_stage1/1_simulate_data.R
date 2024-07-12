# Simulate Data for Placeholder Results Section for Stage 1 Registered Report
# Paul Alexander Bloom, May 3 2024

library(Matrix)
library(tidyverse)
library(simr)
library(ggrepel)
library(brms)
set.seed(1)

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
fixed_dose = c(1.5, 0, -.25, -1)
rand_dose <- list(0.5, 0, .5)

# Residual variance is 1 (so fixed effects are cohen's d)
res = 1

# make initial models  (outcome is automatically called y)
set.seed(1)
setup_model_mpfc <- makeLmer(mpfc ~ group*time + (time|id), fixef=fixed_dose, VarCorr=rand_dose, sigma=res, data=df)
one_simulated_brain_dataset = setup_model_mpfc@frame

one_simulated_brain_dataset = one_simulated_brain_dataset %>%
  group_by(id) %>%
  mutate(head_motion_intercept = rnorm(n=1)) %>%
  ungroup() %>%
  mutate(mean_fd = rnorm(n = nrow(.), mean = head_motion_intercept, sd = .5),
         pcc = rnorm(n = nrow(.), mean = mpfc, sd = 0.3))


one_simulated_brain_dataset = mutate(one_simulated_brain_dataset, time = ifelse(time == 0, ' pre', 'post'))

# Behavioral Analysis -----------------------------------------------------

trial = 1:20
valence = c('positive', 'negative')

# 90 participants
one_simulated_behavior_dataset = expand.grid(id = 1:45, time =time, run = run, group = group, trial = trial, valence = valence)
one_simulated_behavior_dataset = mutate(one_simulated_behavior_dataset, id = ifelse(group == '15', id + 45, id))

dropout_frame = df %>% mutate(dropout = 'no')

one_simulated_behavior_dataset = left_join(one_simulated_behavior_dataset, dropout_frame, by = c('id', 'time', 'run', 'group')) %>%
  dplyr::filter(!is.na(dropout))

# Pulled from "Self-Referential Processing in Depressed Adolescents: A HighDensity ERP Study" (Auerbach et al., 2015)
mean_positive_endorse = .3
mean_negative_endorse_pre = .6
mean_negative_endorse_post_15 = .5
mean_negative_endorse_post_30 = .38

mean_change_negative_endorse_15 = mean_negative_endorse_post_15 - mean_negative_endorse_pre
mean_change_negative_endorse_30 = mean_negative_endorse_post_30 - mean_negative_endorse_pre

# simulate participant-level 'latent' parameters
one_simulated_behavior_dataset = one_simulated_behavior_dataset %>%
  group_by(id) %>%
  mutate(endorse_pct_pos_pre = runif(n=1, min = mean_positive_endorse - .2, max = mean_positive_endorse + .2),
         endorse_pct_neg_pre = runif(n=1, min = mean_negative_endorse_pre - .2, max = mean_negative_endorse_pre + .2),
         change_pct_neg = ifelse(group == 15,
                                 runif(n=1, min = mean_change_negative_endorse_15 - .1, max = mean_change_negative_endorse_15 + .1),
                                 runif(n=1, min = mean_change_negative_endorse_30 - .1, max = mean_change_negative_endorse_30 + .1)
         ),
         change_pct_pos = runif(n=1, min = -.1, max = .1)) %>%
  ungroup() 

# then use them to simulate trial-level data
one_simulated_behavior_dataset = one_simulated_behavior_dataset %>%
  group_by(id, time, run, group, valence, trial) %>%
  mutate(endorse = rbinom(n = 1, size =1, prob = 
                            case_when(
                              time == 0 & valence == 'positive' ~ endorse_pct_pos_pre,
                              time == 0 & valence == 'negative' ~ endorse_pct_neg_pre,
                              time == 1 & valence == 'positive' ~ endorse_pct_pos_pre + change_pct_pos,
                              time == 1 & valence == 'negative' ~ endorse_pct_neg_pre + change_pct_neg,
                            ))) %>%
  ungroup()

save(one_simulated_behavior_dataset, one_simulated_brain_dataset, file = 'simuldated_datasets_for_placeholder_results.rda')





