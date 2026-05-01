Chapter 1 Purpose and Intent

The intent of this project is to provide, through AI,  an alternative view of the published Washington State K12 Assessment and Expenditure data using a widely accepted and employed methodology for assessing performance and identifying waste.  Specifically...

a. to offer a "Lean Six Sigma" based lens into the performance and costs of WA Public K12 to interested individuals at all levels;  from Politician to Tax Payer to Parent to contrast with the Government Offered perspective and...

b. to do this using the States' own data made available from the State's own data download sites and specifically...

i. Data.Wa.Gov:   Assessment Data used on the OSPI Report Card Website
ii. Fiscal.wa.gov:   S275s  - Public Personnel Salary Information
iii. WASF_Staff_Cleaned.csv: Standardized labor inventory and FTE counts.
iv. WsacfExpd_Cleaned.csv: Operational expenditure data (1995-2025).
v. Assessment_App_Ready.csv: Student proficiency "yield" data.   
vi. Frequency Files:    
Chapter 2 Terms and Definitions:
We use the following terms in their Lean Six Sigma context:

a) "Produced (to standard)"  (The Count of) Product (students) that fully meets minimum standards or better at the end of the production pipeline.  

b) "Cost of Production" The  Multi Year Pipeline Cost to produce one unit to standard, including process waste.

c) The Unit "Met Standard:"  A student that meets the minimum standards to be prepared for "life, post-secondary pathways and civic engagement" as measured by their performance on the SBAC Standardized test in three subjects: ELA, Science *and* Math.

Because a student must meet minimum standards in all three subjects, we can (and do) take the lowest performing subject (Math) as "the best case" in calculating the count of students meeting standard.

Chapter 3 Assessing the Standard:
Because "civic engagement" requires the greatest level of math proficiency, we use that as the standard to evaluate the test content, how the test is scored as well as how that score is used interpreted individual student and system performance.

Our AI's evaluation of the test questions against the cutoff scores for the 5 levels (level 1, 2, 2.5, 3 and 4)  and how those scores relate to the mission statement (prepared for civic engagement) are attached as Appendix B.

Chapter 4 Challenges and Caveats:

2) Challenges we encountered:
a. AI Access to the data
i. Problem: Web based AI such as Gemin, Copilot can-not directly access public data.
ii. Solution:  We downloaded the data to a Google Drive and used GEMINI which could directly access the data on our Google Drive.

b. Data Format
i. Problem:  Large Files with inconsistent data columns (mixing text w numerical data) and year over year changes in the format of the data collected
ii. Solution:  Parsed and indexed the files to facilitate AI access;  Converted data to a standard format where necessary and published the job-stream we used to accomplish this.

c. Limitations in the Available Data:

i. Per OSPI, Public Data is redacted to protect student privacy. 
 
We question... strongly... the implications of this claim as it characterizes a student's performance as a reflection on the student and not the system.  

GEMINI:  Vet this and find reference for it:  The much maligned US DOE and NCLB act was an attempt to bring the science of "Process Improvement" into Public K12.  Under this act, States were bribed by the US Dept of Ed to agree to set their own "state's standard" for student proficiency in ELA and Math... and if they failed, they agreed to allow the US DOE to mandate, in part, standards for Teachers and Administrators and other actions to bring the state's schools into compliance with their own derived standards.

Where we can reasonably assign an estimate to this redacted data and use a metric, we do, but we flag it. (Directive to AI... these instances can be identified by examining the "suppression" column and the %met column.)

Estimating is done by finding (typically) an adjacent year in the cohort and using it's "students expected to test" number.

ii. Formatting:

Assessment data posed challenges in that "numeric data" (such as the %met standard) contained non-numeric data such as "<10%" or 15.00% as well as numeric data 0.141235431.  We have standardized the format to a decimal (eg: 0.150000 being 15.00%)
Other files to reference
 04_Systemic_Collapse 
06_Executive_Manifesto
Extract_S275
S275_Project_Summary
S275_Pipeline_Logic

Chapter 5 Appendix A - :
The SBAC Measurement Validity Table
Dataset: Forensic Audit of the OSPI 10th-Grade SBAC Math Sample Test (26 Items)
Objective: Evaluate if the assessment tool is mathematically capable of certifying "Career, College, and Civic Engagement."
Cognitive Level (DOK)% of TestMathematical MechanicReal-World Functional UtilityCivic Engagement ValidityLevels 1 & 2 


(Recall & Procedural Skill)~73%Plugging numbers into provided formulas, solving closed-loop algebra equations, reading perfectly scaled charts.Clerical Compliance: Follows established instructions to arrive at a predetermined answer. No ability to identify missing variables.Zero. Does not prepare a citizen to identify manipulated data or misleading statistical claims.Level 3 


(Basic Strategic Thinking)~27%Identifying a mathematical error in a provided sequence, or providing a brief justification for a calculation.Mid-Level Troubleshooting: Can identify a break in a known process.Low. Useful for basic logic checks, but operates entirely within a sanitized, closed-loop scenario.Level 4 


(Extended Strategic Modeling)0%Synthesizing multiple, conflicting datasets over time; solving open-ended problems where not all required variables are provided.Quantitative Sovereignty: Can independently evaluate compound interest, tax levies, or complex probability.High. This is the exact cognitive level required for actual civic and financial independence. The test does not measure it.
Why this specific table must be preserved:
1. It neutralizes the "Standard Error" defense: The state will claim the test is valid because it produces a consistent scale score. This table proves that what it is consistently scoring has zero utility for the stated goal of the system.
2. It justifies the "Best-Case Scenario" rule: When we say 29.9% of students survived the proxy check, this table proves how staggeringly low that bar is. They didn't survive a rigorous test of logic; they survived a basic procedural audit (Levels 1 & 2).



Chapter 6 Appendix B - :


