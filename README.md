Honors project by Andrew Thomas and Ty Vredeveld

Dedicated to our mothers. WIthout them, we wouldn't be here today.

Good article: https://www.smartsheet.com/guide-to-material-requirements-planning

Reference for AdventureWorks2012: http://www.sqldatadictionary.com/AdventureWorks2012.pdf

PLAN OF ATTACK:

	Calculate current orders
	+
	Calculate seasonal demand
	+
	Calculate recurring orders
	=
	Demand
	
	Use bill of materials to find out part requirements from demand
	
	Subtract current inventory
	
	Make sure we meet safety levels
	
	Output table with quantities of parts to be ordered
	
Questions to ask:
	Are reoccuring orders a thing?
	
	Do we need to write triggers of re-order points or just project part needs?
	
	Calculate seasonal demand over last X years or last X years with real data? aka How do work with old database.