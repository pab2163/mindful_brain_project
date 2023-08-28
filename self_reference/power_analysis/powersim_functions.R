simulate_one_run = function(id, run_num, time, prop_pos, prop_neg, n_trials, group){
  trial_df = data.frame(trial=1:n_trials)
  trial_df = mutate(trial_df, condition = c(rep('pos', n_trials/2), rep('neg', n_trials/2)))
  trial_df = trial_df %>%
    group_by(trial, condition) %>%
    mutate(endorse = case_when(
      condition == 'pos' ~ rbinom(n =1, size = 1, prob = prop_pos),
      condition == 'neg' ~ rbinom(n =1, size = 1, prob = prop_neg),
    )) %>%
    ungroup()
  
  trial_df=mutate(trial_df, 
                  id = id,
                  run=run_num,
                  time=time,
                  group=group)
  return(trial_df)
  
}


winsor_0_1 = Vectorize(function(x){
  if (x < 0){
    out = 0
  }else if(x>1){
    out = 1
  }else{
    out = x
  }
  return(out)
})

simulate_study = function(effect_size_negative, effect_size_dose, iter, param){
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
  
  mean_neg_prop = .6
  mean_pos_prop = .4
  sd_pos_prop = .2
  sd_neg_prop = .2
  mean_prop_pos_change = 0
  sd_prop_pos_change = .025
  mean_prop_neg_change = effect_size_negative
  sd_prop_neg_change = .05
  
  df = df %>%
    mutate(a = 1) %>%
    pivot_wider(id_cols = c('id', 'run', 'group'), names_from = 'time', values_from = 'a')   %>%
    group_by(id, group) %>%
    mutate(., prop_pos_pre = rnorm(n = 1, mean_pos_prop, sd_pos_prop),
           prop_neg_pre = rnorm(n = 1, mean_neg_prop, sd_neg_prop),
           prop_pos_post = prop_pos_pre + rnorm(n = 1, mean_prop_pos_change, sd_prop_pos_change),
           prop_neg_post = ifelse(group == '15',
                                  prop_neg_pre + rnorm(n = 1, mean_prop_neg_change, sd_prop_neg_change),
                                  prop_neg_pre + rnorm(n = 1, mean_prop_neg_change + effect_size_dose, sd_prop_neg_change))) 
  
  
  
  df = mutate(df,
              prop_pos_pre = winsor_0_1(prop_pos_pre),
              prop_neg_pre = winsor_0_1(prop_neg_pre),
              prop_pos_post = winsor_0_1(prop_pos_post),
              prop_neg_post = winsor_0_1(prop_neg_post))
  
  for (row in 1:nrow(df)){
    if (row ==1){
      all_trials_df = simulate_one_run(id = df$id[row], 
                                       run_num = df$run[row],
                                       time=0, 
                                       prop_pos = df$prop_pos_pre[row],
                                       prop_neg = df$prop_neg_pre[row],
                                       n_trials = 24,
                                       group=df$group[row])
      all_trials_df = rbind(all_trials_df, 
                            simulate_one_run(id = df$id[row], 
                                             run_num = df$run[row],
                                             time=1, 
                                             prop_pos = df$prop_pos_post[row],
                                             prop_neg = df$prop_neg_post[row],
                                             n_trials = 24,
                                             group=df$group[row]))
    }
    else{
      all_trials_df = rbind(all_trials_df, 
                            simulate_one_run(id = df$id[row], 
                                             run_num = df$run[row],
                                             time=0, 
                                             prop_pos = df$prop_pos_pre[row],
                                             prop_neg = df$prop_neg_pre[row],
                                             n_trials = 24,
                                             group=df$group[row]))
      all_trials_df = rbind(all_trials_df, 
                            simulate_one_run(id = df$id[row], 
                                             run_num = df$run[row],
                                             time=1, 
                                             prop_pos = df$prop_pos_post[row],
                                             prop_neg = df$prop_neg_post[row],
                                             n_trials = 24,
                                             group=df$group[row])) 
    }
  }
  
  no_fu = dplyr::filter(df, is.na(`1`))
  all_trials_df = dplyr::filter(all_trials_df, time==0 | !id %in% no_fu$id)
  
  if (param == 'time'){
    model = lme4::glmer(data = all_trials_df, endorse ~ condition*time + (condition*time|id),
                        family = binomial(link = 'logit'))
    model_summary = summary(model)

    outframe = data.frame(model_summary$coefficients)
    outframe$iter = iter
    outframe$term = row.names(outframe)
    outframe$true_effect_size = effect_size_negative
  }else if (param == 'time:dose'){
    model = lme4::glmer(data = all_trials_df, endorse ~ condition*time*group + (condition*time|id),
                        family = binomial(link = 'logit'))
    
    model_summary = summary(model)
    outframe = data.frame(model_summary$coefficients)
    outframe$iter = iter
    outframe$term = row.names(outframe)
    outframe$true_effect_size = effect_size_dose
    
  }
  return(list('model_summary'=outframe))
  
}

