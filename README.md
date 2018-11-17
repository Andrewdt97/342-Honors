Honors project by Andrew Thomas and Ty Vredeveld

Dedicated to our mothers. WIthout them, we wouldn't be here today.

Good article: https://www.smartsheet.com/guide-to-material-requirements-planning

Reference for AdventureWorks2012: http://www.sqldatadictionary.com/AdventureWorks2012.pdf

PLAN OF ATTACK:

	Remove deprecated calculations

	Calculate current orders
	+
	Calculate seasonal demand
	+
	Calculate recurring orders
	=
	Demand
	
	Use bill of materials to find out part requirements from demand
		- Cursor through demand and run SP to get component needs
	
	Subtract current inventory
	
	Make sure we meet safety levels
	
	Output table with quantities of parts to be ordered
	
Questions to ask:
	Are reoccuring orders a thing?
	
	Do we need to write triggers of re-order points or just project part needs?
	
	What do we do about in process use with old data?