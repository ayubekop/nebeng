select * from [48563Customer_TM]

dbcc checkident ('[48563Customer_TM]', noreseed)

dbcc checkident ('[48563Customer_TM]', reseed, 10)
