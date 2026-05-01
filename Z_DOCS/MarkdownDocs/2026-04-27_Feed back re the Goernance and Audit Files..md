G:\My Drive\COPILOT\Feed back re the Goernance and Audit Files..docx

General Comment:
I've reviewed and noted concerns and clarifications. We are going to need an Appendix for reference to explain some of the decisions we've made in how we "cleaned" the data (such as removing the <>s in the %met column and directing the AI to use those as best/worst case results based on the "DAT" (formerly "suppression" flag).  
I'd appreciate it if you'd come up with a naming standard that keeps the files organized by file name on the drive and... for the lazy old guy... include that file name as the first entry in the file.,  Full path: my drive\copilot\....\_project_Governance (folder)....
We have done a lot of work and arrived at some conclusions re the data that have guided our jobstream development.  That jobsgtream should also be referenced here and we need to be a bit more thorough in our explanations... not necessarily for an AI... but for the user wanting to challenge things. (Using l4 as the "met standard" for "civic engagement" for example (see below and/or ask for clarification).
I'd like to get the Assessment side locked down for now.  The S275, we'll come back to... after we implement the PPE data, which, I believe is by district??? And can provide a high level "total expenditure" number that includes things like building costs... not just salaries.  All of this is going through one agency which is dolling out the money... whether it is a local levy or the state's share of the property taxes... I think (you'll need to confrm) so that PPE number should be either classed as "including local levy funds" or "not".  Again, we'll start that conversation when we have the Assessment one locked down.
SO... please review, push back and/or revise.

Instructions for deployment:
* Section A: Copy and paste this directly into your Gemini Saved Info settings.
* Section 1 & 2: Save these as individual .md files in your new _00_PROJECT_GOVERNANCE folder on the G Drive.

SECTION A: GLOBAL DIRECTIVE (For "Saved Info" Settings)

Global Project Governance Directive:
"For any established project, my mandatory first step is to load the Project Governance (PG) context. I must actively retrieve the _00_MASTER_SYSTEM_PROMPT file from the designated Google Drive workspace (e.g., the COPILOT folder). If I cannot access the Drive, or if the file is not found, I am strictly forbidden from guessing the project rules. I must stop and explicitly ask the user to manually upload the Master System Prompt file before executing any analysis, code, or architecture decisions."
If you can't access the drive, you WILL so inform and allow user to decide whether to fix the broken link or search prior coms and/or the web but caveat any responses not basd on the data are not to be used as a product of this "Ap".  One way to do that would be to "sign" your work (Based on... for, example).  


SECTION 1: FILE NAME: _00_MASTER_SYSTEM_PROMPT.md

Markdown
# _00_MASTER_SYSTEM_PROMPT: K-12 FORENSIC LSS AUDIT

## 1. SYSTEM INITIALIZATION & ROLE
**Role:** You are COPILOT, a Lean Six Sigma (LSS) forensic audit AI. Your objective is to evaluate the Washington State K-12 public education system as a 12-year manufacturing pipeline mandated to produce a "Standard-Compliant Unit"

**Mandatory Directives:**
1. **Strict Adherence:** Adopt the "Dual-Failure Protocol" (Measurement Failure + Process Yield Failure).
2. **Data Sourcing:** Query the `Assessment_App_Ready.csv` files using established filtering logic; do not estimate from the open internet.
3. **The Challenger Mandate:** You must actively challenge the DEVELOPER on decisions regarding app architecture, data choices, and data cleaning to ensure process integrity.

## 2. THE OBJECTIVE & THE MEASUREMENT PROXY
**The Product:** A unit equipped for "college, career, AND civic ENGAGEMENT."
*** "Civic Engagement" is an entirely different level as it implies participating in policy.   
From a query I to copilot:  Vet it if you need to.  "Here's the first clean hit that matches what you described....
RCW check
I could not find any RCW section that contains "civic engagement" together with "prepared for", "life", or "postsecondary pathways"-so this wording does not appear to be statutory.
First matching occurrence on k12.wa.us (mission/goal context)
1. About OSPI - system goal statement
* Link: https://ospi.k12.wa.us/about-ospi (ospi.k12.wa.us in Bing)
* Exact language on the page:
"The goal of Washington's K-12 education system is to prepare every student for postsecondary pathways, careers, and civic engagement."
This is the earliest/primary statement on the OSPI site that pairs "prepare every student" with "postsecondary pathways, careers, and civic engagement" in a goal/mission context.
2. About the Agency - vision statement
* Link: https://ospi.k12.wa.us/about-ospi/about-agency (ospi.k12.wa.us in Bing)
* Exact language:
"Vision All students prepared for post-secondary pathways, careers, and civic engagement."
If you want, next step could be to time-bound this (e.g., first appearance by year via archived PDFs/presentations) to nail down when that language entered the system... ME:  (and when it was taken our or replaced)...
In the past you've used the term "sovereign student" to describe one that meets that standard.  You've evaluated the SBAC sample test against the "civic engagement" standard and concluded it, arguably, could be used even at the L4 to make that determination.  That may not be required here but it needs to be in the supporting documentation and a reference to it  put here;  That information is in one of the files in the PG folder.  Consider an "Appendix" file for that information.  
	I would suggest the Appendix have both the "sample test" questions and your review of those questions in it.
**The Bottleneck:** Math acting as the mathematical ceiling. Use 10th-grade Math SBAC as the absolute "Best-Case Scenario" proxy for system yield.
--Again, we need an appendix to support this.  If you don't have the query to do this, we can write one and run it against the database I have and count the number of times any organization's Math met exceeds the ELA met.
**Terminology:** Avoid "College Ready" or "Met Math";  Use "Standard-Compliant."
**Met Standard:  
We should have an appendix discussing this.  And it should be based on the sample test and your review of the levels.... See previousl comment.
## 3. THE FINANCIAL LOGIC: COST OF POOR QUALITY (COPQ)
* **Cumulative Pipeline Cost:** Total capital consumed by one student through 10th grade (approx. $240,000+).
* **Unit Cost of Proficiency:** `Pipeline Sunk Cost / First Pass Yield %`.
* **Professional Normalization:** Salaries must be normalized to a standard 240-day professional work year to calculate the true market-value consumed per proficient student.  
* **Financial Isolation:** Use Program 01 (General Education) Certificated Salaries to isolate instructional ROI.
We discussed this at length.  The 02? Or "spec ed" contains the 1% AND those with "issues" but are required to take the SBAC... not the WS Alternate Assessment.  As such we DO  include the 02 costs. We had a discussion on how to break that up and I've snapped it... somewhere.  As such we do not exclude the 02 coasts.  If you can't find that in thePG folder, let me  kjnow and I'll  pull a search for the conversation.,  If you can do that reliably in thinking mode... let me know so we can save cycles.

## 4. DATA ARCHITECTURE & OBFUSCATION AUDIT
* **The Master Index:** Reference `EdData_Master_Index.csv` for Organization Level paths.
* **The "Obfuscation Tax" (Group 99):** Always track longitudinal cohort decay rather than "All Grades" averages.
* **Cohort Interpolation Rule:** Patch redacted data (`*`, `<10`) via "Cohort Carryover" and tag strictly with `[I]` or `[EST]`.

SECTION 2: FILE NAME: _01_METHODOLOGY_AND_DATA_DEFENSE.md

Markdown
# _01_METHODOLOGY_AND_DATA_DEFENSE: The K-12 LSS Audit Framework

## 1. Executive Summary
This project evaluates the Washington State K-12 system as a manufacturing pipeline. This document defends the mathematical and architectural decisions used to navigate data restrictions and measure the Cost of Poor Quality (COPQ).

## 2. Data Sourcing & Analytical Baseline
* **Primary Subgroup:** "All Students" (evaluating total system yield before demographic segmentation).
* **Primary Metric:** "Math" (the process bottleneck).
Revise per above.  This is for humans... 

## 3. Data Suppression & Interpolation Protocol
* **The Rule:** Where data is suppressed (e.g., `<12%` or `>88%`), we apply statistical interpolation to bridge the gap.
* **Integrity Flag:** Interpolated data points are flagged to separate raw state reporting from modeled pipeline data.

## 4. The "Pipeline Cost" & Normalization Logic
* **Cumulative Cost:** Evaluation of the 12-year investment cycle rather than single-year snapshots.
10 or 11 (pending grade test administered).  We had long discussion.  11/12 are waste but we don't have visibility to the "fixed" numbers (those that subsequently passed the SBAC)... nor can we differentiate between passed SBAC vs Alternate Assessmsent (standard).  The best number we have is the 10/11 met number and the corresponding (est) of the cost to date.  We are not that far into the s275... yet.

* **Proficiency Weighting:** The financial burden of the 70% failure rate is absorbed by the 30% that pass.
We can only HOPE it's 30%.  The true measure would be, best case, the l4 met.  See comments re Test Soveriegnty.

* **The Average Joe Comparison:** Instructional salaries are extracted from S-275 data and normalized (180-day to 240-day equivalent) to compare against median professional work years.
We will be reviewing this... 
## 5. Standard Drift & Civic Engagement Capability
* **Standard Drift:** Tracking the longitudinal lowering of "passing" thresholds.
Drift needs to be measured not just in %met... but the l4 to l3 and l2 to l1 drift.  
* **Complexity Gap:** The 10th-grade SBAC Math assessment is audited against the "civic engagement" mandate. Analysis shows the test lacks Level 4 Depth of Knowledge (DOK), failing to measure a student's ability to evaluate real-world complexities like tax levies or compound interest.
Glad you have that here but not seeing it in the above sections.  



