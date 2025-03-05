library(pROC)
library(lme4)
library(dplyr)


# set path
setwd('C:\\Users\\user\\Documents\\GitHub\\R_Course_2024\\final_project')

# Load the data from an RDS file
# df = readRDS("df.rds")



### helper functions for regressions ----


# for logistic regression:


logistic_analysis = function(model, data, outcome_var = "event_memory", predictor_var = "MEGA_Z", file_prefix = "Logistic_Analysis") {
  
  # Generate predicted probabilities (fixed effects only and full prediction)
  pred_prob_fixed = predict(model, type = "response", re.form = NA)  # Fixed effects only
  pred_prob_full = predict(model, type = "response")  # Fixed + Random effects
  
  # Compute and plot the ROC curve
  roc_curve = roc(data[[outcome_var]], pred_prob_full)
  roc_plot = plot(roc_curve, main = "ROC Curve for Logistic Regression Model", col = "blue", lwd = 2)
  
  # Calculate AUC value and add to the plot
  auc_value = auc(roc_curve)
  text(0.6, 0.2, paste("AUC =", round(auc_value, 3)), col = "red", cex = 1.5)
  
  # Print AUC value to console
  print(paste("AUC:", auc_value))
  
  
  # Store predicted probabilities in the data frame
  data$pred_prob_fixed = pred_prob_fixed
  data$pred_prob_full = pred_prob_full
  
  # Plot the logistic regression: Predicted probabilities vs predictor (e.g., MEGA_score)
  log_plot = ggplot(data, aes_string(x = predictor_var)) +
    # Show the individual data points (raw data), colored by the actual event memory outcome (0 or 1)
    geom_point(aes(y = pred_prob_full, color = as.factor(.data[[outcome_var]])), alpha = 0.7, size=2) +  
    # Plot the fixed effect line (general trend of predictor on predicted probability)
    geom_line(aes(y = pred_prob_fixed), color = "blue", size = 1) + 
    labs(title = paste("Logistic Regression: Predicted Probability vs", predictor_var),
         x = predictor_var, y = "Predicted Probability of Memory",
         color = "Event Memory") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_color_manual(values = c("No" = "red", "Yes" = "green"))
  
  # Return the plots
  return(list(ROC_Plot = roc_plot, Logistic_Plot = log_plot))  
}


save_roc = function(result) {
  
  name = deparse(substitute(result))
    roc_plot = result$ROC_Plot
  
  jpeg(paste0("ROC_curve_",name,".jpeg"), width = 10, height = 10, units = "in", res = 300)
  plot(roc_plot, main = paste0("ROC Curve for ", name, " Logistic Regression Model: ", name), col = "blue", lwd = 2)
  text(0.6, 0.2, paste("AUC =", round(auc(result$ROC_Plot), 3)), col = "red", cex = 1.5)
  dev.off()  
  
}


# for linear regression:


feature_importance = function(model) {
  
  movie_coef = coef(model)
  movie_names = names(movie_coef)
  
  # Sort the coefficients by absolute value in decreasing order
  sorted_indices = order(abs(movie_coef), decreasing = TRUE)
  
  # Apply the sorting to both the coefficients and the movie names
  movie_coef_sorted = movie_coef[sorted_indices]
  movies_sorted_by_coef = movie_names[sorted_indices]
  
  # Create a data frame with the sorted movie names and coefficients
  coef_df = data.frame(Movie = movies_sorted_by_coef, Coefficient = movie_coef_sorted)
  coef_df$abs_coef = abs(coef_df$Coefficient)
  coef_df$Sign = ifelse(coef_df$Coefficient > 0, "Positive", "Negative")
  coef_df$Movie = factor(coef_df$Movie, levels = coef_df$Movie)
  
  # Create a plot
  plt = ggplot(coef_df, aes(x = Movie, y = abs_coef, color = Sign)) + 
    geom_point(size = 3) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
    theme_minimal() + 
    labs(title = "Movie Coefficients Sorted by Absolute Value", x = "Movie", y = "Coefficient") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
    scale_color_manual(values = c("Positive" = "blue", "Negative" = "red"))
  
  return(list(coef = coef_df, plot = plt))
  
}


feature_selection = function(coef_df, num_features=10) {
  
  features = coef_df |>
    filter(Sign=='Positive')
  
  return(head(features, num_features))
  
}



### logistic regression ----


# Logistic regression model for memory by MEGA score
logistic_model = glmer(event_memory ~ MEGA_Z + (1|Subject), family = binomial, data = df)

log_result = logistic_analysis(logistic_model, df)

print(log_result$ROC_Plot)
print(log_result$Logistic_Plot)

# Save the ROC plot to a file
save_roc(log_result)

# Save the logit curve to a file
ggsave("LogPlot.jpeg", plot = log_result$Logistic_Plot, width = 14, height = 10, dpi = 300)




### linear regression ----


# linear regression for (MEGA_memory = MEGA Z score x event memory effect coding) by movie

# I first tried mixed model with random intercept for each subject
# but the sd was so small that I decided to switch back

linear_model = lm(MEGA_memory ~ Movie -1, data = df)
result = feature_importance(linear_model)

print(result$plot)

ggsave("feature_importance.jpeg", plot = result$plot, width = 12, height = 10, dpi = 300)

