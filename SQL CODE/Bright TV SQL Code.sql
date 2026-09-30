select * 
from`tv_database`.`bright_tv-casestudy`.`users_table` 
limit 100;

---How Big is the data
Select Count(*) AS number_0f_rows,
       Count (Distinct UserID) AS number_of_subscribers
from`tv_database`.`bright_tv-casestudy`.`users_table` ;

--checking for duplicates in my data

Select UserID,
 Count (*) AS duplicate_count
from`tv_database`.`bright_tv-casestudy`.`users_table`
GROUP BY UserID
Having Count(*) > 1 ;

---are there any rows where UserID is Null or has no values
Select Count(*) AS cnt
from`tv_database`.`bright_tv-casestudy`.`users_table`
Where UserID IS NULL;

---------------------------------------------------------------------
---Gender checks
---------------------------------------------------------------------
Select Distinct gender
from`tv_database`.`bright_tv-casestudy`.`users_table`;

Select COUNT(*)
from`tv_database`.`bright_tv-casestudy`.`users_table`
Where gender = ' ';

Select  Count(*) AS Cnt,
        Count(Distinct UserID) AS Subs,
    Case
        WHEN gender = ' ' THEN 'Unknown'
        WHEN gender ilike '%None%' THEN 'Unknown'
        Else gender
    END AS Gender
from`tv_database`.`bright_tv-casestudy`.`users_table`
GROUP BY Gender;

---------------------------------------------------------------------
---Race checks
---------------------------------------------------------------------
Select Distinct Race
from`tv_database`.`bright_tv-casestudy`.`users_table`;


Select  Distinct
    CASE
        WHEN Race IN ('other') THEN 'None'
        WHEN Race = ' ' THEN 'None'
    ELSE Race
END AS Race

from`tv_database`.`bright_tv-casestudy`.`users_table`;

Select Count(*) AS num_rows
from`tv_database`.`bright_tv-casestudy`.`users_table`
WHERE Race IS NULL;

---------------------------------------------------------------------
---Province checks
---------------------------------------------------------------------

Select Distinct Province
from`tv_database`.`bright_tv-casestudy`.`users_table`;

Select Distinct 
        CASE
            WHEN Province  = ' ' THEN 'Uncategoirzied'
            WHEN Province  = 'None' THEN 'Uncategoirzied'
        Else Province
END AS Region
from`tv_database`.`bright_tv-casestudy`.`users_table`;

---------------------------------------------------------------------
---Age
---------------------------------------------------------------------

select Min(Age) AS min_age,
       Max(Age) As Max_age
from`tv_database`.`bright_tv-casestudy`.`users_table`;

Select Count(*) AS Cnt
from`tv_database`.`bright_tv-casestudy`.`users_table`
Where Age IS NULL;
---Final Code
WITH users_table AS (
Select UserID,
        CASE
            WHEN Province  = ' ' THEN 'Uncategoirzied'
            WHEN Province  = 'None' THEN 'Uncategoirzied'
        Else Province
     END AS Region,
    Age,    
        CASE
            WHEN Age = 0 THEN 'Infants'
            WHEN Age BETWEEN 1 AND 12 THEN 'Kids'
            WHEN Age BETWEEN 13 AND 19 THEN 'Teenager'
            WHEN Age BETWEEN 20 AND 35 THEN 'Youth'
            WHEN Age BETWEEN 36 AND 50 THEN 'Adult'
            WHEN Age BETWEEN 51 AND 65 THEN 'Mature Adult'
            WHEN Age > 65 THEN 'Retired'
        END AS age_groups,

        Case
             WHEN Email IS NOT NULL OR  Email  = ' ' OR  Email  NOT IN ('None') THEN 1
         ELSE 0
         END AS Email_flag,

         Case 
            WHEN `Social Media Handle` IS NOT NULL OR  `Social Media Handle` != ' ' OR `Social Media Handle` NOT IN ('None') THEN 1
         ELSE 0
         END AS Social_Media_flag,

        CASE
            WHEN Race ilike ('%other%') THEN 'None'
            WHEN Race = ' ' THEN 'None'
            ELSE Race
        END AS Race,

         Case
            WHEN gender = ' ' THEN 'Unknown'
            WHEN gender ilike '%None%' THEN 'Unknown'
            Else gender
        END AS Gender

from`tv_database`.`bright_tv-casestudy`.`users_table`
),
viewership_table AS (
    select  
        COALESCE(UserID0,userid4,0) AS userid,
        ----Dates Extraction-----
        DAYNAME(RecordDate2) AS day_name,
        Hour(RecordDate2) AS hour_of_day,
        TO_CHAR(RecordDate2, 'yyyyMM') AS Month_id,-------TO_CHAR(): cINVERTS A DATE INTO A STRING & TO_DATE(): Converts a string into a date
        TO_DATE (RecordDate2) AS Watch_date,---is to extract the date from the timestamp in our table
        ---TIME (RecordDate2)AS Watch_time,
        DAY(RecordDate2) AS day_of_week,

        CASE
            WHEN day_name IN ('Sat','Sun') Then 'Weekend'
            Else 'Weekday'
        END AS day_classification,
        MONTHNAME(RecordDate2) AS Month_name,

    Case
        When Channel2 IN ('SawSee','Sawsee') Then 'SawSee'
        When Channel2 IN ('SuperSport Live Events','Supersport Live Events','Live on SuperSport','DStv Events 1') Then 'Live Events'
        Else Channel2 
        End AS Tv_channel,
        ----Time Checks / Time Extraction----
        date_format(RecordDate2, 'HH:mm:ss') AS Watch_time,
        CASE
            WHEN watch_time BETWEEN '00:00:00' AND '05:59:59' THEN '01. Midnight'
            WHEN watch_time BETWEEN '06:00:00' AND '11:59:59' THEN '02. Morning'
            WHEN watch_time BETWEEN '12:00:00' AND '16:59:59' THEN '03. Afternoon'
            WHEN watch_time BETWEEN '17:00:00' AND '23:59:59' THEN '04. Evening'
        END AS time_of_day,
        date_format(`Duration 2`, 'HH:mm:ss') AS duration,

        ROUND(Hour(`Duration 2`) * 60 + minute(`Duration 2`) + second(`Duration 2`) / 60, 2) AS duration_minute,
    
        CASE
            WHEN duration BETWEEN '00:05:00' AND '00:30:00' THEN '01.Low Usage <30 Mins'
            WHEN duration BETWEEN '00:30:01' AND '00:59:59' THEN '02.Medium Usage<60 Mins'
            WHEN duration >'00:59:59'  THEN '03.High Usage >60 Mins'
            ELSE '04.No Usage'
            END AS screen_time_bucket,

        CASE
             WHEN duration <= '00:05:00' THEN 'None User'
             ELSE 'Active User'
        END AS user_flag

From `tv_database`.`bright_tv-casestudy`.`viewership_table`

)
Select COALESCE(A.userid,B.userid) AS sub_id,
       Month_id,
       Watch_date,
       day_of_week,
       day_name,
       day_classification,
       Tv_channel,
       Watch_time,
       duration,
       duration_minute,
       screen_time_bucket,
       hour_of_day,
       Region,
       age_groups,
       Social_Media_flag,
       Email_flag,
       time_of_day,
       Race,
       Gender,
       user_flag
    
      
from viewership_table AS A 
left join users_table as B
ON A.userid = B.userid
Group by all;



