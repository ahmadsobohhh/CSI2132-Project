--
-- PostgreSQL database dump
--

\restrict xF9lEWcJYa1evf8zxZrv7Nxlor18B997Qi5G17krfoN8G5BIaSi9Hg81jarU3fD

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

-- Started on 2026-04-02 20:33:45 EDT

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
-- TOC entry 5 (class 2615 OID 17709)
-- Name: locations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA locations;


--
-- TOC entry 6 (class 2615 OID 17710)
-- Name: people; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA people;


--
-- TOC entry 7 (class 2615 OID 17711)
-- Name: records; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA records;


--
-- TOC entry 875 (class 1247 OID 17713)
-- Name: view_type; Type: TYPE; Schema: locations; Owner: -
--

CREATE TYPE locations.view_type AS ENUM (
    'Sea',
    'Mountain'
);


--
-- TOC entry 878 (class 1247 OID 17718)
-- Name: gid; Type: TYPE; Schema: people; Owner: -
--

CREATE TYPE people.gid AS ENUM (
    'SSN',
    'SIN',
    'Driver'
);


--
-- TOC entry 881 (class 1247 OID 17726)
-- Name: gid9; Type: TYPE; Schema: people; Owner: -
--

CREATE TYPE people.gid9 AS ENUM (
    'SSN',
    'SIN'
);


--
-- TOC entry 884 (class 1247 OID 17732)
-- Name: booking_states; Type: TYPE; Schema: records; Owner: -
--

CREATE TYPE records.booking_states AS ENUM (
    'Active',
    'Transformed',
    'Cancelled'
);


--
-- TOC entry 887 (class 1247 OID 17740)
-- Name: checking_states; Type: TYPE; Schema: records; Owner: -
--

CREATE TYPE records.checking_states AS ENUM (
    'Checked-In',
    'Checked-Out'
);


--
-- TOC entry 261 (class 1255 OID 17745)
-- Name: addhotel(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.addhotel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		Update people.employee set hotel_id = NEW.hotel_id where employee_id = NEW.manager_id;
		UPDATE locations.hotel_chain set number_hotels = number_hotels + 1 where hotel_chain_id = NEW.chain_id;
		return NEW;
	END;
$$;


--
-- TOC entry 241 (class 1255 OID 17746)
-- Name: addroom(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.addroom() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE locations.Hotel set number_rooms = number_rooms + 1 where hotel_id = NEW.hotel_id;
		return NEW;
	END;
$$;


--
-- TOC entry 242 (class 1255 OID 17747)
-- Name: recalculatehotels(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.recalculatehotels() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		NEW.number_hotels = (select count(*) from locations.hotel where chain_id = NEW.hotel_chain_id);
		return NEW;
	END;
$$;


--
-- TOC entry 243 (class 1255 OID 17748)
-- Name: recalculaterooms(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.recalculaterooms() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		NEW.number_rooms = (select count(*) from locations.room where hotel_id = NEW.hotel_id);
		return NEW;
	END;
$$;


--
-- TOC entry 244 (class 1255 OID 17749)
-- Name: removehotel(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.removehotel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE locations.hotel_chain set number_hotels = number_hotels - 1 where hotel_chain_id = OLD.chain_id;
		return OLD;
	END;
$$;


--
-- TOC entry 245 (class 1255 OID 17750)
-- Name: removeroom(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.removeroom() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE locations.Hotel set number_rooms = number_rooms - 1 where hotel_id = OLD.hotel_id;
		return OLD;
	END;
$$;


--
-- TOC entry 246 (class 1255 OID 17751)
-- Name: setnumberhotels(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.setnumberhotels() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		NEW.number_hotels = 0;
		return NEW;
	END;
$$;


--
-- TOC entry 247 (class 1255 OID 17752)
-- Name: setnumberrooms(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.setnumberrooms() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		NEW.number_rooms = 0;
		return NEW;
	END;
$$;


--
-- TOC entry 252 (class 1255 OID 17753)
-- Name: checkdoublebooking(); Type: FUNCTION; Schema: records; Owner: -
--

CREATE FUNCTION records.checkdoublebooking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		if exists (Select 1 from records.booking_records where room_number = New.room_number and hotel_id = NEW.hotel_id and start_date < NEW.end_date and end_date > New.start_date) THEN
			return NULL;
		end if;
		return NEW;
	END;
$$;


--
-- TOC entry 253 (class 1255 OID 17754)
-- Name: transformrecord(); Type: FUNCTION; Schema: records; Owner: -
--

CREATE FUNCTION records.transformrecord() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	begin
		update records.booking_records set status = 'Transformed' where room_number = NEW.room_number and hotel_id = NEW.hotel_id and start_date = NEW.start_date;
		return NEW;
	end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 17755)
-- Name: hotel; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel (
    hotel_id integer NOT NULL,
    chain_id integer NOT NULL,
    manager_id integer NOT NULL,
    rating integer,
    number_rooms integer DEFAULT 0,
    name character varying(20),
    street_number integer,
    street_name character varying(20),
    city character varying(20),
    province character varying(20),
    postal_code character varying(6),
    CONSTRAINT hotel_rating_check CHECK (((rating >= 0) AND (rating <= 10)))
);


--
-- TOC entry 218 (class 1259 OID 17760)
-- Name: hotel_chain; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_chain (
    hotel_chain_id integer NOT NULL,
    name character varying(20),
    number_hotels integer DEFAULT 0,
    street_number integer,
    street_name character varying(20),
    city character varying(20),
    province character varying(20),
    postal_code character varying(6)
);


--
-- TOC entry 219 (class 1259 OID 17764)
-- Name: hotel_chain_email; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_chain_email (
    chain_id integer NOT NULL,
    chain_email character varying(20) NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 17767)
-- Name: hotel_chain_email_chain_id_seq; Type: SEQUENCE; Schema: locations; Owner: -
--

ALTER TABLE locations.hotel_chain_email ALTER COLUMN chain_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME locations.hotel_chain_email_chain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 221 (class 1259 OID 17768)
-- Name: hotel_chain_hotel_chain_id_seq; Type: SEQUENCE; Schema: locations; Owner: -
--

ALTER TABLE locations.hotel_chain ALTER COLUMN hotel_chain_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME locations.hotel_chain_hotel_chain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 17769)
-- Name: hotel_chain_phone; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_chain_phone (
    chain_id integer NOT NULL,
    chain_phone numeric(10,0) NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 17772)
-- Name: hotel_email; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_email (
    id integer NOT NULL,
    email character varying(20) NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 17775)
-- Name: hotel_hotel_id_seq; Type: SEQUENCE; Schema: locations; Owner: -
--

ALTER TABLE locations.hotel ALTER COLUMN hotel_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME locations.hotel_hotel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 225 (class 1259 OID 17776)
-- Name: hotel_phone; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_phone (
    id integer NOT NULL,
    phone numeric(10,0) NOT NULL
);


--
-- TOC entry 226 (class 1259 OID 17779)
-- Name: room; Type: TABLE; Schema: locations; Owner: -
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


--
-- TOC entry 227 (class 1259 OID 17784)
-- Name: room_amenities; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.room_amenities (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    amenity character varying(20) NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 17787)
-- Name: room_problems; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.room_problems (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    problem character varying(20) NOT NULL
);


--
-- TOC entry 229 (class 1259 OID 17790)
-- Name: room_room_number_seq; Type: SEQUENCE; Schema: locations; Owner: -
--

ALTER TABLE locations.room ALTER COLUMN room_number ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME locations.room_room_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 230 (class 1259 OID 17791)
-- Name: customer; Type: TABLE; Schema: people; Owner: -
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


--
-- TOC entry 231 (class 1259 OID 17795)
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: people; Owner: -
--

ALTER TABLE people.customer ALTER COLUMN customer_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME people.customer_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 232 (class 1259 OID 17796)
-- Name: employee; Type: TABLE; Schema: people; Owner: -
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


--
-- TOC entry 233 (class 1259 OID 17800)
-- Name: employee_employee_id_seq; Type: SEQUENCE; Schema: people; Owner: -
--

ALTER TABLE people.employee ALTER COLUMN employee_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME people.employee_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 234 (class 1259 OID 17801)
-- Name: employee_role; Type: TABLE; Schema: people; Owner: -
--

CREATE TABLE people.employee_role (
    id integer NOT NULL,
    roles character varying(20) NOT NULL
);


--
-- TOC entry 236 (class 1259 OID 17808)
-- Name: booking_archive; Type: TABLE; Schema: records; Owner: -
--

CREATE TABLE records.booking_archive (
    archive_id integer NOT NULL,
    original_booking_id integer NOT NULL,
    customer_name_snap character varying(60) NOT NULL,
    hotel_name_snap character varying(60) NOT NULL,
    room_number_snap integer NOT NULL,
    start_date_snap date NOT NULL,
    end_date_snap date NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 17812)
-- Name: booking_archive_archive_id_seq; Type: SEQUENCE; Schema: records; Owner: -
--

ALTER TABLE records.booking_archive ALTER COLUMN archive_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME records.booking_archive_archive_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 235 (class 1259 OID 17804)
-- Name: booking_records; Type: TABLE; Schema: records; Owner: -
--

CREATE TABLE records.booking_records (
    booking_id integer NOT NULL,
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    customer_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status records.booking_states,
    CONSTRAINT datecheck CHECK ((end_date > start_date))
);


--
-- TOC entry 237 (class 1259 OID 17811)
-- Name: booking_records_booking_id_seq; Type: SEQUENCE; Schema: records; Owner: -
--

ALTER TABLE records.booking_records ALTER COLUMN booking_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME records.booking_records_booking_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 239 (class 1259 OID 17813)
-- Name: renting_records; Type: TABLE; Schema: records; Owner: -
--

CREATE TABLE records.renting_records (
    renting_id integer NOT NULL,
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    customer_id integer NOT NULL,
    employee_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    payment_amount integer,
    status records.checking_states,
    CONSTRAINT datecheck CHECK ((end_date > start_date))
);


--
-- TOC entry 240 (class 1259 OID 17817)
-- Name: renting_records_renting_id_seq; Type: SEQUENCE; Schema: records; Owner: -
--

ALTER TABLE records.renting_records ALTER COLUMN renting_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME records.renting_records_renting_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3586 (class 0 OID 17755)
-- Dependencies: 217
-- Data for Name: hotel; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel VALUES (1, 0, 1, 10, 5, 'The Slumber', 124, 'Alphabet St.', 'Test City', 'Atlantis', 'A1AA1A');
INSERT INTO locations.hotel VALUES (4, 1, 4, 8, 0, 'The Retconning', 55, 'Dirt Rd.', 'Middle Of Nowhere', 'Ontario', 'L1PC2C');
INSERT INTO locations.hotel VALUES (3, 1, 3, 7, 0, 'The Reckoning', 54, 'Dirt Rd.', 'Middle Of Nowhere', 'Ontario', 'L1PC2C');
INSERT INTO locations.hotel VALUES (2, 0, 2, 7, 5, 'The Wakening', 12, 'Last St.', 'First City', 'Ontario', 'J1NC2C');
INSERT INTO locations.hotel VALUES (21, 2, 20, 7, 0, 'Oswego', 551, 'Sutherland Ave', 'Kelowna', 'BC', 'V1Y9P4');
INSERT INTO locations.hotel VALUES (22, 2, 21, 8, 0, 'Empress', 21, 'Government St', 'Victoria', 'BC', 'V8W1W5');
INSERT INTO locations.hotel VALUES (23, 2, 22, 3, 0, 'Grand Pacific', 463, 'Belleville St', 'Victoria', 'BC', 'V8V1X3');
INSERT INTO locations.hotel VALUES (24, 2, 23, 5, 0, 'Resort', 21, 'Crescent Rd', 'St. Andrews', 'NB', 'E5B1B5');
INSERT INTO locations.hotel VALUES (25, 2, 24, 6, 0, 'Sunset', 11, 'Sunset Dr', 'St. Andrews', 'NB', 'E5B2M1');
INSERT INTO locations.hotel VALUES (26, 2, 25, 1, 0, 'Lake Louise', 311, 'Tunnel Dr', 'Lake Louise', 'AB', 'T0L1E0');
INSERT INTO locations.hotel VALUES (27, 2, 26, 4, 0, 'Mount Royal', 91, 'Rue Catherine', 'Montréal', 'QC', 'H3B1M5');
INSERT INTO locations.hotel VALUES (28, 3, 27, 8, 0, 'Sheraton', 12, 'Queen St W', 'Toronto', 'ON', 'M5H2M9');
INSERT INTO locations.hotel VALUES (29, 3, 28, 7, 0, 'St. Regis', 25, 'Bay St', 'Toronto', 'ON', 'M5H4G3');
INSERT INTO locations.hotel VALUES (30, 3, 29, 7, 0, 'Chelsea', 3, 'Ripley Ave', 'Toronto', 'ON', 'M5V2P2');
INSERT INTO locations.hotel VALUES (31, 3, 30, 5, 0, 'Delta Toronto', 75, 'Simcoe St', 'Toronto', 'ON', 'M5J3A6');
INSERT INTO locations.hotel VALUES (32, 3, 31, 5, 0, 'Frontenac', 1, 'Rue Carrières', 'Québec City', 'QC', 'G1R4P5');
INSERT INTO locations.hotel VALUES (33, 3, 32, 3, 0, 'Palace Royal', 44, 'Rue Grande', 'Québec City', 'QC', 'G1R2J6');
INSERT INTO locations.hotel VALUES (34, 3, 33, 8, 0, 'Auberge des Arts', 28, 'Rue Saint-Jean', 'Québec City', 'QC', 'G1R1P5');
INSERT INTO locations.hotel VALUES (35, 3, 34, 6, 0, 'Vancouver Suites', 32, 'Burrard St', 'Vancouver', 'BC', 'V6Z1X4');
INSERT INTO locations.hotel VALUES (36, 4, 35, 6, 0, 'Inn at the Forks', 75, 'Forks Rd', 'Winnipeg', 'MB', 'R3C4T6');
INSERT INTO locations.hotel VALUES (37, 4, 36, 5, 0, 'Fort Garry', 221, 'Broadway St', 'Winnipeg', 'MB', 'R3C0M6');
INSERT INTO locations.hotel VALUES (38, 4, 37, 9, 0, 'Selkirk', 33, 'Princess St', 'Winnipeg', 'MB', 'R3B1K2');
INSERT INTO locations.hotel VALUES (39, 4, 38, 3, 0, 'Blackfoot', 94, '0 Ave SE', 'Calgary', 'AB', 'T2G0S6');
INSERT INTO locations.hotel VALUES (40, 4, 39, 7, 0, 'Sandman Edmonton', 251, 'Olympia Blvd NW', 'Edmonton', 'AB', 'T5T4J5');
INSERT INTO locations.hotel VALUES (8, 0, 7, 6, 5, 'Metropolitan', 145, 'Howe St', 'Vancouver', 'BC', 'V6C2Y9');
INSERT INTO locations.hotel VALUES (15, 1, 14, 5, 5, 'Petit Mtl', 188, 'Rue Paul O', 'Montréal', 'QC', 'H2Y1Z8');
INSERT INTO locations.hotel VALUES (11, 1, 10, 5, 6, 'Ritz-Carlton', 1128, 'Sherbrooke St W', 'Montréal', 'QC', 'H3G1H6');
INSERT INTO locations.hotel VALUES (17, 4, 16, 3, 4, 'Moose', 145, 'Banff Ave', 'Banff', 'AB', 'T1L1B8');
INSERT INTO locations.hotel VALUES (12, 1, 11, 7, 5, 'William Gray', 421, 'Rue Vincent', 'Montréal', 'QC', 'H2Y3A6');
INSERT INTO locations.hotel VALUES (19, 4, 18, 2, 4, 'Arts', 139, '1 St SW', 'Calgary', 'AB', 'T2P0G8');
INSERT INTO locations.hotel VALUES (9, 0, 8, 2, 6, 'Sutton Place', 845, 'Burrard St', 'Vancouver', 'BC', 'V6Z2K6');
INSERT INTO locations.hotel VALUES (16, 1, 15, 6, 4, 'Banff', 425, 'Springs Dr', 'Banff', 'AB', 'T1L1J4');
INSERT INTO locations.hotel VALUES (14, 1, 13, 3, 6, 'Birks Mtl', 147, 'Rue James', 'Montréal', 'QC', 'H2Y1N1');
INSERT INTO locations.hotel VALUES (20, 2, 19, 6, 5, 'Bed & Breakfast', 512, 'Main St', 'Kelowna', 'BC', 'V1Y6M9');
INSERT INTO locations.hotel VALUES (7, 0, 6, 9, 6, 'Paradox', 1239, 'W Georgia St', 'Vancouver', 'BC', 'V6E4A2');
INSERT INTO locations.hotel VALUES (18, 4, 17, 4, 5, 'Delta', 229, '4 Ave SW', 'Calgary', 'AB', 'T2P0H7');
INSERT INTO locations.hotel VALUES (10, 0, 9, 4, 6, 'Fairmont Queen', 430, 'Rue Gauchetière', 'Montréal', 'QC', 'H5A1J5');
INSERT INTO locations.hotel VALUES (13, 1, 12, 8, 6, 'Place d’Armes', 65, 'Rue Jacques', 'Montréal', 'QC', 'H2Y1K9');
INSERT INTO locations.hotel VALUES (6, 0, 5, 7, 7, 'Fairmont', 201, 'W Georgia St', 'Vancouver', 'BC', 'V6C2W6');
INSERT INTO locations.hotel VALUES (0, 0, 0, 0, 10, 'Testing', 0, '', '', '', '');


--
-- TOC entry 3587 (class 0 OID 17760)
-- Dependencies: 218
-- Data for Name: hotel_chain; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain VALUES (3, 'Only Name', 8, NULL, 'Last St.', NULL, NULL, NULL);
INSERT INTO locations.hotel_chain VALUES (2, 'Test Chain 3', 8, 122, 'Alphabet St.', 'Test City', 'Atlantis', 'A1AA1A');
INSERT INTO locations.hotel_chain VALUES (4, 'No Name', 8, 14, 'Last St.', 'First City', 'ON', 'J1NC2C');
INSERT INTO locations.hotel_chain VALUES (1, 'Test Chain 2', 8, 123, 'Alphabet St.', 'Test city', 'Atlantis', 'A1AA1A');
INSERT INTO locations.hotel_chain VALUES (0, 'Test Chain', 8, 123, 'Alphabet St.', 'Test city', 'Atlantis', 'A1AA1A');


--
-- TOC entry 3588 (class 0 OID 17764)
-- Dependencies: 219
-- Data for Name: hotel_chain_email; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain_email VALUES (0, 'hotel$@Chain.com');
INSERT INTO locations.hotel_chain_email VALUES (1, 'first@Chain.com');


--
-- TOC entry 3591 (class 0 OID 17769)
-- Dependencies: 222
-- Data for Name: hotel_chain_phone; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain_phone VALUES (0, 1111111111);
INSERT INTO locations.hotel_chain_phone VALUES (1, 1111111112);


--
-- TOC entry 3592 (class 0 OID 17772)
-- Dependencies: 223
-- Data for Name: hotel_email; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_email VALUES (0, 'unique@hotels.com');
INSERT INTO locations.hotel_email VALUES (1, 'unique2@hotels.com');
INSERT INTO locations.hotel_email VALUES (2, 'chicken@hotels.com');
INSERT INTO locations.hotel_email VALUES (3, 'food@hotels.com');


--
-- TOC entry 3594 (class 0 OID 17776)
-- Dependencies: 225
-- Data for Name: hotel_phone; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_phone VALUES (0, 1111111111);
INSERT INTO locations.hotel_phone VALUES (1, 1345167232);
INSERT INTO locations.hotel_phone VALUES (2, 2345167232);
INSERT INTO locations.hotel_phone VALUES (3, 2345667232);


--
-- TOC entry 3595 (class 0 OID 17779)
-- Dependencies: 226
-- Data for Name: room; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room VALUES (1, 6, 120, 2, 'Sea', true);
INSERT INTO locations.room VALUES (2, 7, 150, 3, 'Mountain', false);
INSERT INTO locations.room VALUES (3, 8, 200, 4, 'Sea', true);
INSERT INTO locations.room VALUES (4, 9, 180, 2, 'Mountain', false);
INSERT INTO locations.room VALUES (0, 0, 2, 1, 'Sea', false);
INSERT INTO locations.room VALUES (1, 0, 2, 1, 'Mountain', false);
INSERT INTO locations.room VALUES (2, 0, 2, 1, 'Mountain', false);
INSERT INTO locations.room VALUES (10, 1, 2000000, 40000, 'Mountain', false);
INSERT INTO locations.room VALUES (11, 1, 2000, 3, 'Mountain', false);
INSERT INTO locations.room VALUES (12, 1, 6000, 2, 'Mountain', false);
INSERT INTO locations.room VALUES (13, 1, 3000, 2, 'Sea', false);
INSERT INTO locations.room VALUES (14, 1, 2000, 1, 'Sea', false);
INSERT INTO locations.room VALUES (15, 2, 2200, 2, 'Sea', false);
INSERT INTO locations.room VALUES (16, 2, 2200, 2, 'Sea', false);
INSERT INTO locations.room VALUES (17, 2, 2200, 2, 'Sea', false);
INSERT INTO locations.room VALUES (18, 2, 2300, 2, 'Sea', true);
INSERT INTO locations.room VALUES (19, 2, 2200, 2, 'Mountain', true);
INSERT INTO locations.room VALUES (5, 0, 2, 1, 'Sea', true);
INSERT INTO locations.room VALUES (7, 0, 2, 1, 'Sea', true);
INSERT INTO locations.room VALUES (9, 0, 20000, 4, 'Mountain', true);
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


--
-- TOC entry 3596 (class 0 OID 17784)
-- Dependencies: 227
-- Data for Name: room_amenities; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room_amenities VALUES (0, 0, '');
INSERT INTO locations.room_amenities VALUES (1, 0, 'Trees');
INSERT INTO locations.room_amenities VALUES (1, 0, 'Blankets');


--
-- TOC entry 3597 (class 0 OID 17787)
-- Dependencies: 228
-- Data for Name: room_problems; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room_problems VALUES (0, 0, 'Legs');
INSERT INTO locations.room_problems VALUES (0, 0, 'Eyes');
INSERT INTO locations.room_problems VALUES (0, 0, 'Chicken');
INSERT INTO locations.room_problems VALUES (1, 0, 'Chicken');
INSERT INTO locations.room_problems VALUES (2, 0, 'Chicken');


--
-- TOC entry 3599 (class 0 OID 17791)
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
-- TOC entry 3601 (class 0 OID 17796)
-- Dependencies: 232
-- Data for Name: employee; Type: TABLE DATA; Schema: people; Owner: -
--

INSERT INTO people.employee VALUES (0, 0, 0, 'Bob', '', 'Bobson', 123, 'Alphabet St.', 'Test City', 'Atlantis', 'A1AA1A', 1, 'SSN');
INSERT INTO people.employee VALUES (1, 0, 1, 'Bob 2', ':', 'The Second Coming', 123, 'Alphabet St.', 'Test City', 'Atlantis', 'A1AA1A', 2, 'SSN');
INSERT INTO people.employee VALUES (2, 0, 2, 'Inigo', NULL, 'Montonya', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO people.employee VALUES (3, 1, 3, 'Person of Interest', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1738, 'SIN');
INSERT INTO people.employee VALUES (4, 1, 4, '2nd Person', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 999999999, 'SSN');
INSERT INTO people.employee VALUES (5, 2, 6, 'John', 'A', 'Smith', 123, 'Maple St', 'Toronto', 'ON', 'M1A1A1', 123456789, 'SIN');
INSERT INTO people.employee VALUES (6, 3, 7, 'Emma', 'B', 'Johnson', 45, 'Oak Ave', 'Ottawa', 'ON', 'K1A0B1', 234567890, 'SSN');
INSERT INTO people.employee VALUES (7, 4, 8, 'Liam', 'C', 'Williams', 78, 'Pine Rd', 'Montreal', 'QC', 'H1A2B2', 345678901, 'SIN');
INSERT INTO people.employee VALUES (8, 2, 9, 'Olivia', 'D', 'Brown', 89, 'Cedar Ln', 'Calgary', 'AB', 'T1X1A1', 456789012, 'SSN');
INSERT INTO people.employee VALUES (9, 3, 10, 'Noah', 'E', 'Jones', 12, 'Birch St', 'Vancouver', 'BC', 'V5K0A1', 567890123, 'SIN');
INSERT INTO people.employee VALUES (10, 4, 11, 'Ava', 'F', 'Garcia', 56, 'Elm St', 'Winnipeg', 'MB', 'R2C0A1', 678901234, 'SSN');
INSERT INTO people.employee VALUES (11, 2, 12, 'William', 'G', 'Miller', 34, 'Ash Dr', 'Halifax', 'NS', 'B3H0A1', 789012345, 'SIN');
INSERT INTO people.employee VALUES (12, 3, 13, 'Sophia', 'H', 'Davis', 67, 'Spruce Ct', 'Edmonton', 'AB', 'T5A0A1', 890123456, 'SSN');
INSERT INTO people.employee VALUES (13, 4, 14, 'James', 'I', 'Rodriguez', 90, 'Willow Way', 'Regina', 'SK', 'S4P0A1', 901234567, 'SIN');
INSERT INTO people.employee VALUES (14, 2, 15, 'Isabella', 'J', 'Martinez', 21, 'Poplar St', 'Victoria', 'BC', 'V8W0A1', 112233445, 'SSN');
INSERT INTO people.employee VALUES (15, 3, 16, 'Benjamin', 'K', 'Hernandez', 43, 'Chestnut Blvd', 'Quebec City', 'QC', 'G1A0A2', 223344556, 'SIN');
INSERT INTO people.employee VALUES (16, 4, 17, 'Mia', 'L', 'Lopez', 65, 'Fir St', 'St. John''s', 'NL', 'A1A0A1', 334455667, 'SSN');
INSERT INTO people.employee VALUES (17, 2, 18, 'Lucas', 'M', 'Gonzalez', 87, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A1', 445566778, 'SIN');
INSERT INTO people.employee VALUES (18, 3, 19, 'Charlotte', 'N', 'Wilson', 19, 'River St', 'Hamilton', 'ON', 'L8P0A1', 556677889, 'SSN');
INSERT INTO people.employee VALUES (19, 4, 20, 'Henry', 'O', 'Anderson', 29, 'Lakeview Ave', 'London', 'ON', 'N6A0A1', 667788990, 'SIN');
INSERT INTO people.employee VALUES (20, 2, 21, 'Amelia', 'P', 'Thomas', 39, 'Hill Rd', 'Kitchener', 'ON', 'N2A0A1', 778899001, 'SSN');
INSERT INTO people.employee VALUES (21, 3, 22, 'Alexander', 'Q', 'Taylor', 49, 'Sunset Blvd', 'Windsor', 'ON', 'N9A0A1', 889900112, 'SIN');
INSERT INTO people.employee VALUES (22, 4, 23, 'Harper', 'R', 'Moore', 59, 'Park St', 'Kelowna', 'BC', 'V1Y0A1', 990011223, 'SSN');
INSERT INTO people.employee VALUES (23, 2, 24, 'Daniel', 'S', 'Jackson', 69, 'Forest Dr', 'Barrie', 'ON', 'L4N0A1', 101112131, 'SIN');
INSERT INTO people.employee VALUES (24, 3, 25, 'Evelyn', 'T', 'Martin', 79, 'Garden Ave', 'Sudbury', 'ON', 'P3A0A1', 212223242, 'SSN');
INSERT INTO people.employee VALUES (25, 4, 26, 'Matthew', 'U', 'Lee', 89, 'Highland Rd', 'Kingston', 'ON', 'K7L0A1', 323334353, 'SIN');
INSERT INTO people.employee VALUES (26, 2, 27, 'Abigail', 'V', 'Perez', 99, 'Valley St', 'Guelph', 'ON', 'N1G0A1', 434445464, 'SSN');
INSERT INTO people.employee VALUES (27, 3, 28, 'Joseph', 'W', 'Thompson', 109, 'Meadow Ln', 'Sherbrooke', 'QC', 'J1H0A1', 545556575, 'SIN');
INSERT INTO people.employee VALUES (28, 4, 29, 'Emily', 'X', 'White', 119, 'Creek Rd', 'Trois-Rivieres', 'QC', 'G9A0A1', 656667686, 'SSN');
INSERT INTO people.employee VALUES (29, 2, 30, 'David', 'Y', 'Harris', 129, 'Bridge St', 'Moncton', 'NB', 'E1C0A1', 767778797, 'SIN');
INSERT INTO people.employee VALUES (30, 3, 31, 'Ella', 'Z', 'Sanchez', 139, 'Harbour Rd', 'Fredericton', 'NB', 'E3B0A1', 878889808, 'SSN');
INSERT INTO people.employee VALUES (31, 4, 32, 'Michael', 'A', 'Clark', 149, 'Ocean Ave', 'Charlottetown', 'PE', 'C1A0A1', 989990919, 'SIN');
INSERT INTO people.employee VALUES (32, 2, 33, 'Avery', 'B', 'Ramirez', 159, 'Bay St', 'Yellowknife', 'NT', 'X1A0A1', 111222333, 'SSN');
INSERT INTO people.employee VALUES (33, 3, 34, 'Ethan', 'C', 'Lewis', 169, 'North Rd', 'Whitehorse', 'YT', 'Y1A0A1', 222333444, 'SIN');
INSERT INTO people.employee VALUES (34, 4, 35, 'Sofia', 'D', 'Robinson', 179, 'South St', 'Iqaluit', 'NU', 'X0A0A1', 333444555, 'SSN');
INSERT INTO people.employee VALUES (35, 2, 36, 'Logan', 'E', 'Walker', 189, 'East Ave', 'Thunder Bay', 'ON', 'P7A0A1', 444555666, 'SIN');
INSERT INTO people.employee VALUES (36, 3, 37, 'Aria', 'F', 'Young', 199, 'West Blvd', 'Peterborough', 'ON', 'K9J0A1', 555666777, 'SSN');
INSERT INTO people.employee VALUES (37, 4, 38, 'Jacob', 'G', 'Allen', 209, 'King St', 'Brantford', 'ON', 'N3T0A1', 666777888, 'SIN');
INSERT INTO people.employee VALUES (38, 2, 39, 'Scarlett', 'H', 'King', 219, 'Queen St', 'Sarnia', 'ON', 'N7T0A1', 777888999, 'SSN');
INSERT INTO people.employee VALUES (39, 3, 40, 'Mason', 'I', 'Wright', 229, 'Prince Rd', 'Niagara Falls', 'ON', 'L2G0A1', 888999000, 'SIN');


--
-- TOC entry 3603 (class 0 OID 17801)
-- Dependencies: 234
-- Data for Name: employee_role; Type: TABLE DATA; Schema: people; Owner: -
--

INSERT INTO people.employee_role VALUES (0, 'Manager');
INSERT INTO people.employee_role VALUES (1, 'Custodian');
INSERT INTO people.employee_role VALUES (2, 'The Manager');
INSERT INTO people.employee_role VALUES (3, 'The Boss');
INSERT INTO people.employee_role VALUES (2, 'Bob');


--
-- TOC entry 3605 (class 0 OID 17808)
-- Dependencies: 236
-- Data for Name: booking_archive; Type: TABLE DATA; Schema: records; Owner: -
--



--
-- TOC entry 3604 (class 0 OID 17804)
-- Dependencies: 235
-- Data for Name: booking_records; Type: TABLE DATA; Schema: records; Owner: -
--

INSERT INTO records.booking_records VALUES (1, 1, 0, 1, '2026-03-31', '2026-04-01', 'Active');
INSERT INTO records.booking_records VALUES (2, 2, 0, 2, '2026-03-31', '2026-04-01', 'Active');
INSERT INTO records.booking_records VALUES (3, 10, 1, 4, '2026-03-31', '2026-04-05', 'Active');
INSERT INTO records.booking_records VALUES (4, 11, 1, 5, '2024-04-05', '2026-04-05', 'Cancelled');
INSERT INTO records.booking_records VALUES (5, 11, 1, 5, '2026-04-01', '2026-04-05', 'Active');
INSERT INTO records.booking_records VALUES (0, 0, 0, 0, '2026-03-31', '2027-03-31', 'Transformed');


--
-- TOC entry 3608 (class 0 OID 17813)
-- Dependencies: 239
-- Data for Name: renting_records; Type: TABLE DATA; Schema: records; Owner: -
--

INSERT INTO records.renting_records VALUES (0, 0, 0, 0, 0, '2026-03-31', '2027-03-31', 1000, 'Checked-In');


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 220
-- Name: hotel_chain_email_chain_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_chain_email_chain_id_seq', 1, false);


--
-- TOC entry 3616 (class 0 OID 0)
-- Dependencies: 221
-- Name: hotel_chain_hotel_chain_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_chain_hotel_chain_id_seq', 3, true);


--
-- TOC entry 3617 (class 0 OID 0)
-- Dependencies: 224
-- Name: hotel_hotel_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_hotel_id_seq', 4, true);


--
-- TOC entry 3618 (class 0 OID 0)
-- Dependencies: 229
-- Name: room_room_number_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.room_room_number_seq', 19, true);


--
-- TOC entry 3619 (class 0 OID 0)
-- Dependencies: 231
-- Name: customer_customer_id_seq; Type: SEQUENCE SET; Schema: people; Owner: -
--

SELECT pg_catalog.setval('people.customer_customer_id_seq', 6, true);


--
-- TOC entry 3620 (class 0 OID 0)
-- Dependencies: 233
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: people; Owner: -
--

SELECT pg_catalog.setval('people.employee_employee_id_seq', 4, true);


--
-- TOC entry 3621 (class 0 OID 0)
-- Dependencies: 238
-- Name: booking_archive_archive_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.booking_archive_archive_id_seq', 1, false);


--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 237
-- Name: booking_records_booking_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.booking_records_booking_id_seq', 5, true);


--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 240
-- Name: renting_records_renting_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.renting_records_renting_id_seq', 1, false);


--
-- TOC entry 3390 (class 2606 OID 17819)
-- Name: hotel_chain_email hotel_chain_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_pkey PRIMARY KEY (chain_id, chain_email);


--
-- TOC entry 3392 (class 2606 OID 17821)
-- Name: hotel_chain_phone hotel_chain_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_pkey PRIMARY KEY (chain_id, chain_phone);


--
-- TOC entry 3388 (class 2606 OID 17823)
-- Name: hotel_chain hotel_chain_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain
    ADD CONSTRAINT hotel_chain_pkey PRIMARY KEY (hotel_chain_id);


--
-- TOC entry 3394 (class 2606 OID 17825)
-- Name: hotel_email hotel_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_pkey PRIMARY KEY (id, email);


--
-- TOC entry 3384 (class 2606 OID 17827)
-- Name: hotel hotel_hotel_id_key; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_hotel_id_key UNIQUE (hotel_id);


--
-- TOC entry 3396 (class 2606 OID 17829)
-- Name: hotel_phone hotel_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_pkey PRIMARY KEY (id, phone);


--
-- TOC entry 3386 (class 2606 OID 17831)
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (hotel_id, chain_id);


--
-- TOC entry 3400 (class 2606 OID 17833)
-- Name: room_amenities room_amenities_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_pkey PRIMARY KEY (room_number, hotel_id, amenity);


--
-- TOC entry 3398 (class 2606 OID 17835)
-- Name: room room_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (room_number, hotel_id);


--
-- TOC entry 3402 (class 2606 OID 17837)
-- Name: room_problems room_problems_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_pkey PRIMARY KEY (room_number, hotel_id, problem);


--
-- TOC entry 3404 (class 2606 OID 17839)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 3406 (class 2606 OID 17841)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 3410 (class 2606 OID 17843)
-- Name: employee_role employee_role_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee_role
    ADD CONSTRAINT employee_role_pkey PRIMARY KEY (id, roles);


--
-- TOC entry 3408 (class 2606 OID 17845)
-- Name: employee employee_sin_key; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_sin_key UNIQUE (sin);


--
-- TOC entry 3414 (class 2606 OID 17849)
-- Name: booking_archive booking_archive_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_archive
    ADD CONSTRAINT booking_archive_pkey PRIMARY KEY (archive_id);


--
-- TOC entry 3412 (class 2606 OID 17847)
-- Name: booking_records booking_records_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_pkey PRIMARY KEY (booking_id);


--
-- TOC entry 3416 (class 2606 OID 17851)
-- Name: renting_records renting_records_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_pkey PRIMARY KEY (renting_id);


--
-- TOC entry 3433 (class 2620 OID 17852)
-- Name: hotel addHotel; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "addHotel" AFTER INSERT ON locations.hotel FOR EACH ROW EXECUTE FUNCTION locations.addhotel();


--
-- TOC entry 3439 (class 2620 OID 17853)
-- Name: room addRoom; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "addRoom" AFTER INSERT ON locations.room FOR EACH ROW EXECUTE FUNCTION locations.addroom();


--
-- TOC entry 3437 (class 2620 OID 17854)
-- Name: hotel_chain recalchotels; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER recalchotels BEFORE UPDATE ON locations.hotel_chain FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION locations.recalculatehotels();


--
-- TOC entry 3434 (class 2620 OID 17855)
-- Name: hotel recalcrooms; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER recalcrooms BEFORE UPDATE ON locations.hotel FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION locations.recalculaterooms();


--
-- TOC entry 3435 (class 2620 OID 17856)
-- Name: hotel removeHotel; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "removeHotel" BEFORE DELETE ON locations.hotel FOR EACH ROW EXECUTE FUNCTION locations.removehotel();


--
-- TOC entry 3440 (class 2620 OID 17857)
-- Name: room removeroom; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER removeroom BEFORE DELETE ON locations.room FOR EACH ROW EXECUTE FUNCTION locations.removeroom();


--
-- TOC entry 3436 (class 2620 OID 17858)
-- Name: hotel zeroRooms; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "zeroRooms" BEFORE INSERT ON locations.hotel FOR EACH ROW WHEN ((new.number_rooms <> 0)) EXECUTE FUNCTION locations.setnumberrooms();


--
-- TOC entry 3438 (class 2620 OID 17859)
-- Name: hotel_chain zerohotels; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER zerohotels BEFORE INSERT ON locations.hotel_chain FOR EACH ROW WHEN ((new.number_hotels <> 0)) EXECUTE FUNCTION locations.setnumberhotels();


--
-- TOC entry 3441 (class 2620 OID 17860)
-- Name: renting_records checkDoubleBooking; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "checkDoubleBooking" BEFORE INSERT ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.checkdoublebooking();


--
-- TOC entry 3442 (class 2620 OID 17861)
-- Name: renting_records updateBookingStatus; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "updateBookingStatus" AFTER INSERT ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.transformrecord();


--
-- TOC entry 3419 (class 2606 OID 17862)
-- Name: hotel_chain_email hotel_chain_email_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3417 (class 2606 OID 17867)
-- Name: hotel hotel_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3420 (class 2606 OID 17872)
-- Name: hotel_chain_phone hotel_chain_phone_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3421 (class 2606 OID 17877)
-- Name: hotel_email hotel_email_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3418 (class 2606 OID 17882)
-- Name: hotel hotel_manager_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3422 (class 2606 OID 17887)
-- Name: hotel_phone hotel_phone_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3424 (class 2606 OID 17892)
-- Name: room_amenities room_amenities_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3423 (class 2606 OID 17897)
-- Name: room room_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3425 (class 2606 OID 17902)
-- Name: room_problems room_problems_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3426 (class 2606 OID 17907)
-- Name: employee employee_chain_id_fkey; Type: FK CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3427 (class 2606 OID 17912)
-- Name: employee_role employee_role_id_fkey; Type: FK CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee_role
    ADD CONSTRAINT employee_role_id_fkey FOREIGN KEY (id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3428 (class 2606 OID 17928)
-- Name: booking_records booking_records_customer_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES people.customer(customer_id);


--
-- TOC entry 3429 (class 2606 OID 17918)
-- Name: booking_records booking_records_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id);


--
-- TOC entry 3430 (class 2606 OID 17933)
-- Name: renting_records renting_records_customer_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES people.customer(customer_id);


--
-- TOC entry 3431 (class 2606 OID 17938)
-- Name: renting_records renting_records_employee_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES people.employee(employee_id);


--
-- TOC entry 3432 (class 2606 OID 17923)
-- Name: renting_records renting_records_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id);


-- Completed on 2026-04-02 20:33:45 EDT

--
-- PostgreSQL database dump complete
--

\unrestrict xF9lEWcJYa1evf8zxZrv7Nxlor18B997Qi5G17krfoN8G5BIaSi9Hg81jarU3fD

