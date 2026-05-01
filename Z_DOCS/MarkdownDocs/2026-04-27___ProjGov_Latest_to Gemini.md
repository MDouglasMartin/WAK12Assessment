I'm trying to organize my k12 project. I'm using both you Claud and Gemini and sometimes Copilot.
Mission Statement:
- Mission Statement/Objective:

"To establish a portal to Washington State's Public K12 data that any AI can use to present a "Process Improvement" view of that data.

Unlike the current reporting style website that reports year over year information such as "Expenditures per Student" and "%Met of the 3rd grade in school or district X"... this (AI... chose one:  Application, Effort, website)  opens up that same data to any AI allowing it to assume the role of, for example,  a Lean Six Sigma Black Belt.  

      By doing this, we can 
* Begin to explain "what Met" actually means and... what it doesn't mean;
* Show the true cost of producing a student to standard or what several AI's refer to as... a "Sovereign Student"... and the cost and waste associated with it.
* How the state, individual districts... and even some schools are perform in terms of those standard and where to look for problems
(AI... there was some pretty good summarizations in some of the doc files)

What an AI needs:
- Auditing:  The Transformation and the Resultant Data:

While not easily auditable, the source data used in this "application" is readily available on the data.wa.gov website and the transformations (code) and results are available on this website.  (AI... need this to point to the Jobstreams Folder)

- Governance: Processing Directions:
o A governance file that expressly directs AI to
* No estimating, guessing, hallucinating:  If you can't access the data... you will report that you can't access the data.
* ONLY use data on this website (GIT/Google Drive) when responding to queries based on the data in this website.  If the AI uses data outside of his domain it must be identified as from outside this domain and a link provided.
* Calculate performance and costs from a Lean Six Sigma perspective.   This includes...
* Using a cohort as the basis ie "Graduating Class" aka group of students tracked from Grade 3 to Grade 10 or 11 (pending year HS test was administrated)
* Calculating and using the adjusted pipeline cost (schools are in 180 each 7.5 hr days vs full time 240 tax payer 240-260 8 hr days) using either ...
o Summarized s275 (labor cost)
o Per Pupil Expenditures (full cost)
* Calculate the %met based on Math 10th Grade L4 met percent - (See Appendix "Civic Engagement and SBAC measures")
* Us the "All Students Group" as the basis for met (See Appendix "Why 'All' Groups") 

o AI is expressly prohibited from using or attempting to use "genetic or DEI based diversity subgroups" (race, gender, ethnicity) for comparison on this data (See Appendix "No know association between skin color and Math Capability")
Appendix: 
"Civic Engagement and SBAC measures"

Why All Subgroups
What the human needs:
o A clear understanding of what the project is and how it differs from what is currently available
o An LLM to be able to query the data and be given more than just :  Cohort x had a 15% met standards.
o Reassurance the responses are based on well vetted information and a solid process used in evaluating that data
o 
 
We're working in three environments:
- My machine:
o SQL Server with the data pulled from the "source data sites"  data.wa.gov, fiscal.wa.gov, ospi (sample test),  and other authorities
Constraints:
- It appears that everyone can access the GitHub site.
- We need both a "development" and a "deployed"  site.  I would recommend the "dev" site be on my machine in a separate stack.  
