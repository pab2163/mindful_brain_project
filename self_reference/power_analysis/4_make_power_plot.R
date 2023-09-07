library(tidyverse)
library(simr)
library(ggrepel)


# For Aims 1 & 2 (Panel A)
iter_aims1_2 = 10000
eff_df_main = read.csv('powersims_aim1_10000.csv')
eff_df_dose = read.csv('powersims_aim2_10000.csv')

eff_df_dose$type = 'Aim 2A'
eff_df_main$type = 'Aim 1A'


eff_df = rbind(eff_df_dose, eff_df_main)


eff_df$power = eff_df$power / iter_aims1_2
eff_df$power_uncorrected = eff_df$power_uncorrected / iter_aims1_2


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



# Aims 3 (Panel B) --------------------------------------------------------
iter_aim2 = 10000
eff_df_selfref_change = read.csv('eff_df_selfref_change.csv')

eff_df_selfref_change$power = eff_df_selfref_change$power / iter_aim2

eff_df_selfref_change_closest_80 = dplyr::filter(eff_df_selfref_change, power >= 0.8) %>%
  top_n(n = 1, wt = -1*power) %>%
  mutate(descript = paste0('Aims 3A & 3B\n\U03C9\U00B2~=', round(omega2, 3)))


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
power_grid
cowplot::save_plot(power_grid, base_height = 6, base_width = 10, filename = 'power_grid_plot.png')


