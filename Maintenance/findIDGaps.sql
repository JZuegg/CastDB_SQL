
Select id, next_id
From (
 Select id, lead(id) over (Order by id) next_id
   From (
     Select to_number(substr(Compound_ID,2,10)) id
       From Compound
      Where Compound_ID like 'C0%'
        )
      )
Where id <> next_id-1
