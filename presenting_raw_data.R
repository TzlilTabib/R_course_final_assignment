library(ggplot2)
library(ggdist)
library(ggridges)

load("raw_data_long.RData")

## Bivariate plots
# Age by gender histogram
figure_1 <- ggplot(df, aes(x = age, fill = gender)) +
  geom_histogram(bins = 5, alpha = 0.8) +
  scale_fill_manual(values = c("male" = "#93e6d4", "female" = "#f57a9f")) +
  labs(title   = "Age by Gender",
       caption = "Note: N = 22",
       x       = "age",
       y       = "count",
       fill    = "Gender") +
  theme_minimal() +
  theme(
    plot.caption = element_text(hjust = 0, face = "italic"))

ggsave("./figure_1.png", figure_1, bg = "white", width = 8, height = 6)

# Government support and education level
figure_2 <- ggplot(df, aes(x = education, fill = government_support)) +
  geom_bar(stat = "count", alpha = 0.7) +
  scale_y_continuous(breaks = seq(0, 10, 1)) +  
  labs(title   = "Education level by government support (categorical)",
       caption = "Government support coded as <= 40 (support in Netanyahu) and >=60 as support in Benet-Lapid",
       x       = "Education level",
       y       = "count",
       fill    = "Government Support") +
  scale_fill_manual(values = c("Benet-Lapid" = "blue", "Netanyahu" = "red")) +
  theme_minimal() +
  theme(
    plot.caption = element_text(hjust = 0, face = "italic"))

ggsave("./figure_2.png", figure_2, bg = "white", width = 8, height = 6)

# Political wing affiliation by coalition/opposition support
figure_3 <- ggplot(df, aes(x = coalition_opposition, y = political_camp_raw, fill = coalition_opposition)) +
  geom_point(size = 2) +
  geom_boxplot(alpha = 0.6) +
  labs(title    = "Political wing affiliation by coalition/opposition support",
       caption  = "The scale of political wing affiliation was captioned in the survey: 
       * lower end (0 on the y axis) as right wing
       * upper end (100 on the y axis) as left wing",
       x        = "Dichotomic coalition / opposition support", 
       y        = "Political wing affiliation rating",
       fill     = "Coalition or opposition support") +
  scale_fill_manual(values = c("opposition" = "blue", "coalition" = "red")) +
  theme_minimal() +
  theme(
    plot.caption = element_text(hjust = 0, face = "italic"))
  
ggsave("./figure_3.png", figure_3, bg = "white", width = 8, height = 6)

## Multivariate plots
# Age by political affiliation and gender
figure_4 <- ggplot(df, aes(x = age, y = gender, fill = political_camp)) +
  geom_density_ridges(alpha = 0.6) +
  labs(title = "Age density distribution by political affiliation and gender",
       x     = "Age",
       y     = "Gender",
       fill  = "Political wing affiliation") +
  scale_fill_manual(values = c("right" = "red", "left" = "blue")) +
  theme_minimal()

ggsave("./figure_4.png", figure_4, bg = "white", width = 8, height = 6)

# Political involvement by government support and political camp
figure_5 <- ggplot(df, aes(x = political_involvement, y = government_support, fill = political_camp)) +
  stat_halfeye(adjust = 0.5, justification = -0.2, .width = 0, alpha = 0.7) +
  geom_boxplot(width = 0.2, outlier.shape = NA, alpha = 0.7) +
  geom_jitter(position = position_nudge(y = -0.2), alpha = 0.7) +
  theme_minimal() +
  labs(title = "Political involvement by government support and political camp",
       x     = "Political involvement",
       y     = "Government support",
       fill  = "Political camp") +
  scale_fill_manual(values = c("left" = "blue", "right" = "red"))

ggsave("./figure_5.png", figure_5, bg = "white", width = 8, height = 6)
