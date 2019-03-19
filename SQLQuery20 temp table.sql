Declare @TempTable table(
	id int primary key,
	name varchar(50),
	email varchar(50)
)

insert into @TempTable values (1,'max','max@maxmax.com')

select * from @TempTable


create table #TempTable(
	id int primary key,
	name varchar(50),
	email varchar(50)
)
insert into #TempTable values (1,'max','max@maxmax.com')
select * from #TempTable
