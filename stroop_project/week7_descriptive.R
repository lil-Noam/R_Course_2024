
### descriptive statistics ----

summary_conditions = df_filtered |>
  group_by(task, congruency) |>
  summarize(
    mean_rt = mean(rt, na.rm = TRUE),
    sd_rt = sd(rt, na.rm = TRUE),
    mean_accuracy = mean(accuracy, na.rm = TRUE),
    sd_accuracy = sd(accuracy, na.rm = TRUE)
  )



### plotting ----


library(ggplot2)


#plot rt

ggplot(summary_conditions, aes(x = task, y = mean_rt, fill = congruency)) +
  geom_bar(stat = "identity", position = position_dodge()) +
  geom_errorbar(aes(ymin = mean_rt - sd_rt, ymax = mean_rt + sd_rt),
                position = position_dodge(0.9), width = 0.25) +
  labs(
    title = "Mean Reaction Times by Task and Congruency",
    x = "Task",
    y = "Mean Reaction Time (ms)",
    fill = "Congruency"
  ) +
  theme_minimal()

# scatter plot

ggplot(df_filtered, aes(x = task, y = rt, color = congruency)) +
  geom_point(alpha = 0.5, position = position_jitter(width = 0.2)) +  # נקודות עם רנדומליות קלה
  labs(
    title = "Reaction Times by Task and Congruency",
    x = "Task",
    y = "Reaction Time (ms)",
    color = "Congruency"
  ) +
  theme_minimal()
