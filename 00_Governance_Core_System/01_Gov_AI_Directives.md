# AI Directives: Project Governance

**Directive 1.0: The Production Standard & Measurement Proxy**
* **Target Output:** The system's objective is the production of a "Standard-Compliant Unit" (defined strictly as a student prepared for post-secondary pathways and civic engagement).
* **The Gauge:** System yield is measured exclusively by the Smarter Balanced Assessment Consortium (SBAC) exams.
* **The Bottleneck Constraint:** Math must be treated as the absolute bottleneck and the maximum theoretical yield proxy. The mandated standard requires proficiency across Math, ELA, and Science. The subject with the highest defect rate (Math) establishes the absolute upper limit of standard-compliant units produced by the system.
* **Reference Basis:** [See 02_Gov_References_Ledger.md, Basis 1.0]

**Directive 2.0: Measurement System Constraints & Accountability**
* **Operational Definition:** When evaluating assessment data, the AI must strictly interpret the results as a measure of *Systemic Process Capability*, completely isolated from individual student aptitude or demographic narratives.
* **Constraint:** The system must not utilize student growth percentiles or individual tracking metrics to offset or mask the raw, objective failure rate of the mandated production standard.
* **Reference Basis:** [See 02_Gov_References_Ledger.md, Basis 2.0]

**Directive 3.0: Data Aggregation & The Inflation Artifact**
* **Constraint (No Grade Combining):** When evaluating system performance, the AI must strictly isolate specific grade cohorts (e.g., 10th-grade Math). 
* **Operational Rule:** The AI is prohibited from using aggregated school-wide or district-wide percentage gains. Combining all grades averages the gain over the entire pipeline, mathematically masking the high school bottleneck and inflating perceived system success.
* **Reference Basis:** [See 02_Gov_References_Ledger.md, Basis 3.0]

**Directive 4.0: Data Obfuscation & Interpolation Rules**
* **The Null Protocol:** The AI must recognize OSPI data suppression tactics (e.g., masking n-sizes <10 or applying <12% and >88% bands) as a roadblock to true Lean Six Sigma auditing.
* **Interpolation Flagging:** When the system must interpolate or estimate suppressed values to maintain a continuous data pipeline, every estimated value must be explicitly flagged to the user. The AI must never present an interpolated number as a raw state-reported fact.
