-- CUSTOMER TABLE
IF EXISTS (SELECT * FROM sysobjects WHERE NAME = '58659Customer_TM' AND XTYPE ='U')
	DROP TABLE [dbo].[58659Customer_TM]
GO
CREATE TABLE [dbo].[58659Customer_TM] (
    CustomerID int PRIMARY KEY NOT NULL,
    Name varchar(255),
    Address varchar(255),
    Phone varchar(20),
    Email varchar(50),
    Sex varchar(10)
); 

-- PRODUCT TABLE
IF EXISTS (SELECT * FROM sysobjects WHERE NAME = '58659Product_TM' AND XTYPE ='U')
	DROP TABLE [dbo].[58659Product_TM]
GO
CREATE TABLE [dbo].[58659Product_TM] (
    ProductID int PRIMARY KEY NOT NULL,
    Name varchar(255),
    Description varchar(255),
	Price varchar(255)
);

-- ORDER TABLE
IF EXISTS (SELECT * FROM sysobjects WHERE NAME = '58659Order_TT' AND XTYPE ='U')
	DROP TABLE [dbo].[58659Order_TT]
GO 
CREATE TABLE [dbo].[58659Order_TT] (
    OrderID INT PRIMARY KEY NOT NULL,
    DateIssued DATETIME,
    DateFulfilled DATETIME,
	Status varchar(255),
	Tnc varchar(255),
	CustomerID varchar(255)
); 

-- INVOICE TABLE
IF EXISTS (SELECT * FROM sysobjects WHERE NAME = '58659Invoice_TT' AND XTYPE ='U')
	DROP TABLE [dbo].[58659Invoice_TT]
GO
CREATE TABLE [dbo].[58659Invoice_TT] (
    InvoiceID int PRIMARY KEY NOT NULL,
    DateInvoice varchar(255),
    OrderID int,
	ProductID int,
	Quantity int
); 

-- INVOICEPROD TABLE
IF EXISTS (SELECT * FROM sysobjects WHERE NAME = '58659InvoiceProd_TT' AND XTYPE ='U')
	DROP TABLE [dbo].[58659InvoiceProd_TT]
GO
CREATE TABLE [dbo].[58659InvoiceProd_TT] (
    ID INT PRIMARY KEY NOT NULL,
    InvoiceID int,
	ProductID int,
	Quantity int
); 

--PersonID int FOREIGN KEY REFERENCES Persons(PersonID)
