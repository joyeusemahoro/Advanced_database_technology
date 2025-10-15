-- Q1. Create 6 tables using correct constraints(PK,FK,NOT NULL, CHECK).
-- Table1:Menu
CREATE TABLE Menu (
    MenuID SERIAL PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    UnitPrice NUMERIC(10,2) NOT NULL CHECK (UnitPrice > 0),
    Availability BOOLEAN NOT NULL DEFAULT TRUE
);

-- Table2: Customer
CREATE TABLE Customer (
    CustomerID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Contact VARCHAR(15),
    Email VARCHAR(100),
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other'))
);

-- Table3: TableInfo
CREATE TABLE TableInfo (
    TableID SERIAL PRIMARY KEY,
    TableNo INT NOT NULL UNIQUE,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Status VARCHAR(20) NOT NULL DEFAULT 'Available'
);

-- Table4: Staff
CREATE TABLE Staff (
    StaffID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Contact VARCHAR(15),
    Shift VARCHAR(20) CHECK (Shift IN ('Morning', 'Evening', 'Night'))
);

-- Table5: OrderInfo
CREATE TABLE OrderInfo (
    OrderID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL REFERENCES Customer(CustomerID),
    StaffID INT NOT NULL REFERENCES Staff(StaffID),
    TableID INT NOT NULL REFERENCES TableInfo(TableID),
    OrderDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
);

-- Table6: OrderDetail
CREATE TABLE OrderDetail (
    DetailID SERIAL PRIMARY KEY,
-- 	-- Q2.CASCADE DELETE applied on the following row
    OrderID INT NOT NULL REFERENCES OrderInfo(OrderID) ON DELETE CASCADE,
    MenuID INT NOT NULL REFERENCES Menu(MenuID),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    SubTotal NUMERIC(10,2) NOT NULL CHECK (SubTotal >= 0)
);

-- Q3.10 Items inserted, 5 Staff members, and 5 Customers
-- 10 Items inserted
INSERT INTO Menu(ItemName,Category,UnitPrice) VALUES 
('Ubugali','Side',1500.05),
('Imvange','Main Course', 4000),
('Ibishyimbo','Side', 1000),
('Inkoko','Main Course', 6000),
('Ifi','Main Course', 5000),
('Igisafuriya','Main Course', 5000),
('Agatogo','Apettizer', 3000.15),
('Igihaza','Apettizer', 2000),
('Inyange juice','Bevelage', 400),
('Ikivuguto','Bevelage', 400);

-- 5 Staff members inserted
INSERT INTO Staff (FullName, Role, Contact, Shift) VALUES
('Alice Umutoni', 'Waiter', '0788123456', 'Morning'),
('JeanClaude Kabayiza', 'Chef', '0788234567', 'Evening'),
('Judith Murekatete', 'Waiter', '0788345678', 'Night'),
('Eric Niyonsaba', 'Manager', '0788456789', 'Morning'),
('Diane Uwamahoro', 'Waiter', '0788567890', 'Evening');

-- 5 Customers inserted
INSERT INTO Customer (FullName, Contact, Email, Gender) VALUES
('John Nshimiye', '0788000001', 'john@gmail.com', 'Male'),
('Jane Ishimwe', '0788000002', 'jane@gmail.com', 'Female'),
('Alice Kayitesi', '0788000003', 'alice@gmail.com', 'Female'),
('David Nkurunziza', '0788000004', 'david@gmail.com', 'Male'),
('Grace Uwimana', '0788000005', 'grace@gmail.com', 'Female');

-- Q4.Retrieving top 3 most frequently ordered menu items
SELECT m.ItemName, COUNT(od.MenuID) AS TimesOrdered
FROM OrderDetail od
JOIN Menu m ON od.MenuID = m.MenuID
GROUP BY m.ItemName
ORDER BY TimesOrdered DESC
LIMIT 3;

-- Q5. Update an order'status after payment is received
UPDATE OrderInfo
SET Status = 'Paid'
WHERE OrderID = 1;

-- Q6.Daily sales Report per staff
SELECT s.FullName AS StaffName, DATE(o.OrderDate) AS SaleDate, SUM(od.SubTotal) AS TotalSales
FROM OrderInfo o
JOIN Staff s ON o.StaffID = s.StaffID
JOIN OrderDetail od ON o.OrderID = od.OrderID
GROUP BY s.FullName, DATE(o.OrderDate)
ORDER BY SaleDate, StaffName;

-- Q7. Create a View showing total revenue per category
CREATE VIEW RevenuePerCategory AS
SELECT m.Category, SUM(od.SubTotal) AS TotalRevenue
FROM OrderDetail od
JOIN Menu m ON od.MenuID = m.MenuID
GROUP BY m.Category;

-- Q8.Trigger:To update status automatically when an order start
CREATE OR REPLACE FUNCTION update_table_status()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE TableInfo
    SET Status = 'Occupied'
    WHERE TableID = NEW.TableID;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_table_status
AFTER INSERT ON OrderInfo
FOR EACH ROW
EXECUTE FUNCTION update_table_status();
