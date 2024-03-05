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
fixed_dose = c(0, 0, -.25, -1)
rand_dose <- list(0.5, 0, .5)

# Residual variance is 1 (so fixed effects are cohen's d)
# http://jakewestfall.org/blog/index.php/2016/03/25/five-different-cohens-d-statistics-for-within-subject-designs/
res = 1

# make initial models  (outcome is automatically called y)
setup_model <- makeLmer(y ~ group*time + (time|id), fixef=fixed_dose, VarCorr=rand_dose, sigma=res, data=df)
summary(setup_model)

one_simulated_dataset = setup_model@frame

one_simulated_dataset = one_simulated_dataset %>%
  group_by(id) %>%
  mutate(head_motion_intercept = rnorm(n=1)) %>%
  ungroup() %>%
  mutate(mean_fd = rnorm(n = nrow(.), mean = head_motion_intercept, sd = .5))


fd_icc_check = lmer(data = one_simulated_dataset, mean_fd ~ 1 + (1|id))
sjPlot::tab_model(fd_icc_check)


# model looks something like this
#dmn_activation~time*dose + framewise_displacement + (time | id)

one_simulated_dataset = mutate(one_simulated_dataset, time = ifelse(time == 0, ' pre', 'post'))



model_random_slope <- brms::brm(y ~ group*time + (time|id), data=one_simulated_dataset,
                         iter=2000, cores = 4)

model_random_intercept <- brms::brm(y ~ group*time + (1|id), data=one_simulated_dataset,
                                iter=2000, cores = 4)


one_simulated_dataset = mutate(one_simulated_dataset, 
                               time_binary = ifelse(time == 'post', 1, 0))

model_random_intercept_no_dose  <- brms::brm(y ~ group:time_binary + time_binary + (1|id), data=one_simulated_dataset,
                                    iter=2000, cores = 4)

loo_random_slope = loo(model_random_slope)
loo_random_intercept = loo(model_random_intercept)

loo_compare(loo_random_slope, loo_random_intercept)

fixef(model_random_intercept)
fixef(model_random_slope)


summary(model_random_intercept_no_dose)


ggplot(data = one_simulated_dataset, aes(x = time, y = y, color = group)) +
  geom_point() +
  geom_line(aes(group = id))

raw_data_summary = one_simulated_dataset %>%
  group_by(group, time, id) %>%
  summarise(dmn_avg = mean(y))

summary(model_random_intercept_no_dose)


cond_fx = conditional_effects(model_random_intercept_no_dose)
cond_fx$`time_binary:group` %>%
  dplyr::filter(., time_binary %in% c(0, 1)) %>%
  dplyr::mutate(time = ifelse(time_binary == 0, ' pre', 'post')) %>%
  ggplot(data = ., aes(x = time, y = estimate__, color = group)) +
    geom_line(data = raw_data_summary, aes(x = time, y = dmn_avg, color = group, group = id), alpha = 0.2) +
    geom_point(position = position_dodge(0.1), size = 3) +
    geom_line(aes(group = group), position = position_dodge(0.1), lwd = 1) +
    geom_errorbar(aes(ymin = lower__, ymax = upper__), width = 0, position = position_dodge(0.1), lwd = 1) +
    labs(x = 'Time', y = 'DMN Activity', color = 'mbNF Dose') +
    theme_bw()

# Behavioral Analysis -----------------------------------------------------

trial = 1:20
valence = c('positive', 'negative')


# 90 participants
df_behavior = expand.grid(id = 1:45, time =time, run = run, group = group, trial = trial, valence = valence)
df_behavior = mutate(df_behavior, id = ifelse(group == '15', id + 45, id))

dropout_frame = df %>% mutate(dropout = 'no')

df_behavior = left_join(df_behavior, dropout_frame, by = c('id', 'time', 'run', 'group')) %>%
  dplyr::filter(!is.na(dropout))


mean_positive_endorse_pre = .3
mean_negative_endorse = .6
mean_positive_endorse_post_15 = .4
mean_positive_endorse_post_30 = .5


mean_change_positive_endorse_15 = mean_positive_endorse_post_15 - mean_positive_endorse_pre
mean_change_positive_endorse_30 = mean_positive_endorse_post_30 - mean_positive_endorse_pre


df_behavior = df_behavior %>%
  group_by(id) %>%
  mutate(endorse_pct_pos_pre = runif(n=1, min = mean_positive_endorse_pre - .2, max = mean_positive_endorse_pre + .2),
         endorse_pct_neg_pre = runif(n=1, min = mean_negative_endorse - .2, max = mean_negative_endorse + .2),
         change_pct_pos = ifelse(group == 15,
                                  runif(n=1, min = mean_change_positive_endorse_15 - .1, max = mean_change_positive_endorse_15 + .1),
                                  runif(n=1, min = mean_change_positive_endorse_30 - .1, max = mean_change_positive_endorse_30 + .1)
                                  ),
         change_pct_neg = ifelse(group == 15,
                                 runif(n=1, min = -.1, max = .1),
                                 runif(n=1, min = -.1, max = .1))) %>%
  ungroup() %>%
  group_by(id, time, run, group, valence, trial)
  mutate(endorse = rbinom(n = ))


df_behavior %>% ungroup() %>% group_by(group) %>% summarise(mean_pos_change = mean(change_pct_pos))
