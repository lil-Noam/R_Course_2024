top_n = function(linear_model, df, num_features) {
  
  result = feature_importance(linear_model)
  top = feature_selection(result$coef, num_features)
  
  n_movies = sub("Moviemov", "mov", top$Movie)
  df_n = df[df$Movie %in% n_movies, ]
  
  logistic_model = glmer(event_memory ~ MEGA_Z + (1 | Subject), family = binomial, data = df_n)
  
  analysis = logistic_analysis(logistic_model, df_n)
  return(list(ROC_Plot = analysis$ROC_Plot, Logistic_Plot = analysis$Logistic_Plot))
}


top3 = top_n(linear_model, df, 3)
top5 = top_n(linear_model, df, 5)
top10 = top_n(linear_model, df, 10)





# Save the plots to files

save_roc(top3)
ggsave("LogPlot_top3.jpeg", plot = top3$Logistic_Plot, width = 14, height = 10, dpi = 300)


save_roc(top5)
ggsave("LogPlot_top5.jpeg", plot = top5$Logistic_Plot, width = 14, height = 10, dpi = 300)


save_roc(top10)
ggsave("LogPlot_top10.jpeg", plot = top10$Logistic_Plot, width = 14, height = 10, dpi = 300)
