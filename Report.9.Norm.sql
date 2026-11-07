-- =====================================================================
-- Report.9 - Order form normalized to 3NF
-- Run with:   mysql -u root -p -t < Report.9.Norm.sql
-- Note: ORDER is a reserved word in SQL, so the table name `Order` is
--       always written between backticks.
-- =====================================================================
DROP DATABASE IF EXISTS orderform;
CREATE DATABASE orderform;
USE orderform;

CREATE TABLE Customer (
    CustID   INT          NOT NULL AUTO_INCREMENT,
    Name     VARCHAR(100) NOT NULL,
    Phone    VARCHAR(30),
    Address  VARCHAR(200),
    City     VARCHAR(100),
    PRIMARY KEY (CustID)
);

CREATE TABLE Product (
    ProdID       CHAR(4)       NOT NULL,
    Description  VARCHAR(100)  NOT NULL,
    Price        DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (ProdID)
);

CREATE TABLE `Order` (
    OrderID    VARCHAR(10) NOT NULL,
    OrderDate  DATE        NOT NULL,
    CustID     INT         NOT NULL,
    PRIMARY KEY (OrderID),
    FOREIGN KEY (CustID) REFERENCES Customer (CustID)
);

CREATE TABLE OrderProductList (
    OrderID   VARCHAR(10) NOT NULL,
    ProdID    CHAR(4)     NOT NULL,
    Quantity  INT         NOT NULL DEFAULT 1,
    PRIMARY KEY (OrderID, ProdID),
    FOREIGN KEY (OrderID) REFERENCES `Order` (OrderID),
    FOREIGN KEY (ProdID)  REFERENCES Product (ProdID)
);

-- data of the order form
INSERT INTO Customer (CustID, Name, Phone, Address, City) VALUES
    (1, 'Tran Giang Son', '+84-4 37 91 69 60', '18 Hoang Quoc Viet', 'Hanoi, Vietnam');

INSERT INTO Product (ProdID, Description, Price) VALUES
    ('P101', 'Intel i7 6700K',            349),
    ('P102', 'ASUS Z170A-P',              149),
    ('P103', 'Corsair DDR4 4 x 8GB',      469),
    ('P104', 'Samsung EVO 850 512GB',     249),
    ('P105', 'GeForce GTX 1080 8G',       725),
    ('P106', 'Corsair CS750M 80+ Gold',   119),
    ('P107', 'Corsair Carbide 400R Mid',   85);

INSERT INTO `Order` (OrderID, OrderDate, CustID) VALUES
    ('on7126', '2016-07-11', 1);

INSERT INTO OrderProductList (OrderID, ProdID, Quantity) VALUES
    ('on7126', 'P101', 1), ('on7126', 'P102', 1), ('on7126', 'P103', 1),
    ('on7126', 'P104', 1), ('on7126', 'P105', 1), ('on7126', 'P106', 1),
    ('on7126', 'P107', 1);

-- rebuild the original order form from the 3NF tables
SELECT o.OrderID, o.OrderDate, c.Name, c.Phone, c.Address, c.City
FROM `Order` o
JOIN Customer c ON c.CustID = o.CustID
WHERE o.OrderID = 'on7126';

SELECT l.ProdID, p.Description, l.Quantity, p.Price
FROM OrderProductList l
JOIN Product p ON p.ProdID = l.ProdID
WHERE l.OrderID = 'on7126'
ORDER BY l.ProdID;

SELECT SUM(l.Quantity * p.Price) AS order_total
FROM OrderProductList l
JOIN Product p ON p.ProdID = l.ProdID
WHERE l.OrderID = 'on7126';
