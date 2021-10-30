
-- How many distinct user IDs in each table
SELECT COUNT (DISTINCT Id) FROM fitdata.dbo.dailyActivity_merged
SELECT COUNT (DISTINCT Id) FROM fitdata.dbo.dailyCalories_merged
SELECT COUNT (DISTINCT Id) FROM fitdata.dbo.dailyIntensities_merged
SELECT COUNT (DISTINCT Id) FROM fitdata.dbo.dailySteps_merged
SELECT COUNT (DISTINCT Id) FROM fitdata.dbo.sleepDay_merged
SELECT COUNT (DISTINCT Id) FROM fitdata.dbo.weightLogInfo_merged

--Check to see if Calorie data is the same
SELECT
  dailyActivity_merged.Calories 
  , dailyCalories_merged.Calories
FROM fitdata..dailyActivity_merged
JOIN fitdata..dailyCalories_merged 
 ON (fitdata..dailyActivity_merged.Id = fitdata..dailyCalories_merged.Id and fitdata..dailyActivity_merged.ActivityDate = fitdata..dailyCalories_merged.ActivityDay)

--Check to see if Step data is the same
SELECT
  dailyActivity_merged.TotalSteps
  , dailySteps_merged.StepTotal
FROM
  fitdata..dailyActivity_merged
JOIN fitdata..dailySteps_merged
  ON (fitdata..dailyActivity_merged.Id = fitdata..dailySteps_merged.Id and fitdata..dailyActivity_merged.ActivityDate = fitdata..dailySteps_merged.ActivityDay)

--Check to see if Intensities data is the same
SELECT
  dailyActivity_merged.VeryActiveDistance
  , dailyIntensities_merged.VeryActiveDistance
FROM
  dailyActivity_merged
JOIN dailyIntensities_merged
 ON (fitdata..dailyActivity_merged.Id = fitdata..dailyIntensities_merged.Id and fitdata..dailyActivity_merged.ActivityDate = fitdata..dailyIntensities_merged.ActivityDay)

 --I'm convinced this is the same data, no need to use the smaller files for Calories, Steps, or Intensities



 --Check data types of all columns
SELECT * FROM fitdata.INFORMATION_SCHEMA.columns

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM fitdata.INFORMATION_SCHEMA.columns

--Fix data types since everything was varchar
ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN ActivityDate DATE

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN TotalSteps NUMERIC (18,0)

ALTER TABLE fitdata..dailyActivity_merged
ALTER COLUMN Id NUMERIC (18,0)

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN TotalDistance FLOAT

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN TrackerDistance FLOAT

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN LoggedActivitiesDistance FLOAT

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN VeryActiveDistance FLOAT

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN ModeratelyActiveDistance FLOAT

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN LightActiveDistance FLOAT

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN SedentaryActiveDistance FLOAT

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN VeryActiveMinutes NUMERIC (18,0)

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN FairlyActiveMinutes NUMERIC (18,0)

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN LightlyActiveMinutes NUMERIC (18,0)

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN SedentaryMinutes NUMERIC (18,0)

ALTER TABLE fitdata..dailyActivity_merged
 ALTER COLUMN Calories NUMERIC (18,0)

ALTER TABLE weightLogInfo_merged
 ALTER COLUMN Id NUMERIC (18,0)

ALTER TABLE weightLogInfo_merged
 ALTER COLUMN "Date" DATE
 
ALTER TABLE weightLogInfo_merged
 ALTER COLUMN WeightKg FLOAT

ALTER TABLE weightLogInfo_merged
 ALTER COLUMN WeightPounds FLOAT

ALTER TABLE weightLogInfo_merged
 ALTER COLUMN Fat INT

ALTER TABLE weightLogInfo_merged
 ALTER COLUMN BMI FLOAT

ALTER TABLE weightLogInfo_merged
 ALTER COLUMN LogId NUMERIC (18,0)

ALTER TABLE sleepDay_merged
 ALTER COLUMN Id NUMERIC (18,0)

ALTER TABLE sleepDay_merged
 ALTER COLUMN SleepDay DATE

ALTER TABLE sleepDay_merged
 ALTER COLUMN TotalSleepRecords INT

ALTER TABLE sleepDay_merged
 ALTER COLUMN TotalMinutesAsleep NUMERIC (18,0)

ALTER TABLE sleepDay_merged
 ALTER COLUMN TotalTimeInBed NUMERIC (18,0)


SELECT * FROM sleepDay_merged

--join dailyActivity and sleepDay
SELECT * 
FROM dailyActivity_merged
LEFT JOIN sleepDay_merged
ON (dailyActivity_merged.Id = sleepDay_merged.Id and dailyActivity_merged.ActivityDate = sleepDay_merged.SleepDay)

SELECT * FROM weightLogInfo_merged

--join dailyActivity and weightLogInfo
SELECT
 *
FROM
 dailyActivity_merged
LEFT JOIN weightLogInfo_merged
ON (dailyActivity_merged.Id = weightLogInfo_merged.Id and dailyActivity_merged.ActivityDate = weightLogInfo_merged.Date)


--count number of IsManualReport True occurrences in weight log
SELECT
 IsManualReport,
 COUNT(IsManualReport) as self_reporting
FROM
 weightLogInfo_merged
GROUP BY
 IsManualReport



 -----Analysis-----

 --average daily active minutes per user
SELECT
  AVG(VeryActiveMinutes) as avg
FROM
  dailyActivity_merged

--number of observations per user
SELECT Id, COUNT(Id) as observations
FROM dailyActivity_merged
GROUP BY Id
ORDER BY observations


 --averages
 SELECT AVG(TotalSteps) as avg_steps
  , AVG(VeryActiveDistance) as avg_very_active_dist
  , AVG(ModeratelyActiveDistance) as avg_mod_active_dist
  , AVG(LightActiveDistance) as avg_light_active_dist
  , AVG(SedentaryActiveDistance) as avg_sed_active_dist
  , AVG(VeryActiveMinutes) as avg_very_active_minutes
  , AVG(FairlyActiveMinutes) as avg_fairly_active_minutes
  , AVG(LightlyActiveMinutes) as avg_lightly_active_minutes
  , AVG(SedentaryMinutes) as sedentary_minutes
  , AVG(Calories) as avg_calories
 FROM fitdata..dailyActivity_merged


 -- per user averages
SELECT Id
  , COUNT(Id) as days_observed
  , AVG(TotalSteps) as avg_daily_steps
  , AVG(VeryActiveDistance) as avg_very_active_dist
  , AVG(ModeratelyActiveDistance) as avg_mod_active_dist
  , AVG(LightActiveDistance) as avg_light_active_dist
  , AVG(SedentaryActiveDistance) as avg_sed_active_dist
  , AVG(VeryActiveMinutes) as avg_very_active_minutes
  , AVG(FairlyActiveMinutes) as avg_fairly_active_minutes
  , AVG(LightlyActiveMinutes) as avg_lightly_active_minutes
  , AVG(SedentaryMinutes) as sedentary_minutes
  , AVG(Calories) as avg_calories
 FROM fitdata..dailyActivity_merged
 GROUP BY Id
 ORDER BY avg_daily_steps DESC


 -- looking at steps, very active minutes, and avg daily calories burned
 SELECT Id 
  , COUNT (Id) as days_observed
  , AVG(TotalSteps) as avg_daily_steps
  , AVG(VeryActiveMinutes) as very_active_minutes
  , AVG(Calories) as avg_calories
 FROM
  fitdata..dailyActivity_merged
 GROUP BY Id
 ORDER BY very_active_minutes DESC
 
 -- looking at sedentary minutes vs avg daily calories burned
 SELECT Id 
  , COUNT (Id) as days_observed
  , AVG(SedentaryMinutes) as sedentary_minutes
  , AVG(Calories) as avg_calories
 FROM
  fitdata..dailyActivity_merged
 GROUP BY Id
 ORDER BY avg_calories DESC


--look at weight tracking and how it was tracked
SELECT Id, "Date", WeightPounds, BMI, IsManualReport
 FROM weightLogInfo_merged
 ORDER BY Id, "Date"

-- Sleep Data

SELECT * FROM sleepDay_merged

--Sleep averages and number of sleep observations recorded per user
SELECT AVG(TotalSleepRecords) as avg_sleep_records
  , AVG(TotalMinutesAsleep) as avg_sleep_minutes
  , AVG(TotalTimeInBed) as avg_time_in_bed
  , (AVG(TotalTimeInBed) - AVG(TotalMinutesAsleep)) as awake_in_bed
FROM
 sleepDay_merged


SELECT Id
 , COUNT (Id) as days_observed
 , AVG(TotalSleepRecords) as avg_sleep_records
 , AVG(TotalMinutesAsleep) as avg_sleep_minutes
 , AVG(TotalTimeInBed) as avg_time_in_bed
 , (AVG(TotalTimeInBed) - AVG(TotalMinutesAsleep)) as awake_in_bed
FROM
 sleepDay_merged
GROUP BY Id
ORDER BY awake_in_bed



