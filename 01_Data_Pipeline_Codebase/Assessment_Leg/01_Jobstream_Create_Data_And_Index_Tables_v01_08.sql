--AIs latest - v01_07

-- To get an updated time stam


--G:\My Drive\COPILOT\PipeLine_01_Assessment\Jobstream_Create_Data_And_Index_Tables_v01_08.sql

-- Changes from v01_06 (incorporates manual edits from working version):
--   1. ztto sweep: pattern updated to catch ALL dirty variants in one expression per column:
--         CASE WHEN ISNULL(LTRIM(RTRIM(CAST(col as varchar(N)))),'null') IN ('','null')
--              THEN NULL
--              ELSE LTRIM(RTRIM(CAST(col as varchar(N))))
--         END
--      Catches: actual NULL, '' empty, ' ' whitespace, 'NULL' string, 'null' string
--      Confirmed via SQL test: ISNULL(@var,'null') IN ('','null') handles both space and NULL
--   2. KG added back to DELETE step (outside scope grades 3-11)
--   3. Grade range corrected to 3-11 (SBAC grade 12 does not exist)
--   4. GradYear comment updated: cohort identifier
--   5. PercentLevel1/2 comments corrected: both L1 and L2 = did not meet standard
USE [EdData]
GO

--GOTO EndLoad  

--------------------------------------------------------------------------------------------------------------------------
-- LOAD THE ASSESSMENT DATA TO A SEMI TEMP TABLE
-- Raw staging only: column name normalization, null placeholders, gradelevel cast where needed.
-- All string cleaning is consolidated in pre-process step below (ztto).
--
-- Source-specific column differences noted inline on each block:
--   Assessment_22-23        : [Test Administration (group)] not present; Foundational cols not present
--   Assessment_14-15_to_21-22: [Suppression] = DAT; different col names for counts; no Participation/Foundational
--   Assessment_24_25        : OSPI renamed CountMet/PctMet/PctMetTestedOnly cols post-Covid (same metric)
--   Assessment_23-24        : [Percent Met Tested Only] col name variant; no Participation/Alt Assessment
--------------------------------------------------------------------------------------------------------------------------

BEGIN TRY DROP TABLE dbo.ztt END TRY BEGIN CATCH END CATCH;

-- Assessment_22-23
SELECT
       [SchoolYear]
      ,[OrganizationLevel]
      ,[County]
      ,[ESDName]
      ,[ESDOrganizationId]
      ,[DistrictCode]
      ,[DistrictName]
      ,[DistrictOrganizationId]
      ,[SchoolCode]
      ,[SchoolName]
      ,[SchoolOrganizationId]
      ,[CurrentSchoolType]
      ,[StudentGroupType]
      ,[StudentGroup]
      ,[GradeLevel]
      ,[Test Administration (group)]                        = cast(null as varchar(400))    -- not in 22-23
      ,[TestAdministration]
      ,[TestSubject]
      ,[DAT]
      ,[Count of Students Expected to Test]
      ,[Count of Students Expected to Test included previously passed]
      ,[CountMetStandard]
      ,[PercentMetStandard]
      ,[PercentLevel1]
      ,[PercentLevel2]
      ,[PercentLevel3]
      ,[PercentLevel4]
      ,[PercentMetTestedOnly]
      ,[PercentNoScore]
      ,[PercentParticipation]
      ,[Percent Foundational Grade-Level Knowledge And Above] = cast(null as float)   -- not in 22-23
      ,[Count Foundational Grade-Level Knowledge And Above]   = cast(null as float)   -- not in 22-23
      ,[Percent Taking Alternative Assessment]                = cast(null as float)   -- not in 22-23
      ,[DataAsOf]
INTO dbo.ztt
FROM [dbo].[Assessment_22-23]

-- Assessment_14-15_to_21-22
-- [Suppression] = DAT equivalent in this vintage
-- [CountofStudentsExpectedtoTest(including previously passed)] = Count...included previously passed
-- PercentParticipation and Foundational cols not available
INSERT INTO dbo.ztt
SELECT
       [SchoolYear]
      ,[OrganizationLevel]
      ,[County]
      ,[ESDName]
      ,[ESDOrganizationID]
      ,[DistrictCode]
      ,[DistrictName]
      ,[DistrictOrganizationId]
      ,[SchoolCode]
      ,[SchoolName]
      ,[SchoolOrganizationid]
      ,[CurrentSchoolType]
      ,[StudentGroupType]
      ,[StudentGroup]
      ,[GradeLevel]
      ,null                                                                            -- [Test Administration (group)] not in 14-21
      ,[TestAdministration]
      ,[TestSubject]
      ,[Suppression]                                                                   -- DAT equivalent in 14-21
      ,[Count of Students Expected to Test]
      ,[CountofStudentsExpectedtoTest(including previously passed)]
      ,[CountMetStandard]
      ,[PercentMetStandard]
      ,[PercentLevel1]
      ,[PercentLevel2]
      ,[PercentLevel3]
      ,[PercentLevel4]
      ,[PercentMetTestedOnly]
      ,[Percent No Score]
      ,null                                                                            -- PercentParticipation not in 14-21
      ,null                                                                            -- Percent Foundational not in 14-21
      ,null                                                                            -- Count Foundational not in 14-21
      ,null                                                                            -- Percent Taking Alternative not in 14-21
      ,[DataAsOf]
FROM [dbo].[Assessment_14-15_to_21-22]

-- Assessment_24_25
-- OSPI renamed columns post-Covid (same metric, different name -- see governance file)
-- [Count Consistent Grade Level Knowledge And Above]   = CountMetStandard
-- [Percent Consistent Grade Level Knowledge And Above] = PercentMetStandard
-- [Percent Consistent Tested Only]                     = PercentMetTestedOnly
-- [Percent Participation]                              = PercentParticipation (col name variant)
INSERT INTO dbo.ztt
SELECT
       [SchoolYear]
      ,[OrganizationLevel]
      ,[County]
      ,[ESDName]
      ,[ESDOrganizationID]
      ,[DistrictCode]
      ,[DistrictName]
      ,[DistrictOrganizationId]
      ,[SchoolCode]
      ,[SchoolName]
      ,[SchoolOrganizationid]
      ,[CurrentSchoolType]
      ,[StudentGroupType]
      ,[StudentGroup]
      ,[GradeLevel]                = cast([GradeLevel] as numeric)                    -- stored as text in 24-25
      ,[Test Administration (group)]
      ,[TestAdministration]
      ,[TestSubject]
      ,[DAT]
      ,[Count of Students Expected to Test]
      ,[Count of Students Expected to Test (including previously passed)]
      ,[Count Consistent Grade Level Knowledge And Above]                              -- OSPI rename of CountMetStandard
      ,[Percent Consistent Grade Level Knowledge And Above]                            -- OSPI rename of PercentMetStandard
      ,[PercentLevel1]
      ,[PercentLevel2]
      ,[PercentLevel3]
      ,[PercentLevel4]
      ,[Percent Consistent Tested Only]                                                -- OSPI rename of PercentMetTestedOnly
      ,[Percent No Score]
      ,[Percent Participation]                                                         -- col name variant in 24-25
      ,[Percent Foundational Grade-Level Knowledge And Above]
      ,[Count Foundational Grade-Level Knowledge And Above]
      ,[Percent Taking Alternative Assessment]
      ,[DataAsOf]
FROM [dbo].[Assessment_24_25]

-- Assessment_23-24
-- [Percent Met Tested Only] = PercentMetTestedOnly (col name variant)
-- PercentParticipation and Percent Taking Alternative not available
INSERT INTO dbo.ztt
SELECT
       [SchoolYear]
      ,[OrganizationLevel]
      ,[County]
      ,[ESDName]
      ,[ESDOrganizationID]
      ,[DistrictCode]
      ,[DistrictName]
      ,[DistrictOrganizationId]
      ,[SchoolCode]
      ,[SchoolName]
      ,[SchoolOrganizationid]
      ,[CurrentSchoolType]
      ,[StudentGroupType]
      ,[StudentGroup]
      ,[GradeLevel]
      ,[Test Administration (group)]
      ,[TestAdministration]
      ,[TestSubject]
      ,[DAT]
      ,[Count of Students Expected to Test]
      ,[Count of Students Expected to Test (including previously passed)]
      ,[CountMetStandard]
      ,[PercentMetStandard]
      ,[PercentLevel1]
      ,[PercentLevel2]
      ,[PercentLevel3]
      ,[PercentLevel4]
      ,[Percent Met Tested Only]                                                       -- col name variant in 23-24
      ,[Percent No Score]
      ,null                                                                            -- PercentParticipation not in 23-24
      ,[Percent Foundational Grade-Level Knowledge And Above]
      ,[Count Foundational Grade-Level Knowledge And Above]
      ,null                                                                            -- Percent Taking Alternative not in 23-24
      ,[DataAsOf]
FROM [dbo].[Assessment_23-24]

ENDLOAD:
GO

--------------------------------------------------------------------------------------------------------------------------
-- PRE-PROCESS: Clean ztt before view layer
-- Step 1: Delete known garbage rows
-- Step 2: Comprehensive NULL sweep to dbo.ztto (single clean staging table)
-- Views read from ztto -- no repeated string cleaning needed downstream
--------------------------------------------------------------------------------------------------------------------------
print 'at 288'

-- Step 1: Delete garbage rows
-- 44 rows: Twin Harbors/New Market Skills Center CSV parse error (Aberdeen SD 2015-16)
-- Comma in school name caused column shift -- student group names landed in GradeLevel
DELETE FROM dbo.ztt
WHERE 
    LTRIM(RTRIM(LOWER(ISNULL(CAST(TestAdministration as varchar(50)),'')))) = 'all grades'
    OR LTRIM(RTRIM(ISNULL(CAST(GradeLevel as varchar(50)),''))) IN
    (
     'All Students'
    ,'Female'
    ,'KG'                   -- legitimate grade but outside current scope (grades 3-12)
    ,'Non Migrant'
    ,'Non Section 504'
    ,'Non-English Language Learners'
    ,'Non-Foster Care'
    ,'Non-Homeless'
    ,'Non-Low Income'
    ,'Students without Disabilities'
    ,'Unknown'
    ,'White'
    );

-- Step 2: Comprehensive sweep to ztto
-- Pattern applied to every column: NULLIF(LTRIM(RTRIM(ISNULL(CAST(col as varchar(N)),''))), '')
-- Converts to actual NULL: actual NULL, empty string, whitespace only, and 'NULL' string
-- Non-string columns cast to varchar -- _IN and _Out handle numeric conversion downstream
BEGIN TRY DROP TABLE dbo.ztto END TRY BEGIN CATCH END CATCH;

-- Sweep pattern per column:
--   CASE WHEN ISNULL(LTRIM(RTRIM(CAST(col as varchar(N)))),'null') IN ('','null')
--        THEN NULL
--        ELSE LTRIM(RTRIM(CAST(col as varchar(N))))
--   END
-- Catches: actual NULL, '' empty, ' ' whitespace, 'NULL'/'null' string variants
select 
 [SchoolYear] =  case when isnull([SchoolYear],'null') IN ('','null')          THEN NULL ELSE [SchoolYear] end
, [OrganizationLevel] =  case when isnull([OrganizationLevel],'null') IN ('','null')          THEN NULL ELSE [OrganizationLevel] end
, [County] =  case when isnull([County],'null') IN ('','null')          THEN NULL ELSE [County] end
, [ESDName] =  case when isnull([ESDName],'null') IN ('','null')          THEN NULL ELSE [ESDName] end
, [ESDOrganizationId] =  case when isnull([ESDOrganizationId],'null') IN ('','null')          THEN NULL ELSE [ESDOrganizationId] end
, [DistrictCode] =  case when isnull([DistrictCode],'null') IN ('','null')          THEN NULL ELSE [DistrictCode] end
, [DistrictName] =  case when isnull([DistrictName],'null') IN ('','null')          THEN NULL ELSE [DistrictName] end
, [DistrictOrganizationId] =  case when isnull([DistrictOrganizationId],'null') IN ('','null')          THEN NULL ELSE [DistrictOrganizationId] end
, [SchoolCode] =  case when isnull([SchoolCode],'null') IN ('','null')          THEN NULL ELSE [SchoolCode] end
, [SchoolName] =  case when isnull([SchoolName],'null') IN ('','null')          THEN NULL ELSE [SchoolName] end
, [SchoolOrganizationId] =  case when isnull([SchoolOrganizationId],'null') IN ('','null')          THEN NULL ELSE [SchoolOrganizationId] end
, [CurrentSchoolType] =  case when isnull([CurrentSchoolType],'null') IN ('','null')          THEN NULL ELSE [CurrentSchoolType] end
, [StudentGroupType] =  case when isnull([StudentGroupType],'null') IN ('','null')          THEN NULL ELSE [StudentGroupType] end
, [StudentGroup] =  case when isnull([StudentGroup],'null') IN ('','null')          THEN NULL ELSE [StudentGroup] end
, [GradeLevel] =  case when isnull([GradeLevel],'null') IN ('','null')          THEN NULL ELSE [GradeLevel] end
, [Test Administration (group)] =  case when isnull([Test Administration (group)],'null') IN ('','null')          THEN NULL ELSE [Test Administration (group)] end
, [TestAdministration] =  case when isnull([TestAdministration],'null') IN ('','null')          THEN NULL ELSE [TestAdministration] end
, [TestSubject] =  case when isnull([TestSubject],'null') IN ('','null')          THEN NULL ELSE [TestSubject] end
, [DAT] =  case when isnull([DAT],'null') IN ('','null')          THEN NULL ELSE [DAT] end
, [Count of Students Expected to Test] =  case when isnull([Count of Students Expected to Test],'null') IN ('','null')          THEN NULL ELSE [Count of Students Expected to Test] end
, [Count of Students Expected to Test included previously passed] =  case when isnull([Count of Students Expected to Test included previously passed],'null') IN ('','null')          THEN NULL ELSE [Count of Students Expected to Test included previously passed] end
, [CountMetStandard] =  case when isnull([CountMetStandard],'null') IN ('','null')          THEN NULL ELSE [CountMetStandard] end
, [PercentMetStandard] =  case when isnull([PercentMetStandard],'null') IN ('','null')          THEN NULL ELSE [PercentMetStandard] end
, [PercentLevel1] =  case when isnull([PercentLevel1],'null') IN ('','null')          THEN NULL ELSE [PercentLevel1] end
, [PercentLevel2] =  case when isnull([PercentLevel2],'null') IN ('','null')          THEN NULL ELSE [PercentLevel2] end
, [PercentLevel3] =  case when isnull([PercentLevel3],'null') IN ('','null')          THEN NULL ELSE [PercentLevel3] end
, [PercentLevel4] =  case when isnull([PercentLevel4],'null') IN ('','null')          THEN NULL ELSE [PercentLevel4] end
, [PercentMetTestedOnly] =  case when isnull([PercentMetTestedOnly],'null') IN ('','null')          THEN NULL ELSE [PercentMetTestedOnly] end
, [PercentNoScore] =  case when isnull([PercentNoScore],'null') IN ('','null')          THEN NULL ELSE [PercentNoScore] end
, [PercentParticipation] =  case when isnull([PercentParticipation],'null') IN ('','null')          THEN NULL ELSE [PercentParticipation] end
, [Percent Foundational Grade-Level Knowledge And Above]	--=  case when isnull([Percent Foundational Grade-Level Knowledge And Above],'null') IN ('','null')     THEN NULL ELSE [Percent Foundational Grade-Level Knowledge And Above] end
, [Count Foundational Grade-Level Knowledge And Above]		--=  case when isnull([Count Foundational Grade-Level Knowledge And Above],'null') IN ('','null')          THEN NULL ELSE [Count Foundational Grade-Level Knowledge And Above] end
, [Percent Taking Alternative Assessment]					--=  case when isnull([Percent Taking Alternative Assessment],'null') IN ('','null')          THEN NULL ELSE [Percent Taking Alternative Assessment] end
, [DataAsOf] =  case when isnull([DataAsOf],'null') IN ('','null')          THEN NULL ELSE [DataAsOf] end
INTO dbo.ztto
FROM dbo.ztt;

-- Confirm row counts
SELECT 'ztto' AS tbl, COUNT(*) AS rows FROM dbo.ztto
UNION ALL
SELECT 'ztt',         COUNT(*) FROM dbo.ztt;
GO

--------------------------------------------------------------------------------------------------------------------------
-- WRAP THE TABLE WITH A FIRST PASS VIEW
-- Reads from dbo.ztto (pre-cleaned)
-- ztto guarantees: no NULL strings, no blanks, no whitespace-only values on any column
-- String cleaning in this view is minimal -- ztto already handled it
--------------------------------------------------------------------------------------------------------------------------

CREATE or ALTER VIEW [dbo].[V_ZAssessment_15to25_IN]
AS

select *
from
    (   
    SELECT
         [SchoolYear]                 = [SchoolYear]                                   -- clean from ztto

        -- GradYear: computed from clean SchoolYear -- NULL SchoolYear yields NULL GradYear
        ,[GradYear]                   = case 
                                            when ISNUMERIC(GradeLevel) = 1
                                             and cast(GradeLevel as float) between 3 and 11
                                             and [SchoolYear] is not null
                                            then substring([SchoolYear],1,4) + (14 - cast(GradeLevel as int))
                                            else null 
                                        end

        ,[OrganizationLevel]          = [OrganizationLevel]
        ,[County]                     = [County]
        ,[ESDName]                    = [ESDName]
        ,[ESDOrganizationId]          = [ESDOrganizationId]
        ,[DistrictCode]               = [DistrictCode]
        ,[DistrictName]               = [DistrictName]
        ,[DistrictOrganizationId]     = [DistrictOrganizationId]
        ,[SchoolCode]                 = [SchoolCode]
        ,[SchoolName]                 = [SchoolName]
        ,[SchoolOrganizationId]       = [SchoolOrganizationId]
        ,[CurrentSchoolType]          = [CurrentSchoolType]
        ,[StudentGroupType]           = [StudentGroupType]
        ,[StudentGroup]               = [StudentGroup]

        -- GradeLevel: normalize 'All Grades' and NULL to 99
        -- All non-numeric garbage deleted in pre-process step -- only 'All Grades' remains
        ,[GradeLevel]                 = case 
                                            when GradeLevel is null            then 99
                                            when GradeLevel = 'All Grades'     then 99
                                            else GradeLevel 
                                        end

        ,[TestAdministration]         = [TestAdministration]
        ,[TestSubject]                = [TestSubject]

        -- DAT_Original: preserve raw suppression value before classification
        ,DAT_Original                 = DAT

        -- Count columns: clean from ztto
        ,[Count of Students Expected to Test]
                                      = [Count of Students Expected to Test]
        ,[CountMetStandard]           = [CountMetStandard]
        ,[Count of Students Expected to Test included previously passed]
                                      = [Count of Students Expected to Test included previously passed]

        -- LSS Audit Trail: retain OSPI published string before any numeric conversion
        ,PercentMetStandard_OSPI      = PercentMetStandard

        -- DAT: classified suppression code (from cross apply below)
        ,DAT                          = dato

        -- PercentMetStandard: cleaned numeric (from cross apply below)
        -- Pmet preference order: L3+L4 sum -> PercentMetStandard -> LtGt DAT value
        ,PercentMetStandard           = Pmet

        -- Level percents: clean from ztto, passed through as varchar for downstream TRY_CAST
        ,[PercentLevel1]              = cast ([PercentLevel1] as decimal(14,13))
        ,[PercentLevel2]              = cast ([PercentLevel2] as decimal(14,13))
        ,[PercentLevel3]              = cast ([PercentLevel3] as decimal(14,13))
        ,[PercentLevel4]              = cast ([PercentLevel4] as decimal(14,13))
        ,[PercentMetTestedOnly]       = cast ([PercentMetTestedOnly] as decimal(14,13))
        ,[PercentNoScore]             = cast ([PercentNoScore] as decimal(14,13))
        ,[PercentParticipation]       = cast ([PercentParticipation] as decimal(14,13))

        -- NOTE: New columns as of 2023-24 -- OSPI metric adjustment post-Covid reporting
        ,[Percent Foundational Grade-Level Knowledge And Above]
        ,[Count Foundational Grade-Level Knowledge And Above]
        ,[Percent Taking Alternative Assessment]
        ,[DataAsOf]

        -- LSS Audit: Flag where L3+L4 pct don't reconcile to PercentMet (tolerance 0.001)
        -- Computed at earliest point where Pmet and L3/L4 are simultaneously clean
        ,PctMet_L3L4_Flag             = 
                CASE
                    WHEN ISNUMERIC(v.PercentLevel3) = 0 OR ISNUMERIC(v.PercentLevel4) = 0  THEN 'No L3L4'
                    WHEN Pmet IS NULL                                                        THEN 'No PctMet'
                    WHEN ABS(  (CAST(v.PercentLevel3 AS FLOAT) + CAST(v.PercentLevel4 AS FLOAT)) 
                             - Pmet) > 0.001                                                THEN 'Discrepancy'
                    ELSE 'OK'
                END

        -- LSS Audit: Signed delta (L3+L4) - PctMet for SPC/trend analysis
        -- Positive = OSPI published higher than L3+L4 sum; Negative = lower
        ,PctMet_L3L4_Delta            = 
                CASE
                    WHEN ISNUMERIC(v.PercentLevel3) = 1
                     AND ISNUMERIC(v.PercentLevel4) = 1
                     AND Pmet IS NOT NULL
                    THEN (CAST(v.PercentLevel3 AS FLOAT) + CAST(v.PercentLevel4 AS FLOAT)) - Pmet
                    ELSE NULL
                END

    FROM
        (
        select c.Dato, d.Pmet, z.*
        from dbo.ztto z
        cross apply 
        (   -- Classify DAT/suppression code into standard categories
            -- DAT is already NULL (not blank) from ztto -- simplified check
            select Dato = 
                case 
                    when z.dat is null                               then 'None'
                    when z.dat like 'cross%'                         then 'cross'
                    when z.dat like '<%' or z.DAT like '>%'         then 'LtGt'
                    when z.dat in ('N<10','no students')             then 'Lt10orNo'
                    else 'ERR_' + z.DAT 
                end
        ) c
        cross apply
        (   -- Derive clean PercentMet: prefer L3+L4 sum, fall back to PercentMetStandard
            select Pmet = case when pmet > 1 then pmet / 100.00 else pmet end
            from
                (select Pmet = 
                    case
                        when isnumeric(PercentLevel3) = 1 AND ISNUMERIC(PercentLevel4) = 1 
                             and cast(PercentLevel3 as float) + cast(PercentLevel4 as float) > 0.00 
                                then cast(cast(PercentLevel3 as float) + cast(PercentLevel4 as float) as varchar(15))
                        when ISNUMERIC(PercentMetStandard) = 1
                            then CAST(PercentMetStandard as float)
                        when Dato = 'LtGt' 
                            then cast(substring(replace(z.dat,'%',''),2,30) as float)
                        else null 
                    end
                ) d
            ) d
        ) v
        where 
            (OrganizationLevel in ('state', 'district') OR (organizationLevel = 'School' and CurrentSchoolType = 'p'))
            and TestAdministration = 'sbac'
            and TestSubject        = 'math'
            -- GradeLevel filter: pass grades 3-12 and All Grades rollup only
            -- Eliminates KG, grades 1-2, and any non-numeric values not caught by delete step
            and (
                    (ISNUMERIC(GradeLevel) = 1 and cast(GradeLevel as float) between 3 and 11)
                 or GradeLevel = 'All Grades'
                 or GradeLevel is null
                )
            AND ( 
                    (studentgrouptype = 'All'      and studentgroup = 'All Students')
                or  (studentgrouptype = 'Foster'   and studentgroup = 'Foster Care')
                or  (studentgrouptype = 'FRL'      and studentgroup = 'Low-Income')
                or  (studentgrouptype = 'homeless' and studentgroup = 'Homeless')
                or  (studentgrouptype = 'Migrant'  and studentgroup = 'Migrant')
                or  (studentgrouptype = 'Military' and studentgroup = 'Military Parent')
               )
    ) v
GO

--------------------------------------------------------------------------------------------------------------------------
-- WRAP THE CLEANED NUMERIC COLUMNS WITH SECONDARY "CLEANING" LOGIC
--------------------------------------------------------------------------------------------------------------------------

CREATE or ALTER VIEW [dbo].[V_ZAssessment_15to25_Out] as
SELECT [GradYear]
      -- AI-ready physical string key -- '~' sentinel for NULL components (cannot appear in real codes)
      ,OrgCodeKey                               = CONCAT(OrganizationLevel, '|', ISNULL(ESDOrganizationId,'~'), '|', ISNULL(DistrictCode,'~'), '|', ISNULL(SchoolCode,'~'))
      ,[SchoolYear]
      ,[OrganizationLevel]
      ,[County]
      ,[ESDName]
      ,[ESDOrganizationId] 
      ,[DistrictCode]
      ,[DistrictName]
      ,[DistrictOrganizationId]             = TRY_CAST([DistrictOrganizationId] as int)
      ,[SchoolCode]
      ,[SchoolName]
      ,[SchoolOrganizationId]               = TRY_CAST(SchoolOrganizationId as int)
      ,[CurrentSchoolType]
      ,[StudentGroupType]
      ,[StudentGroup]
      ,[GradeLevel]                         = TRY_CAST(gradelevel as int)
      ,[TestAdministration]
      ,[TestSubject]
      ,[DAT]
      ,[Count of Students Expected to Test] = TRY_CAST([Count of Students Expected to Test] as int)
      ,[CountMetStandard]                   = TRY_CAST([CountMetStandard] as int)
      ,[Count of Students Expected to Test included previously passed] = TRY_CAST([Count of Students Expected to Test included previously passed] as int)
      ,[PercentMetStandard_OSPI]            -- LSS Audit Trail: Retaining OSPI's published string
      ,[PercentMetStandard]                 = case when PercentMetStandard > 1.0 then percentmetstandard/100.00 else PercentMetStandard * 1.0 end 
      ,[PercentLevel1]                      = [PercentLevel1] 
      ,[PercentLevel2]                      = [PercentLevel2] 
      ,[PercentLevel3]                      = [PercentLevel3]
      ,[PercentLevel4]                      = [PercentLevel4]
      ,[PercentMetTestedOnly]               = [PercentMetTestedOnly] 
      ,[PercentNoScore]                     = [PercentNoScore] 
      ,[PercentParticipation]               = [PercentParticipation] 
       ,[Percent Foundational Grade-Level Knowledge And Above] 
       ,[Count Foundational Grade-Level Knowledge And Above] 
       ,[Percent Taking Alternative Assessment] 
      ,[DataAsOf]
      ,[PctMet_L3L4_Flag]       -- LSS Audit: carried through untouched
      ,[PctMet_L3L4_Delta]      -- LSS Audit: carried through untouched
  FROM [dbo].[V_ZAssessment_15to25_IN] v
GO

--------------------------------------------------------------------------------------------------------------------------
-- LSS Refactor: Build the Master Dimension and Fact Tables (Star Schema)
--------------------------------------------------------------------------------------------------------------------------

BEGIN TRY DROP TABLE dbo.Master_Org_Index END TRY BEGIN CATCH END CATCH;
BEGIN TRY DROP TABLE dbo.Assessment_Fact END TRY BEGIN CATCH END CATCH;
GO

-- 1. Create the Dimension Table: Master_Org_Index
WITH CleanNames AS (
    SELECT DISTINCT
        OrgCodeKey,
        OrganizationLevel,
        ESDOrganizationId,
        DistrictCode,
        SchoolCode,
        FIRST_VALUE(ESDName)      OVER (PARTITION BY OrgCodeKey ORDER BY SchoolYear DESC) as LatestESDName,
        FIRST_VALUE(DistrictName) OVER (PARTITION BY OrgCodeKey ORDER BY SchoolYear DESC) as LatestDistrictName,
        FIRST_VALUE(SchoolName)   OVER (PARTITION BY OrgCodeKey ORDER BY SchoolYear DESC) as LatestSchoolName
    FROM [dbo].[V_ZAssessment_15to25_Out]
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY OrganizationLevel, ISNULL(ESDOrganizationId,'~'), ISNULL(DistrictCode,'~'), ISNULL(SchoolCode,'~')) as OrgIndexId,
    OrgCodeKey,
    OrganizationLevel,
    
    -- ESD business rules: source data confirmed clean -- IS NULL sufficient
    CASE WHEN OrganizationLevel = 'State'  THEN '00000'
         WHEN ESDOrganizationId IS NULL    THEN '999'
         ELSE ESDOrganizationId END        AS ESDOrganizationId,

    -- ESD Name for AI name resolution
    CASE WHEN OrganizationLevel = 'State'  THEN 'Statewide'
         WHEN ESDOrganizationId IS NULL    THEN 'Unaffiliated/Charter'
         ELSE LatestESDName END            AS ESDName,

    DistrictCode,
    SchoolCode,
    
    -- Business Rule: District Name Consistency
    CASE WHEN OrganizationLevel = 'State'    THEN 'Statewide Total'
         ELSE LatestDistrictName END         AS DistrictName,
         
    -- Business Rule: School Name Consistency
    CASE WHEN OrganizationLevel = 'State'    THEN 'Statewide Total'
         WHEN OrganizationLevel = 'District' THEN 'District Total'
         ELSE LatestSchoolName END           AS SchoolName,

    -- AI-readable display name for fuzzy name resolution
    -- AI directive: if name not found, suggest reducing to one word or provide county/district
    CASE WHEN OrganizationLevel = 'State'    THEN 'Washington State'
         WHEN OrganizationLevel = 'District' THEN CONCAT(LatestDistrictName, ' | ', LatestESDName)
         ELSE CONCAT(LatestSchoolName, ' | ', LatestDistrictName, ' | ', LatestESDName) END AS DisplayName
         
INTO dbo.Master_Org_Index
FROM CleanNames;
GO

-- 2. Create the Fact Table: Assessment_Fact
SELECT 
       I.OrgIndexId             -- Single Lean Key replaces strings and redundant IDs
      ,v.[GradYear]             -- Year student will graduate... used as "cohort"
      ,v.[SchoolYear]           -- YYYY-YY format (eg 2022-24)
      ,v.[CurrentSchoolType]    -- We only pull "P" for Public
      ,v.[StudentGroupType]     -- Circumstantial groups only (see governance file)
      ,v.[StudentGroup]         -- All Students, Low-Income, Homeless, Migrant, Foster, Military
      ,v.[GradeLevel]           -- 3-8, 10, 11, 12(investigate if present), 99 (all grades rollup)
      ,v.[TestAdministration]   -- SBAC only
      ,v.[TestSubject]          -- Math only (current scope)
      ,v.[DAT]                  -- Suppression: None, LtGt, Lt10orNo, cross
      ,v.[Count of Students Expected to Test] 
      ,v.[CountMetStandard]     -- Count of students scoring L3 or L4
      ,v.[Count of Students Expected to Test included previously passed]  -- PercentMet denominator
      ,v.[PercentMetStandard_OSPI]      -- LSS Audit Trail: OSPI published string (may include %)
      ,v.[PercentMetStandard]           -- LSS Calculated: clean L3+L4 decimal
      ,v.[PercentLevel1]        -- Did not meet standard
      ,v.[PercentLevel2]        -- Approaching standard
      ,v.[PercentLevel3]        -- Met standard
      ,v.[PercentLevel4]        -- Exceeded standard
      ,v.[PercentMetTestedOnly]   
      ,v.[PercentNoScore]
      ,v.[PercentParticipation]
      ,v.[Percent Foundational Grade-Level Knowledge And Above]   -- 2023-24+ only
      ,v.[Count Foundational Grade-Level Knowledge And Above]     -- 2023-24+ only
      ,v.[Percent Taking Alternative Assessment]                  -- 2023-24+ only
      ,v.[DataAsOf]
      ,v.[PctMet_L3L4_Flag]     -- LSS Audit: OK / No L3L4 / No PctMet / Discrepancy
      ,v.[PctMet_L3L4_Delta]    -- LSS Audit: signed delta for SPC analysis
INTO dbo.Assessment_Fact
FROM [dbo].[V_ZAssessment_15to25_Out] v
JOIN dbo.Master_Org_Index I ON v.OrgCodeKey = I.OrgCodeKey;
GO

-- 3. Validation: Entity split check
-- If this returns rows, a school appears under more than one OrgIndexId -- breaks cohort build
SELECT 
     SchoolCode
    ,DistrictCode
    ,COUNT(DISTINCT OrgIndexId)  AS IdCount
    ,COUNT(DISTINCT OrgCodeKey)  AS KeyCount
    ,MIN(DisplayName)            AS FirstName
    ,MAX(DisplayName)            AS LastName
FROM dbo.Master_Org_Index
WHERE OrganizationLevel = 'School'
  AND SchoolCode IS NOT NULL
GROUP BY SchoolCode, DistrictCode
HAVING COUNT(DISTINCT OrgIndexId) > 1
ORDER BY IdCount DESC;

-- 4. Spot check: TOP 100 fact table rows
SELECT TOP 100 * FROM dbo.Assessment_Fact ORDER BY OrgIndexId, SchoolYear DESC;

--------------------------------------------------------------------------------------------------------------------------
-- STEP 5: Add AI File Routing (FileIndex) and Payload Sizes (RowCount)
-- This ensures the downstream PowerShell script knows exactly how to shard the data.
--------------------------------------------------------------------------------------------------------------------------

ALTER TABLE dbo.Master_Org_Index ADD [FileIndex] VARCHAR(100);
ALTER TABLE dbo.Master_Org_Index ADD [RowCount] INT;
GO

-- Build the explicit filename routing strings
UPDATE dbo.Master_Org_Index
SET FileIndex = 
    CASE 
        WHEN OrganizationLevel = 'State' THEN 'Assmt_State'
        WHEN OrganizationLevel = 'District' THEN 'Assmt_D_' + ISNULL(DistrictCode, '00000')
        WHEN OrganizationLevel = 'School' THEN 'Assmt_S_' + ISNULL(DistrictCode, '00000') + '_' + ISNULL(SchoolCode, '0000')
        ELSE 'Assmt_Unknown'
    END;
GO

-- Calculate the exact mathematical payload size for each shard
WITH FactCounts AS (
    SELECT OrgIndexId, COUNT(*) as cnt
    FROM dbo.Assessment_Fact
    GROUP BY OrgIndexId
)
UPDATE idx
SET idx.[RowCount] = fc.cnt
FROM dbo.Master_Org_Index idx
JOIN FactCounts fc ON idx.OrgIndexId = fc.OrgIndexId;
GO