library(tidyverse)
library(simr)
library(ggrepel)
iter = 1000
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

# Residual variance is 1 (so fixed effects are cohen's d)
# http://jakewestfall.org/blog/index.php/2016/03/25/five-different-cohens-d-statistics-for-within-subject-designs/
res = 1

# make initial models 
model_dose <- makeLmer(y ~ group*time + (time|id), fixef=fixed_dose, VarCorr=rand_dose, sigma=res, data=df)
model_main_effect <- makeLmer(y ~ time + (time|id), fixef=fixed_main, VarCorr=rand_main, sigma=res, data=df)

n_tests = 3
alpha_level = .05/n_tests


# Main Effect -------------------------------------------------------------
effect_sizes = seq(from = -.7, to = -.1, by = .01)
eff_df_main = data.frame(effect_sizes = effect_sizes)
eff_df_main$power = NA
eff_df_main$omega2 = NA

for (effect_size in effect_sizes){
  fixef(model_main_effect)['time'] <- effect_size
  effsize_m = effectsize::omega_squared(model_main_effect)
  eff_df_main$omega2[eff_df_main$effect_sizes == effect_size] = effsize_m$Omega2_partial[effsize_m$Parameter =='time']
  
  sim_treat <- powerSim(model_main_effect, nsim=iter, test = fixed(xname='time', 't'))
  eff_df_main$power[eff_df_main$effect_sizes == effect_size] = sum(sim_treat$pval < alpha_level)
  eff_df_main$power_uncorrected[eff_df_main$effect_sizes == effect_size] = sum(sim_treat$pval < .05)
  
  
}

# Dose --------------------------------------------------------------------

effect_sizes = seq(from = -1.1, to = -.1, by = .01)
eff_df_dose = data.frame(effect_sizes = effect_sizes)
eff_df_dose$power = NA
eff_df_dose$omega2 = NA

for (effect_size in effect_sizes){
  fixef(model_dose)['group30:time'] <- effect_size
  effsize_m = effectsize::omega_squared(model_dose)
  eff_df_dose$omega2[eff_df_dose$effect_sizes == effect_size] = effsize_m$Omega2_partial[effsize_m$Parameter =='group:time']

  sim_treat <- powerSim(model_dose, nsim=iter, test = fixed(xname='group30:time', 't'))
  eff_df_dose$power[eff_df_dose$effect_sizes == effect_size] = sum(sim_treat$pval < alpha_level)
  eff_df_dose$power_uncorrected[eff_df_dose$effect_sizes == effect_size] = sum(sim_treat$pval < .05)
  
  
}

# See together ------------------------------------------------------------

eff_df_dose$type = 'Aim 2A'
eff_df_main$type = 'Aim 1A'


eff_df = rbind(eff_df_dose, eff_df_main)

write.csv(eff_df, file = 'power_sims_aims1_2.csv')
eff_df = read_csv('power_sims_aims1_2.csv')


eff_df$power = eff_df$power / iter
eff_df$power_uncorrected = eff_df$power_uncorrected / iter


eff_df = eff_df %>%
  pivot_longer(c(power, power_uncorrected)) %>%
  mutate(hyp = case_when(
    type == 'Aim 2A' & name == 'power_uncorrected' ~ 'Aim 2B',
    type == 'Aim 2A' & name == 'power' ~ 'Aim 2A',
    type == 'Aim 1A' & name == 'power_uncorrected' ~ 'Aim 1B',
    type == 'Aim 1A' & name == 'power' ~ 'Aim 1A',
  )) %>%
  dplyr::select(power=value, everything())


eff_df_closest_80 = dplyr::filter(eff_df, power >= 0.8) %>%
  group_by(hyp) %>%
  top_n(n = 1, wt = -1*power) %>%
  mutate(descript = paste0(hyp, '\nd~=', -1*effect_sizes))


power_plot_1 = ggplot(data = eff_df, aes(x = -1*effect_sizes, y = power, color = hyp)) +
  geom_rect(ymin = -Inf, ymax = 0, xmin = -Inf, xmax = 0.2, aes(fill = 'Very Small'), alpha = 0.05, color = 'black') +
  geom_rect(ymin = -Inf, ymax = 0., xmin = 0.8, xmax = Inf, aes(fill = 'Large'), alpha = 0.05, color = 'black') +
  geom_rect(ymin = -Inf, ymax = 0, xmin = 0.2, xmax = 0.5, aes(fill = 'Small'), alpha = 0.05, color = 'black') +
  geom_rect(ymin = -Inf, ymax = 0, xmin = 0.5, xmax = 0.8, aes(fill = 'Medium'), alpha = 0.05, color = 'black')  +
  #geom_point(size = 2) + 
  geom_hline(yintercept = .80, lty = 2) +
  geom_vline(data = eff_df_closest_80, mapping = aes(xintercept = -1*effect_sizes,
             color=hyp), lwd = 1, lty =2, show.legend = FALSE) +
  geom_line(lwd = 1) +
  geom_label_repel(data = eff_df_closest_80, nudge_x = 0.2, nudge_y = -.1,
                 aes(label = descript), show.legend = FALSE) +
  labs(x = "Effect Size (Cohen's d)", y = 'Power', color = 'Aim') +
  theme_bw() +
  scale_fill_manual(values = c('gray45', 'gray60', 'gray75', 'white')) +
  scale_color_viridis_d(end = 0.8, 
                        labels = c('Aim 1A: Pre > post change in DMN activation',
                                   'Aim 1B: Pre > post change in negative self-referential bias',
                                   'Aim 2A: Dose effect on pre > post change in DMN activation',
                                   'Aim 2B: Dose effect on pre > post change in negative self-referential bias'),
                        breaks = c('Aim 1A','Aim 1B','Aim 2A','Aim 2B')) +
  scale_y_continuous(breaks = seq(from = 0, to = 1, by = .1)) +
  scale_x_continuous(breaks = seq(from = 0.1, to = 1, by = .1)) +
  guides(fill = 'none', label = 'none',
         color = guide_legend(nrow=4, byrow = TRUE)) + 
  theme(legend.position = 'bottom') 


power_plot_1

