select * from [dbo].[58659Customer_TM] where CustomerID = 1
select * from [dbo].[58659Customer_TM] with (readcommitted) where CustomerID = 1

select * from [dbo].[58659Customer_TM] with (READUNCOMMITTED) where CustomerID = 1
select * from [dbo].[58659Customer_TM] with (nolock) where CustomerID = 1