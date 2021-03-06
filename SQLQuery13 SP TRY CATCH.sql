USE [SQL_TELLER]
GO
/****** Object:  StoredProcedure [dbo].[48563DisplayCustomerOrder]    Script Date: 03/18/2019 14:50:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER proc [dbo].[48563DisplayCustomerOrder]
@pnCustomerID bigint
as
declare @pcErrMessage varchar(100)

BEGIN TRY
	if not exists (select top 1 1 from [48563Customer_TM] where CustomerID = @pnCustomerID)
	begin
		raiserror('Customer ID tidak ditemukan', 16,1)
	end
	
    select cust.Name, cust.[Address], ord.OrderID, ord.DateIssued, ord.DateFulfilled, ord.[Status]
		, ord.TnC, inv.InvoiceID, inv.[Date]
		from dbo.[48563Invoice_TT] inv join dbo.[48563Order_TT] ord
		on inv.OrderID = ord.OrderID
		join dbo.[48563Customer_TM] cust
		on cust.CustomerID = ord.CustomerID
	where cust.CustomerID = @pnCustomerID
	
    --print 'test'
    return 0
END TRY
BEGIN CATCH
	if @@Trancount > 0
		rollback tran
		
	set @pcErrMessage = ERROR_MESSAGE()

		raiserror (@pcErrMessage, 16, 1)
	return 1		
END CATCH;