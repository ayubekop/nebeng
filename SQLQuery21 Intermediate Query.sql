select * from [dbo].[58659Customer_TM]
select * from [dbo].[58659Order_TT]
select * from [dbo].[58659Product_TM]
select * from [dbo].[58659Invoice_TT]
select * from [dbo].[58659InvoiceProd_TT]

SELECT *, convert(int,A.Quantity) * convert(money,C.Price) as PQ 
FROM [dbo].[58659InvoiceProd_TT] A
JOIN [dbo].[58659Invoice_TT] B ON A.InvoiceID = B.InvoiceID
JOIN [dbo].[58659Product_TM] C ON A.ProductID = C.ProductID
JOIN [dbo].[58659Order_TT] D ON B.OrderID = D.OrderID
JOIN [dbo].[58659Customer_TM] E ON D.CustomerID = E.CustomerID


--Nomer 1 ceritanya 
--Cari > 5
SELECT D.CustomerID, E.Name, Count(D.OrderID) as totalOrder
FROM [dbo].[58659InvoiceProd_TT] A
JOIN [dbo].[58659Invoice_TT] B ON A.InvoiceID = B.InvoiceID
JOIN [dbo].[58659Product_TM] C ON A.ProductID = C.ProductID
JOIN [dbo].[58659Order_TT] D ON B.OrderID = D.OrderID
JOIN [dbo].[58659Customer_TM] E ON D.CustomerID = E.CustomerID
where E.Name is not null
group by D.CustomerID, E.Name
having Count(D.OrderID)>5
order by totalOrder 

--Nomer 2 ceritanya
SELECT D.CustomerID, E.Name, Count(D.OrderID) as totalOrder,  SUM(convert(int,A.Quantity) * convert(money,C.Price)) / SUM(convert(int,A.Quantity)) as [Rata Rata]
FROM [dbo].[58659InvoiceProd_TT] A
JOIN [dbo].[58659Invoice_TT] B ON A.InvoiceID = B.InvoiceID
JOIN [dbo].[58659Product_TM] C ON A.ProductID = C.ProductID
JOIN [dbo].[58659Order_TT] D ON B.OrderID = D.OrderID
JOIN [dbo].[58659Customer_TM] E ON D.CustomerID = E.CustomerID
where E.Name is not null
group by D.CustomerID, E.Name
having SUM(convert(int,A.Quantity) * convert(money,C.Price)) / SUM(convert(int,A.Quantity)) > 6000
order by totalOrder 




