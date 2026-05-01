
?? K-12 Value Stream Audit: Governance & Data Dictionary
Part 1: Core Audit Principles (The "Playbook")
* The "As-It-Lays" Accounting Rule: We do not cleanse, smooth, or normalize outlier salaries or extreme "Benefit-to-FTE" ratios. If a district paid a full-time benefit load for a 0.1 FTE employee, that represents actual economic friction (System Waste) and remains in the total pipeline cost.
* The 99% Mandate (The Quality Gate): The state mandate requires "all students" to be ready for life, career, and civic engagement. Only the ~1% of students taking the WA-AIM (alternate assessment for severe cognitive disabilities) are excluded from the denominator.
* The "Rework" Inclusion: Funding from Program 21 (Special Education) is included in the Total Pipeline Cost. Because 99% of students are held to the standard 10th-grade SBAC, the cost to remediate or support them (Rework) is part of the true cost of producing a proficient unit.
* The Capacity Reality (The 1,000-Hour Floor): * A standard 1.0 FTE on paper (ftedays $\times$ ftehrs) equals roughly 1,350 hours per year.
o Actual instructional time ("Machine Time") is closer to 1,000 hours per year.
o This capacity gap (compared to the 2,080-hour "Average Joe" year) must be accounted for when calculating the True Hourly Rate of instruction.

Part 2: Cost Calculation Formula (The Pipeline Math)
To calculate the 13-Year Cumulative Cost to produce one (1) student proficient in 10th-grade Math, we must establish the Total Burdened Cost at the district level.
* The Cash Bucket (W-2 Gross): tfinsal (Which should equal certbase + clasbase + othersal).
* The Benefit Burden (Shadow Cost): cins (Insurance) + cman (Mandatory Benefits, which includes cbrtn/Retirement).
* Total Employee Investment: tfinsal + cins + cman
?? The "Double-Dip" Assignment Defect (CRITICAL)
Because a single employee (recno) can have multiple assignments (asspct, asssal), their total employee costs (tfinsal, cins, cman) are repeated on every row.
* Governance Action: We cannot simply SUM(tfinsal). We must calculate the Allocated Assignment Burden.
* Allocation Formula: The cost of a specific row is: asssal + ((asssal / tfinsal) * (cins + cman)). This ensures benefits are proportionally distributed across the employee's various duties without inflating the district total.

Part 3: Categorization & Value-Stream Mapping (The Data Dictionary)
We use the following columns to determine where the money went (Direct Labor vs. Overhead vs. Waste).
1. Activity Codes (act) - The Functional Task:
* Activity 27: Direct Teaching (The "Value-Added" classroom labor).
* Activity 21-25: Instructional Support / Principals.
* Activity 11-15: Administrative Overhead / Board / Superintendent.
2. Duty Roots (droot) - The Operator Identity:
* 31-34: Direct Classroom Teachers.
* 11-13: Executive Administration.
* 90s (91-99): Classified Staff / Support / Facilities.
* 61: Paid Leave (100% Non-Value-Added Waste).
3. Program Codes (prog) - The Funding Bucket:
* Program 01: Basic Education (The Main Line).
* Program 21/24: Special Education / Learning Assistance (The Rework Line).
* Program 31: Vocational / CTE.
4. The "History of Horses" Variables:
* major: Used to identify the staff member's degree subject.
* camix1S: The state funding multiplier based on experience and degrees. Used to audit whether paying a premium for senior/highly-degreed staff correlates with higher Math proficiency yields.

Part 4: Pending Data Integrity Vetting (The "Todo" List)
Before aggregating the final view, the following systemic data defects must be vetted and diagnosed:
1. The 2014-2015 Triplication Defect:
o Issue: Raw data for 14-15 appears to be triple-reported. Applying SELECT DISTINCT across the whole row over-corrected and dropped the row count to less than 1/3.
o Action Required: Write a diagnostic query to find exactly which columns are causing the duplication (likely a date/timestamp or a minor allocation variance) so we can group the data cleanly without losing valid multi-assignment rows.
2. The asssal vs. tfinsal Gap Check:
o Issue: Districts frequently fail to distribute asssal (Assignment Salary) correctly to match tfinsal (Total Salary).
o Action Required: Create a vetting script that groups by recno and compares SUM(asssal) to the MAX(tfinsal). Any employee where the sum of their parts does not equal their total W-2 needs to be flagged.
3. The darea (Duty Area) Blindspot:
o Issue: darea is completely NULL across the dataset, masking subject-specific routing (Math vs. PE).
o Action Required: Formally abandon darea and pivot to using a combination of major and prog to proxy subject-matter alignment.

Next Step

