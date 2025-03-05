# Load the lme4 package for mixed-effects models
library(lme4)

# Example data for mixed-effects model
# Let's assume 'Subject' is the random effect and we have a continuous response variable


df1 = df |>
  dplyr::select()


movie_vec = colnames(dummy_dict)

# Fit an initial mixed-effects model
initial_model <- lmer(MEGA_score ~ movie_vec  + (1 | Subject), data = df)

# Perform stepwise selection (using AIC) for mixed-effects model
stepwise_model <- step(initial_model, direction = "both", trace = 1)

# Print the summary of the final model
summary(stepwise_model)
