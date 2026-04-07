--
-- PostgreSQL database dump
--

\restrict jCdqD8OyWWSgaVQ7Iqm955cpCf0VGkCNn5snwMhuiN1rbsAw9HYlWQ7UkygwlxQ

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

-- Started on 2026-04-07 16:31:42 EDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3628 (class 0 OID 17999)
-- Dependencies: 218
-- Data for Name: hotel_chain; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain VALUES (3, 'Selkirk', 8, 68, 'Forest Dr', 'Barrie', 'ON', 'L4N0A0');
INSERT INTO locations.hotel_chain VALUES (2, 'Blackfoot', 8, 98, 'Valley St', 'Guelph', 'ON', 'N1G0A0');
INSERT INTO locations.hotel_chain VALUES (4, 'Fairmont', 8, 20, 'Poplar St', 'Victoria', 'BC', 'V8W0A0');
INSERT INTO locations.hotel_chain VALUES (1, 'Sandman', 8, 33, 'Ash Dr', 'Halifax', 'NS', 'B3H0A0');
INSERT INTO locations.hotel_chain VALUES (0, 'Paradox', 8, 86, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A0');


--
-- TOC entry 3629 (class 0 OID 18003)
-- Dependencies: 219
-- Data for Name: hotel_chain_email; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain_email VALUES (0, 'hotel$@Chain.com');
INSERT INTO locations.hotel_chain_email VALUES (1, 'first@Chain.com');


--
-- TOC entry 3632 (class 0 OID 18008)
-- Dependencies: 222
-- Data for Name: hotel_chain_phone; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain_phone VALUES (0, 1111111111);
INSERT INTO locations.hotel_chain_phone VALUES (1, 1111111112);

--
-- TOC entry 3640 (class 0 OID 18030)
-- Dependencies: 230
-- Data for Name: customer; Type: TABLE DATA; Schema: people; Owner: -
--

INSERT INTO people.customer VALUES (0, 'The', '', 'Customer', 12, 'No St.', 'No City', 'No Province', '000000', '2026-03-31', 'SIN', 123123123);
INSERT INTO people.customer VALUES (1, 'The', '', 'Senior', 13, 'No St.', 'No City', 'No Province', '000000', '2026-03-31', 'SIN', 123123124);
INSERT INTO people.customer VALUES (2, 'The', '', 'Junior', 13, 'No St.', 'No City', 'No Province', '000000', '2026-03-31', 'SIN', 123423124);
INSERT INTO people.customer VALUES (3, 'The', '', 'Criminal', 31, 'No St.', 'No City', 'No Province', '000000', '2026-03-31', 'SSN', 223423124);
INSERT INTO people.customer VALUES (5, 'John', '', 'Doe', 5, 'First St.', 'First City', 'Ontario', '000000', '2026-03-31', 'SIN', 323423324);
INSERT INTO people.customer VALUES (6, 'John', '"The Johnson"', 'Johnson', 14, 'First St.', 'First City', 'Ontario', '000000', '2026-03-31', 'SIN', 323463324);
INSERT INTO people.customer VALUES (4, 'Smith', 'Loblaws', 'Smithson', 1, 'First St.', 'First City', 'Ontario', '000000', '2026-03-31', 'SIN', 323423124);

--
-- TOC entry 3642 (class 0 OID 18035)
-- Dependencies: 232
-- Data for Name: employee; Type: TABLE DATA; Schema: people; Owner: -
--

INSERT INTO people.employee VALUES (14, 2, 15, 'Daniel', 'F.', 'Gonzalez', 22, 'Poplar St', 'Victoria', 'BC', 'V8W0A3', 112233445, 'SSN');
INSERT INTO people.employee VALUES (11, 2, 12, 'Abigail', '', 'Smith', 35, 'Ash Dr', 'Halifax', 'NS', 'B3H0A3', 789012345, 'SIN');
INSERT INTO people.employee VALUES (17, 2, 18, 'Isabella', '', 'Thomas', 88, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A3', 445566778, 'SIN');
INSERT INTO people.employee VALUES (5, 2, 6, 'William', '', 'Brown', 124, 'Maple St', 'Toronto', 'ON', 'M1A1A3', 123456789, 'SIN');
INSERT INTO people.employee VALUES (20, 2, 21, 'Lucas', '', 'Jackson', 41, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A3', 778899001, 'SSN');
INSERT INTO people.employee VALUES (8, 2, 9, 'John', 'E.', 'Perez', 91, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A3', 456789012, 'SSN');
INSERT INTO people.employee VALUES (24, 3, 25, 'John', '', 'Miller', 72, 'Forest Dr', 'Barrie', 'ON', 'L4N0A4', 212223242, 'SSN');
INSERT INTO people.employee VALUES (9, 3, 10, 'Amelia', '', 'Gonzalez', 102, 'Valley St', 'Guelph', 'ON', 'N1G0A4', 567890123, 'SIN');
INSERT INTO people.employee VALUES (12, 3, 13, 'Olivia', '', 'Smith', 23, 'Poplar St', 'Victoria', 'BC', 'V8W0A4', 890123456, 'SSN');
INSERT INTO people.employee VALUES (0, 0, 0, 'Daniel', 'A.', 'Jackson', 69, 'Forest Dr', 'Barrie', 'ON', 'L4N0A1', 1, 'SSN');
INSERT INTO people.employee VALUES (31, 0, 32, 'John', 'B.', 'Smith', 123, 'Maple St', 'Toronto', 'ON', 'M1A1A1', 989990919, 'SIN');
INSERT INTO people.employee VALUES (15, 3, 16, 'Daniel', 'H.', 'Thomas', 36, 'Ash Dr', 'Halifax', 'NS', 'B3H0A4', 223344556, 'SIN');
INSERT INTO people.employee VALUES (34, 0, 35, 'Amelia', '', 'Thomas', 39, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A1', 333444555, 'SSN');
INSERT INTO people.employee VALUES (37, 0, 38, 'Olivia', '', 'Brown', 89, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A1', 666777888, 'SIN');
INSERT INTO people.employee VALUES (18, 3, 19, 'Abigail', '', 'Brown', 89, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A4', 556677889, 'SSN');
INSERT INTO people.employee VALUES (21, 3, 22, 'Isabella', '', 'Jackson', 125, 'Maple St', 'Toronto', 'ON', 'M1A1A4', 889900112, 'SIN');
INSERT INTO people.employee VALUES (27, 3, 28, 'William', 'T.', 'Perez', 41, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A4', 545556575, 'SIN');
INSERT INTO people.employee VALUES (6, 3, 7, 'Lucas', '', 'Martinez', 91, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A4', 234567890, 'SSN');
INSERT INTO people.employee VALUES (25, 4, 26, 'Abigail', 'D.', 'Gonzalez', 73, 'Forest Dr', 'Barrie', 'ON', 'L4N0A5', 323334353, 'SIN');
INSERT INTO people.employee VALUES (22, 4, 23, 'Isabella', '', 'Smith', 103, 'Valley St', 'Guelph', 'ON', 'N1G0A5', 990011223, 'SSN');
INSERT INTO people.employee VALUES (19, 4, 20, 'William', '', 'Thomas', 24, 'Poplar St', 'Victoria', 'BC', 'V8W0A5', 667788990, 'SIN');
INSERT INTO people.employee VALUES (3, 1, 3, 'Olivia', 'C.', 'Perez', 70, 'Forest Dr', 'Barrie', 'ON', 'L4N0A2', 1738, 'SIN');
INSERT INTO people.employee VALUES (1, 0, 1, 'Abigail', '', 'Perez', 99, 'Valley St', 'Guelph', 'ON', 'N1G0A1', 2, 'SSN');
INSERT INTO people.employee VALUES (2, 0, 2, 'Isabella', '', 'Martinez', 21, 'Poplar St', 'Victoria', 'BC', 'V8W0A1', NULL, NULL);
INSERT INTO people.employee VALUES (29, 0, 30, 'William', '', 'Miller', 34, 'Ash Dr', 'Halifax', 'NS', 'B3H0A1', 767778797, 'SIN');
INSERT INTO people.employee VALUES (32, 0, 33, 'Lucas', '', 'Gonzalez', 87, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A1', 111222333, 'SSN');
INSERT INTO people.employee VALUES (16, 4, 17, 'Lucas', '', 'Brown', 37, 'Ash Dr', 'Halifax', 'NS', 'B3H0A5', 334455667, 'SSN');
INSERT INTO people.employee VALUES (13, 4, 14, 'John', 'P.', 'Jackson', 89, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A5', 901234567, 'SIN');
INSERT INTO people.employee VALUES (10, 4, 11, 'Amelia', 'G.', 'Perez', 126, 'Maple St', 'Toronto', 'ON', 'M1A1A5', 678901234, 'SSN');
INSERT INTO people.employee VALUES (7, 4, 8, 'Olivia', 'Q.', 'Martinez', 42, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A5', 345678901, 'SIN');
INSERT INTO people.employee VALUES (28, 4, 29, 'Daniel', '', 'Miller', 92, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A5', 656667686, 'SSN');
INSERT INTO people.employee VALUES (40, 0, NULL, 'Not', NULL, 'Manager', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO people.employee VALUES (35, 1, 36, 'Daniel', 'Y.', 'Martinez', 100, 'Valley St', 'Guelph', 'ON', 'N1G0A2', 444555666, 'SIN');
INSERT INTO people.employee VALUES (36, 1, 37, 'Abigail', '', 'Miller', 22, 'Poplar St', 'Victoria', 'BC', 'V8W0A2', 555666777, 'SSN');
INSERT INTO people.employee VALUES (33, 1, 34, 'Isabella', '', 'Gonzalez', 35, 'Ash Dr', 'Halifax', 'NS', 'B3H0A2', 222333444, 'SIN');
INSERT INTO people.employee VALUES (39, 1, 40, 'William', '', 'Smith', 88, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A2', 888999000, 'SIN');
INSERT INTO people.employee VALUES (4, 1, 4, 'Lucas', '', 'Thomas', 123, 'Maple St', 'Toronto', 'ON', 'M1A1A2', 999999999, 'SSN');
INSERT INTO people.employee VALUES (30, 1, 31, 'John', 'D.', 'Brown', 40, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A2', 878889808, 'SSN');
INSERT INTO people.employee VALUES (38, 1, 39, 'Amelia', '', 'Jackson', 90, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A2', 777888999, 'SSN');
INSERT INTO people.employee VALUES (23, 2, 24, 'Amelia', '', 'Martinez', 71, 'Forest Dr', 'Barrie', 'ON', 'L4N0A3', 101112131, 'SIN');
INSERT INTO people.employee VALUES (26, 2, 27, 'Olivia', '', 'Miller', 101, 'Valley St', 'Guelph', 'ON', 'N1G0A3', 434445464, 'SSN');

--
-- TOC entry 3644 (class 0 OID 18040)
-- Dependencies: 234
-- Data for Name: employee_role; Type: TABLE DATA; Schema: people; Owner: -
--

INSERT INTO people.employee_role VALUES (0, 'Manager');
INSERT INTO people.employee_role VALUES (1, 'Manager');
INSERT INTO people.employee_role VALUES (2, 'Manager');
INSERT INTO people.employee_role VALUES (3, 'Manager');
INSERT INTO people.employee_role VALUES (4, 'Manager');
INSERT INTO people.employee_role VALUES (5, 'Manager');
INSERT INTO people.employee_role VALUES (6, 'Manager');
INSERT INTO people.employee_role VALUES (7, 'Manager');
INSERT INTO people.employee_role VALUES (8, 'Manager');
INSERT INTO people.employee_role VALUES (9, 'Manager');
INSERT INTO people.employee_role VALUES (10, 'Manager');
INSERT INTO people.employee_role VALUES (11, 'Manager');
INSERT INTO people.employee_role VALUES (12, 'Manager');
INSERT INTO people.employee_role VALUES (13, 'Manager');
INSERT INTO people.employee_role VALUES (14, 'Manager');
INSERT INTO people.employee_role VALUES (15, 'Manager');
INSERT INTO people.employee_role VALUES (16, 'Manager');
INSERT INTO people.employee_role VALUES (17, 'Manager');
INSERT INTO people.employee_role VALUES (18, 'Manager');
INSERT INTO people.employee_role VALUES (19, 'Manager');
INSERT INTO people.employee_role VALUES (20, 'Manager');
INSERT INTO people.employee_role VALUES (21, 'Manager');
INSERT INTO people.employee_role VALUES (22, 'Manager');
INSERT INTO people.employee_role VALUES (23, 'Manager');
INSERT INTO people.employee_role VALUES (24, 'Manager');
INSERT INTO people.employee_role VALUES (25, 'Manager');
INSERT INTO people.employee_role VALUES (26, 'Manager');
INSERT INTO people.employee_role VALUES (27, 'Manager');
INSERT INTO people.employee_role VALUES (28, 'Manager');
INSERT INTO people.employee_role VALUES (29, 'Manager');
INSERT INTO people.employee_role VALUES (30, 'Manager');
INSERT INTO people.employee_role VALUES (31, 'Manager');
INSERT INTO people.employee_role VALUES (32, 'Manager');
INSERT INTO people.employee_role VALUES (33, 'Manager');
INSERT INTO people.employee_role VALUES (34, 'Manager');
INSERT INTO people.employee_role VALUES (35, 'Manager');
INSERT INTO people.employee_role VALUES (36, 'Manager');
INSERT INTO people.employee_role VALUES (37, 'Manager');
INSERT INTO people.employee_role VALUES (38, 'Manager');
INSERT INTO people.employee_role VALUES (39, 'Manager');

--
-- TOC entry 3627 (class 0 OID 17994)
-- Dependencies: 217
-- Data for Name: hotel; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel VALUES (40, 4, 39, 7, 0, 'Sandman', 88, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A2');
INSERT INTO locations.hotel VALUES (9, 0, 8, 2, 6, 'Sutton', 91, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A4');
INSERT INTO locations.hotel VALUES (10, 0, 9, 4, 6, 'Queen', 42, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A5');
INSERT INTO locations.hotel VALUES (11, 1, 10, 5, 6, 'Carlton', 126, 'Maple St', 'Toronto', 'ON', 'M1A1A5');
INSERT INTO locations.hotel VALUES (12, 1, 11, 7, 5, 'William', 35, 'Ash Dr', 'Halifax', 'NS', 'B3H0A3');
INSERT INTO locations.hotel VALUES (13, 1, 12, 8, 6, 'Place ', 23, 'Poplar St', 'Victoria', 'BC', 'V8W0A4');
INSERT INTO locations.hotel VALUES (14, 1, 13, 3, 6, 'Birks', 89, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A5');
INSERT INTO locations.hotel VALUES (15, 1, 14, 5, 5, 'Petit', 22, 'Poplar St', 'Victoria', 'BC', 'V8W0A3');
INSERT INTO locations.hotel VALUES (20, 2, 19, 6, 5, 'Bed', 37, 'Ash Dr', 'Halifax', 'NS', 'B3H0A5');
INSERT INTO locations.hotel VALUES (23, 2, 22, 3, 0, 'Grand', 24, 'Poplar St', 'Victoria', 'BC', 'V8W0A5');
INSERT INTO locations.hotel VALUES (26, 2, 25, 1, 0, 'Lake', 103, 'Valley St', 'Guelph', 'ON', 'N1G0A5');
INSERT INTO locations.hotel VALUES (27, 2, 26, 4, 0, 'Royal', 71, 'Forest Dr', 'Barrie', 'ON', 'L4N0A3');
INSERT INTO locations.hotel VALUES (29, 3, 28, 7, 0, 'Regis', 73, 'Forest Dr', 'Barrie', 'ON', 'L4N0A5');
INSERT INTO locations.hotel VALUES (31, 3, 30, 5, 0, 'Delta', 41, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A4');
INSERT INTO locations.hotel VALUES (35, 3, 34, 6, 0, 'Suites', 123, 'Maple St', 'Toronto', 'ON', 'M1A1A1');
INSERT INTO locations.hotel VALUES (36, 4, 35, 6, 0, 'Forks', 100, 'Valley St', 'Guelph', 'ON', 'N1G0A2');
INSERT INTO locations.hotel VALUES (37, 4, 36, 5, 0, 'Garry', 22, 'Poplar St', 'Victoria', 'BC', 'V8W0A2');
INSERT INTO locations.hotel VALUES (34, 3, 33, 8, 0, 'Auberge', 40, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A2');
INSERT INTO locations.hotel VALUES (33, 3, 32, 3, 0, 'Palace', 34, 'Ash Dr', 'Halifax', 'NS', 'B3H0A1');
INSERT INTO locations.hotel VALUES (38, 4, 37, 9, 0, 'Selkirk', 89, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A1');
INSERT INTO locations.hotel VALUES (39, 4, 38, 3, 0, 'Blackfoot', 90, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A2');
INSERT INTO locations.hotel VALUES (0, 0, 0, 0, 10, 'Testing', 69, 'Forest Dr', 'Barrie', 'ON', 'L4N0A1');
INSERT INTO locations.hotel VALUES (6, 0, 5, 7, 7, 'Fairmont', 70, 'Forest Dr', 'Barrie', 'ON', 'L4N0A2');
INSERT INTO locations.hotel VALUES (7, 0, 6, 9, 6, 'Paradox', 123, 'Maple St', 'Toronto', 'ON', 'M1A1A2');
INSERT INTO locations.hotel VALUES (8, 0, 7, 6, 5, 'Metropolitan', 124, 'Maple St', 'Toronto', 'ON', 'M1A1A3');
INSERT INTO locations.hotel VALUES (3, 1, 3, 7, 0, 'Reckoning', 91, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A3');
INSERT INTO locations.hotel VALUES (4, 1, 4, 8, 0, 'Retconning', 102, 'Valley St', 'Guelph', 'ON', 'N1G0A4');
INSERT INTO locations.hotel VALUES (28, 3, 27, 8, 0, 'Sheraton', 72, 'Forest Dr', 'Barrie', 'ON', 'L4N0A4');
INSERT INTO locations.hotel VALUES (1, 0, 1, 10, 5, 'Slumber', 99, 'Valley St', 'Guelph', 'ON', 'N1G0A1');
INSERT INTO locations.hotel VALUES (2, 0, 2, 7, 5, 'Wakening', 21, 'Poplar St', 'Victoria', 'BC', 'V8W0A1');
INSERT INTO locations.hotel VALUES (16, 1, 15, 6, 4, 'Banff', 36, 'Ash Dr', 'Halifax', 'NS', 'B3H0A4');
INSERT INTO locations.hotel VALUES (21, 2, 20, 7, 0, 'Oswego', 88, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A3');
INSERT INTO locations.hotel VALUES (22, 2, 21, 8, 0, 'Empress', 89, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A4');
INSERT INTO locations.hotel VALUES (24, 2, 23, 5, 0, 'Resort', 41, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A3');
INSERT INTO locations.hotel VALUES (25, 2, 24, 6, 0, 'Sunset', 125, 'Maple St', 'Toronto', 'ON', 'M1A1A4');
INSERT INTO locations.hotel VALUES (30, 3, 29, 7, 0, 'Chelsea', 101, 'Valley St', 'Guelph', 'ON', 'N1G0A3');
INSERT INTO locations.hotel VALUES (32, 3, 31, 5, 0, 'Frontenac', 92, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A5');
INSERT INTO locations.hotel VALUES (17, 4, 16, 3, 4, 'Moose', 87, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A1');
INSERT INTO locations.hotel VALUES (18, 4, 17, 4, 5, 'Delta', 35, 'Ash Dr', 'Halifax', 'NS', 'B3H0A2');
INSERT INTO locations.hotel VALUES (19, 4, 18, 2, 4, 'Arts', 39, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A1');

--
-- TOC entry 3633 (class 0 OID 18011)
-- Dependencies: 223
-- Data for Name: hotel_email; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_email VALUES (0, 'unique@hotels.com');
INSERT INTO locations.hotel_email VALUES (1, 'unique2@hotels.com');
INSERT INTO locations.hotel_email VALUES (2, 'chicken@hotels.com');
INSERT INTO locations.hotel_email VALUES (3, 'food@hotels.com');


--
-- TOC entry 3635 (class 0 OID 18015)
-- Dependencies: 225
-- Data for Name: hotel_phone; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_phone VALUES (0, 1111111111);
INSERT INTO locations.hotel_phone VALUES (1, 1345167232);
INSERT INTO locations.hotel_phone VALUES (2, 2345167232);
INSERT INTO locations.hotel_phone VALUES (3, 2345667232);


--
-- TOC entry 3636 (class 0 OID 18018)
-- Dependencies: 226
-- Data for Name: room; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room VALUES (1, 6, 120, 2, 'Sea', true);
INSERT INTO locations.room VALUES (2, 7, 150, 3, 'Mountain', false);
INSERT INTO locations.room VALUES (3, 8, 200, 4, 'Sea', true);
INSERT INTO locations.room VALUES (4, 9, 180, 2, 'Mountain', false);
INSERT INTO locations.room VALUES (11, 1, 2000, 3, 'Mountain', false);
INSERT INTO locations.room VALUES (14, 1, 2000, 1, 'Sea', false);
INSERT INTO locations.room VALUES (15, 2, 2200, 2, 'Sea', false);
INSERT INTO locations.room VALUES (16, 2, 2200, 2, 'Sea', false);
INSERT INTO locations.room VALUES (17, 2, 2200, 2, 'Sea', false);
INSERT INTO locations.room VALUES (18, 2, 2300, 2, 'Sea', true);
INSERT INTO locations.room VALUES (19, 2, 2200, 2, 'Mountain', true);
INSERT INTO locations.room VALUES (5, 10, 220, 5, 'Sea', true);
INSERT INTO locations.room VALUES (6, 11, 140, 2, 'Mountain', true);
INSERT INTO locations.room VALUES (7, 12, 175, 3, 'Sea', false);
INSERT INTO locations.room VALUES (8, 13, 160, 2, 'Mountain', true);
INSERT INTO locations.room VALUES (9, 14, 210, 4, 'Sea', false);
INSERT INTO locations.room VALUES (10, 15, 190, 3, 'Mountain', true);
INSERT INTO locations.room VALUES (11, 16, 130, 2, 'Sea', false);
INSERT INTO locations.room VALUES (12, 17, 170, 3, 'Mountain', true);
INSERT INTO locations.room VALUES (13, 18, 250, 5, 'Sea', false);
INSERT INTO locations.room VALUES (14, 19, 300, 6, 'Mountain', true);
INSERT INTO locations.room VALUES (15, 20, 275, 4, 'Sea', false);
INSERT INTO locations.room VALUES (16, 6, 160, 3, 'Mountain', true);
INSERT INTO locations.room VALUES (17, 7, 180, 2, 'Sea', false);
INSERT INTO locations.room VALUES (18, 8, 220, 4, 'Mountain', true);
INSERT INTO locations.room VALUES (19, 9, 240, 5, 'Sea', false);
INSERT INTO locations.room VALUES (20, 10, 260, 6, 'Mountain', true);
INSERT INTO locations.room VALUES (1, 11, 135, 2, 'Sea', true);
INSERT INTO locations.room VALUES (2, 12, 145, 3, 'Mountain', false);
INSERT INTO locations.room VALUES (3, 13, 155, 2, 'Sea', true);
INSERT INTO locations.room VALUES (4, 14, 165, 3, 'Mountain', false);
INSERT INTO locations.room VALUES (5, 15, 175, 4, 'Sea', true);
INSERT INTO locations.room VALUES (6, 16, 185, 2, 'Mountain', false);
INSERT INTO locations.room VALUES (7, 17, 195, 3, 'Sea', true);
INSERT INTO locations.room VALUES (8, 18, 205, 4, 'Mountain', false);
INSERT INTO locations.room VALUES (9, 19, 215, 5, 'Sea', true);
INSERT INTO locations.room VALUES (10, 20, 225, 2, 'Mountain', false);
INSERT INTO locations.room VALUES (11, 6, 235, 3, 'Sea', true);
INSERT INTO locations.room VALUES (12, 7, 245, 4, 'Mountain', false);
INSERT INTO locations.room VALUES (13, 8, 255, 5, 'Sea', true);
INSERT INTO locations.room VALUES (14, 9, 265, 2, 'Mountain', false);
INSERT INTO locations.room VALUES (15, 10, 275, 3, 'Sea', true);
INSERT INTO locations.room VALUES (16, 11, 285, 4, 'Mountain', false);
INSERT INTO locations.room VALUES (17, 12, 295, 5, 'Sea', true);
INSERT INTO locations.room VALUES (18, 13, 305, 2, 'Mountain', false);
INSERT INTO locations.room VALUES (19, 14, 315, 3, 'Sea', true);
INSERT INTO locations.room VALUES (20, 15, 325, 4, 'Mountain', false);
INSERT INTO locations.room VALUES (7, 14, 198, 3, 'Sea', true);
INSERT INTO locations.room VALUES (12, 9, 256, 4, 'Mountain', false);
INSERT INTO locations.room VALUES (3, 18, 145, 2, 'Sea', true);
INSERT INTO locations.room VALUES (19, 7, 310, 5, 'Mountain', true);
INSERT INTO locations.room VALUES (5, 11, 167, 2, 'Sea', false);
INSERT INTO locations.room VALUES (16, 20, 289, 6, 'Mountain', true);
INSERT INTO locations.room VALUES (2, 6, 134, 2, 'Sea', false);
INSERT INTO locations.room VALUES (11, 15, 222, 3, 'Mountain', true);
INSERT INTO locations.room VALUES (12, 13, 175, 2, 'Sea', true);
INSERT INTO locations.room VALUES (14, 17, 260, 4, 'Mountain', false);
INSERT INTO locations.room VALUES (1, 12, 120, 1, 'Sea', false);
INSERT INTO locations.room VALUES (20, 8, 330, 5, 'Mountain', true);
INSERT INTO locations.room VALUES (6, 19, 210, 3, 'Sea', true);
INSERT INTO locations.room VALUES (11, 10, 240, 4, 'Mountain', false);
INSERT INTO locations.room VALUES (4, 16, 155, 2, 'Sea', true);
INSERT INTO locations.room VALUES (10, 14, 200, 3, 'Mountain', false);
INSERT INTO locations.room VALUES (13, 6, 270, 5, 'Sea', true);
INSERT INTO locations.room VALUES (18, 11, 295, 4, 'Mountain', true);
INSERT INTO locations.room VALUES (15, 9, 225, 3, 'Sea', false);
INSERT INTO locations.room VALUES (17, 20, 305, 5, 'Mountain', true);
INSERT INTO locations.room VALUES (7, 8, 180, 2, 'Sea', false);
INSERT INTO locations.room VALUES (12, 18, 265, 4, 'Mountain', true);
INSERT INTO locations.room VALUES (3, 7, 150, 2, 'Sea', true);
INSERT INTO locations.room VALUES (19, 13, 315, 6, 'Mountain', false);
INSERT INTO locations.room VALUES (6, 10, 170, 2, 'Sea', true);
INSERT INTO locations.room VALUES (6, 6, 285, 5, 'Mountain', false);
INSERT INTO locations.room VALUES (2, 15, 140, 1, 'Sea', true);
INSERT INTO locations.room VALUES (10, 11, 230, 3, 'Mountain', true);
INSERT INTO locations.room VALUES (8, 17, 190, 2, 'Sea', false);
INSERT INTO locations.room VALUES (14, 12, 255, 4, 'Mountain', true);
INSERT INTO locations.room VALUES (1, 19, 125, 1, 'Sea', false);
INSERT INTO locations.room VALUES (20, 9, 335, 6, 'Mountain', true);
INSERT INTO locations.room VALUES (60, 16, 205, 3, 'Sea', true);
INSERT INTO locations.room VALUES (11, 14, 245, 4, 'Mountain', false);
INSERT INTO locations.room VALUES (4, 20, 160, 2, 'Sea', true);
INSERT INTO locations.room VALUES (9, 7, 210, 3, 'Mountain', false);
INSERT INTO locations.room VALUES (1, 18, 275, 5, 'Sea', true);
INSERT INTO locations.room VALUES (18, 10, 300, 4, 'Mountain', true);
INSERT INTO locations.room VALUES (15, 13, 235, 3, 'Sea', false);
INSERT INTO locations.room VALUES (17, 6, 310, 5, 'Mountain', true);
INSERT INTO locations.room VALUES (3, 0, 560, 1, 'Sea', false);
INSERT INTO locations.room VALUES (4, 0, 700, 1, 'Sea', false);
INSERT INTO locations.room VALUES (8, 0, 1340, 7, 'Sea', false);
INSERT INTO locations.room VALUES (6, 0, 1900, 3, 'Sea', true);
INSERT INTO locations.room VALUES (0, 0, 227, 1, 'Sea', false);
INSERT INTO locations.room VALUES (1, 0, 777, 1, 'Mountain', false);
INSERT INTO locations.room VALUES (2, 0, 227, 1, 'Mountain', false);
INSERT INTO locations.room VALUES (12, 1, 1600, 2, 'Mountain', false);
INSERT INTO locations.room VALUES (13, 1, 500, 2, 'Sea', false);
INSERT INTO locations.room VALUES (5, 0, 214, 1, 'Sea', true);
INSERT INTO locations.room VALUES (7, 0, 222, 1, 'Sea', true);
INSERT INTO locations.room VALUES (9, 0, 1660, 4, 'Mountain', true);
INSERT INTO locations.room VALUES (10, 1, 900, 4, 'Mountain', false);


--
-- TOC entry 3637 (class 0 OID 18023)
-- Dependencies: 227
-- Data for Name: room_amenities; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room_amenities VALUES (0, 0, '');
INSERT INTO locations.room_amenities VALUES (1, 0, 'Trees');
INSERT INTO locations.room_amenities VALUES (1, 0, 'Blankets');


--
-- TOC entry 3638 (class 0 OID 18026)
-- Dependencies: 228
-- Data for Name: room_problems; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room_problems VALUES (0, 0, 'Legs');
INSERT INTO locations.room_problems VALUES (0, 0, 'Eyes');
INSERT INTO locations.room_problems VALUES (0, 0, 'Chicken');
INSERT INTO locations.room_problems VALUES (1, 0, 'Chicken');
INSERT INTO locations.room_problems VALUES (2, 0, 'Chicken');


--
-- TOC entry 3645 (class 0 OID 18043)
-- Dependencies: 235
-- Data for Name: booking_records; Type: TABLE DATA; Schema: records; Owner: -
--

INSERT INTO records.booking_records VALUES (1, 1, 0, 1, '2026-03-31', '2026-04-01', 'Active');
INSERT INTO records.booking_records VALUES (2, 2, 0, 2, '2026-03-31', '2026-04-01', 'Active');
INSERT INTO records.booking_records VALUES (3, 10, 1, 4, '2026-03-31', '2026-04-05', 'Active');
INSERT INTO records.booking_records VALUES (4, 11, 1, 5, '2024-04-05', '2026-04-05', 'Cancelled');
INSERT INTO records.booking_records VALUES (5, 11, 1, 5, '2026-04-01', '2026-04-05', 'Active');
INSERT INTO records.booking_records VALUES (0, 0, 0, 0, '2026-03-31', '2027-03-31', 'Cancelled');

--
-- TOC entry 3649 (class 0 OID 18052)
-- Dependencies: 239
-- Data for Name: renting_records; Type: TABLE DATA; Schema: records; Owner: -
--

--
-- TOC entry 3646 (class 0 OID 18047)
-- Dependencies: 236
-- Data for Name: booking_archive; Type: TABLE DATA; Schema: records; Owner: -
--

--
-- TOC entry 3651 (class 0 OID 18057)
-- Dependencies: 241
-- Data for Name: renting_archive; Type: TABLE DATA; Schema: records; Owner: -
--

INSERT INTO records.renting_archive VALUES (1, 9001, 'Archive Customer', 'Archive Employee', 'Archive Hotel', 101, '2025-11-01', '2025-11-06', 1450, 'Checked-Out');
INSERT INTO records.renting_archive VALUES (2, 0, 'The  Customer', 'Bob  Bobson', 'Testing', 0, '2026-03-31', '2027-03-31', 1000, 'Checked-Out');

-- Completed on 2026-04-07 16:31:42 EDT

--
-- PostgreSQL database dump complete
--

\unrestrict jCdqD8OyWWSgaVQ7Iqm955cpCf0VGkCNn5snwMhuiN1rbsAw9HYlWQ7UkygwlxQ
