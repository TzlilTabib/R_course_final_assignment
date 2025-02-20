library(dplyr)
library(lme4)
library(ggplot2)
library(ggh4x)
library(pROC)

load("filtered_data_long.RData")

### Statistical analyses -------------------------------------------------------
## Descriptive statistics
descriptives <- df |>
  group_by(gender, political_camp) |>
  summarise(
    count    = n_distinct(subject_code),
    mean_age = mean(age),
    sd_age   = sd(age))

write.csv(descriptives, "./filtered_descriptives.csv")

## Linear regression -----------------------------------------------------------
# Predicting support ratings by political affiliation (raw score) and stimulus type (subject code as a random effect)
mixed_linear_model <- lmer(support ~ political_camp_raw * stimulus_type + (1 | subject_code), data = df)
summary(mixed_linear_model)

# Defining facet colors based on expected support of camp in stimulus type
facet_colors <- c("anti_right" = "#D6E6FF", "pro_left"  = "#D6E6FF",  
                  "anti_left"  = "#FFD6D6", "pro_right" = "#FFD6D6")  

# Plotting the linear model
figure_6 <- ggplot(df, aes(x = political_camp_raw, y = support, color = political_camp)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = TRUE, color = "black") +
  facet_wrap2(~stimulus_type, strip = strip_themed(background_x = elem_list_rect(fill = facet_colors[levels(df$stimulus_type)]))) +
  scale_color_manual(values = c("left" = "#1253e0", "right" = "#f53333")) +
  theme_minimal() +
  labs(title    = "Support Ratings by Political Affiliation rating (Faceted by Stimulus Type)",
       x        = "Political affiliation (raw rating)",
       y        = "Support ratings",
       color    = "Political affiliation (categorical)",
       subtitle = "Stimuli types are colored by expected support in type by political camp affiliation") +
  theme(
    strip.text = element_text(face = "bold"))

ggsave("./figure_6.png", figure_6, bg = "white", width = 10, height = 8)

## Logistic regression ---------------------------------------------------------
# Predicting dichotomic extreme levels by support ratings
# Coding a dichotomic variable for extreme ratings (using median extreme in sample)
df <-df |>
  mutate(
    extreme_binary <- ifelse(extreme >= median(extreme, na.rm = TRUE), 1, 0))

# The model (subject code as a random effect)
mixed_logit_model <- glmer(extreme_binary ~ support + (1 | subject_code), data = df, family = binomial)
summary(mixed_logit_model)

# Calculating AUC
df$predicted_prob <- predict(mixed_logit_model, type = "response")
roc <- roc(df$extreme_binary, df$predicted_prob)
auc(roc)

# Plotting ROC with AUC value
png("figure_7.png", width = 800, height = 600)
figure_7 <- plot(roc, col = "blue", main = "ROC Curve for Logistic Regression", lwd = 2)
legend("bottomright", legend = paste("AUC =", round(auc), 3), col = "blue", lwd = 2)
dev.off()