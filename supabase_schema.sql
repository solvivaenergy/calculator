-- ============================================================
-- SOLVIVA CALCULATOR — Supabase Database Schema & Seed Data
-- Run this in the Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- 1. ASSUMPTIONS
CREATE TABLE assumptions (
    key TEXT PRIMARY KEY,
    value NUMERIC NOT NULL
);

INSERT INTO
    assumptions (key, value)
VALUES ('acPeakUtilization', 0.5),
    ('inflationRate', 0.03),
    ('netMeteringEfficiency', 0.5),
    ('netMeteringBuyback', 7.25),
    ('rtoInterestRate', 0.28),
    ('partnerDiscount', 0.05),
    ('kwhPerKwpPerDay', 3.6),
    ('batteryEfficiency', 0.98),
    ('allowableDoD', 0.95),
    ('solarDegradation', 0.005),
    ('lcoeNpvRate', 0.06),
    ('npvDiscountEarlyPay', 0.08),
    ('batteryMargin', 0.28),
    ('rsdMargin', 0.28),
    ('netMeteringMargin', 0.40),
    ('cfeiMargin', 0.40),
    ('cablingMargin', 0.28),
    ('travelMargin', 0.28),
    ('roofLocationMargin', 0.20);

-- 2. DEVICES
CREATE TABLE devices (
    name TEXT PRIMARY KEY,
    kw NUMERIC NOT NULL,
    is_ac BOOLEAN NOT NULL DEFAULT FALSE
);

INSERT INTO
    devices (name, kw, is_ac)
VALUES ('', 0, FALSE),
    ('1.0hp AC', 1, TRUE),
    ('1.5hp AC', 1.3, TRUE),
    ('2.0hp AC', 1.8, TRUE),
    ('2.5hp AC', 2, TRUE),
    ('3.0hp AC', 2.8, TRUE),
    ('Microwave/Toaster', 1, FALSE),
    ('6" Stove Burner', 1.5, FALSE),
    ('8" Stove Burner', 2.5, FALSE),
    ('Electric Oven', 3, FALSE),
    (
        'Level-1 EV Charger',
        1.5,
        FALSE
    ),
    (
        'Level-2 EV Charger',
        9.6,
        FALSE
    ),
    ('Washing Machine', 0.8, FALSE),
    (
        'Elec Clothes Dryer',
        5,
        FALSE
    );

-- 3. RADIANCE CURVE
CREATE TABLE radiance_curve (
    hour INTEGER PRIMARY KEY,
    factor NUMERIC NOT NULL
);

INSERT INTO
    radiance_curve (hour, factor)
VALUES (6, 0.017),
    (7, 0.049),
    (8, 0.078),
    (9, 0.103),
    (10, 0.121),
    (11, 0.132),
    (12, 0.132),
    (13, 0.121),
    (14, 0.103),
    (15, 0.078),
    (16, 0.049),
    (17, 0.017);

-- 4. SOLAR PRICES
CREATE TABLE solar_prices (
    kwp NUMERIC PRIMARY KEY,
    price_per_kwp NUMERIC NOT NULL,
    cost NUMERIC NOT NULL,
    acqui_cost NUMERIC NOT NULL
);

INSERT INTO
    solar_prices (
        kwp,
        price_per_kwp,
        cost,
        acqui_cost
    )
VALUES (5.16, 45000, 165780, 15000),
    (6.41, 45000, 186674, 15000),
    (8.39, 45000, 268809, 15000),
    (10.32, 40500, 313550, 15000),
    (12.26, 40500, 385683, 15000),
    (15.48, 38250, 438445, 15000),
    (20, 38250, 560120, 15000);

-- 5. ROOF PRICES (surcharge by kWp index position 0-6)
CREATE TABLE roof_prices (
    roof_type TEXT NOT NULL,
    kwp_index INTEGER NOT NULL,
    spot_price NUMERIC NOT NULL,
    PRIMARY KEY (roof_type, kwp_index)
);

INSERT INTO
    roof_prices (
        roof_type,
        kwp_index,
        spot_price
    )
VALUES ('asphalt', 0, 46830),
    ('asphalt', 1, 58695),
    ('asphalt', 2, 76302.8),
    ('asphalt', 3, 93912),
    ('asphalt', 4, 111520.5),
    ('asphalt', 5, 140868),
    ('asphalt', 6, 181954.5),
    ('concrete', 0, 86688),
    ('concrete', 1, 108360),
    ('concrete', 2, 140868),
    ('concrete', 3, 173376),
    ('concrete', 4, 205884),
    ('concrete', 5, 260064),
    ('concrete', 6, 335916);

-- 6. LOCATION PRICES (surcharge by kWp index position 0-6)
CREATE TABLE location_prices (
    location TEXT NOT NULL,
    kwp_index INTEGER NOT NULL,
    spot_price NUMERIC NOT NULL,
    PRIMARY KEY (location, kwp_index)
);

INSERT INTO
    location_prices (
        location,
        kwp_index,
        spot_price
    )
VALUES ('cebu', 0, 102318.104),
    ('cebu', 1, 113119.034),
    ('cebu', 2, 129753.316),
    ('cebu', 3, 150987.914),
    ('cebu', 4, 167535.452),
    ('cebu', 5, 194542.46),
    ('cebu', 6, 237685.196),
    ('siargao', 0, 566558.104),
    ('siargao', 1, 577359.034),
    ('siargao', 2, 593993.316),
    ('siargao', 3, 650507.914),
    ('siargao', 4, 667055.452),
    ('siargao', 5, 694062.46),
    ('siargao', 6, 772485.196);

-- 7. RSD PRICES
CREATE TABLE rsd_prices (
    kwp NUMERIC PRIMARY KEY,
    cost NUMERIC NOT NULL,
    spot NUMERIC NOT NULL
);

INSERT INTO
    rsd_prices (kwp, cost, spot)
VALUES (5.16, 20900, 32511.11),
    (6.41, 24500, 38111.11),
    (8.39, 29900, 46511.11),
    (10.32, 35300, 54911.11),
    (12.26, 40700, 63311.11),
    (15.48, 49700, 77311.11),
    (20, 62300, 96911.11);

-- 8. BATTERY PRICES
CREATE TABLE battery_prices (
    component TEXT PRIMARY KEY,
    cost NUMERIC NOT NULL,
    spot NUMERIC NOT NULL
);

INSERT INTO
    battery_prices (component, cost, spot)
VALUES ('battery', 46100, 71711.11),
    ('rack', 5000, 7777.78),
    ('ats', 6000, 9333.33),
    ('materials', 2200, 3422.22),
    (
        'installWith',
        10500,
        16333.33
    ),
    (
        'installAlone',
        26500,
        41222.22
    );

-- 9. OTHER PRICES
CREATE TABLE other_prices (
    key TEXT PRIMARY KEY,
    cost NUMERIC,
    spot NUMERIC
);

INSERT INTO
    other_prices (key, cost, spot)
VALUES (
        'netMetering',
        20050,
        37426.67
    ),
    (
        'cfeiPermits',
        20000,
        37333.33
    ),
    ('dcCablePerM', 750, 1166.67),
    ('acCablePerM', 1600, 2488.89),
    (
        'deliveryFixed',
        4000,
        6222.22
    ),
    ('deliveryPerKm', 50, 77.78);

-- 10. MAINTENANCE PRICES
CREATE TABLE maintenance_prices (
    kwp NUMERIC PRIMARY KEY,
    cost_per_visit NUMERIC NOT NULL
);

INSERT INTO
    maintenance_prices (kwp, cost_per_visit)
VALUES (5.16, 8930),
    (6.41, 8930),
    (8.39, 8930),
    (10.32, 8930),
    (12.26, 9850),
    (15.48, 12460),
    (20, 16100);

-- ============================================================
-- ROW LEVEL SECURITY — public read-only via anon key
-- ============================================================
ALTER TABLE assumptions ENABLE ROW LEVEL SECURITY;

ALTER TABLE devices ENABLE ROW LEVEL SECURITY;

ALTER TABLE radiance_curve ENABLE ROW LEVEL SECURITY;

ALTER TABLE solar_prices ENABLE ROW LEVEL SECURITY;

ALTER TABLE roof_prices ENABLE ROW LEVEL SECURITY;

ALTER TABLE location_prices ENABLE ROW LEVEL SECURITY;

ALTER TABLE rsd_prices ENABLE ROW LEVEL SECURITY;

ALTER TABLE battery_prices ENABLE ROW LEVEL SECURITY;

ALTER TABLE other_prices ENABLE ROW LEVEL SECURITY;

ALTER TABLE maintenance_prices ENABLE ROW LEVEL SECURITY;

-- Allow anyone (anon) to SELECT
CREATE POLICY "Public read" ON assumptions FOR SELECT USING (true);

CREATE POLICY "Public read" ON devices FOR SELECT USING (true);

CREATE POLICY "Public read" ON radiance_curve FOR
SELECT USING (true);

CREATE POLICY "Public read" ON solar_prices FOR SELECT USING (true);

CREATE POLICY "Public read" ON roof_prices FOR SELECT USING (true);

CREATE POLICY "Public read" ON location_prices FOR
SELECT USING (true);

CREATE POLICY "Public read" ON rsd_prices FOR SELECT USING (true);

CREATE POLICY "Public read" ON battery_prices FOR
SELECT USING (true);

CREATE POLICY "Public read" ON other_prices FOR SELECT USING (true);

CREATE POLICY "Public read" ON maintenance_prices FOR
SELECT USING (true);