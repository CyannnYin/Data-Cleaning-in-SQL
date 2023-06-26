/* Cleaning Data in SQL Queries */

SELECT * FROM [Supply Chain];

--- <Section 1>
--- Populate Origin Address data

SELECT a.Origin_Port, a.Origin_Address, b.Origin_Port, b.Origin_Address, ISNULL (a.Origin_Address, b.Origin_Address)
FROM [Supply Chain] a 
JOIN [Supply Chain] b 
    ON a.Origin_Port = b.Origin_Port
    AND a.Order_ID <> b. Order_ID
WHERE a.Origin_Address is NULL

UPDATE a
SET Origin_Address = ISNULL(a.Origin_Address, b.Origin_Address)
FROM [Supply Chain] a 
JOIN [Supply Chain] b 
    ON a.Origin_Port = b.Origin_Port
    AND a.Order_ID <> b. Order_ID
WHERE a.Origin_Address is NULL

--- Populate Destination Address data

SELECT a.Destination_Port, a.Destination_Address, b.Destination_Port, b.Destination_Address, ISNULL (a.Destination_Address, b.Destination_Address)
FROM [Supply Chain] a 
JOIN [Supply Chain] b 
    ON a.Destination_Port = b.Destination_Port
    AND a.Order_ID <> b. Order_ID
WHERE a.Destination_Address is NULL

UPDATE a
SET Destination_Address = ISNULL(a.Destination_Address, b.Destination_Address)
FROM [Supply Chain] a 
JOIN [Supply Chain] b 
    ON a.Destination_Port = b.Destination_Port
    AND a.Order_ID <> b. Order_ID
WHERE a.Destination_Address is NULL

--- Populate Origin/Destination Zip Code

UPDATE a
SET Origin_Zip_Code = ISNULL(a.Origin_Zip_Code, b.Origin_Zip_Code)
FROM [Supply Chain] a 
JOIN [Supply Chain] b 
    ON a.Origin_Port = b.Origin_Port
    AND a.Order_ID <> b. Order_ID
WHERE a.Origin_Zip_Code is NULL

UPDATE a
SET Destination_Zip_Code = ISNULL(a.Destination_Zip_Code, b.Destination_Zip_Code)
FROM [Supply Chain] a 
JOIN [Supply Chain] b 
    ON a.Origin_Port = b.Origin_Port
    AND a.Order_ID <> b. Order_ID
WHERE a.Destination_Zip_Code is NULL

--- <Section 2>
--- Breaking out Address into Individual Columns (Address, City)

SELECT
SUBSTRING(Origin_Address, 1, CHARINDEX(',', Origin_Address) -1 ) as Address
, SUBSTRING(Origin_Address, CHARINDEX(',', Origin_Address) + 1 , LEN(Origin_Address)) as Address
FROM [Supply Chain]

ALTER TABLE [Supply Chain]
ADD OriginSplitAddress Nvarchar(255);

UPDATE [Supply Chain]
SET OriginSplitAddress = SUBSTRING(Origin_Address, 1, CHARINDEX(',', Origin_Address) -1 )

ALTER TABLE [Supply Chain]
ADD OriginSplitCity Nvarchar(255);

UPDATE [Supply Chain]
SET OriginSplitCity = SUBSTRING(Origin_Address, CHARINDEX(',', Origin_Address) + 1 , LEN(Origin_Address))

Select
PARSENAME(REPLACE(Destination_Address, ',', '.') , 2)
,PARSENAME(REPLACE(Destination_Address, ',', '.') , 1)
From [Supply Chain]

ALTER TABLE [Supply Chain]
ADD DestinationSplitAddress Nvarchar(255);

UPDATE [Supply Chain]
SET DestinationSplitAddress = PARSENAME(REPLACE(Destination_Address, ',', '.') , 2)

ALTER TABLE [Supply Chain]
ADD DestinationSplitCity Nvarchar(255);

UPDATE [Supply Chain]
SET DestinationSplitCity = PARSENAME(REPLACE(Destination_Address, ',', '.') , 1)

--- <Section 3>
--- Determining if Origin_Port is equal to Destination_Port ('Y' or 'N')

ALTER TABLE [Supply Chain]
ADD SameLocation Nvarchar(1);

UPDATE [Supply Chain]
SET SameLocation = CASE When Origin_Port = Destination_Port THEN 'Y'
    ELSE 'N'
END

SELECT DISTINCT (SameLocation), Count(SameLocation)
From [Supply Chain]
Group by SameLocation
order by 2

--- <Section 4>
--- Checking Duplicates

SELECT Order_ID, COUNT(*) AS count
FROM [Supply Chain]
GROUP BY Order_ID
HAVING COUNT(*) > 1;

--- <Section 5>
--- Deleting Unused Columns

Select *
From [Supply Chain]

ALTER TABLE [Supply Chain]
DROP COLUMN TPT, Service_Level, Ship_ahead_day_count, Ship_Late_Day_count, Plant_Code