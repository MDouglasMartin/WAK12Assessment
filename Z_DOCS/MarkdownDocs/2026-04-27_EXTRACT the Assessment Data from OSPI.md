
1) EXTRACT the Assessment Data from OSPI 

2) Wrap it in a view to so we can include all of the years (V_Assessment)

3) PROC:  [dbo].[Charts_Met_01_CreateByGroup_View] 

Create a view to reduce 2  [dbo].[Charts_Met_ByGroup_View]
Reduce the size of the extract record and filter the data.  
Current filter is grades 3-11, math, sbac, school and student group isn't null

4) Create EXCEL worksheet to drive the process (input)  and receive the output  (ChartsWCorrelation.xlsm):
a. Input:  Groups to Plot and Run Correlation Coefficient against
i. StudentGroups - to pivot the student groups into a single record
ii. ChartPairs - Columns to Graph and Correlate

b. Output:  To same Worksheet but to different workbooks...  Charts w/ Correlation Coefficients - 1 per worksheet 

5) Create Linked Server for the above Spread Sheet (ChartsWCorrelation)
 
6) PROC:  dbo.Charts_Met_02_Create_Select
Using the student groups identified in the excel worksheet - "Pivot Up" the selected groups into a single record.

7) Proc: dbo.Charts_Met_03_Create_Join   (and pivot the selected data)

Create the "joins" needed to support the select portion of the pivot done in the previous step... and append it to create a view (dbo.CHARTS_MET_EXTRACT_AND_PIVOT_VIEW) 

AND... extract the data to dbo.CHARTS_MET_EXTRACT_AND_PIVOT_TABLE 

8) Execute the Excel Sproc to create each of the worksheet graphs.  NOTE 9 

9) PROC: dbo.CHARTS_Met_04_Calc_Correlation   (ChartTitle, Column1, Column2)
Run the correlation coefficient script (in SQL) for the specified columns pulled from the table I 7 above.  It filters only taking columns > 0

The correlation coefficient needs to be pulled from Excel as the charts are being produced.
 
10) 
       

