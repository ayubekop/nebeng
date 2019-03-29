Create table [58659KoInOrder] (
	Id int identity(1,1),
	OrderDate datetime ,
	OrderNumber varchar(100)
	constraint PK_58659KoInOrder primary key(Id)
)

create table [58659KoInProduct](
	Id int identity(1,1),
	ArtDating varchar(100),
	ArtDescription varchar(100),
	ArtId varchar(100),
	Artist varchar(100)
	ArtistBirthDate datetime,
	ArtistDeathTime datetime,
	ArtistNationality varchar(100),
	Category varchar(100),
	Price money,
	Size varchar(100),
	Title varchar(100)
	constraint PK_58659KoInProduct primary key(Id)
)
ALTER TABLE [KoInProduct58659]
ALTER COLUMN ArtistBirthDate varchar(100);

ALTER TABLE [KoInProduct58659]
ALTER COLUMN ArtistDeathTime varchar(100);

select * from [KoInProduct58659]
sp_help [KoInProduct58659]

alter table [58659KoInProduct]
add Artist Varchar(100)

create table [58659KoInOrderItem](
	Id int identity(1,1),
	OrderId int,
	ProductId int,
	Quantity int,
	UnitPrice money,
	constraint PK_58659KoInOrderItem primary key(Id),
	constraint FK_58659KoInOrderItem_Orders_OrderId foreign key (OrderId) references [58659KoInOrder](Id),
	constraint FK_58659KoInOrderItem_Products_ProductId foreign key (ProductId) references [58659KoInProduct](Id)
)

insert [58659KoInProduct](Category, Size, Price, Title, ArtDescription, ArtDating, ArtId, Artist, ArtistBirthDate, ArtistDeathTime, ArtistNationality)
select 'Poster', '48 x 36', '89.99', 'Self-portrait', 'Vincent moved to Paris in 1886, after hearing from his brother Theo about the new','1887', 'SK-A-3262', 'Vincent van gogh', '1853-03-30T00:00:00','1890-07-29T00:00:00','Nederlands' 

select * from KoInProduct58659
select * from KoInOrder58659
select * from KoInOrderItem58659