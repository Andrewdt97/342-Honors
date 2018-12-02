use AdventureWorks2012
go

alter proc BOM_CTE
	@ID int
as
begin
		with cte (pID, cID, qty) as
		(
			select ROOT.pID, ROOT.cID, ROOT.qty
			from BOM_setup ROOT
			where ROOT.pID = @ID
		union all
			select PARENT.pID, CHILD.cID, PARENT.qty * CHILD.qty
			from cte PARENT, BOM_setup CHILD
			where PARENT.cID = CHILD.pID
		)
		select pID, cID, sum(qty) as "Total"
		from cte
		group by pID, cID
		order by pID, cID;
end;
go