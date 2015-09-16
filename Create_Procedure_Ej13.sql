ALTER PROCEDURE pSelQuantitiesByTitleAndDate
(

--1) Define the parameter list;
-- Parameter Name, Data Type, Default Value
 
 @ShowAll nVarchar(4) = 'True' --True/False
	, @StartDate datetime = '01/01/1990' -- Any valid date
	, @EndDate datetime = '01/01/2100' --Any valid date
	, @PreFix nVarchar(3) = '%' --Any three wildcard search characters
	
)
AS

BEGIN -- Create procedure Body --
--2) Set the @AverageQty variable here since you cannot use subqueries in the
-- stored procedures parameter list.
DECLARE @AverageQty int
		SELECT @AverageQty = AVG(SalesQuantity) FROM DWPubsSales.dbo.FactSales

--3) Get the Report Data

SELECT
DP.PublisherName
, [Title] = DT.Titlename
, [TitleId] = DT.TitleId
, [OrderDate] = CONVERT(varchar(50), [Date], 101)
, [Total for that Day by Title] = SUM(SalesQuantity)
, [Average Qty in the FactSales Table] = @AverageQty
, [KPI on AverageQty] = CASE
WHEN Sum(SalesQuantity)
	between (@AverageQty -5) and (@AverageQty +5) THEN 0
WHEN SUM(SalesQuantity) < (@AverageQty -5) THEN  -1
WHEN SUM(SalesQuantity) > (@AverageQty +5) THEN  1	
END

FROM DWPubsSales.dbo.FactSales AS FS
JOIN DWPubsSales.dbo.DimDates AS DD
ON
FS.OrderDateKey = DD.DateKey
INNER JOIN DWPubsSales.dbo.DimTitles AS DT
ON
DT.TitleKey = FS.TitleKey
INNER JOIN DWPubsSales.dbo.DimPublishers AS DP
ON
DP.PublisherKey = DT.PublisherKey

WHERE 
 @ShowAll = 'True'
 OR
 [Date] BETWEEN @StartDate AND @EndDate
 AND
 [TitleId] like @PreFix
 GROUP BY
 DP.PublisherName
 , DT.TitleName
 , DT.TitleId
 , CONVERT(varchar(50), [Date], 101)
 ORDER BY 
 DP.PublisherName, [Title], [OrderDate] 
END -- the body of the stored procedure --