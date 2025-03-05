library(dplyr)
library(readr)
library(tidyr)


setwd('C:\\Users\\user\\Documents\\Noam_Rcourse\\final_project')


### PREPROCESSING ----

# load the csv file into R
data = read_csv("data_MEGAproject.csv")

# add dummy for event memory 
data = data |>
  mutate(event_memory = ifelse(memorysource == 'event_memory', 1, 0),
         Movie = gsub("mov([0-9])$", "mov0\\1", Movie),
         MEGA_Z = scale(MEGA_score))


# count subjects and movies
subject_dict = unique(data$Subject)
movie_dict = sort(unique(data$Movie))
print(paste("the data contains", length((subject_dict)), "subjects and", length(movie_dict), "movies"))


# make new df of the relevant features only
df = data |> dplyr::select(Subject, Movie, MEGA_score, MEGA_Z, event_memory)

# factorizing event memory
df = df |>
  mutate(event_memory = factor(df$event_memory, levels = c(0, 1), labels = c("No", "Yes")))



### EDA plotting ----


library(ggplot2)
library(ggdist)


# scatter plots of MEGA by movie/subject

plt_mov = ggplot(df, aes(x = factor(Movie), y = MEGA_score, color = event_memory)) + 
  geom_point() + 
  theme_minimal() + 
  labs(title = "Event/MEGA by movie", x = "Movie", y = "MEGA") +
  scale_color_manual(values = c("blue", "red"), labels = c("No Event", "Event"))  # Custom colors and labels

print(plt_mov)

ggsave("MEGA by movie.jpeg", plot = plt_mov, width = 22, height = 10, dpi = 300)



plt_subj = ggplot(df, aes(x = Subject, y = MEGA_score, color = event_memory)) + 
  geom_point() + 
  theme_minimal() + 
  labs(title = "Event/MEGA by subject", x = "Subject", y = "MEGA") +
  scale_color_manual(values = c("blue", "red"), labels = c("No Event", "Event"))  # Custom colors and labels

print(plt_subj)

ggsave("MEGA by subject.jpeg", plot = plt_subj, width = 22, height = 10, dpi = 300)


# Boxplot of MEGA by event_memory with subplot for each movie/subject


plt_movie <- ggplot(df, aes(x = event_memory, y = MEGA_score)) + 
  geom_point() +
  geom_boxplot(aes(group = event_memory), color = "blue", alpha = 0.2) +
  geom_smooth(method = "lm", aes(group = 1), color = "red", size = 1) +
  scale_x_discrete(labels = c("0" = "No", "1" = "Yes")) + 
  theme_minimal() + 
  facet_wrap(~ factor(Movie), scales = "free") +
  labs(title = "Multiple Subplots by movie", x = "Memory", y = "MEGA")

print(plt_movie)

ggsave("Multiple Subplots by movie.jpeg", plot = plt_movie, width = 14, height = 10, dpi = 300)



plt_subject <- ggplot(df, aes(x = event_memory, y = MEGA_score)) + 
  geom_point() +  # Scatter plot layer
  geom_boxplot(aes(group = event_memory), color = "blue", alpha = 0.2) +
  geom_smooth(method = "lm", aes(group = 1), color = "red", size = 1) + 
  scale_x_discrete(labels = c("0" = "No", "1" = "Yes")) + 
  theme_minimal() + 
  facet_wrap(~ Subject, scales = "free") +
  labs(title = "Multiple Subplots by subject", x = "Memory", y = "MEGA")

print(plt_subject)

ggsave("Multiple Subplots by subject.jpeg", plot = plt_subject, width = 14, height = 10, dpi = 300)



### More preprocessing ----


# Count the occurrences of 'Yes' and 'No' responses for each movie
movie_memory = df |>
  group_by(Movie, event_memory) |>
  summarise(count = n(), .groups = "drop") |>
  pivot_wider(names_from = event_memory, values_from = count, values_fill = list(count = 0))


# Remove movies with 0 yes or 0 no
movie_memory_filtered = movie_memory |>
  filter(Yes > 0 & No > 0)

# Join the filtered movie_memory with df to retain only movies with both Yes and No responses
df = df |>
  filter(Movie %in% movie_memory_filtered$Movie)


# factorize movies, add event effect coding
df = df |>
  mutate(Movie = factor(Movie),
         event_effect = ifelse(event_memory ==  "Yes", 1, -1))

# create MEGA memory metric
df = df |>
  mutate(MEGA_memory = MEGA_Z * event_effect)

# make dummy variable for each movie
dummy_dict = model.matrix(~ Movie - 1, data = df)
df = cbind(df, dummy_dict)
