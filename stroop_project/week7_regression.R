
### regression ----


library(lme4)

# to account for the fact that each subject did all conditions
# I consulted with chatGPT on how to include subject as a random effect
# and got:
# (1 | subject) for variance in intercept between participants
# (task * congruency | subject) for variance in slope between participants

model = lmer(rt ~ task * congruency + (1 + task * congruency | subject), data = df_filtered)

coef(model)
summary(model)
