# Assessment Data Codebase Directives
> **Status:** Active (Pass 1)
> **Purpose:** Strict rules governing the SQL logic, data ingestion, and structural handling of the SBAC K-12 Assessment data.

## 1.0 Table Structure & Ingestion Constraints
* **Subgroup Isolation:** All baseline assessment queries MUST default to the "All Students" subgroup to establish the absolute system capability before any demographic segmentation is applied.
* **Subject Isolation:** All queries evaluating maximum system yield MUST isolate the "Math" subject identifier, as it represents the documented system bottleneck.

## 2.0 Handling Suppressed Values (The Null Protocol)
* **Flagging:** Any SQL script or processor importing OSPI assessment data must maintain the state's suppression flags (e.g., Suppression = TRUE or matching the <12% / >88% strings).
* **Interpolation Logic:** When applying algorithms to estimate suppressed n-sizes or percentages to maintain continuous time-series data, the resulting dataset must include an Is_Estimated boolean column. 
