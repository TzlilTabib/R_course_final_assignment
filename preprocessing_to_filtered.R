library(dplyr)

df <- read.csv("./raw_data_long.csv")

### RAW DATA TO FILTERED DATA --------------------------------------------------
# Filtering NA rows (rating of the sample stimulus)
df <- df |>
  filter(!is.na(index))

## Checking consistency of participants ratings to exclude outliers
## Based on reported political affiliation - 
# Counting inconsistencies in support ratings of posts by stimulus type
df <- df |>
  mutate(
    inconsistency = case_when(
      political_camp == "left" & stimulus_type == "pro_left" & support < 3 ~ 1,
      political_camp == "left" & stimulus_type == "anti_left" & support > 5 ~ 1,
      political_camp == "left" & stimulus_type == "pro_right" & support > 5 ~ 1,
      political_camp == "left" & stimulus_type == "anti_right" & support < 3 ~ 1,
      political_camp == "right" & stimulus_type == "pro_right" & support < 3 ~ 1,
      political_camp == "right" & stimulus_type == "anti_right" & support > 5 ~ 1,
      political_camp == "right" & stimulus_type == "pro_left" & support > 5 ~ 1,
      political_camp == "right" & stimulus_type == "anti_left" & support < 3 ~ 1,
      TRUE ~ 0))

# Summarizing inconsistencies by subject code and stimulus type
inconsistencies_summary <- df |>
  filter(inconsistency == 1) |>
  group_by(subject_code, stimulus_type) |>
  summarise(inconsistencies = n(), .groups = "drop")

# Filtering outliers (n(inconsistencies) > 9 for any stimulus type)
outliers <- inconsistencies_summary |>
  filter(inconsistencies > 9) |>
  pull(subject_code)

df <- df |>
  filter(!subject_code %in% outliers)

write.csv(df, "./filtered_data_long.csv")
