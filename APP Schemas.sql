--
-- PostgreSQL database dump
--

\restrict Lt6rwiWGuq1So7GYfKNHkNVC2aWAFyQFSf80ZgfKVfLphHdJDSvPIwss1MI0ozY

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

-- Started on 2026-03-25 23:12:26 EDT

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
-- TOC entry 7 (class 2615 OID 17136)
-- Name: locations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA locations;


ALTER SCHEMA locations OWNER TO postgres;

--
-- TOC entry 6 (class 2615 OID 17135)
-- Name: people; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA people;


ALTER SCHEMA people OWNER TO postgres;

--
-- TOC entry 5 (class 2615 OID 17128)
-- Name: records; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA records;


ALTER SCHEMA records OWNER TO postgres;

--
-- TOC entry 867 (class 1247 OID 17160)
-- Name: view_type; Type: TYPE; Schema: locations; Owner: postgres
--

CREATE TYPE locations.view_type AS ENUM (
    'Sea',
    'Mountain'
);


ALTER TYPE locations.view_type OWNER TO postgres;

--
-- TOC entry 861 (class 1247 OID 17146)
-- Name: gid; Type: TYPE; Schema: people; Owner: postgres
--

CREATE TYPE people.gid AS ENUM (
    'SSN',
    'SIN',
    'Driver'
);


ALTER TYPE people.gid OWNER TO postgres;

--
-- TOC entry 864 (class 1247 OID 17154)
-- Name: gid9; Type: TYPE; Schema: people; Owner: postgres
--

CREATE TYPE people.gid9 AS ENUM (
    'SSN',
    'SIN'
);


ALTER TYPE people.gid9 OWNER TO postgres;

--
-- TOC entry 858 (class 1247 OID 17138)
-- Name: booking_states; Type: TYPE; Schema: records; Owner: postgres
--

CREATE TYPE records.booking_states AS ENUM (
    'Active',
    'Transformed',
    'Cancelled'
);


ALTER TYPE records.booking_states OWNER TO postgres;

--
-- TOC entry 855 (class 1247 OID 17130)
-- Name: checking_states; Type: TYPE; Schema: records; Owner: postgres
--

CREATE TYPE records.checking_states AS ENUM (
    'Checked-In',
    'Checked-Out'
);


ALTER TYPE records.checking_states OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 17213)
-- Name: hotel; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.hotel (
    hotel_id integer NOT NULL,
    chain_id integer NOT NULL,
    manager_id integer NOT NULL,
    rating integer,
    number_rooms integer,
    name integer,
    street_number integer,
    street_name character varying(20),
    city character varying(20),
    province character varying(20),
    postal_code character varying(6),
    CONSTRAINT hotel_number_rooms_check CHECK ((number_rooms > 0)),
    CONSTRAINT hotel_rating_check CHECK (((rating >= 0) AND (rating <= 10)))
);


ALTER TABLE locations.hotel OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 17165)
-- Name: hotel_chain; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.hotel_chain (
    hotel_chain_id integer NOT NULL,
    name character varying(20),
    number_hotels integer,
    street_number integer,
    street_name character varying(20),
    city character varying(20),
    province character varying(20),
    postal_code character varying(6)
);


ALTER TABLE locations.hotel_chain OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17170)
-- Name: hotel_chain_email; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.hotel_chain_email (
    chain_id integer NOT NULL,
    chain_email character varying(20) NOT NULL
);


ALTER TABLE locations.hotel_chain_email OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17180)
-- Name: hotel_chain_phone; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.hotel_chain_phone (
    chain_id integer NOT NULL,
    chain_phone numeric(10,0) NOT NULL
);


ALTER TABLE locations.hotel_chain_phone OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 17232)
-- Name: hotel_email; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.hotel_email (
    id integer NOT NULL,
    email character varying(20) NOT NULL
);


ALTER TABLE locations.hotel_email OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17242)
-- Name: hotel_phone; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.hotel_phone (
    id integer NOT NULL,
    phone numeric(10,0) NOT NULL
);


ALTER TABLE locations.hotel_phone OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 17252)
-- Name: room; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.room (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    price integer,
    capacity integer,
    view_type locations.view_type,
    is_etendable boolean,
    CONSTRAINT room_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT room_price_check CHECK ((price > 0))
);


ALTER TABLE locations.room OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 17274)
-- Name: room_amenities; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.room_amenities (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    amenity character varying(20) NOT NULL
);


ALTER TABLE locations.room_amenities OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17284)
-- Name: room_problems; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.room_problems (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    problem character varying(20) NOT NULL
);


ALTER TABLE locations.room_problems OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 17294)
-- Name: customer; Type: TABLE; Schema: people; Owner: postgres
--

CREATE TABLE people.customer (
    customer_id integer NOT NULL,
    first_name character varying(20),
    middle_name character varying(20),
    last_name character varying(20),
    street_number integer,
    street_name character varying(20),
    city character varying(20),
    province character varying(20),
    postal_code character varying(6),
    registration_date date DEFAULT now(),
    id_type people.gid,
    id_number integer
);


ALTER TABLE people.customer OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17190)
-- Name: employee; Type: TABLE; Schema: people; Owner: postgres
--

CREATE TABLE people.employee (
    employee_id integer NOT NULL,
    chain_id integer,
    hotel_id integer,
    first_name character varying(20),
    middle_name character varying(20),
    last_name character varying(20),
    street_number integer,
    street_name character varying(20),
    city character varying(20),
    province character varying(20),
    postal_code character varying(6),
    sin numeric(9,0),
    government_id people.gid9,
    CONSTRAINT employee_sin_check CHECK ((sin >= (0)::numeric))
);


ALTER TABLE people.employee OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 17203)
-- Name: employee_role; Type: TABLE; Schema: people; Owner: postgres
--

CREATE TABLE people.employee_role (
    id integer NOT NULL,
    roles character varying(20) NOT NULL
);


ALTER TABLE people.employee_role OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17300)
-- Name: booking_records; Type: TABLE; Schema: records; Owner: postgres
--

CREATE TABLE records.booking_records (
    booking_id integer NOT NULL,
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    customer_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status records.booking_states
);


ALTER TABLE records.booking_records OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17305)
-- Name: renting_records; Type: TABLE; Schema: records; Owner: postgres
--

CREATE TABLE records.renting_records (
    booking_id integer NOT NULL,
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    customer_id integer NOT NULL,
    employee_id integer NOT NULL,
    start_date date,
    end_date date,
    payment_amount integer,
    status records.checking_states
);


ALTER TABLE records.renting_records OWNER TO postgres;

--
-- TOC entry 3548 (class 0 OID 17213)
-- Dependencies: 222
-- Data for Name: hotel; Type: TABLE DATA; Schema: locations; Owner: postgres
--

COPY locations.hotel (hotel_id, chain_id, manager_id, rating, number_rooms, name, street_number, street_name, city, province, postal_code) FROM stdin;
\.


--
-- TOC entry 3543 (class 0 OID 17165)
-- Dependencies: 217
-- Data for Name: hotel_chain; Type: TABLE DATA; Schema: locations; Owner: postgres
--

COPY locations.hotel_chain (hotel_chain_id, name, number_hotels, street_number, street_name, city, province, postal_code) FROM stdin;
\.


--
-- TOC entry 3544 (class 0 OID 17170)
-- Dependencies: 218
-- Data for Name: hotel_chain_email; Type: TABLE DATA; Schema: locations; Owner: postgres
--

COPY locations.hotel_chain_email (chain_id, chain_email) FROM stdin;
\.


--
-- TOC entry 3545 (class 0 OID 17180)
-- Dependencies: 219
-- Data for Name: hotel_chain_phone; Type: TABLE DATA; Schema: locations; Owner: postgres
--

COPY locations.hotel_chain_phone (chain_id, chain_phone) FROM stdin;
\.


--
-- TOC entry 3549 (class 0 OID 17232)
-- Dependencies: 223
-- Data for Name: hotel_email; Type: TABLE DATA; Schema: locations; Owner: postgres
--

COPY locations.hotel_email (id, email) FROM stdin;
\.


--
-- TOC entry 3550 (class 0 OID 17242)
-- Dependencies: 224
-- Data for Name: hotel_phone; Type: TABLE DATA; Schema: locations; Owner: postgres
--

COPY locations.hotel_phone (id, phone) FROM stdin;
\.


--
-- TOC entry 3551 (class 0 OID 17252)
-- Dependencies: 225
-- Data for Name: room; Type: TABLE DATA; Schema: locations; Owner: postgres
--

COPY locations.room (room_number, hotel_id, price, capacity, view_type, is_etendable) FROM stdin;
\.


--
-- TOC entry 3552 (class 0 OID 17274)
-- Dependencies: 226
-- Data for Name: room_amenities; Type: TABLE DATA; Schema: locations; Owner: postgres
--

COPY locations.room_amenities (room_number, hotel_id, amenity) FROM stdin;
\.


--
-- TOC entry 3553 (class 0 OID 17284)
-- Dependencies: 227
-- Data for Name: room_problems; Type: TABLE DATA; Schema: locations; Owner: postgres
--

COPY locations.room_problems (room_number, hotel_id, problem) FROM stdin;
\.


--
-- TOC entry 3554 (class 0 OID 17294)
-- Dependencies: 228
-- Data for Name: customer; Type: TABLE DATA; Schema: people; Owner: postgres
--

COPY people.customer (customer_id, first_name, middle_name, last_name, street_number, street_name, city, province, postal_code, registration_date, id_type, id_number) FROM stdin;
\.


--
-- TOC entry 3546 (class 0 OID 17190)
-- Dependencies: 220
-- Data for Name: employee; Type: TABLE DATA; Schema: people; Owner: postgres
--

COPY people.employee (employee_id, chain_id, hotel_id, first_name, middle_name, last_name, street_number, street_name, city, province, postal_code, sin, government_id) FROM stdin;
\.


--
-- TOC entry 3547 (class 0 OID 17203)
-- Dependencies: 221
-- Data for Name: employee_role; Type: TABLE DATA; Schema: people; Owner: postgres
--

COPY people.employee_role (id, roles) FROM stdin;
\.


--
-- TOC entry 3555 (class 0 OID 17300)
-- Dependencies: 229
-- Data for Name: booking_records; Type: TABLE DATA; Schema: records; Owner: postgres
--

COPY records.booking_records (booking_id, room_number, hotel_id, customer_id, start_date, end_date, status) FROM stdin;
\.


--
-- TOC entry 3556 (class 0 OID 17305)
-- Dependencies: 230
-- Data for Name: renting_records; Type: TABLE DATA; Schema: records; Owner: postgres
--

COPY records.renting_records (booking_id, room_number, hotel_id, customer_id, employee_id, start_date, end_date, payment_amount, status) FROM stdin;
\.


--
-- TOC entry 3360 (class 2606 OID 17174)
-- Name: hotel_chain_email hotel_chain_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_pkey PRIMARY KEY (chain_id, chain_email);


--
-- TOC entry 3362 (class 2606 OID 17184)
-- Name: hotel_chain_phone hotel_chain_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_pkey PRIMARY KEY (chain_id, chain_phone);


--
-- TOC entry 3358 (class 2606 OID 17169)
-- Name: hotel_chain hotel_chain_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel_chain
    ADD CONSTRAINT hotel_chain_pkey PRIMARY KEY (hotel_chain_id);


--
-- TOC entry 3374 (class 2606 OID 17236)
-- Name: hotel_email hotel_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_pkey PRIMARY KEY (id, email);


--
-- TOC entry 3370 (class 2606 OID 17221)
-- Name: hotel hotel_hotel_id_key; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_hotel_id_key UNIQUE (hotel_id);


--
-- TOC entry 3376 (class 2606 OID 17246)
-- Name: hotel_phone hotel_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_pkey PRIMARY KEY (id, phone);


--
-- TOC entry 3372 (class 2606 OID 17219)
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (hotel_id, chain_id);


--
-- TOC entry 3380 (class 2606 OID 17278)
-- Name: room_amenities room_amenities_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_pkey PRIMARY KEY (room_number, hotel_id, amenity);


--
-- TOC entry 3378 (class 2606 OID 17258)
-- Name: room room_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (room_number, hotel_id);


--
-- TOC entry 3382 (class 2606 OID 17288)
-- Name: room_problems room_problems_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_pkey PRIMARY KEY (room_number, hotel_id, problem);


--
-- TOC entry 3384 (class 2606 OID 17299)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: people; Owner: postgres
--

ALTER TABLE ONLY people.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 3364 (class 2606 OID 17195)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: people; Owner: postgres
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 3368 (class 2606 OID 17207)
-- Name: employee_role employee_role_pkey; Type: CONSTRAINT; Schema: people; Owner: postgres
--

ALTER TABLE ONLY people.employee_role
    ADD CONSTRAINT employee_role_pkey PRIMARY KEY (id, roles);


--
-- TOC entry 3366 (class 2606 OID 17197)
-- Name: employee employee_sin_key; Type: CONSTRAINT; Schema: people; Owner: postgres
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_sin_key UNIQUE (sin);


--
-- TOC entry 3386 (class 2606 OID 17304)
-- Name: booking_records booking_records_pkey; Type: CONSTRAINT; Schema: records; Owner: postgres
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_pkey PRIMARY KEY (booking_id);


--
-- TOC entry 3388 (class 2606 OID 17309)
-- Name: renting_records renting_records_pkey; Type: CONSTRAINT; Schema: records; Owner: postgres
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_pkey PRIMARY KEY (booking_id);


--
-- TOC entry 3389 (class 2606 OID 17175)
-- Name: hotel_chain_email hotel_chain_email_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3393 (class 2606 OID 17222)
-- Name: hotel hotel_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3390 (class 2606 OID 17185)
-- Name: hotel_chain_phone hotel_chain_phone_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3395 (class 2606 OID 17237)
-- Name: hotel_email hotel_email_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3394 (class 2606 OID 17227)
-- Name: hotel hotel_manager_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3396 (class 2606 OID 17247)
-- Name: hotel_phone hotel_phone_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3398 (class 2606 OID 17279)
-- Name: room_amenities room_amenities_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3397 (class 2606 OID 17259)
-- Name: room room_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3399 (class 2606 OID 17289)
-- Name: room_problems room_problems_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3391 (class 2606 OID 17198)
-- Name: employee employee_chain_id_fkey; Type: FK CONSTRAINT; Schema: people; Owner: postgres
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3392 (class 2606 OID 17208)
-- Name: employee_role employee_role_id_fkey; Type: FK CONSTRAINT; Schema: people; Owner: postgres
--

ALTER TABLE ONLY people.employee_role
    ADD CONSTRAINT employee_role_id_fkey FOREIGN KEY (id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


-- Completed on 2026-03-25 23:12:27 EDT

--
-- PostgreSQL database dump complete
--

\unrestrict Lt6rwiWGuq1So7GYfKNHkNVC2aWAFyQFSf80ZgfKVfLphHdJDSvPIwss1MI0ozY

