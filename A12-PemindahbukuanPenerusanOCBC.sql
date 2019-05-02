USE SQL_RMT
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RMTDCPindahBukuPenerusanOCBC] 

/*            
 CREATED BY    : Ayub
 CREATION DATE : 20190502            
 DESCRIPTION   : RMTDCPindahBukuPenerusanOCBC
 SOURCE FROM   : RMTOCBCGroupRekonMT103
 REVISED BY    :            
            
 DATE,  USER,   PROJECT,  NOTE            
 -----------------------------------------------------------------------            

   END REVISED                           
            
*/             

@pcMode  int,        
@pdDateFrom datetime = null,
@pdDateTo datetime = null,
@pcStatus varchar (20), 
@pdReceivedDateFrom datetime = null, 
@pdReceivedDateTo datetime = null
              
as              
              
declare              
@ID    bigint,              
@JenisTransaksi varchar(10),              
@Currency  varchar(5),              
@Amount  money,              
@cSelect  nvarchar(4000),              
@cColumn  nvarchar(4000),              
@cWhere  nvarchar(4000),              
@cCommand  nvarchar(4000),              
@nStatus  int,              
@cErrMsg  varchar (100),              
@nCount  int,              
@nCountMT  int,          
@nCountRTGSIn  int,              
@nCountRTGSOut int,              
@nSumPB  money,              
@nSumRTGSIn money,              
@nSumRTGSOut money,           
@nSumMT  money,          
@nCountSKNOut  int,      
@nSumSKNOut  money,    
@nRTGSMinAmount money,
@cCotPBNow varchar(15),
@cCotRTGSNow varchar(15),
@cCotSKNNow varchar(15),
@nCountValueDate int,
@nCountCutOff int,
@nCountToday int

SELECT @cCotPBNow = convert(varchar(15),ParamValue)
FROM RMTOCBCGroupParam_TR
WHERE ParamDesc = 'CutOffTime PB'
                              
SELECT @cCotRTGSNow = convert(varchar(15),ParamValue)
FROM RMTOCBCGroupParam_TR
WHERE ParamDesc = 'CutOffTime RTGS'

SELECT @cCotSKNNow = convert(varchar(15),ParamValue)
FROM RMTOCBCGroupParam_TR
WHERE ParamDesc = 'CutOffTime SKN'

select @nRTGSMinAmount =  ParamValue                
from RMTOCBCGroupParam_TR                
where ParamDesc = 'RTGS Min Amount'                
          
create table #f20          
(          
	row_id    int,          
	f20     varchar(20),          
	StatusId   int,          
	TransactionType varchar (10),
	Currency   varchar (3),       
	Amount    money,      
	ValueDate   datetime,              
	SentDate   datetime,          
	ReceivedDate  datetime,          
	f50_nama_alamat varchar(100),          
	f59_nama_alamat varchar(100),          
	SenderBank   varchar(40), 
	BeneBank   varchar (40),
	NamaBankPengirim varchar(150),  
	RemittanceInformation varchar(200),  
	CutOff datetime,
	Periode varchar(20),
	ApproveDate datetime
)          

create table #Incoming              
(              
	[Sort] int,          
	[ID] int,               
	[JenisTransaksi] varchar(10),              
	[PB/RTGS/SKN] varchar(10),      
	[Currency] varchar(3),              
	[Amount] money,              
	[ValueDate] datetime,              
	[SentDate] datetime,              
	[Jam] varchar(10),              
	[TRN] varchar(25),              
	[RelatedRTN] varchar(25),              
	[Member] varchar(100),              
	[BeneficiaryBank] varchar(300),              
	[SenderRef] varchar(300),              
	[Sender] varchar(200),              
	[Receiver] varchar(200),              
	[Originating] varchar(200),              
	[UltimateAccount] varchar(40),          
	[Status] varchar(50),              
	[Description] varchar(100),              
	[SenderBank] varchar(40),          
	[BeneBank] varchar(40),          
	[RefRTGS] varchar(100),          
	NamaBankPengirim varchar(150),  
	RemittanceInformation varchar(200),  
	Periode varchar(20),
	ErrorMsg varchar(200),
	ApproveDate datetime
 )              
              
set @pdDateTo = dateadd(day,1,@pdDateTo)                           
set @pdReceivedDateTo = dateadd(day,1,@pdReceivedDateTo)              
set @cWhere = '
				where b.method = 103 
				AND b.direction = ''I'' 
				AND b.[status] in (''430'', ''431'')  
				AND b.f32_currency = ''IDR''  
			  '

set @cSelect = 'select '

if @pdDateFrom is not null and @pdDateTo is not null
begin
	set @cWhere = @cWhere + '
					and b.f32_date >= ''' + convert(varchar, @pdDateFrom, 112) + '''
					and b.f32_date < ''' + convert(varchar, @pdDateTo, 112)+ '''
					'         
end
else if @pdReceivedDateFrom is not null and @pdReceivedDateTo is not null
begin
	set @cWhere = @cWhere + '
					and b.sent_date >= ''' + convert(varchar, @pdReceivedDateFrom, 112) + '''
					and b.sent_date < ''' + convert(varchar, @pdReceivedDateTo, 112)+ '''
					'   					
end
else
begin
	set @cErrMsg = 'Tanggal harus diisi!'              
	goto ERROR              
end


if @pcStatus != 'ALL'            
begin              
    select @nStatus = StatusId from RMTOCBCGroupParamStatus_TR where StatusDesc = @pcStatus              
    select @cWhere = @cWhere + 'and a.StatusId = ' + convert(varchar, @nStatus)              
end           
             
select @cColumn = 'b.row_id, 
				   b.f20, 
				   a.StatusId, 
				   a.TransactionType, 
				   b.f32_currency, 
				   b.f32_amount, 
				   b.f32_date, 
				   b.sent_date,  
				   b.received_date, 
				   b.f50_nama_alamat1, 
				   b.f59_nama_alamat1, 
				   b.sender, 
				   b.f57_bic, 
				   sbt.Institution, 
				   isnull(b.f70_info1, '''') + isnull(b.f70_info2, '''') + isnull(b.f70_info3, '''') + isnull(b.f70_info4, '''') 
				   '       

select @cColumn = @cColumn + ', null, null, ApprovedDate'
      
select @cCommand = 'from swift_mt1xx_table b
					left join RMTOCBCGroupFilter_TM a          
					on b.row_id = a.RowId           
					left join dbo.SwiftBICTable sbt  
					on b.sender = sbt.BIC  
					join RMTOCBCGroupAccount_TR z                    
					on b.sender = z.BIC                    
					and z.isDefault = 1                    
					and z.Status = 1                       
				  '
select @cSelect = @cSelect + @cColumn + @cCommand + @cWhere              
  
insert into #f20          
exec sp_executesql @cSelect  
          
if @@error <> 0              
begin                
	set @cErrMsg = 'Gagal insert #f20!'              
	goto ERROR              
end          

update a
set TransactionType = 'PB'
from #f20 a
join RMTOCBCGroupList_TR                            
on Sender = SenderBank 
and BIC = isnull(BeneBank, '')
where TransactionType is null

update #f20
set TransactionType = 'RTGS'
where Amount >= @nRTGSMinAmount    
and TransactionType is null

update #f20
set TransactionType = 'SKN'
where Amount < @nRTGSMinAmount
and TransactionType is null

update #f20
set Periode = 'Value Date'
where datediff (dd, SentDate, ValueDate) > 0

update #f20 
set CutOff = case TransactionType 
	when 'PB' then convert(datetime,(convert(VARCHAR(8),SentDate,112) + ' '+convert(varchar(15),@cCotPBNow)))
	when 'RTGS' then convert(datetime,(convert(VARCHAR(8),SentDate,112) + ' '+convert(varchar(15),@cCotRTGSNow)))
	when 'SKN' then convert(datetime,(convert(VARCHAR(8),SentDate,112) + ' '+convert(varchar(15),@cCotSKNNow)))
	end
where Periode is null

update #f20
set Periode = 'Today'
where SentDate <= CutOff
and Periode is null

update #f20
set Periode = 'Cut Off Time'
where Periode is null

--MT103 & PB                 
insert #Incoming              
select 0, 
	   a.row_id, 
	   'MT103', 
	   a.TransactionType, 
	   a.Currency, 
	   a.Amount, 
	   a.ValueDate, 
	   a.SentDate,               
	   substring(convert (varchar, a.ReceivedDate,114),1,8), 
	   a.f20,
	   '',
	   '',
	   '',
	   '', 
	   a.f50_nama_alamat, 
	   a.f59_nama_alamat,
	   '',
	   '',
	   c.StatusDesc, 
	   a.f20, 
	   a.SenderBank, 
	   a.BeneBank, 
	   '', 
	   a.NamaBankPengirim,
	   a.RemittanceInformation,
	   a.Periode, null, ApproveDate 

from #f20 a left join RMTOCBCGroupParamStatus_TR c              
			on a.StatusId = c.StatusId          
               
if @@error <> 0         
begin      
	set @cErrMsg = 'Gagal insert MT103!'              
	goto ERROR              
end               
          
--RTGS Out                     
insert #Incoming              
select 0, 
	   d.row_id, 
	   'RTGS Out', 
	   a.TransactionType, 
	   d.currency_code, 
	   d.amount,               
	   d.value_date, 
	   substring(convert (varchar, d.interface_time,114),1,8), 
	   d.trn_code, 
	   d.rmt_number, 
	   d.to_member,          
	   d.to_account_name, 
	   '','', 
	   d.ultimate_bene_name, 
	   d.originating_name, 
	   d.ultimate_bene_account,          
	   e.client_desc, 
	   left (c.Description,20), 
	   a.SenderBank, 
	   a.BeneBank, 
	   d.payment_detail,          
	   a.NamaBankPengirim,
	   a.RemittanceInformation, 
	   null, 
	   null, 
	   null

from #f20 a join RMTOCBCGroupRTGS_TM c             
			on c.Description like a.f20 + '%'              
			join rtgs_clearing_out d              
			on convert(bigint, c.NoRemittance) = convert(bigint, d.rmt_number)
			join rtgs_status_table e              
			on d.rtgs_status = e.status          

where c.SuccessBit = 1            
            
if @@error <> 0              
begin                          
	set @cErrMsg = 'Gagal insert RTGS Out!'              
	goto ERROR              
end               
              
--RTGS in                    
insert #Incoming              
select 0, 
	   d.row_id, 
	   'RTGS In',  
	   a.TransactionType, 
	   d.currency_code,               
	   d.amount, 
	   d.value_date, 
	   NULL, 
	   substring(convert (varchar, d.sending_time,114),1,8),               
	   d.trn_code, 
	   d.rmt_number, 
	   d.to_member, 
	   d.to_account_name,
	   '',
	   '',
	   d.ultimate_bene_name, 
	   d.originating_name, 
	   d.ultimate_bene_account, 
	   e.client_desc, 
	   left(c.PaymentDetail,20),           
	   a.SenderBank, 
	   a.BeneBank, 
	   d.payment_detail, 
	   a.NamaBankPengirim, 
	   a.RemittanceInformation, 
	   null, 
	   null, 
	   null

from #f20 a join RMTOCBCGroupRetur_TM c              
			on c.PaymentDetail like a.f20+'%'                     
			join rtgs_clearing_in d              
			on d.row_id = c.RowId              
			join rtgs_status_table e              
			on d.rtgs_status = e.status            
             
if @@error <> 0              
begin                          
	set @cErrMsg = 'Gagal insert RTGS In!'              
	goto ERROR              
end               
      
--SKN Out              
insert #Incoming              
select 0, 
	   0, 
	   'SKN Out', 
	   a.TransactionType, 
	   'IDR', 
	   TransferAmount,
	   [ValueDate], 
	   [ValueDate], 
	   '23:59:59', 
	   'CN', 
	   right(NoRemittance, 16),
	   
	   case 
		when isnull(F57BicNew, '') = '' 
			then BeneBank 
		else F57BicNew 
	   end,
	   
	   BNKNAME,
	   '',
	   '', 
	   BeneficiaryName,
	   ApplicantName + ' ' +  ApplicantAddress1 + ' ' +  ApplicantAddress2 + ' ' +  ApplicantAddress3,
	   BeneficiaryAccountNumber,
	   
	   case SuccessBit 
		when 1 
			then 'Success'       
		when 0 
			then 'OnProgress'       
		when 2 
			then 'Failed' 
	   end, 
	   
	   BankReferenceNumber, 
	   a.SenderBank,

	   case 
		when isnull(F57BicNew, '') = '' 
			then BeneBank 
		else F57BicNew 
	   end,     

	   Descriptions, 
	   a.NamaBankPengirim, 
	   a.RemittanceInformation, 
	   null, 
	   null, 
	   null

from #f20 a join RMTOCBCGroupSKN_TM c             
			on a.f20 = BankReferenceNumber      
			join RMTOCBCGroupFilter_TM b    
			on b.RowId = c.RowId       
			left join SQL_REPLICATE..RMSKNPAR1      
			on BNKCODE = BankTujuan      
         
if @@error <> 0              
begin                          
	set @cErrMsg = 'Gagal insert SKN Out!'              
	goto ERROR              
end               

-- Hitung total record dan total amount per jenis transaksi              
select @nCount = count (JenisTransaksi), 
	   @nSumPB = sum (Amount) 
from #Incoming 
where [PB/RTGS/SKN] = 'PB' and JenisTransaksi = 'MT103'          

select @nCountMT = count (JenisTransaksi), 
	   @nSumMT = sum (Amount) 
from #Incoming 
where JenisTransaksi = 'MT103'          

select @nCountRTGSOut = count (JenisTransaksi), 
	   @nSumRTGSOut = sum (Amount) 
from #Incoming 
where JenisTransaksi = 'RTGS Out'              

select @nCountRTGSIn = count (JenisTransaksi), 
	   @nSumRTGSIn = sum (Amount) 
from #Incoming 
where JenisTransaksi = 'RTGS In'              

select @nCountSKNOut = count (JenisTransaksi), 
	   @nSumSKNOut = sum (Amount) 
from #Incoming 
where JenisTransaksi = 'SKN Out'                

select @nCountValueDate = count(1) 
from #Incoming 
where Periode = 'Value Date' and JenisTransaksi = 'MT103'

select @nCountCutOff = count(1) 
from #Incoming 
where Periode = 'Cut Off Time' and JenisTransaksi = 'MT103'

select @nCountToday = count(1) 
from #Incoming 
where Periode = 'Today' and JenisTransaksi = 'MT103'
               

if @pcMode = 1            
begin              
insert #Incoming              
select 0, 
	   0, 
	   'PB', 
	   a.TransactionType, 
	   a.Currency, 
	   c.DebitAmount,
	   a.ValueDate,
	   a.SentDate,
	   substring(convert (varchar, c.ChangeDate,114),1,8), 
	   a.f20,
	   '',
	   '',
	   '',
	   '', 
	   a.f50_nama_alamat, 
	   a.f59_nama_alamat,
	   '',
	   '',
	   'Failed', 
	   a.f20, 
	   a.SenderBank, 
	   a.BeneBank, 
	   '', 
	   a.NamaBankPengirim,  
	   a.RemittanceInformation, 
	   null, 
	   c.ErrorMsg, 
	   null

from #f20 a join RMTOCBCGroupOverbookingFailed_TH c              
			on a.row_id = c.RowId
            
select Description          
into #Sort_TMP          
from #Incoming           
group by Description          
having count(1) = 1          
        
update #Incoming           
set Sort = 1          
from #Incoming a join #Sort_TMP b          
				 on a.Description = b.Description          
drop table #Sort_TMP

insert #Incoming              
select 0, 
	   0, 
	   'RTGS Out', 
	   a.TransactionType, 
	   'IDR', 
	   c.TransferAmount, 
	   dbo.fnDecimalToDate(c.TransactionDate), 
	   dbo.fnDecimalToDate(c.TransactionDate), 
	   substring(convert(varchar,c.ChangeDate,114),1,8),
	   null, 
	   c.NoRemittance,
	   c.ToMemberCode, 
	   c.BeneficiaryBankName, 
	   '',
	   '', 
	   c.BeneficiaryName, 
	   isnull(c.SenderName, '') + ' ' + isnull(c.ApplicantAddress1, '') + ' ' + isnull(c.ApplicantAddress2, '') + ' ' + isnull(c.ApplicantAddress3, ''), 
	   c.BeneficiaryAccountNumber, 
	   'Failed', 
	   left (c.Description,20), 
	   a.SenderBank, 
	   a.BeneBank, 
	   isnull(c.Description, '') + ' ' + isnull(c.BankReferenceNumber, '') + ' ' + isnull(c.BeneficiaryAccountNumber, ''), 
	   a.NamaBankPengirim, 
	   a.RemittanceInformation, 
	   null, 
	   c.ErrorMsg, 
	   null

from #f20 a join RMTOCBCGroupRTGSFailed_TH c             
			on c.Description like a.f20 + '%'              

insert #Incoming              
select 0, 
	   0, 
	   'SKN Out', 
	   a.TransactionType, 
	   'IDR', 
	   c.TransferAmount,
	   [ValueDate], 
	   [ValueDate], 
	   substring(convert (varchar, c.ChangeDate,114),1,8), 
	   'CN', 
	   right(NoRemittance, 16),    

	   case 
		when isnull(F57BicNew, '') = '' 
			then BeneBank 
		else F57BicNew 
	   end,
	   
	   BNKNAME, 
	   '',
	   '', 
	   BeneficiaryName,
	   ApplicantName + ' ' +  ApplicantAddress1 + ' ' +  ApplicantAddress2 + ' ' +  ApplicantAddress3,
	   BeneficiaryAccountNumber,
	   'Failed', 
	   BankReferenceNumber, 
	   a.SenderBank,     

	   case 
		when isnull(F57BicNew, '') = '' 
			then BeneBank 
		else F57BicNew 
	   end,     
	   
	   Descriptions, 
	   a.NamaBankPengirim, 
	   a.RemittanceInformation, 
	   null, 
	   c.ErrorMsg, 
	   null

from #f20 a join RMTOCBCGroupSKNFailed_TH c             
			on a.f20 = BankReferenceNumber      
			join RMTOCBCGroupFilter_TM b    
			on b.RowId = c.RowId       
			left join SQL_REPLICATE..RMSKNPAR1      
			on BNKCODE = BankTujuan

select * from #Incoming 
order by Sort, [Description], convert(datetime, convert(varchar, SentDate, 112)), Jam

end             
               
if @pcMode = 2            
select @nCount as CountPB, 
	   @nSumPB as SumPB, 
	   @nCountMT as CountMT, 
	   @nSumMT as SumMT,
	   @nCountRTGSOut as CountRTGSOut, 
	   @nCountRTGSIn as CountRTGSIn, 
	   @nSumRTGSIn as SumRTGSIn, 
	   @nSumRTGSOut as SumRTGSOut,
	   @nCountSKNOut as CountSKNOut, 
	   @nSumSKNOut as SumSKNOut, 
	   @nCountValueDate as CountValueDate, 
	   @nCountCutOff as CountCutOff, 
	   @nCountToday as CountToday
                 
drop table #f20            
drop table #Incoming              
    
return 0                
                
ERROR:                
 set @cErrMsg = isnull(@cErrMsg, error_message())                
 raiserror 99999 @cErrMsg                
 return 1
