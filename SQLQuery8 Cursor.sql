CREATE PROCEDURE [58659spDisplayCustomerOrder]
  @CustomerID int = 0,
  @return int output
  

BEGIN
   INSERT INTO pelanggan values (@nama,@alamat)
   SELECT * FROM pelanggan
END
