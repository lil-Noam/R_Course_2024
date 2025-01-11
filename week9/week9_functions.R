# R course for beginners
# Week 9
# assignment by Noam Gabay, id 208540815


descriptive_stats = function(df, subject_start=0, subject_end=max(df$subject_id)) {
  
  df = df[((subject_id >= subject_start) & (subject_id <= subject_end)),]
  
  
  # check number of samples and raise error if too short
  if ((dim(df)[1]) < 10) {
    
    stop("data is too short")
    
  }
  
  
  # empty dataframe for storing results
  results = data.frame(
    Variable = character(),
    Type = character(),
    Description = character(),
    stringsAsFactors = FALSE
  )
  
  # iterating over columns
  for (col in names(df)) {
    
    
    
    if (class(df[[col]]) == "factor"){
      
      levels_counts = table(df[[col]])
      description = paste(names(levels_counts), levels_counts, sep = ":", collapse = ", ")
      type = "Categorical"
      
    }
    
    else if (is.numeric(df[[col]])) {
      
      min = min(df[[col]], na.rm = TRUE)
      max = max(df[[col]], na.rm = TRUE)
      mean = mean(df[[col]], na.rm = TRUE)
      description = paste("Min:", min, "Max:", max, "Mean:", mean)
      type = "Numeric"
      
    }
    
    else {
      
      description = "Unsupported type"
      type = "Other"
      
      }
    
    col_result = data.frame(
      Variable = col,
      Type = type,
      Description = description,
      stringsAsFactors = FALSE
    )
    
    results = rbind(results, col_result)
    
  }
  
  return(results)
  
  }
