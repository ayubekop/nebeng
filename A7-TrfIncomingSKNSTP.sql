USE SQL_RMT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RMTDCTrfIncomingSKNSTP] 

/*            
 CREATED BY    : Ayub
 CREATION DATE : 20190430            
 DESCRIPTION   : RMTDCTrfIncomingSKNSTP
 SOURCE FROM   : RMTSknCNRptGeneral
 REVISED BY    :            
            
 DATE,  USER,   PROJECT,  NOTE            
 -----------------------------------------------------------------------            

   END REVISED                           
            
*/             

@pdClearingDate datetime,      
@pcBankPengirim varchar(11) = null,       
@pnStatusId varchar(100),       
@pcNewTransactionType varchar(100) = null,      
@pbIsStp int = null,       
@pnErrorCode varchar(100) = null,      
@pnUserId int = null,       
@pnSupervisorId int = null,       
@pnPeriod int = null,      
@pnNominalStart money,       
@pnNominalEnd money,    
@pbIsBulk bit,
@pdClearingDateEnd datetime,
@pcBranchConfirm varchar(3)

as      
set nocount on       
      
declare      
@cCommand nvarchar(4000),       
@cClearingDateFrom varchar(8),      
@cClearingDateTo varchar(8)      
      
set @cClearingDateFrom = convert(varchar, @pdClearingDate, 112)      
set @cClearingDateTo = convert(varchar, dateadd(dd, 1, @pdClearingDateEnd), 112)      
      
select *        
into #Error_TMP        
from dbo.Split(@pnErrorCode, ',', 0, 0)        
where result <> ''        
      
select *        
into #Status_TMP        
from dbo.Split(@pnStatusId, ',', 0, 0)        
where result <> ''        
      
select *        
into #NewTransactionType_TMP        
from dbo.Split(@pcNewTransactionType, ',', 0, 0)        
where result <> ''        

set @cCommand = '      
	select d.RowId, TPKDate, IdentitasPesertaPengirimAsal, NamaNasabahPengirim, IdentitasPesertaPenerimaAkhir,       
	NamaNasabahPenerima, NomorRekeningNasabahPenerima, JenisTransaksi, Nominal, NomorReferensi, Keterangan,       
	SOR, RmtNumber, ClientDesc, UserId, SupervisorId, NewTransactionType, NewAccountId, NewAccountName,       
	NewBranchId, RejectReason, SendToCoreTime, ErrDesc, ErrorMessage, BatchNo  
	'  

set @cCommand = @cCommand + ' , Periode '      

set @cCommand = @cCommand + ' , ConfirmReason, NomorRekeningNasabahPengirim '       
						  + ' from RMTSknCN_TM d'      
						  + ' join RMTSknCNStatus_TR '      
						  + ' on Status = StatusId '      
						  + ' left join RMTErrorParameter '      
						  + ' on ErrCode = ErrorCode '      
      
if isnull(@pcNewTransactionType, '') != ''      
begin      
	set @cCommand = @cCommand + ' join #NewTransactionType_TMP b 
								on b.result = isnull(NewTransactionType, ''BLANK'') '      
end      

if isnull(@pnStatusId, '') != ''      
begin      
	set @cCommand = @cCommand + ' join #Status_TMP a 
								on a.result = Status '      
end      
      
if isnull(@pnErrorCode, '') != ''      
begin      
	set @cCommand = @cCommand + ' join #Error_TMP c 
								on c.result = isnull(ErrorCode,0) '      
end      

if @pcBranchConfirm = 'ALL'
begin
	set @cCommand = @cCommand + ' left join RMTIncomingBranchConfirmation_TM e 
								on d.RowId = e.RowId and Sources = ''SKN'' '
end

if @pcBranchConfirm = 'YES'
begin
	set @cCommand = @cCommand + ' join RMTIncomingBranchConfirmation_TM e
								on d.RowId = e.RowId and Sources = ''SKN'' and ConfirmReason != ''Tidak perlu konfirmasi'' '
end

if @pcBranchConfirm = 'NO'
begin
	set @cCommand = @cCommand + ' join RMTIncomingBranchConfirmation_TM e
								on d.RowId = e.RowId and Sources = ''SKN'' and ConfirmReason = ''Tidak perlu konfirmasi'' '
end
      
set @cCommand = @cCommand + ' where TPKDate >= ''' + @cClearingDateFrom 
						  + ''' and TPKDate < ''' + @cClearingDateTo + ''' '      

if isnull(@pbIsStp, 0) !=0      
begin      
	if @pbIsStp = 1 -- STP      
		set @cCommand = @cCommand + ' and isnull(ErrorCode, 0) = 0 '      
	if @pbIsStp = 2 -- STEP      
		set @cCommand = @cCommand + ' and isnull(ErrorCode, 0) != 0 '      
end
      
if isnull(@pcBankPengirim, '') != ''      
begin      
	set @cCommand = @cCommand + ' and IdentitasPesertaPengirimAsal = '' ' + @pcBankPengirim + ''''         
end      

if isnull(@pnUserId, 0) != 0      
begin      
	set @cCommand = @cCommand + ' and UserId = ' + convert(varchar, @pnUserId)      
end      

if isnull(@pnSupervisorId, 0) != 0      
begin      
	set @cCommand = @cCommand + ' and SupervisorId = ' + convert(varchar, @pnSupervisorId)      
end      

if isnull(@pnPeriod, 0) != 0       
begin      
	set @cCommand = @cCommand + ' and Periode = ' + convert(varchar, @pnPeriod)      
end      

if isnull(@pnNominalStart, 0) != 0      
begin      
	set @cCommand = @cCommand + ' and Nominal >= ' + convert(varchar, @pnNominalStart)              
end      

if isnull(@pnNominalEnd, 0) != 0       
begin      
	set @cCommand = @cCommand + ' and Nominal <= ' + convert(varchar, @pnNominalEnd)      
end      

if @pbIsBulk = 1    
begin    
	set @cCommand = @cCommand + ' and KodeDKE != 1 '    
end    
else    
begin    
	set @cCommand = @cCommand + ' and KodeDKE = 1'    
end    
      
exec sp_executesql @cCommand