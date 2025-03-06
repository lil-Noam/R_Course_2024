library(caret)
library(randomForest)


# Recursive Feature Elimination - feature selection

rfe_model = rfe(df[, 8:length(df)], df$MEGA_memory, 
                 sizes = c(1:10),
                 rfeControl = rfeControl(functions = rfFuncs, method = "cv"))

print(rfe_model)
rfe_importance = rfe_model$optVariables
print(rfe_importance)




# random forest model - feature importance
rf_model = randomForest(MEGA_memory ~ . - event_effect - event_memory, data = df[5:length(df)], importance = TRUE)

# View importance
importance(rf_model)
# Plot importance
varImpPlot(rf_model)

rf_importance_values = importance(rf_model)
rf_sorted_importance = rf_importance_values[order(-rf_importance_values[, 1]),]
rf_movies = rownames(rf_sorted_importance)




### comparison between RF and our model ----

importance_df = data.frame(LR = result$coef$Movie, RF = rf_movies)
print(importance_df)


# Initialize empty vectors to store the indices
LR_indices = numeric(nrow(importance_df))
RF_indices = numeric(nrow(importance_df))

movie_id = importance_df$LR

# Loop over each row and check where the movie is in each column
for(i in 1:nrow(importance_df)) {
  LR_indices[i] <- which(importance_df$LR == movie_id[i])
  RF_indices[i] <- which(importance_df$RF == movie_id[i])
}


indices_df = data.frame(
  Movie_ID = movie_id,
  LR = LR_indices,
  RF = RF_indices
)

# Create a long-format dataframe
indices_df_long = indices_df |>
  pivot_longer(cols = c(LR, RF), 
               names_to = "Model", 
               values_to = "Rank")


# Create plot
method_plot = ggplot(indices_df_long, aes(x = Model, y = Rank, color = Movie_ID, group = Movie_ID)) +
  geom_point(size = 3) +  # Points for each movie
  geom_line(color = "gray", alpha = 0.5) +  # Lines connecting the points for each movie
  labs(title = "Movie Ranking Across Models (LR, RF)",
       x = "Model",
       y = "Rank") +
  scale_y_reverse() +  # Flip the y-axis so that top-ranked movies are at the top
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))  # Rotate x-axis labels for clarity

print(method_plot)

ggsave("method_comparison.jpeg", plot = method_plot, width = 12, height = 10, dpi = 300)
