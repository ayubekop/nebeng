-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ayub
-- Create date: 18-03-2019
-- Description:	
-- =============================================
CREATE PROCEDURE [58659spDisplayCustOrder] 
	-- Add the parameters for the stored procedure here
	@CustomerID int = 0 
AS
DECLARE @pcErrMessage varchar(255)
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statememnts for procedure here
	BEGIN TRY
	if not exists (select top 1 1 from [dbo].[58659Customer_TM] where CustomerID = @CustomerID)
	begin
		raiserror('Customer ID tidak ditemukan', 16,1)
	end
	
    select * from [dbo].[58659Customer_TM] where CustomerID = @CustomerID
    --print 'test'
    return 0
END TRY
BEGIN CATCH		
	set @pcErrMessage = ERROR_MESSAGE()

		raiserror (@pcErrMessage, 16, 1)
	return 1		
END CATCH;
END
GO



