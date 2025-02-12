library(ggplot2)
library(ggdist)

df <- read.csv("./raw_data_wide.csv")

## Bivariate plots
# Age by gender histogram
figure_1 <- ggplot(df, aes(x = age, fill = gender)) +
  geom_histogram(bins = 5, alpha = 0.8) +
  scale_fill_manual(values = c("male" = "#93e6d4", "female" = "#f57a9f")) +
  labs(title   = "Figure 1: Age by Gender",
       caption = "Note: N = 22",
       x       = "age",
       y       = "count",
       fill    = "Gender") +
  theme_minimal() +
  theme(
    plot.caption = element_text(hjust = 0, face = "italic"))

ggsave("./figure_1.png", figure_1, bg = "white", width = 8, height = 6)

# Political wing affiliation by coalition/opposition support
figure_2 <- ggplot(df, aes(x = coalition_opposition, y = political_camp_raw, fill = coalition_opposition)) +
  geom_point(size = 2) +
  geom_boxplot(alpha = 0.6) +
  labs(title    = "Political wing affiliation by coalition/opposition support",
       caption = "The scale of political wing affiliation was captioned in the survey: 
       * lower end (0 on the y axis) as right wing
       * upper end (100 on the y axis) as left wing",
       x        = "Dichotomic coalition / opposition support", 
       y        = "Political wing affiliation rating",
       fill     = "Coalition or opposition support") +
  theme_minimal() +
  theme(
    plot.caption = element_text(hjust = 0, face = "italic"))
  
ggsave("./figure_2.png", figure_2, bg = "white", width = 8, height = 6)
  




# Multivariate plots




