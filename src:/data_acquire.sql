-- Step 1: Create the FILTERED_PATIENTS table: Patients with the first ICU admission
-- This step identifies the first ICU admission for each patient (based on the minimum PATIENTUNITSTAYID).
-- This assumes that a patient might have multiple ICU admissions.

CREATE OR REPLACE TABLE EICU.PUBLIC.FILTERED_PATIENTS AS 
SELECT 
    DISTINCT UNIQUEPID,
    MIN(PATIENTUNITSTAYID) AS PATIENTUNITSTAYID,
FROM 
    EICU.PUBLIC.PATIENT 
GROUP BY 
    UNIQUEPID;

-- Verify the final result
SELECT * FROM EICU.PUBLIC.FILTERED_PATIENTS;
SELECT DISTINCT UNIQUEPID FROM EICU.PUBLIC.FILTERED_PATIENTS;


-- Step 2: Filter patients with ICU stay >= 48 hours (2 days)
-- This step filters out patients whose ICU stay was less than 48 hours (2 days).
--  This is based on the assumption that there is a table named APACHEPATIENTRESULT which contains the duration of ICU stay for each patient.

CREATE OR REPLACE TABLE EICU.PUBLIC.FILTERED_PATIENTS_48H AS 
SELECT 
    DISTINCT 
    p.PATIENTUNITSTAYID
FROM 
    EICU.PUBLIC.FILTERED_PATIENTS p
JOIN 
    EICU.PUBLIC.APACHEPATIENTRESULT apr
ON 
    p.PATIENTUNITSTAYID = apr.PATIENTUNITSTAYID
WHERE 
    apr.ACTUALICULOS >= 2;

-- Verify the table
SELECT * FROM EICU.PUBLIC.FILTERED_PATIENTS_48H;
SELECT DISTINCT PATIENTUNITSTAYID FROM EICU.PUBLIC.FILTERED_PATIENTS_48H;


-- Step 3: Create the PATIENT_FINAL_RESULT table
-- This step joins the filtered patients with the original PATIENT table to extract additional patient information.


CREATE OR REPLACE TABLE EICU.PUBLIC.PATIENT_FINAL_RESULT AS
SELECT
    p.PATIENTUNITSTAYID,
    p.UNIQUEPID,
    p.AGE,
    p.GENDER, 
    p.ETHNICITY,
    p.UNITDISCHARGESTATUS

FROM 
    EICU.PUBLIC.FILTERED_PATIENTS_48H fph 
JOIN  
    EICU.PUBLIC.PATIENT p 
ON 
    fph.PATIENTUNITSTAYID = p.PATIENTUNITSTAYID;

-- Verify the final result
SELECT * FROM EICU.PUBLIC.PATIENT_FINAL_RESULT;
SELECT DISTINCT PATIENTUNITSTAYID FROM EICU.PUBLIC.PATIENT_FINAL_RESULT;


-- Step 4: Create and insert value to LAB_RESULTS_AGGREGATED
-- Group measurements into eight-hour intervals (laboratory tests) using the median.
-- This step aggregates lab results into 8-hour intervals for each patient.  
-- It handles negative offsets by treating them as values for the first hour. 

CREATE OR REPLACE TABLE EICU.PUBLIC.LAB_RESULTS_AGGREGATED (
    PATIENTUNITSTAYID NUMBER(38,0),
    "Hours after admission to the ICU" NUMBER(5,0), -- Column for 8-hour intervals
    ALBUMIN NUMBER(9,2),
    BUN NUMBER(9,2),
    TOTALBILIRUBIN NUMBER(9,2),
    LACTATE NUMBER(9,2),
    BICARBONATE NUMBER(9,2),
    BANDNEUTROPHILS NUMBER(9,2),
    CHLORIDE NUMBER(9,2),
    CREATININE NUMBER(9,2),
    GLUCOSE NUMBER(9,2),
    HEMOGLOBIN NUMBER(9,2),
    HEMATOCRIT NUMBER(9,2),
    PLATELETCOUNT NUMBER(9,2),
    POTASSIUM NUMBER(9,2),
    PTT NUMBER(9,2),
    SODIUM NUMBER(9,2),
    WBCCOUNT NUMBER(9,2),
    PRIMARY KEY (PATIENTUNITSTAYID, "Hours after admission to the ICU") 
);

INSERT INTO EICU.PUBLIC.LAB_RESULTS_AGGREGATED
SELECT 
    l.patientUnitStayID,
    CASE
        WHEN l.labResultOffset < 0 THEN 0  -- Treat negative offsets as 0
        ELSE FLOOR(l.labResultOffset / 480) 
    END AS "Hours after admission to the ICU", 
    MEDIAN(CASE WHEN l.LABNAME = 'albumin' THEN l.LABRESULT END) AS ALBUMIN,
    MEDIAN(CASE WHEN l.LABNAME = 'bicarbonate' THEN l.LABRESULT END) AS BICARBONATE,
    MEDIAN(CASE WHEN l.LABNAME = 'BUN' THEN l.LABRESULT END) AS BUN,
    MEDIAN(CASE WHEN l.LABNAME = 'chloride' THEN l.LABRESULT END) AS CHLORIDE,
    MEDIAN(CASE WHEN l.LABNAME = 'creatinine' THEN l.LABRESULT END) AS CREATININE,
    MEDIAN(CASE WHEN l.LABNAME = 'bands %' THEN l.LABRESULT END) AS BANDNEUTROPHILS, 
    MEDIAN(CASE WHEN l.LABNAME = 'glucose' THEN l.LABRESULT END) AS GLUCOSE,
    MEDIAN(CASE WHEN l.LABNAME = 'Hct' THEN l.LABRESULT END) AS HEMATOCRIT,
    MEDIAN(CASE WHEN l.LABNAME = 'Hgb' THEN l.LABRESULT END) AS HEMOGLOBIN,
    MEDIAN(CASE WHEN l.LABNAME = 'lactate' THEN l.LABRESULT END) AS LACTATE,
    MEDIAN(CASE WHEN l.LABNAME = 'platelets x 1000' THEN l.LABRESULT END) AS PLATELETCOUNT,
    MEDIAN(CASE WHEN l.LABNAME = 'potassium' THEN l.LABRESULT END) AS POTASSIUM,
    MEDIAN(CASE WHEN l.LABNAME = 'PTT' THEN l.LABRESULT END) AS PTT,
    MEDIAN(CASE WHEN l.LABNAME = 'total bilirubin' THEN l.LABRESULT END) AS TOTALBILIRUBIN,
    MEDIAN(CASE WHEN l.LABNAME = 'sodium' THEN l.LABRESULT END) AS SODIUM,
    MEDIAN(CASE WHEN l.LABNAME = 'WBC x 1000' THEN l.LABRESULT END) AS WBCCOUNT
FROM 
    EICU.PUBLIC.LAB l -- Alias for LAB
WHERE l.labName IN ('albumin', 'bicarbonate', 'BUN', 'chloride', 'creatinine', 'bands %', 'glucose', 'Hct', 'Hgb', 'lactate', 'platelets x 1000', 'potassium', 'PTT', 'total bilirubin', 'sodium', 'WBC x 1000')
GROUP BY 
    l.patientUnitStayID, 
    CASE
        WHEN l.labResultOffset < 0 THEN 0  -- Treat negative offsets as 0
        ELSE FLOOR(l.labResultOffset / 480) 
    END 
ORDER BY l.patientUnitStayID;

-- Verify the table
SELECT * FROM EICU.PUBLIC.LAB_RESULTS_AGGREGATED;
SELECT DISTINCT PATIENTUNITSTAYID FROM EICU.PUBLIC.LAB_RESULTS_AGGREGATED;

-- Step 5: Create and insert value to VITAL_SIGNS_AGGREGATED
-- Group measurements into hourly intervals (vital signs) using the median.
-- This step aggregates vital sign measurements into hourly intervals for each patient.
-- It handles negative offsets by treating them as values for the first hour. 


CREATE OR REPLACE TABLE EICU.PUBLIC.VITAL_SIGNS_AGGREGATED AS 
SELECT
    vp.patientunitstayid,
    CASE 
        WHEN vp.observationoffset < 0 THEN 0  -- Treat negative offsets as 0
        ELSE FLOOR(vp.observationoffset / 60) 
    END AS "Hours after admission to the ICU",  -- Calculate hours
    MEDIAN(vp.heartrate) AS VITAL_HEARTRATE,
    MEDIAN(vp.respiration) AS VITAL_RESPIRATION,
    MEDIAN(vp.sao2) AS VITAL_SAO2,
    MEDIAN(vp.temperature) AS VITAL_TEMPERATURE,
    MEDIAN(vp.systemicsystolic) AS VITAL_SYSTEMIC_SYSTOLIC,
    MEDIAN(vp.systemicdiastolic) AS VITAL_SYSTEMIC_DIASTOLIC,
    MEDIAN(vp.systemicmean) AS VITAL_SYSTEMIC_MEAN
FROM 
    EICU.PUBLIC.VITALPERIODIC vp
GROUP BY 
    vp.patientunitstayid, 
    CASE 
        WHEN vp.observationoffset < 0 THEN 0  -- Treat negative offsets as 0
        ELSE FLOOR(vp.observationoffset / 60) 
    END;  

-- Verify the final result for vital signs
SELECT * FROM EICU.PUBLIC.VITAL_SIGNS_AGGREGATED;

-- Verify the table
SELECT * FROM EICU.PUBLIC.VITAL_SIGNS_AGGREGATED;
SELECT DISTINCT PATIENTUNITSTAYID FROM EICU.PUBLIC.VITAL_SIGNS_AGGREGATED;


-- Step 6: Filter the patient with with vital signs and lab measurements taken for more than 48 hours.
-- This step filters patients who have enough data for analysis.
--  LAB_RESULTS_AGGREGATED: Check for patients with a maximum "Hours after admission to the ICU" greater than 6.  Since your data is aggregated in 8-hour intervals, this ensures that they have at least 8 hours (6 + 2) of lab data.
--  VITAL_SIGNS_AGGREGATED: Check for patients with a maximum "Hours after admission to the ICU" greater than 48. This ensures they have at least 48 hours of vital sign data.


CREATE OR REPLACE TABLE EICU.PUBLIC.FINAL_PATIENTS AS
SELECT DISTINCT fph.PATIENTUNITSTAYID
FROM EICU.PUBLIC.FILTERED_PATIENTS_48H fph  -- Patients with ICU stay >= 48 hours
INTERSECT
SELECT DISTINCT lra.PATIENTUNITSTAYID
FROM EICU.PUBLIC.LAB_RESULTS_AGGREGATED lra
WHERE lra.PATIENTUNITSTAYID IN (
    SELECT PATIENTUNITSTAYID
    FROM EICU.PUBLIC.LAB_RESULTS_AGGREGATED
    GROUP BY PATIENTUNITSTAYID
    HAVING MAX("Hours after admission to the ICU") > 6
)
INTERSECT
SELECT DISTINCT vsa.PATIENTUNITSTAYID
FROM EICU.PUBLIC.VITAL_SIGNS_AGGREGATED vsa
WHERE vsa.PATIENTUNITSTAYID IN (
    SELECT PATIENTUNITSTAYID
    FROM EICU.PUBLIC.VITAL_SIGNS_AGGREGATED
    GROUP BY PATIENTUNITSTAYID
    HAVING MAX("Hours after admission to the ICU") > 48
);

-- Verify the final result
SELECT * FROM EICU.PUBLIC.FINAL_PATIENTS;
SELECT DISTINCT PATIENTUNITSTAYID FROM EICU.PUBLIC.FINAL_PATIENTS;


-- Step 7: Combine
-- This step combines all the data, including patient information, lab results, and vital signs, based on PATIENTUNITSTAYID.
--  It uses LEFT JOINs to ensure that all patients are included, even if they don't have matching data in all tables.


CREATE OR REPLACE TABLE EICU.PUBLIC.COMBINED_DATA AS
SELECT 
    fp.PATIENTUNITSTAYID,
    pfr.UNIQUEPID,
    pfr.AGE,
    pfr.GENDER,
    pfr.ETHNICITY,
    pfr.UNITDISCHARGESTATUS,
    lra."Hours after admission to the ICU" AS LAB_8HOURS,
    lra.ALBUMIN,
    lra.BUN,
    lra.TOTALBILIRUBIN,
    lra.LACTATE,
    lra.BICARBONATE,
    lra.CHLORIDE,
    lra.CREATININE,
    lra.GLUCOSE,
    lra.HEMOGLOBIN,
    lra.HEMATOCRIT,
    lra.PLATELETCOUNT,
    lra.POTASSIUM,
    lra.PTT,
    lra.SODIUM,
    lra.WBCCOUNT,
    vsa."Hours after admission to the ICU" AS VITAL_HOURS,
    vsa.VITAL_HEARTRATE,
    vsa.VITAL_RESPIRATION,
    vsa.VITAL_SAO2,
    vsa.VITAL_TEMPERATURE,
    vsa.VITAL_SYSTEMIC_SYSTOLIC,
    vsa.VITAL_SYSTEMIC_DIASTOLIC,
    vsa.VITAL_SYSTEMIC_MEAN
FROM EICU.PUBLIC.FINAL_PATIENTS fp
JOIN EICU.PUBLIC.PATIENT_FINAL_RESULT pfr ON fp.PATIENTUNITSTAYID = pfr.PATIENTUNITSTAYID
LEFT JOIN EICU.PUBLIC.LAB_RESULTS_AGGREGATED lra ON fp.PATIENTUNITSTAYID = lra.PATIENTUNITSTAYID AND lra."Hours after admission to the ICU" < 3
LEFT JOIN EICU.PUBLIC.VITAL_SIGNS_AGGREGATED vsa ON fp.PATIENTUNITSTAYID = vsa.PATIENTUNITSTAYID AND vsa."Hours after admission to the ICU" < 24
ORDER BY fp.PATIENTUNITSTAYID;

-- Verify the final result
SELECT * FROM EICU.PUBLIC.COMBINED_DATA;
SELECT DISTINCT PATIENTUNITSTAYID FROM EICU.PUBLIC.COMBINED_DATA;
