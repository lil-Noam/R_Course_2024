library(caret)

# Recursive Feature Elimination
rfe_model = rfe(df[, 8:length(df)], df$event_memory, 
                 sizes = c(1:10),
                 rfeControl = rfeControl(functions = rfFuncs, method = "cv"))

print(rfe_model)
