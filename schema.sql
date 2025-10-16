-- Q1. Create 6 tables using correct constraints(PK,FK,NOT NULL, CHECK).
-- Table1:Menu
CREATE TABLE Menu (
    MenuID SERIAL PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    Availability BOOLEAN NOT NULL DEFAULT TRUE
);

-- Table2: Customer
CREATE TABLE Customer (
    CustomerID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Contact VARCHAR(15) NOT NULL,
    Email VARCHAR(100),
    Gender VARCHAR(10) CHECK (Gender IN ('Male', 'Female', 'Other'))
);

-- Table3: TableInfo
CREATE TABLE TableInfo (
    TableID SERIAL PRIMARY KEY,
    TableNo VARCHAR(10) NOT NULL UNIQUE,
    Capacity INTEGER NOT NULL CHECK (Capacity > 0),
    Status VARCHAR(20) NOT NULL DEFAULT 'Available' CHECK (Status IN ('Available', 'Occupied', 'Reserved'))
);

-- Table4: Staff
CREATE TABLE Staff (
    StaffID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL CHECK (Role IN ('Waiter', 'Manager', 'Chef', 'Cashier')),
    Contact VARCHAR(15) NOT NULL,
    Shift VARCHAR(20) NOT NULL CHECK (Shift IN ('Morning', 'Evening', 'Night'))
);

-- Table5: OrderInfo
CREATE TABLE OrderInfo (
    OrderID SERIAL PRIMARY KEY,
    CustomerID INTEGER NOT NULL,
    StaffID INTEGER NOT NULL,
    TableID INTEGER NOT NULL,
    OrderDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Confirmed', 'Preparing', 'Ready', 'Served', 'Paid')),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID) ON DELETE CASCADE,
    FOREIGN KEY (TableID) REFERENCES TableInfo(TableID) ON DELETE CASCADE
);

-- Table6: OrderDetail
CREATE TABLE OrderDetail (
    DetailID SERIAL PRIMARY KEY,
    OrderID INTEGER NOT NULL,
    MenuID INTEGER NOT NULL,
    Quantity INTEGER NOT NULL CHECK (Quantity > 0),
    SubTotal DECIMAL(10,2) NOT NULL CHECK (SubTotal >= 0),
    FOREIGN KEY (OrderID) REFERENCES OrderInfo(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (MenuID) REFERENCES Menu(MenuID) ON DELETE CASCADE
);

-- Q3.10 Items inserted, 5 Staff members, and 5 Customers
-- 10 Items inserted
INSERT INTO Menu (ItemName, Category, UnitPrice, Availability) VALUES
('Imvange', 'Main Course', 3000.00, TRUE),
('Ifi', 'Main Course', 5000.50, TRUE),
('Agatogo', 'Appetizer', 5000.00, TRUE),
('Igisafuriya', 'Main Course', 6000.00, TRUE),
('Ubugali', 'Side Dish', 2000.25, TRUE),
('Ibishyimbo', 'Side Dish', 1000.00, TRUE),
('Inyange juice', 'Beverage', 1500.50, TRUE),
('Inkoko', 'Main Course', 6000.00, TRUE),
('Igihaza', 'Appetizer', 2500.50, TRUE),
('Ikivuguto', 'Bevelage', 1000.00, TRUE);

-- 5 Staff members inserted
INSERT INTO Staff (FullName, Role, Contact, Shift) VALUES
('John Nshimiye', 'Waiter', '0787298477', 'Morning'),
('Maria Gaudence', 'Waiter', '0797298333', 'Evening'),
('David Nkurunziza', 'Manager', '0788245111', 'Morning'),
('Sarah Muhorakeye', 'Chef', '0787295744', 'Evening'),
('Mike Mugisha', 'Cashier', '0793345744', 'Night');

-- 5 Customers inserted
INSERT INTO Customer (FullName, Contact, Email, Gender) VALUES
('Alice Umutoni', '0792223333', 'alice@gmail.com', 'Female'),
('Bob Mugisha', '0789933345', 'bob@gmail.com', 'Male'),
(' Tantine Umurangwa', '0787233335', 'tantine@gmail.com', 'Female'),
('Bigwi Lee', '0788893479', 'bigwi@gmail.com', 'Male'),
('Emmanuela Muhire', '0789099887', 'emma@gemail.com', 'Female');

-- Table Information inserted
INSERT INTO TableInfo (TableNo, Capacity, Status) VALUES
('T01', 4, 'Available'),
('T02', 2, 'Available'),
('T03', 6, 'Available'),
('T04', 4, 'Available'),
('T05', 8, 'Available');

-- Insert Order Information
INSERT INTO OrderInfo (CustomerID, StaffID, TableID, OrderDate, Status) VALUES
(1, 1, 1, '2025-08-20 12:30:00', 'Paid'),
(2, 2, 2, '2025-08-20 13:15:00', 'Paid'),
(3, 1, 3, '2025-08-20 18:00:00', 'Paid'),
(4, 2, 4, '2025-08-21 19:30:00', 'Served'),
(1, 1, 1, '2025-08-22 12:45:00', 'Preparing');

-- Insert Order Details
INSERT INTO OrderDetail (OrderID, MenuID, Quantity, SubTotal) VALUES
(1, 1, 2, 6000.00),  -- 2 Imvange
(1, 6, 1, 5000.50),   -- 1 Ifi
(1, 7, 3, 3000.00),  -- 3 Ibishyimbo
(2, 2, 1, 2000.25),   -- 1 Ubugali
(2, 6, 2, 12000.00),   -- 2 Inkoko
(2, 10, 1, 2500.50),  -- 1 Igihaza
(3, 4, 1, 1500.50),  -- 1 Inyange juice
(3, 3, 1, 5000.00),   -- 5 Ibivuguto
(3, 5, 2, 12000.00),  -- 2 Igisafuriya
(4, 9, 2, 10000.00),  -- 2 Agatogo
(5, 7, 2, 3000.00);  -- 1 Imvange

-- Q4.Retrieving top 3 most frequently ordered menu items
SELECT 
    m.ItemName,
    m.Category,
    COUNT(od.DetailID) as OrderCount,
    SUM(od.Quantity) as TotalQuantity
FROM OrderDetail od
JOIN Menu m ON od.MenuID = m.MenuID
GROUP BY m.MenuID, m.ItemName, m.Category
ORDER BY TotalQuantity DESC
LIMIT 3;

-- Q5. Update an order status after payment is received 
--Example: Update Order status to 'Paid'
UPDATE OrderInfo 
SET Status = 'Paid' 
WHERE OrderID = 4;

-- -- to Check if it is updated, use:
SELECT OrderID, Status FROM OrderInfo WHERE OrderID = 4;

-- Q6.Daily sales Report per staff
SELECT 
    s.StaffID,
    s.FullName as StaffName,
    s.Role,
    DATE(o.OrderDate) as OrderDate,
    COUNT(o.OrderID) as TotalOrders,
    SUM(od.SubTotal) as TotalSales
FROM OrderInfo o
JOIN Staff s ON o.StaffID = s.StaffID
JOIN OrderDetail od ON o.OrderID = od.OrderID
WHERE o.Status = 'Paid'
GROUP BY s.StaffID, s.FullName, s.Role, DATE(o.OrderDate)
ORDER BY OrderDate DESC, TotalSales DESC;

-- Q7. Create a View showing total revenue per category, View use double quotes.
CREATE VIEW "CategoryRevenue" AS
SELECT 
    m.Category,
    COUNT(od.DetailID) as TotalOrders,
    SUM(od.Quantity) as TotalItemsSold,
    SUM(od.SubTotal) as TotalRevenue
FROM OrderDetail od
JOIN Menu m ON od.MenuID = m.MenuID
JOIN OrderInfo o ON od.OrderID = o.OrderID
WHERE o.Status = 'Paid'
GROUP BY m.Category
ORDER BY TotalRevenue DESC;
-- Check the created View
SELECT * FROM "CategoryRevenue";

-- Q8.Trigger:To update status automatically when an order start
-- Create the trigger function
CREATE OR REPLACE FUNCTION update_table_status()
RETURNS TRIGGER AS $$
BEGIN
-- When a new order is created, set table status to 'Occupied'
    IF TG_OP = 'INSERT' THEN
        UPDATE TableInfo 
        SET Status = 'Occupied' 
        WHERE TableID = NEW.TableID;
    END IF;
    
-- When an order status changes to 'Paid', set table status back to 'Available'
    IF TG_OP = 'UPDATE' AND NEW.Status = 'Paid' AND OLD.Status != 'Paid' THEN
        UPDATE TableInfo 
        SET Status = 'Available' 
        WHERE TableID = NEW.TableID;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER order_table_status_trigger
    AFTER INSERT OR UPDATE ON OrderInfo
    FOR EACH ROW
    EXECUTE FUNCTION update_table_status();

-- Test the trigger by inserting a new order
INSERT INTO OrderInfo (CustomerID, StaffID, TableID, Status) 
VALUES (2, 2, 2, 'Confirmed');

-- -- Check if table status updated
SELECT TableID, TableNo, Status FROM TableInfo WHERE TableID = 2;

