library(tidyverse)
library(simr)
iter = 1000
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

n_tests = 8
alpha_level = .05/n_tests

# Dose --------------------------------------------------------------------

effect_sizes = seq(from = .01, to = 1.5, by = .1)
eff_df_selfref_change = data.frame(effect_sizes = effect_sizes)
eff_df_selfref_change$power = NA
eff_df_selfref_change$omega2 = NA

for (effect_size in effect_sizes){
  fixef(model_selfref_change)['selfrefchange:time'] <- effect_size
  effsize_m = effectsize::omega_squared(model_selfref_change)
  eff_df_selfref_change$omega2[eff_df_selfref_change$effect_sizes == effect_size] = effsize_m$Omega2_partial[effsize_m$Parameter =='selfrefchange:time']

  sim_treat <- powerSim(model_selfref_change, nsim=iter, test = fixed(xname='selfrefchange:time', 't'))
  eff_df_selfref_change$power[eff_df_selfref_change$effect_sizes == effect_size] = sum(sim_treat$pval < alpha_level)
  
}


write.csv(eff_df_selfref_change, file = 'eff_df_selfref_change.csv', row.names = FALSE)
eff_df_selfref_change = read.csv('eff_df_selfref_change.csv')



eff_df_selfref_change$power = eff_df_selfref_change$power / iter

eff_df_selfref_change_closest_80 = dplyr::filter(eff_df_selfref_change, power >= 0.8) %>%
  top_n(n = 1, wt = -1*power) %>%
  mutate(descript = paste0('Aims 3A & 3B\n\U03C9\U00B2~=', round(omega2, 2)))


p3 = ggplot(data = eff_df_selfref_change, aes(x = omega2, y = power)) +
  geom_hline(yintercept = .80, lty = 2) +
  geom_line(lwd = 1, aes(color = 'darkred')) +
  #geom_point(size = 2, aes(color = 'darkred')) + 
  labs(x = '\U03C9\U00B2 Effect Size (Omega Squared)', y = 'Power', color = NULL) +
  geom_rect(ymin = -Inf, ymax = 0., xmin = 0.14, xmax = Inf, aes(fill = 'Large'), alpha = 0.05, color = 'black') +
  geom_rect(ymin = -Inf, ymax = 0, xmin = 0, xmax = 0.06, aes(fill = 'Small'), alpha = 0.05, color = 'black') +
  geom_rect(ymin = -Inf, ymax = 0, xmin = 0.06, xmax = 0.14, aes(fill = 'Medium'), alpha = 0.05, color = 'black') + 
  geom_vline(data = eff_df_selfref_change_closest_80, mapping = aes(xintercept = omega2), lwd = 1, lty =2, 
             show.legend = FALSE, color = 'darkred') +
  geom_label_repel(data = eff_df_selfref_change_closest_80, nudge_x = 0.2, nudge_y = -.1,
                   aes(label = descript), show.legend = FALSE, color = 'darkred') +
  scale_fill_manual(values = c('gray60', 'gray75', 'white')) +
  theme_bw() +
  theme(legend.position = 'bottom') +
  scale_y_continuous(breaks = seq(from = 0, to = 1, by = .1)) +
  scale_color_manual(values = 'darkred', labels = 'Aims 3A & 3B: Associations between pre > post change\nin SRET measures (DMN & behavior) and symptom change ') +
  guides(fill = 'none')

p3


power_grid = cowplot::plot_grid(power_plot_1, p3, align = 'h', axis = 'bt', labels = c('A', 'B'))
cowplot::save_plot(power_grid, base_height = 6, base_width = 10, filename = 'power_grid_plot.png')
