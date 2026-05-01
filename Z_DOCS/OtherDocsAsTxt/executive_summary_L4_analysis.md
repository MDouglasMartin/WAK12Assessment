# Executive Summary: Washington State K-12 Assessment Analysis
## Level 4 Bottleneck Investigation & Methodology Framework

**Date:** March 22-23, 2026  
**Scope:** Independent audit of Washington State K-12 education data using OSPI's own raw reporting files  
**Methodology:** Lean Six Sigma (LSS) applied to education pipeline, treating tax dollars as investment and measuring yield at output stage (grades 10-11)

---

## Core Findings (Empirically Verified)

### 1. Math is the Bottleneck (Level 3+): 99.6% Confirmed
SQL analysis of `[EdData].[dbo].[V_Assessment]` (grades 10-11, SBAC, StudentGroupType='ALL'):
- **Math < ELA in 5,844 of 5,870 school-year cases (99.6%)**
- Math is the ceiling on tri-factor proficiency (Math + ELA + Science)
- 26 exceptions suspected to be suppressed data or STEM-magnet selection effects

**Implication:** Any student who meets the tri-factor standard (all three subjects at Level 3+) is constrained by Math performance. Math is the system bottleneck.

### 2. Level 4 Performance (Actual Mastery): 14.9% Current, 12.3% 10-Year Average
- **2024-25 Grade 10 Math Level 4:** 14.9% (exceeded standard)
- **10-year average (2014-15 through 2024-25):** 12.3%
- Level 4 = can actually MASTER the test content (verified: 93% Algebra I, mid-year curriculum)

**Implication:** Only ~15% of Washington 10th graders can master mid-year Algebra I. This is what "exceeding standard" means on a test measuring first-semester high school math.

### 3. OSPI Marketing vs. Pipeline Reality: 32-Point Gap
- **OSPI reports:** 63.3% "Students Showing Foundational Grade-Level Knowledge and Skills or Above" (all grades, includes Level 2 "nearly meets" threshold)
- **Output stage reality (Grade 10):** 30.8% Met Standard (Level 3+), 14.9% Exceeded Standard (Level 4)
- **The gap:** OSPI uses all-grades aggregate data and a rebranded metric (summer 2024) that includes the "temporary" Level 2 threshold set in August 2015

**Implication:** Statistical manipulation hides systemic failure. The public sees 63%; graduates achieve 31%.

### 4. SBAC Test Content: Verified by Direct Examination
File: `Appendix_SBAC_MathTest.docx` (28 questions, all imaged)
- **93% of questions are Algebra I content (mid-year/first-semester)**
- 2 geometry questions (7%): basic parallelogram properties, right triangle trig
- Zero Algebra II, zero Precalculus, zero advanced content
- State official's characterization ("21-question mid-year Algebra I test with maybe one or two geometry questions") = **substantially accurate**

**Implication:** Level 3 ("Met Standard") = can do first-semester algebra. Level 4 ("Exceeded Standard") = can master first-semester algebra. Neither represents "college readiness" as marketed. The bar is absurdly low, and 85% of students still can't clear it.

### 5. The Civic Engagement Gap (Framework Established, Full Analysis Pending)
State mission includes producing civically engaged citizens. Math skills required for civic engagement (percentages, statistics, financial literacy, data interpretation) have **zero overlap** with SBAC test content (polynomial factoring, fractional exponents, systems of equations).

**Implication:** The system tests content irrelevant to its stated mission, then markets failure as success.

---

## Historical Context (Verified)

### NCLB → ESSA Transition (2002-2015)
- **NCLB (2002):** Required 12-year timeline to proficiency, annual progress targets, consequences for failure including restructuring
- **WA joins SBAC (2014-15):** Adopted new test right as 12-year NCLB deadline loomed; immediately set "temporary" Level 2 graduation threshold (below proficiency)
- **ESSA (December 2015):** Led by Sen. Patty Murray (D-WA), eliminated federal requirement for teacher evaluation tied to test scores
- **Result:** Accountability removed, bar lowered, trajectory flattened

### Metric Rebranding (Summer 2024)
- **Original metric:** "Percent Met Standard" (Level 3+)
- **Rebranded metric:** "Students Showing Foundational Grade-Level Knowledge and Skills or Above" (includes Level 2 "nearly meets")
- **Effect:** OSPI can claim 20+ percentage point "improvement" by simply moving the goalposts
- **Political blowback:** Sen. John Braun (R-WA) called it "inflating percentages," comparing it to counting everyone who didn't flunk when the count used to be everyone who got a C or better

---

## Analytical Framework & Methodology Decisions

### Decision 1: Grades 10-11 Only (Output Stage)
**Rationale:** Measuring product quality at the output stage, not mid-production. These are students about to graduate. If the system can't produce proficiency here, earlier grade performance is irrelevant.

### Decision 2: Math as Baseline Metric
**Rationale:** 
1. Math is the bottleneck in 99.6% of tri-factor cases
2. Test content is objectively verifiable (93% Algebra I)
3. Level thresholds have concrete meaning (L3 = met Alg I, L4 = exceeded Alg I)
4. Worst-case/best-case: If Math performance improves, ELA/Science likely follow

**When to revisit:** When Math performance reaches 70%+ statewide or matches ELA consistently

### Decision 3: Skip ELA Level 4 Comparison
**Rationale:** 
- Unknown which ELA level represents "civic literacy" threshold
- Any choice invites controversy without adding analytical value
- Math story stands alone regardless of ELA Level 4 performance
- Potential exception analysis: ~30 schools where Math > ELA likely represent STEM magnets or selection effects, proving system stratification rather than contradicting the bottleneck finding

### Decision 4: Level 4 as "Real Proficiency" Metric
**Rationale:** Given test content (93% mid-year Algebra I), Level 4 ("Exceeded Standard") is the closest proxy for "can actually DO first-semester algebra." Level 3 ("Met Standard") may represent bare minimum passage, not mastery.

**Conservative approach:** We lead with Level 3+ data (OSPI's own "Met Standard" threshold) to make the case unassailable. Level 4 data strengthens the argument but isn't required.

### Decision 5: Lead with the Delta, Not the Drama
**Framing:** "Three independent AI systems analyzed Washington State's own education data. They found performance rates 32-49 percentage points lower than the state publicly reports. Here's the audit trail."

**Tone:** Clinical, factual, relentless. Show the picture. Don't clutch pearls.

---

## Data Sources & Verification

**Primary:** `[EdData].[dbo].[V_Assessment]` - Washington State's own raw assessment reporting data  
**Key fields:** SchoolYear, GradeLevel, StudentGroupType, TestAdministration, TestSubject, PercentMetStandard, PercentLevel3, PercentLeveL4, Percent Foundational Grade-Level [rebrand]

**Test content verification:** `Appendix_SBAC_MathTest.docx` - complete image set of all 28 SBAC Math questions

**Historical policy verification:** 
- NCLB Executive Summary (ED.gov)
- ESSA passage documentation (Patty Murray co-sponsor verified)
- OSPI Report Card metric rebrand (summer 2024, documented via web search)

---

## Next Steps

1. **S275 financial data integration:** Connect per-pupil expenditure to performance outcomes; calculate "cost per proficient student"
2. **PPE files analysis:** Two views of per-pupil expenditure; reconcile with S275 aggregates
3. **Gen Ed vs. Spec Ed allocation:** Determine how to apportion 01 (Gen Ed) and 02 (Spec Ed) salary expenses when Spec Ed includes both SBAC-tested and AIM students
4. **Grade-band apportionment:** Allocate costs across Elementary/Middle/High School when staff serve multiple levels
5. **Science data completion:** Add Science bottleneck analysis to complete tri-factor picture
6. **Exception investigation:** Analyze 26 cases where Math > ELA (suppression hypothesis or STEM selection effects)

---

## Public Access Interface

**Status:** AI-native tool ready at GitHub; awaiting Claude API integration for public query interface  
**Function:** "Want to know how your school is doing? Ask AI here..."  
**Audience:** Parents, taxpayers, journalists, legislators - anyone who wants to audit the $20B/year K-12 pipeline using the state's own data

---

## Collaboration Model

**User role:** Strategic direction, insider knowledge (decade inside WA state agency), empirical verification, active policing of AI language drift  
**Claude role:** Structure, verification, articulation, document creation, challenge assumptions  
**Pattern:** Mutual accountability - both parties push back on unsupported claims, verify with data, document decisions

**Key principle:** Collaborator, not collaborateur. The AI audits the user's claims as rigorously as the user audits OSPI's claims.
