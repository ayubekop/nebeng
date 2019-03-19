declare tran_cur cursor local fast_forward for
	select Address from [dbo].[58659Customer_TM]

declare @address varchar(255)

open tran_cur

while 1=1
begin
	fetch tran_cur into @address
	if @@fetch_status!=0 
		break
	select @address
end

close tran_cur
deallocate tran_cur