# S275 Financial Data Integration Framework
## Applying Assessment Analysis Methodology to Cost-Per-Outcome Calculations

**Version:** 1.0  
**Date:** March 23, 2026  
**Purpose:** Establish principles for connecting per-pupil expenditure (S275/PPE files) to proficiency outcomes (V_Assessment data)

---

## Core Objective

**Calculate:** Cost per proficient student at output stage (grades 10-11)  
**Metric:** Total expenditure ÷ number of students meeting Math Level 3+ standard  
**Result:** "Million Dollar Student" - what it actually costs Washington taxpayers to produce one proficient graduate

---

## Principles Carried Forward from Assessment Analysis

### 1. Output Stage Focus
Just as we measured proficiency at grades 10-11 (output stage), we measure TOTAL SYSTEM COST through grade 11, not just annual costs.

**Implication:** K-11 cumulative expenditure per student, not single-year cost

### 2. Math as Baseline
Since Math is the bottleneck (99.6% of cases), cost per Math-proficient student is the system's effective cost per tri-factor proficient student.

**Alternative view:** Cost per tri-factor proficient student (Math AND ELA AND Science all at L3+) - this will be slightly higher but more precise.

### 3. Conservative First, Comprehensive Later
Start with cleanest allocation (Gen Ed only), then add complexity (Spec Ed, cross-grade staff, facilities).

**Strategy:** Build the model in layers, documenting assumptions at each step.

### 4. Range-Based Estimates
When precise allocation is impossible, use ranges with documented assumptions rather than false precision.

**Coming attractions:** Gen Ed vs. Spec Ed debate, grade-band apportionment debates

---

## Anticipated Allocation Challenges & Resolutions

### Challenge 1: Gen Ed (01) vs. Spec Ed (02) Salaries

**Initial position (conservative):**
- **Include:** 01 (Gen Ed) salaries - 100% attributable to SBAC pipeline
- **Exclude:** 02 (Spec Ed) salaries - serves both SBAC and AIM populations

**Expected challenge:** "Spec Ed has two classes of students - SBAC-tested and AIM (Alternative Assessment). You can't exclude all of 02."

**Resolution framework:**
1. Verify: What percentage of Spec Ed students take SBAC vs. AIM?
2. Options:
   - **Conservative:** Include 01 only
   - **Moderate:** Include 01 + (SBAC-tested Spec Ed % × 02)
   - **Comprehensive:** Include 01 + all 02 (assumes AIM students still consume K-11 resources even if not SBAC-tested)
3. **Report all three:** Show range from conservative to comprehensive
4. **Default to moderate** for headline number, note range in methodology

**Data needed:** 
- Total Spec Ed enrollment by school/district/year
- SBAC participation vs. AIM participation counts
- If unavailable: use statewide ratio as proxy

### Challenge 2: Grade-Band Apportionment

**Problem:** Some staff serve multiple grade bands (e.g., K-12 counselors, split elementary/middle assignments, district-level curriculum specialists).

**S275 structure:** Expenditures may be reported at district level or aggregated across grades, not always cleanly split by elementary/middle/high school.

**Resolution framework:**
1. **Identify clean categories:**
   - Building-level staff clearly assigned to HS = 100% to grades 9-12
   - Building-level staff clearly assigned to ES/MS = exclude
   - District-level staff = apportion

2. **Apportionment methods (in order of preference):**
   - **Method A:** FTE allocation if S275 specifies (best)
   - **Method B:** Enrollment proportion (e.g., if HS is 30% of district enrollment, assign 30% of district-level costs)
   - **Method C:** Equal distribution across grade bands if no better data

3. **Document:** Which method used, why, what data supports it

**Example:** District superintendent serves K-12. Method B: If HS enrollment is 1,200 of 4,000 district total (30%), assign 30% of superintendent salary to HS costs.

### Challenge 3: Facilities and Capital Costs

**Problem:** S275 includes facilities costs, but buildings serve multiple cohorts over time.

**Question:** Do we include facilities in per-student cost, or exclude as infrastructure?

**Resolution framework:**
1. **Start without facilities** (operating costs only) - cleaner comparison across districts
2. **Add facilities in separate analysis** - shows total taxpayer investment
3. **Report both:** "Operating cost per proficient student: $X. Total cost including facilities: $Y."

**Rationale:** Operating costs = annual recurring investment. Facilities = long-term capital investment. Both matter, but they answer different questions.

### Challenge 4: Longitudinal Cohort Tracking

**Ideal:** Track actual cohort from K through 11, sum real costs for those specific students.

**Reality:** Data structure may not support true cohort tracking; students move in/out of district.

**Pragmatic approach:**
- Use K-11 cumulative average per-pupil expenditure as proxy
- Multiply by 12 years (K-11) for order-of-magnitude estimate
- Note limitation: "This is average annual cost × 12 years, not true cohort tracking"

**Alternative:** If data allows, track 5-year or 10-year cohorts and sum actual expenditures.

### Challenge 5: High-Cost Outliers

**Problem:** Some districts have extremely high per-pupil costs due to small size, geographic isolation, or specialized programs.

**Question:** Include or exclude when calculating statewide averages?

**Resolution:**
- **Report statewide median** as well as mean (median is robust to outliers)
- **Disaggregate:** Urban vs. rural, small vs. large districts
- **Flag but don't exclude:** "District X spends $45K/student and graduates 8% proficient. District Y spends $18K/student and graduates 35% proficient."

**Goal:** Show the RANGE of efficiency, not just the average.

---

## Analytical Sequence (Recommended)

### Phase 1: Clean Baseline
**Scope:** Gen Ed (01) salaries + operating costs (exclude facilities), grades 9-12 only, Math Level 3+ as outcome  
**Output:** "It costs Washington taxpayers $X in Gen Ed operating costs per Math-proficient 10th grader"  
**Purpose:** Establish unassailable baseline - most conservative case

### Phase 2: Moderate Expansion
**Scope:** Add Spec Ed (02) proportion for SBAC-tested students, still exclude facilities  
**Output:** "Including Spec Ed services for SBAC-tested students: $Y per proficient student"  
**Purpose:** More comprehensive cost picture, still defensible

### Phase 3: Full System Cost
**Scope:** Add facilities, district-level overhead, K-8 costs (cumulative), comprehensive allocation  
**Output:** "Total K-11 system cost per proficient graduate: $Z"  
**Purpose:** Complete taxpayer investment picture - "Million Dollar Student" calculation

### Phase 4: Efficiency Analysis
**Scope:** Compare cost-per-outcome across districts, identify high-performers and low-performers  
**Output:** "Districts A, B, C produce proficiency at $X per student. Districts D, E, F spend $2X per student for half the outcomes."  
**Purpose:** Show taxpayers where their money is working and where it isn't

---

## Data Quality Checks

Before running calculations, verify:

1. **S275 coverage:** Do we have complete data for target years? Any districts missing?
2. **PPE reconciliation:** Do PPE files match S275 aggregates? If not, why?
3. **Enrollment alignment:** Do S275 enrollment counts match V_Assessment counts?
4. **Suppression impact:** How many schools/districts have suppressed assessment data? Can we calculate costs for those?

**Rule:** If we can't calculate cost-per-outcome due to missing/suppressed data, FLAG IT. "X% of students attend schools where we cannot calculate cost-per-outcome due to data suppression."

---

## Narrative Framing

### The Conservative Case (Phase 1):
"Using only General Education operating costs and focusing on grades 9-12, Washington spends $X to produce each Math-proficient 10th grader. This is the most conservative estimate, excluding Special Education, facilities, and K-8 investment."

### The Moderate Case (Phase 2):
"Including Special Education services for SBAC-tested students, the cost rises to $Y per proficient student. This is still conservative - it excludes facilities and earlier-grade investments."

### The Complete Picture (Phase 3):
"The total K-11 system investment per proficient graduate - including all staff, facilities, and operational costs - is $Z. This is what Washington taxpayers actually spend to produce one student who can meet the state's own minimum standard on a mid-year Algebra I test."

### The Efficiency Question (Phase 4):
"Some districts produce proficiency at half the statewide average cost. Others spend double and get worse results. The system is not just failing - it's failing inefficiently."

---

## Red Lines: What We Will NOT Do

1. **Cherry-pick cheap districts** to make system look efficient
2. **Exclude 02 (Spec Ed) entirely** without acknowledging SBAC-tested Spec Ed population
3. **Use all-grades costs with output-stage outcomes** (inflates efficiency by hiding K-8 investment)
4. **Report single number without range/assumptions** when allocation is contested
5. **Hide outliers** - show the full distribution
6. **Claim precision we don't have** - if it's an estimate, say so

---

## Success Criteria

We will know this framework is working if:

1. **OSPI cannot attack the methodology** because we used their data and conservative assumptions
2. **Different AI systems produce consistent results** when given the same data and directives
3. **Contested allocations are documented** with rationale for each choice
4. **Taxpayers can understand the numbers** without a PhD in education finance
5. **Efficiency outliers are identified** so best practices can be studied (or worst practices investigated)

---

## Open Questions for S275 Work

1. **S275 file structure:** Is expenditure data already aggregated by grade band, or district-level only?
2. **PPE reconciliation:** How do PPE files relate to S275 aggregates? Two views of same data, or different methodologies?
3. **Cohort tracking:** Can we track actual cohorts K-11, or use average annual costs?
4. **Spec Ed participation:** What percentage of Spec Ed students take SBAC vs. AIM? Is this in the data?
5. **Facilities vs. operations:** Are facilities costs clearly separated in S275, or bundled?

**Next step:** Examine S275 file structure, answer these questions, refine allocation methodology accordingly.

---

## Lessons from Assessment Work: What Worked

1. **Start conservative, add complexity** - Built credibility before introducing contested estimates
2. **Document decisions in real-time** - Didn't wait until end to explain choices
3. **Challenge each other** - User pushed back on AI, AI pushed back on user
4. **Verify historical claims** - Didn't assume, searched and confirmed
5. **Show the receipts** - Every claim tied to data source
6. **Admit limitations** - "We don't know X, so we estimated Y with assumption Z"

**Apply these to S275:** Same rigor, same transparency, same mutual accountability.

---

## Version History

**v1.0 (March 23, 2026):** Initial framework based on patterns from assessment bottleneck analysis. Anticipates Gen Ed/Spec Ed allocation debate, grade-band apportionment, facilities treatment, and efficiency analysis structure.
