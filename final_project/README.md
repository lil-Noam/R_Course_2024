# R Course Final Project

#### by Noam Gabay, ID 208540815

© 2024 Nir Lab, Tau. All rights reserved.  <br>
Special thanks to Dr. Flavio J. Schmidig for allowing me to use his data. <br><br>

This project includes 4 files: <br>
1. preprocess_EDA.R - preprocessing of the data and exploratory data analysis.
2. analysis.R - implementation of helper functions and the regression analyses.
3. top_features_modeling.R - logistic regression analysis of the filtered data according to the feature selection process done in the linear regression.
4. RF_RFE.R - to test my idea of feature importance/selection by linear regression, I used more conventional ways of feature importance and selection - first by a recursive elimination model and then by random forest model, using libraries we haven't used in the course.

 <br><br>

## Step A - Defining the Research Question


### About The Dataset

The dataset used for this project belongs to Nir Lab @TAU and was collected as part of an ongoing study aiming to assess memory retrieval without relying on verbal reports. ([Anticipatory Eye Gaze as a Marker of Memory: Preprint](https://www.biorxiv.org/content/10.1101/2024.08.14.607869v1)). <br>

The data contains samples from 30 paticipants who watched 48 short movie clips (8.4-22.4 seconds long), each containing a predefined surprising event occurring at a specific time and location. Participants viewed these movies twice, with a break in between, while their eye movements were recorded using an eye-tracking system, computing the Gaze Distance (GAD) — the mean distance from each gaze point to the event location from the movie’s beginning until the event onset. After the second viewing, verbal memory reports were collected. On the second viewing, besides the 48 movies, participants were presented with 12 lure movies which were shown only on the second viewing and are not included in the dataset. <br>

Dataset columns (features):<br>
* **Subject**: subject id (chr)
* **Movie**: movie id (chr)
* **pupil_size**: (num) normalized increased pupil dilation due to repeated memory viewing, computed as:  $` \frac{pupil size_{1st}-pupil size_{2nd}}{max(pupil size_{1st}, pupil size{2nd})} `$ 
* **MEGA_score**: (num) metric for quantifying anticipatory gaze: normalized difference between GAD of 1st and 2nd viewing. computed as: $` \frac{GAD_{1st}-GAD_{2nd}}{max(GAD_{1st}, GAD{2nd})} `$ <br>
* **memorysource**: (chr) categorical value based on participant's responses: **no_memory** (if recognition_accuracy is wrong), **scenery memory** (if recognition_accuracy is correct + what_ or where_accuracy is wrong) and **event memory** if all three are correct (recognition, what & where).
* **recognition_accuracy**: context recognition according to participant's response (num)
* **what_accuracy**: object recognition according to participant's response (num)
* **where_accuracy_liberal**: event location recall according to participant's response (num)
* **when_accuracy**: temporal recall according to participant's response (num)


### Why I chose this dataset

* I think it is an interesting, promising paradigm that could help advance clinical research in unverbal patients. <br>
* To have this work be meaningful and contribute to my lab mates' project <br>
* It's a nice opportunity to experience what the human researchers in my lab do


### Research Questions

* Can MEGA score predict episodic (event) memory non-verbally? <br>
* Which movie clips have the strongest anticipatory gaze effect, i.e which movies contribute most to MEGA score? <br>
* Can we run the experiment in shorter time, using less movies, and still get the same effect?

<br>

## some EDA

![Scatter plot of event memory and MEGA by movie](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/MEGA%20by%20movie.jpeg)

![Scatter plot of event memory and MEGA by subject](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/MEGA%20by%20subject.jpeg)

![Box plot of event memory and MEGA by Movie](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/Multiple%20Subplots%20by%20movie.jpeg)

![Box plot of event memory and MEGA by subject](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/Multiple%20Subplots%20by%20subject.jpeg)



## Step B - Preprocessing the Data

### 1. Needed variables for analysis: <br>
* **Subject**: (chr) subject ID, no change from the original data. Random effect in mixed model - we'd like to set a random intercept for each subject to account for inter-subject differences.
* **Movie**: (factor) movie ID. Predictive variables for the linear regressions. We Movie names were changed to include 5 characters each (mov01 and not mov1) so that they can be sorted alphabetically. Movies that no subject remembered and movies that all  We also add a dummy variable for each movie by using one-hot encoding: if a sample is taken from a specific movie its dummy value would be 1 while all the other movies' dummy values would be 0.
* **MEGA_score**: (num) MEGA score, computed as mentioned above, no change from original data. Used as a predicted variable in one linear regressions and predictive varible in one logistic regression.
* **MEGA_Z**: (num) scaled MEGA score, scaling done by Z transform.
* **event_memory**: (factor) the column memorysource was changed to a factor, where the value is 1 "Yes" for event_memory and 0 "No" for no memory or scenery memory. Predicted variable for the first logistic regression. In the last linear regression it is effect coded to suit the regression purpose.
* **MEGA_memory**: (num) A metric for goodness of fit between the MEGA score and the memory report, done by multiplying the MEGA_Z value with the effect coded event_memory. It returns a positive value for memory with high MEGA and no memory with low MEGA, and a negative value for memory with low MEGA and no memory with high MEGA. Used as a predicted variable in the last linear regression. 



## Step C - Data Analysis

### 1. My Regressions:
To answer the first question - logistic regression: event_memory ~ scaled MEGA score <br>
To answer the second question - linear regression: MEGA memory ~ Movie
<br>

### 2. Result interpretation:

#### Logistic model: <br>
* **Random effect for Subject (Intercept)**: Standard deviation of 0.4818, showing variability in baseline odds across subjects. <br>
* **Intercept $`\beta_0`$ (-0.9148)**: represents the log-odds of the event memory when MEGA_score is 0 for an average subject (i.e., ignoring the random effects). Applying the logistic function on the intercept results in the probability of the event being remembered to be about 28.6%.<br>
* **MEGA_score $`\beta_1`$ (2.0979)**: For every one-unit increase in MEGA_score, the log-odds of the event happening increase by 2.0979, meaning that as MEGA_score increases, the probability of the movie being remembered (event_memory = 1) increases. By converting log-odds to odd ratio we get that for every one-unit increase in MEGA_score, the odds of the movie to being remembered (compared to not being remembered) increase by approximately 8.14 times. <br>
* **AUC: 0.6866**: This indicates the model’s ability to discriminate between the two classes (memory vs. no memory). An AUC of 0.6866 indicated some discrimination (as it is greater than 0.5) but could likely be improved.

#### Linear model: <br>
* **No intercept** - I removed the intercept from the model to avoid R choosing one movie as a reference level. Instead, the reference is just 0. I tried to use a mixed model with random intercept for each subject, but the sd was so small that it seemed insignificant to include it. <br> 
* **Fixed Effects**: Each movie has a coefficient showing its effect on MEGA_memory (the goodness of fit between the MEGA score and the memory report): positive coefficients (e.g., Moviemov25 = 0.717) indicate an increase in this fit, while negative coefficients (e.g., Moviemov57 = -0.352) indicate a decrease in it. <br>
* **Residual**: The residual standard deviation is 0.9842, indicating some variability in the data that the model hasn't accounted for.

<br>

### 3. GRAPHS:

#### Logistic regression result - MEGA Z vs probability of event memory with true labels
![Logistic regression result - MEGA Z vs probability of event memory with true labels](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/LogPlot.jpeg)

#### Linear regression result - movie coefficients ordered by absolute value
![Linear regression result - movie coefficients ordered by absolute value](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/feature_importance.jpeg)

<br>

### 4. ROC CURVE:

#### ROC curve of the logistic regression
![ROC curve of the logistic regression](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/ROC_curve_log_result.jpeg)


## Logistic regression analysis of the selected movies only

### TOP 10 movies

#### Logistic regression fit
![Logistic regression result - MEGA Z vs probability of event memory with true labels](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/LogPlot_top10.jpeg)

#### ROC curve
![Linear regression result - movie coefficients ordered by absolute value](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/ROC_curve_top10.jpeg)

<br>

### TOP 7 movies

#### Logistic regression fit
![Logistic regression result - MEGA Z vs probability of event memory with true labels](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/LogPlot_top7.jpeg)

#### ROC curve
![Linear regression result - movie coefficients ordered by absolute value](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/ROC_curve_top7.jpeg)

<br>

### TOP 5 movies

#### Logistic regression fit
![Logistic regression result - MEGA Z vs probability of event memory with true labels](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/LogPlot_top5.jpeg)

#### ROC curve
![Linear regression result - movie coefficients ordered by absolute value](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/ROC_curve_top5.jpeg)

<br>


### TOP 3 movies

#### Logistic regression fit
![Logistic regression result - MEGA Z vs probability of event memory with true labels](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/LogPlot_top3.jpeg)

#### ROC curve
![Linear regression result - movie coefficients ordered by absolute value](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/ROC_curve_top3.jpeg)

<br><br>

## Conclusions

* MEGA score is a fairly good predictor of episodic memory, out model managed to classify the data with higher accuracy than random classifier. <br>
* The movies that have the best anticipatory gaze effect are (by this order): #27, #25, #35, #60, #58, #14, #10, #01, #03, #36. Logistic regression on top 3 movies had the highest AUC but as it reduces the samples significantly we chose the second best fit of top 10 movies. <br>
* In all subsets of movies (3, 7, 5 and 10 top movies) AUC is greater than the AUC of the original full set of movies, therefore, we can run the experiment on a smaller subset of movies and still get a strong effect. <br>


## Testing my results using other feature importance/selection methods

I tested my idea of using linear regression for feature importance by comparing it to two other popular methods for feature importance - recursive feature elimination and random forest. <br>

Below is a plot of all features ranked by importance in both our regression model and the forest model: <br>

![Linear regression result - movie coefficients ordered by absolute value](https://github.com/lil-Noam/R_Course_2024/blob/main/final_project/method_comparison.jpeg)

