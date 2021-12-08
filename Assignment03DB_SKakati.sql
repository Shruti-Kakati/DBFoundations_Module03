--*************************************************************************--
-- Title: Assignment03
-- Desc: This script demonstrates the creation of a typical database with:
--       1) Tables
--       2) Constraints
--       3) Views
-- Dev: Shruti Kakati
-- Change Log: 27th October 2021,Shruti Kakati,
-- Listing:
			-- Written queries for 10 different questions
--**************************************************************************--

--[ Create the Database ]--
--********************************************************************--
Use Master;
go
If exists (Select * From sysdatabases Where name='Assignment03DB_ShrutiKakati')
  Begin
  	Use [master];
	  Alter Database Assignment03DB_ShrutiKakati Set Single_User With Rollback Immediate; -- Kick everyone out of the DB
		Drop Database Assignment03DB_ShrutiKakati;
  End
go
Create Database Assignment03DB_ShrutiKakati;
go

Use Assignment03DB_ShrutiKakati;
go
--[ Create the Tables ]--
--********************************************************************--
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL
,[ProductName] [nvarchar](100) NOT NULL
,[ProductCurrentPrice] [money] NOT NULL
,[CategoryID] [int] NULL
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[InventoryCount] [int] NULL
,[ProductID] [int] NOT NULL
);
go

--[ Add Addtional Constaints ]--
--********************************************************************--
ALTER TABLE dbo.Categories
	ADD CONSTRAINT pkCategories PRIMARY KEY CLUSTERED (CategoryID);
go
ALTER TABLE dbo.Categories
	ADD CONSTRAINT uCategoryName UNIQUE NonCLUSTERED (CategoryName);
go

ALTER TABLE dbo.Products
	ADD CONSTRAINT pkProducts PRIMARY KEY CLUSTERED (ProductID);
go
ALTER TABLE dbo.Products
	ADD CONSTRAINT uProductName UNIQUE NonCLUSTERED (ProductName);
go
ALTER TABLE dbo.Products
	ADD CONSTRAINT fkProductsCategories
		FOREIGN KEY (CategoryID)
		REFERENCES dbo.Categories (CategoryID);
go
ALTER TABLE dbo.Products
	ADD CONSTRAINT pkProductsProductCurrentPriceZeroOrMore CHECK (ProductCurrentPrice > 0);
go

ALTER TABLE dbo.Inventories
	ADD CONSTRAINT pkInventories PRIMARY KEY CLUSTERED (InventoryID);
go
ALTER TABLE dbo.Inventories
	ADD CONSTRAINT fkInventoriesProducts
		FOREIGN KEY (ProductID)
		REFERENCES dbo.Products (ProductID);
go
ALTER TABLE dbo.Inventories
	ADD CONSTRAINT ckInventoriesInventoryCountMoreThanZero CHECK (InventoryCount >= 0);
go
ALTER TABLE dbo.Inventories
	ADD	CONSTRAINT dfInventoriesCountIsZero DEFAULT (0)
	FOR [InventoryCount];
go

--[ Create the Views ]--
--********************************************************************--
Create View vCategories
As
  Select[CategoryID],[CategoryName]
  From Categories;
;
go

Create View vProducts
As
  Select [ProductID],[ProductName],[CategoryID],[ProductCurrentPrice]
  From Products;
;
go

Create View vInventories
As
  Select [InventoryID],[InventoryDate],[ProductID],[InventoryCount]
  From Inventories
;
go

--[Insert Test Data ]--
--********************************************************************--
Insert Into Categories
(CategoryName)
Select CategoryName
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, ProductCurrentPrice)
Select ProductName,CategoryID, UnitPrice
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Inventories
(InventoryDate, ProductID, [InventoryCount])
Select '20200101' as InventoryDate, ProductID, UnitsInStock
From Northwind.dbo.Products
UNION
Select '20200201' as InventoryDate, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNION
Select '20200302' as InventoryDate, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show all of the data in the Categories, Products, and Inventories Tables
Select * from vCategories;
go
Select * from vProducts;
go
Select * from vInventories;
go

/********************************* Questions and Answers *********************************/

-- Question 1 (5% pts): How can you show the Category ID and Category Name for 'Seafood'?

SELECT 	*
FROM 	Categories
WHERE 	CategoryName = 'Seafood'
GO

-- Question 2 (5% pts): How can you show the Product ID, Product Name, and Product Price
-- of all Products with the Seafood's Category Id? With the results ordered By the Products Price
-- highest to the lowest!

SELECT 	ProductID,
		ProductName,
		ProductCurrentPrice
FROM 	Products
WHERE 	CategoryID = 8
ORDER BY ProductCurrentPrice DESC
GO

-- Question 3 (5% pts):  How can you show the Product ID, Product Name, and Product Price
-- Ordered By the Products Price highest to the lowest?
-- With only the products that have a price Greater than $100!

SELECT 	ProductID,
		ProductName,
		ProductCurrentPrice
FROM 	Products
WHERE	ProductCurrentPrice > 100
ORDER BY ProductCurrentPrice DESC
GO

-- Question 4 (10% pts): How can you show the CATEGORY NAME, product name, and Product Price
-- from both Categories and Products? Order the results by Category Name
-- and then Product Name, in alphabetical order!
-- (Hint: Join Products to Category)

SELECT	c.CategoryName,
		p.ProductName,
		p.ProductCurrentPrice
FROM	Products p
LEFT JOIN Categories c
ON 		p.CategoryID = c.CategoryID
ORDER BY c.CategoryName, p.ProductName
GO

-- Question 5 (5% pts): How can you show the Product ID and Number of Products in Inventory
-- for the Month of JANUARY? Order the results by the ProductIDs!

SELECT 	ProductID,
		InventoryCount
FROM 	Inventories
WHERE 	DATEPART(month,InventoryDate) = 1
GO


-- Question 6 (10% pts): How can you show the Category Name, Product Name, and Product Price
-- from both Categories and Products. Order the results by price highest to lowest?
-- Show only the products that have a PRICE FROM $10 TO $20!

SELECT 	c.CategoryName,
		p.ProductName,
		p.ProductCurrentPrice
FROM 	Categories c
LEFT JOIN Products p
ON		c.CategoryID = p.CategoryID
WHERE	p.ProductCurrentPrice BETWEEN 10 AND 20
ORDER BY p.ProductCurrentPrice DESC
GO

-- Question 7 (10% pts) How can you show the Product ID and Number of Products in Inventory
-- for the Month of JANUARY? Order the results by the ProductIDs
-- and where the Product IDs are only in the seafood category!
-- (Hint: Use a subquery to get the list of productIds with a category ID of 8)

SELECT 	ProductID, InventoryCount
FROM 	Inventories
WHERE 	ProductID IN
					(	SELECT 	p.ProductID
						FROM 	Products p
						LEFT JOIN  Categories c
						ON 		p.CategoryID = c.CategoryID
						WHERE 	c.CategoryName = 'Seafood'
					)
GO

-- Question 8 (10% pts) How can you show the PRODUCT NAME and Number of Products in Inventory
-- for January? Order the results by the Product Names
-- and where the ProductID as only the ones in the seafood category!
-- (Hint: Use a Join between Inventories and Products to get the Name)

SELECT 	p.ProductName,
		i.InventoryCount
FROM	Products p
LEFT JOIN Inventories i
ON 		p.ProductID = i.ProductID
WHERE 	p.ProductID IN
					(	SELECT 	p.ProductID
						FROM 	Products p
						LEFT JOIN  Categories c
						ON 		p.CategoryID = c.CategoryID
						WHERE 	c.CategoryName = 'Seafood'
					)
AND 	DATEPART(month,InventoryDate) = 1
GO

-- Question 9 (20% pts) How can you show the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBRUARY? Show what the AVERAGE AMOUNT IN INVENTORY was
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names!

SELECT 	p.ProductName,
		Avg(i.InventoryCount) as Avg_amt
FROM	Products p
LEFT JOIN Inventories i
ON 		p.ProductID = i.ProductID
WHERE 	p.ProductID IN
					(	SELECT 	p.ProductID
						FROM 	Products p
						LEFT JOIN  Categories c
						ON 		p.CategoryID = c.CategoryID
						WHERE 	c.CategoryName = 'Seafood'
					)
AND 	DATEPART(month,InventoryDate) IN (1,2)
GROUP BY p.ProductName
ORDER BY p.ProductName
GO

-- Question 10 (20% pts) How can you show the Product Name and Number of Products in Inventory
-- for both JANUARY and FEBRUARY? Show what the AVERAGE AMOUNT IN INVENTORY was
-- and where the ProductID as only the ones in the seafood category
-- and Order the results by the Product Names!
-- Restrict the results to rows with a Average COUNT OF 100 OR HIGHER!

with CTE as
(
	SELECT 	p.ProductName as ProductName,
			Avg(i.InventoryCount) as Avg_amt_in_Inventory
	FROM		Products p
	LEFT JOIN 	Inventories i
	ON 			p.ProductID = i.ProductID
	WHERE 		p.ProductID IN
							(	SELECT 	p.ProductID
								FROM 	Products p
								LEFT JOIN  Categories c
								ON 		p.CategoryID = c.CategoryID
								WHERE 	c.CategoryName = 'Seafood'
							)
	AND 	DATEPART(month,InventoryDate) IN (1,2)
	GROUP BY p.ProductName
)

SELECT *
FROM CTE c
WHERE c.Avg_amt_in_Inventory >=100
ORDER BY c.ProductName
GO


/***************************************************************************************/



