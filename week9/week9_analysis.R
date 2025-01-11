# R course for beginners
# Week 9
# assignment by Noam Gabay, id 208540815

#### CREATE DATAFRAME ----

# generating data

set.seed(123)

n = 100
subject_id = 1:n
age = sample(18:60, size = n, replace = TRUE)
gender = factor(sample(c("male", "female"), size = n, replace = TRUE))

avg_rt_ms = round(rnorm(n, mean = 3100, sd = 900))
avg_rt_ms = pmax(avg_rt_ms, 200)
avg_rt_ms = pmin(avg_rt_ms, 6000)

depression = round(rnorm(n, mean = 50, sd = 20))
depression = pmax(depression, 0)
depression = pmin(depression, 100)

avg_sleep_duration = sample(2:12, size = n, replace = TRUE)

# creating data frame

df = data.frame(subject_id, age, gender, avg_rt_ms, depression, avg_sleep_duration)


#### USE FUNCTION ----

source(paste(getwd(),"/project/week9_functions.R", sep = ""))

print("analysis of the full data:")
print(descriptive_stats(df))
print("analysis of subjects 22 to 66:")
print(descriptive_stats(df, 22, 66))