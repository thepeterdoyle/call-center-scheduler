# Call Center Scheduler (BigQuery)

This project implements a **call-center scheduling and backlog assignment system** in Google BigQuery.  
It creates all the reference tables, operational tables, UDFs, stored procedures, and reporting views needed to:

- Manage new account backlogs (~20,000 per week) across U.S. time zones  
- Respect safe calling windows (8 AM – 9 PM local, with DST and holidays)  
- Split calls between old vs new accounts (4/3 split per hour)  
- Balance assignments fairly across employees (round-robin distribution)  
- Track attempts, completions, and backlog reduction  
- Provide reporting views for managers (adherence, backlog composition, projections)
