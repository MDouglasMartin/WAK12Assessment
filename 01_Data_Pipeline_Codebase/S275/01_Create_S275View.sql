use EdData;
go

CREATE VIEW [dbo].[vw_S275_LSS_Pipeline_Metrics] AS

WITH AggregateBuckets AS (
    SELECT 
        SchoolYear,
        codist,
        
        -- FINANCIAL SUMS (Captures EVERY dollar, including zero-hour TRI/Stipends)
        SUM(CAST(CASE WHEN droot BETWEEN 10 AND 29 THEN asssal ELSE 0 END AS BIGINT)) AS Cost_Management,
        SUM(CAST(CASE WHEN droot BETWEEN 30 AND 49 THEN asssal ELSE 0 END AS BIGINT)) AS Cost_Instruction,
        SUM(CAST(CASE WHEN droot >= 50 THEN asssal ELSE 0 END AS BIGINT)) AS Cost_Support,

        -- ASSIGNMENT HOURS SUMS
        SUM(CASE WHEN droot BETWEEN 10 AND 29 THEN asshpy ELSE 0 END) AS Hours_Management,
        SUM(CASE WHEN droot BETWEEN 30 AND 49 THEN asshpy ELSE 0 END) AS Hours_Instruction,
        SUM(CASE WHEN droot >= 50 THEN asshpy ELSE 0 END) AS Hours_Support,

        -- HEADCOUNT (Unique Humans)
        COUNT(DISTINCT CASE WHEN droot BETWEEN 10 AND 29 THEN CONCAT(LastName, FirstName) END) AS Headcount_Management,
        COUNT(DISTINCT CASE WHEN droot BETWEEN 30 AND 49 THEN CONCAT(LastName, FirstName) END) AS Headcount_Instruction,
        COUNT(DISTINCT CASE WHEN droot >= 50 THEN CONCAT(LastName, FirstName) END) AS Headcount_Support,

        -- MIN/MAX SPREAD (Filters out zero-hour stipends to find the true Base Salary floor/ceiling)
        MIN(CASE WHEN droot BETWEEN 10 AND 29 AND asshpy > 0 THEN (asssal * 1.0 / asshpy) * 2080 END) AS Min_Norm_Sal_Management,
        MAX(CASE WHEN droot BETWEEN 10 AND 29 AND asshpy > 0 THEN (asssal * 1.0 / asshpy) * 2080 END) AS Max_Norm_Sal_Management,
        MIN(CASE WHEN droot BETWEEN 30 AND 49 AND asshpy > 0 THEN (asssal * 1.0 / asshpy) * 2080 END) AS Min_Norm_Sal_Instruction,
        MAX(CASE WHEN droot BETWEEN 30 AND 49 AND asshpy > 0 THEN (asssal * 1.0 / asshpy) * 2080 END) AS Max_Norm_Sal_Instruction,
        MIN(CASE WHEN droot >= 50 AND asshpy > 0 THEN (asssal * 1.0 / asshpy) * 2080 END) AS Min_Norm_Sal_Support,
        MAX(CASE WHEN droot >= 50 AND asshpy > 0 THEN (asssal * 1.0 / asshpy) * 2080 END) AS Max_Norm_Sal_Support,
        
        -- THE FULLY LOADED BOTTOM LINE
        SUM(CAST(asssal AS BIGINT)) AS Total_System_Cost

    FROM [dbo].[vw_S275_Master_Decade]
    -- Drops empty phantom rows but allows valid zero-hour dollars to pass through
    WHERE asssal > 0 
    GROUP BY SchoolYear, codist
)

SELECT 
    SchoolYear,
    codist,
    
    Total_System_Cost,

    -- THE LSS RATIOS
    CAST((Cost_Instruction * 1.0) / NULLIF(Total_System_Cost, 0) AS DECIMAL(5,4)) AS Yield_Ratio_Instruction,
    CAST((Cost_Management * 1.0) / NULLIF(Total_System_Cost, 0) AS DECIMAL(5,4)) AS Yield_Ratio_Management,
    CAST((Cost_Support * 1.0) / NULLIF(Total_System_Cost, 0) AS DECIMAL(5,4)) AS Yield_Ratio_Support_Logistics,

    -- THE SPREAD METRICS (Headcounts and Min/Max)
    Headcount_Instruction,
    CAST(Min_Norm_Sal_Instruction AS DECIMAL(10,2)) AS Min_Norm_Sal_Instruction,
    CAST(Max_Norm_Sal_Instruction AS DECIMAL(10,2)) AS Max_Norm_Sal_Instruction,
    
    Headcount_Management,
    CAST(Min_Norm_Sal_Management AS DECIMAL(10,2)) AS Min_Norm_Sal_Management,
    CAST(Max_Norm_Sal_Management AS DECIMAL(10,2)) AS Max_Norm_Sal_Management,
    
    Headcount_Support,
    CAST(Min_Norm_Sal_Support AS DECIMAL(10,2)) AS Min_Norm_Sal_Support,
    CAST(Max_Norm_Sal_Support AS DECIMAL(10,2)) AS Max_Norm_Sal_Support,

    -- THE AVERAGE JOE NORMALIZATION (Fully Loaded Hourly Rate * 2080)
    CAST(((Cost_Instruction * 1.0) / NULLIF(Hours_Instruction, 0)) * 2080 AS DECIMAL(10,2)) AS Normalized_Avg_Instruction,
    CAST(((Cost_Management * 1.0) / NULLIF(Hours_Management, 0)) * 2080 AS DECIMAL(10,2)) AS Normalized_Avg_Management,
    CAST(((Cost_Support * 1.0) / NULLIF(Hours_Support, 0)) * 2080 AS DECIMAL(10,2)) AS Normalized_Avg_Support,

    -- THE LONGITUDINAL PIPELINE PROJECTION
    (Total_System_Cost * 11) AS Pipeline_11Year_Cumulative_Cost

FROM AggregateBuckets
--order by Normalized_Avg_Instruction desc