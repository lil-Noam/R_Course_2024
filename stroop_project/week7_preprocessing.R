# this code was written by Noam Gabay (AKA lil-noam) on December 20th 2024
# it is made to preprocess the raw stroop data,
# filter it using piping and save the filtered data



### preprocessing ----


# creating raw data

subjects = dir("stroop_data")
df = data.frame()

for (subject in subjects)  {
  temp_data = read.csv(file.path("stroop_data", subject))
  df = rbind(df, temp_data)
}


# piping 

library(dplyr)

df = df |>
  mutate(
    task = ifelse(grepl("word_reading", condition), "word_reading",
                  ifelse(grepl("ink_naming", condition), "ink_naming", NA)),
    
    congruency = ifelse(grepl("_cong", condition), "congruent",
                        ifelse(grepl("incong", condition), "incongruent", NA)),
    
  )

df = df |>
  mutate(
    accuracy = (participant_response == correct_response) * 1
  )


df = df |>
  select(subject, task, congruency, block, trial, accuracy, rt)


df = df |>
  mutate(
    subject = factor(subject),
    task = factor(task, levels = c("word_reading", "ink_naming")),
    congruency = factor(congruency, levels = c("congruent", "incongruent")),
  )


save(df, file = "raw_data.rdata")


### creating filtered data ----

# number of subjects
n_subjects = length(unique(df$subject))

# drop rows with NAs
df_filtered  = na.omit(df)

# condition for rt (assuming rt is in ms)
df_filtered = df_filtered |>
  filter(
    (df_filtered$rt > 300) & (df_filtered$rt < 3000)
  )


# trial percentage

n_trials_original = df |>
  group_by(subject) |>
  summarize(trials = n())

n_trials_left = df_filtered |>
  group_by(subject) |>
  summarize(trials = n())


trial_data = data.frame(
  subject = unique(df_filtered$subject),
  
  percent_remaining = n_trials_left$trials / n_trials_original$trials * 100 ,
  percent_removed = (n_trials_original$trials - n_trials_left$trials) / n_trials_original$trials *100
)

print(trial_data)

trial_summary = trial_data |>
  summarize(
    mean_removed = mean(percent_removed, na.rm = TRUE),
    sd_removed = sd(percent_removed, na.rm = TRUE)
  )

print(trial_summary)

save(df_filtered, file= "filtered_data.csv")

