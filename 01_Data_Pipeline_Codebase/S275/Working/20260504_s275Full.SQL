/* S275_FORENSIC_AUDIT_RAW.sql
   Purpose: Report the raw data exactly as recorded, but aggregated per-human 
            to ensure the District Average is mathematically sound.
*/

WITH PerPersonTotals AS (
    SELECT 
        SchoolYear,
        CoDist,
        cert,
        CASE 
            WHEN droot BETWEEN 31 AND 34 THEN '01_Teacher'
            WHEN droot = 91 THEN '02_Para_Aide'
            WHEN droot BETWEEN 11 AND 13 OR droot BETWEEN 21 AND 25 THEN '03_Admin'
            ELSE '04_Other'
        END AS Labor_Silo,
        SUM(CAST(asssal AS BIGINT)) AS Total_Pay,
        SUM(assfte) AS Total_FTE
    FROM [dbo].[vw_S275_Master_Decade]
    GROUP BY SchoolYear, CoDist, cert, 
             CASE 
                WHEN droot BETWEEN 31 AND 34 THEN '01_Teacher'
                WHEN droot = 91 THEN '02_Para_Aide'
                WHEN droot BETWEEN 11 AND 13 OR droot BETWEEN 21 AND 25 THEN '03_Admin'
                ELSE '04_Other'
             END
)
SELECT 
    SchoolYear,
    CoDist,
    
    -- TEACHERS: Total capacity and raw spread
    CAST(SUM(CASE WHEN Labor_Silo = '01_Teacher' THEN Total_FTE ELSE 0 END) AS DECIMAL(10,2)) AS FTE_Teacher,
    COUNT(DISTINCT CASE WHEN Labor_Silo = '01_Teacher' THEN cert END) AS Headcount_Teacher,
    SUM(CASE WHEN Labor_Silo = '01_Teacher' THEN Total_Pay ELSE 0 END) AS Total_Spend_Teacher,
    
    -- THE AUDIT METRICS: Weighted Average vs Raw Extremes
    SUM(CASE WHEN Labor_Silo = '01_Teacher' THEN Total_Pay ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN Labor_Silo = '01_Teacher' THEN Total_FTE ELSE 0 END), 0) AS Avg_Annual_Teacher,
    
    -- Normalized to 1.0 FTE for the "Average Joe" check, warts and all
    MAX(CASE WHEN Labor_Silo = '01_Teacher' AND Total_FTE > 0 THEN Total_Pay / Total_FTE END) AS Max_Annual_Teacher,
    MIN(CASE WHEN Labor_Silo = '01_Teacher' AND Total_FTE > 0 THEN Total_Pay / Total_FTE END) AS Min_Annual_Teacher,

    -- ADMIN: (Governance & Floor Management)
    CAST(SUM(CASE WHEN Labor_Silo = '03_Admin' THEN Total_FTE ELSE 0 END) AS DECIMAL(10,2)) AS FTE_Admin,
    SUM(CASE WHEN Labor_Silo = '03_Admin' THEN Total_Pay ELSE 0 END) AS Total_Spend_Admin,
    SUM(CASE WHEN Labor_Silo = '03_Admin' THEN Total_Pay ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN Labor_Silo = '03_Admin' THEN Total_FTE ELSE 0 END), 0) AS Avg_Annual_Admin

FROM PerPersonTotals
GROUP BY SchoolYear, CoDist
ORDER BY Max_Annual_Teacher DESC;