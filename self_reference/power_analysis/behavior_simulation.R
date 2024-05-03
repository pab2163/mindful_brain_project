library(Matrix)
library(tidyverse)
library(simr)
library(ggrepel)
library(brms)

run_one_simulation = function(iter, mean_negative_endorse_change_difference){
  set.seed(iter)

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
  
  # Behavioral Analysis -----------------------------------------------------
  
  trial = 1:20
  valence = c('positive', 'negative')
  
  
  # 90 participants
  df_behavior = expand.grid(id = 1:45, time =time, run = run, group = group, trial = trial, valence = valence)
  df_behavior = mutate(df_behavior, id = ifelse(group == '15', id + 45, id))
  
  dropout_frame = df %>% mutate(dropout = 'no')
  
  df_behavior = left_join(df_behavior, dropout_frame, by = c('id', 'time', 'run', 'group')) %>%
    dplyr::filter(!is.na(dropout))
  
  # Pulled from "Self-Referential Processing in Depressed Adolescents: A HighDensity ERP Study" (Auerbach et al., 2015)
  mean_positive_endorse = .3
  mean_negative_endorse_pre = .6
  mean_negative_endorse_post_15 = .5
  mean_negative_endorse_post_30 = .5 - mean_negative_endorse_change_difference
  
  mean_change_negative_endorse_15 = mean_negative_endorse_post_15 - mean_negative_endorse_pre
  mean_change_negative_endorse_30 = mean_negative_endorse_post_30 - mean_negative_endorse_pre
  
  # simulate participant-level 'latent' parameters
  df_behavior = df_behavior %>%
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
  df_behavior = df_behavior %>%
    group_by(id, time, run, group, valence, trial) %>%
    mutate(endorse = rbinom(n = 1, size =1, prob = 
                              case_when(
                                time == 0 & valence == 'positive' ~ endorse_pct_pos_pre,
                                time == 0 & valence == 'negative' ~ endorse_pct_neg_pre,
                                time == 1 & valence == 'positive' ~ endorse_pct_pos_pre + change_pct_pos,
                                time == 1 & valence == 'negative' ~ endorse_pct_neg_pre + change_pct_neg,
                              ))) %>%
    ungroup()
  
  # group data for example plot
  df_behavior_summary_check = df_behavior %>%
    group_by(id, time, group, valence) %>%
    summarise(pct_endorse = sum(endorse)/n())
  
  
  p = ggplot(df_behavior_summary_check %>%
               dplyr::mutate(., time = recode(time, '1'='post', '0'=' pre')), 
             aes(x = factor(time), y = pct_endorse, color = group)) +
    stat_summary(fun.data = mean_cl_boot) +
    facet_grid(~valence)
  
  # model the simulated data (very similar syntax to brms)
  model_random_intercept_behavior <- glmmTMB::glmmTMB(endorse ~ group*time*valence + (time*valence|id), 
                                                      family = 'binomial', data=df_behavior)
  
  # output model coefficients
  model_outputs = broom.mixed::tidy(model_random_intercept_behavior)
  model_outputs$iteration = iter
  
  return(list('model_outputs'=model_outputs, 'example_plot' = p))

  
}


run_power_sim = function(n_iter, mean_negative_endorse_change_difference){
  for (i in 1:n_iter){
    output = run_one_simulation(iter=i, mean_negative_endorse_change_difference = mean_negative_endorse_change_difference)$model_outputs
    if (i ==1){
      combined_outputs = output
    }else{
      combined_outputs = rbind(combined_outputs, output)
    }
  }
  
  return(combined_outputs)
}


# Run analysis at different effect sizes
power_seq = c(seq(from =  0, to = 0.079, by = 0.04), seq(from = 0.08, to = 0.15, by = .01), seq(from = .16, to = .2, by = .02))


start_time = Sys.time()
for (effectsize in power_seq){
  power_sim_one_effect_size = run_power_sim(n_iter = 1000, mean_negative_endorse_change_difference = effectsize)
  power_sim_one_effect_size$true_effect_size = effectsize
  if (effectsize==0){
    power_out = power_sim_one_effect_size
  }else{
    power_out = rbind(power_out, power_sim_one_effect_size)
  }
}
end_time = Sys.time()
print(start_time - end_time)

# Save power simulations
write.csv(power_out, file = 'behavior_power_simulations.csv', row.names = FALSE)

