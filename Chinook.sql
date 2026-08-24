USE Chinook;

-- Initial Data Check

SELECT *
FROM Album;

SELECT *
FROM Artist;

SELECT *
FROM Customer;

SELECT *
FROM Employee;

SELECT *
FROM Genre;

SELECT *
FROM Invoice;

SELECT *
FROM InvoiceLine;

SELECT *
FROM MediaType;

SELECT *
FROM Playlist;

SELECT *
FROM PlaylistTrack;

SELECT *
FROM Track;

# Null Check For Important Columns/Tables

SELECT 
	COUNT(*) AS Total_Albums,
    COUNT(*) - COUNT(AlbumId) AS Album_nulls,
    COUNT(*) - COUNT(Title) AS Title_nulls,
    COUNT(*) - COUNT(ArtistId) AS Artist_nulls
FROM Album;

SELECT 
	COUNT(*) AS Total_Customers,
    COUNT(*) - COUNT(CustomerID) AS id_nulls,
    COUNT(*) - COUNT(FirstName) AS first_name_nulls,
    COUNT(*) - COUNT(LastName) AS last_name_nulls,
    COUNT(*) - COUNT(Company) AS Company_nulls,
    COUNT(*) - COUNT(Address) AS Address_nulls,
    COUNT(*) - COUNT(City) AS City_nulls,
    COUNT(*) - COUNT(State) AS State_nulls,
    COUNT(*) - COUNT(Country) AS Country_nulls,
    COUNT(*) - COUNT(PostalCode) AS Postal_nulls,
    COUNT(*) - COUNT(Phone) AS Phone_nulls,
    COUNT(*) - COUNT(Fax) AS Fax_nulls,
    COUNT(*) - COUNT(Email) AS Email_nulls,
    COUNT(*) - COUNT(SupportRepId) AS Support_nulls
FROM Customer;

SELECT 
	COUNT(*) AS Total_Employee,
    COUNT(*) - COUNT(EmployeeId) AS Employee_Id_null,
    COUNT(*) - COUNT(LastName) AS LastName_null,
    COUNT(*) - COUNT(FirstName) AS FirstName_null,
    COUNT(*) - COUNT(Title) AS Title_null,
    COUNT(*) - COUNT(ReportsTo) AS Report_null,
    COUNT(*) - COUNT(BirthDate) AS BirthDate_null,
    COUNT(*) - COUNT(HireDate) AS HireDate_null,
    COUNT(*) - COUNT(Address) AS Address_null,
    COUNT(*) - COUNT(City) AS City_null,
    COUNT(*) - COUNT(State) AS State_null,
    COUNT(*) - COUNT(Country) AS Country_null,
    COUNT(*) - COUNT(PostalCode) AS PostalCode_null,
    COUNT(*) - COUNT(Phone) AS PhoneNum_null,
    COUNT(*) - COUNT(Fax) AS Fax_null,
    COUNT(*) - COUNT(Email) AS Email_null
FROM Employee;

SELECT
	COUNT(*) AS Total_Invoice,
    COUNT(*) - COUNT(InvoiceId) AS Invoice_null,
    COUNT(*) - COUNT(CustomerId) AS Customer_null,
    COUNT(*) - COUNT(InvoiceDate) AS InvoiceDate_null,
    COUNT(*) - COUNT(BillingAddress) AS BillingAddress_null,
    COUNT(*) - COUNT(BillingCity) AS BillingCity_null,
    COUNT(*) - COUNT(BillingState) AS BillingState_null,
    COUNT(*) - COUNT(BillingCountry) AS BillingCountry_null,
    COUNT(*) - COUNT(BillingPostalCode) AS BillingPostal_null
FROM Invoice;

-- Customer Analysis
# Top 10 Customer

SELECT c.CustomerId, c.FirstName, c.LastName, SUM(i.Total) AS TotalSpent
FROM Customer c
LEFT JOIN Invoice i
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY TotalSpent DESC
LIMIT 10;

# Top Country

SELECT c.Country, COUNT(DISTINCT c.CustomerId) AS Customers, SUM(Total) AS TotalSpent
FROM Customer c
LEFT JOIN Invoice i
ON c.CustomerId = i.CustomerId
GROUP BY c.Country
ORDER BY TotalSpent DESC
LIMIT 10;

-- Sales Analysis

# Top 10 Artist

SELECT a.Name, SUM(i.UnitPrice * i.Quantity) AS TotalRevenue
FROM Artist a
INNER JOIN Album al
ON a.ArtistId = al.ArtistId
INNER JOIN Track t
ON al.AlbumId = t.AlbumId
INNER JOIN InvoiceLine i
ON t.TrackId = i.TrackId
GROUP BY a.Name
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Music Analysis

# Top 10 Genre

SELECT g.Name, SUM(i.UnitPrice * i.Quantity) AS TotalRevenue
FROM Genre g
INNER JOIN Track t
ON g.GenreId = t.GenreId
INNER JOIN InvoiceLine i
ON t.TrackId = i.TrackId
GROUP BY g.Name
ORDER BY TotalRevenue DESC
LIMIT 10;

-- Employee Performance

# Top 5 Employee Performance by Revenue

SELECT e.EmployeeId, e.FirstName, e.LastName, SUM(i.Total) AS TotalRevenue
FROM Employee e
INNER JOIN Customer c
ON e.EmployeeId = c.SupportRepId
INNER JOIN Invoice i
ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
ORDER BY TotalRevenue DESC
LIMIT 5;


# Which Customer Spent More Than The Average

SELECT CustomerId, FirstName, LastName, TotalRevenue
FROM (
	SELECT c.CustomerId, c.FirstName, c.LastName, SUM(i.Total) AS TotalRevenue
	FROM Customer c
    INNER JOIN Invoice i
    ON c.CustomerId = i.CustomerId
    GROUP BY c.CustomerId
) AS CustomerRevenue
WHERE TotalRevenue > (
	SELECT AVG(TotalRevenue)
    FROM (
		SELECT c.CustomerId, c.FirstName, c.LastName, SUM(i.Total) AS TotalRevenue
		FROM Customer c
		INNER JOIN Invoice i
		ON c.CustomerId = i.CustomerId
		GROUP BY c.CustomerId
	) AS CustomerAvg
)
ORDER BY TotalRevenue DESC
LIMIT 10;

# Which Customer Never Made a Purchase

SELECT c.CustomerId, c.FirstName, c.LastName, i.InvoiceId
FROM Customer c
LEFT JOIN Invoice i
    ON c.CustomerId = i.CustomerId
WHERE InvoiceId IS NULL;

# Top 10 Artists Generating Above Average Revenue

SELECT ArtistMoney.ArtistId, ArtistMoney.Name, ArtistRevenue
FROM (
	SELECT a.ArtistId, a.Name, SUM(il.UnitPrice * il.Quantity) AS ArtistRevenue
    FROM Artist a
    INNER JOIN Album al
    ON a.ArtistId = al.ArtistId
    INNER JOIN Track t
    ON al.AlbumId = t.AlbumId
    INNER JOIN InvoiceLine il
    ON t.TrackId = il.TrackId
    GROUP BY ArtistId
    ) AS ArtistMoney
WHERE ArtistRevenue > (
	SELECT AVG(ArtistRevenue)
    FROM (
		SELECT a.ArtistId, a.Name, SUM(il.UnitPrice * il.Quantity) AS ArtistRevenue
		FROM Artist a
		INNER JOIN Album al
		ON a.ArtistId = al.ArtistId
		INNER JOIN Track t
		ON al.AlbumId = t.AlbumId
		INNER JOIN InvoiceLine il
		ON t.TrackId = il.TrackId
        GROUP BY ArtistId
	) AS ArtistAvg
)
ORDER BY ArtistRevenue DESC
LIMIT 10;

# Find the top 5 genres whose total revenue is higher than the average revenue of all genres.

SELECT GenreMoney.GenreId, GenreMoney.Name, GenreMoney.GenreRevenue
FROM (
	SELECT g.GenreId, g.Name, SUM(il.Quantity * il.UnitPrice) AS GenreRevenue
    FROM Genre g
    INNER JOIN Track t
    ON g.GenreId = t.GenreId
    INNER JOIN InvoiceLine il
	ON t.TrackId = il.TrackId
    GROUP BY GenreId
    ) AS GenreMoney
WHERE GenreRevenue > (
	SELECT AVG(GenreRevenue)
    FROM (
		SELECT g.GenreId, g.Name, SUM(il.Quantity * il.UnitPrice) AS GenreRevenue
		FROM Genre g
		INNER JOIN Track t
		ON g.GenreId = t.GenreId
		INNER JOIN InvoiceLine il
		ON t.TrackId = il.TrackId
		GROUP BY GenreId
	) AS GenreAvg
)
ORDER BY GenreRevenue DESC
LIMIT 5;

#  Top 10 Tracks Generating Above Average Revenue

SELECT TrackMoney.TrackId, TrackMoney.Name, TrackRevenue
FROM (
	SELECT t.TrackId, t.Name, SUM(il.Quantity * il.UnitPrice) AS TrackRevenue
    FROM Track t
    INNER JOIN InvoiceLine il
    ON t.TrackId = il.TrackId
    GROUP BY TrackId
    ) AS TrackMoney
WHERE TrackRevenue > (
	SELECT AVG(TrackRevenue)
    FROM (
		SELECT t.TrackId, t.Name, SUM(il.Quantity * il.UnitPrice) AS TrackRevenue
		FROM Track t
		INNER JOIN InvoiceLine il
		ON t.TrackId = il.TrackId
		GROUP BY TrackId
	) AS TrackAvg
)
ORDER BY TrackRevenue DESC
LIMIT 10;

