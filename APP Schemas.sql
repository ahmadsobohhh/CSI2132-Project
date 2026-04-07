--
-- PostgreSQL database dump
--

\restrict OEagMXS3tlk2gHYUneibELawM0jRUKERGoZxD7MfgtFhlmT4uO5OdGrhS4ydZCr

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

-- Started on 2026-04-07 13:50:23 EDT

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
-- TOC entry 5 (class 2615 OID 17946)
-- Name: locations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA locations;


--
-- TOC entry 6 (class 2615 OID 17947)
-- Name: people; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA people;


--
-- TOC entry 7 (class 2615 OID 17948)
-- Name: records; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA records;


--
-- TOC entry 883 (class 1247 OID 17950)
-- Name: view_type; Type: TYPE; Schema: locations; Owner: -
--

CREATE TYPE locations.view_type AS ENUM (
    'Sea',
    'Mountain'
);


--
-- TOC entry 886 (class 1247 OID 17956)
-- Name: gid; Type: TYPE; Schema: people; Owner: -
--

CREATE TYPE people.gid AS ENUM (
    'SSN',
    'SIN',
    'Driver'
);


--
-- TOC entry 889 (class 1247 OID 17964)
-- Name: gid9; Type: TYPE; Schema: people; Owner: -
--

CREATE TYPE people.gid9 AS ENUM (
    'SSN',
    'SIN'
);


--
-- TOC entry 892 (class 1247 OID 17970)
-- Name: booking_states; Type: TYPE; Schema: records; Owner: -
--

CREATE TYPE records.booking_states AS ENUM (
    'Active',
    'Transformed',
    'Cancelled'
);


--
-- TOC entry 895 (class 1247 OID 17978)
-- Name: checking_states; Type: TYPE; Schema: records; Owner: -
--

CREATE TYPE records.checking_states AS ENUM (
    'Checked-In',
    'Checked-Out'
);


--
-- TOC entry 247 (class 1255 OID 17983)
-- Name: addhotel(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.addhotel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		UPDATE locations.hotel_chain set number_hotels = number_hotels + 1 where hotel_chain_id = NEW.chain_id;
		return NEW;
	END;
$$;


--
-- TOC entry 248 (class 1255 OID 17984)
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
-- TOC entry 249 (class 1255 OID 17985)
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
-- TOC entry 250 (class 1255 OID 17986)
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
-- TOC entry 251 (class 1255 OID 17987)
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
-- TOC entry 252 (class 1255 OID 17988)
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
-- TOC entry 253 (class 1255 OID 17989)
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
-- TOC entry 254 (class 1255 OID 17990)
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
-- TOC entry 268 (class 1255 OID 17993)
-- Name: archiverentingrecord(); Type: FUNCTION; Schema: records; Owner: -
--

CREATE FUNCTION records.archiverentingrecord() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        source_renting_id integer;
        source_room_number integer;
        source_hotel_id integer;
        source_customer_id integer;
        source_employee_id integer;
        source_start_date date;
        source_end_date date;
        source_payment integer;
        source_status records.checking_states;
        customer_name_text character varying(60);
        employee_name_text character varying(60);
        hotel_name_text character varying(60);
    BEGIN
        IF TG_OP = 'DELETE' THEN
            source_renting_id := OLD.renting_id;
            source_room_number := OLD.room_number;
            source_hotel_id := OLD.hotel_id;
            source_customer_id := OLD.customer_id;
            source_employee_id := OLD.employee_id;
            source_start_date := OLD.start_date;
            source_end_date := OLD.end_date;
            source_payment := OLD.payment_amount;
            source_status := OLD.status;
        ELSE
            source_renting_id := NEW.renting_id;
            source_room_number := NEW.room_number;
            source_hotel_id := NEW.hotel_id;
            source_customer_id := NEW.customer_id;
            source_employee_id := NEW.employee_id;
            source_start_date := NEW.start_date;
            source_end_date := NEW.end_date;
            source_payment := NEW.payment_amount;
            source_status := NEW.status;
        END IF;

        SELECT COALESCE(CONCAT_WS(' ', c.first_name, c.middle_name, c.last_name), 'Unknown Customer')
        INTO customer_name_text
        FROM people.customer c
        WHERE c.customer_id = source_customer_id;

        SELECT COALESCE(CONCAT_WS(' ', e.first_name, e.middle_name, e.last_name), 'Unknown Employee')
        INTO employee_name_text
        FROM people.employee e
        WHERE e.employee_id = source_employee_id;

        SELECT COALESCE(h.name, 'Unknown Hotel')
        INTO hotel_name_text
        FROM locations.hotel h
        WHERE h.hotel_id = source_hotel_id;

        IF NOT EXISTS (
            SELECT 1
            FROM records.renting_archive ra
            WHERE ra.original_renting_id = source_renting_id
        ) THEN
            INSERT INTO records.renting_archive (
                original_renting_id,
                customer_name_snap,
                employee_name_snap,
                hotel_name_snap,
                room_number_snap,
                start_date_snap,
                end_date_snap,
                payment_amount_snap,
                final_status_snap
            )
            VALUES (
                source_renting_id,
                COALESCE(customer_name_text, 'Unknown Customer'),
                COALESCE(employee_name_text, 'Unknown Employee'),
                COALESCE(hotel_name_text, 'Unknown Hotel'),
                source_room_number,
                source_start_date,
                source_end_date,
                source_payment,
                source_status
            );
        END IF;

        IF TG_OP = 'DELETE' THEN
            RETURN OLD;
        END IF;

        RETURN NEW;
    END;
$$;


--
-- TOC entry 255 (class 1255 OID 17991)
-- Name: checkdoublebooking(); Type: FUNCTION; Schema: records; Owner: -
--

CREATE FUNCTION records.checkdoublebooking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
        if exists (
            Select 1
            from records.booking_records
            where room_number = New.room_number
              and hotel_id = NEW.hotel_id
              and status = 'Active'
              and start_date < NEW.end_date
              and end_date > New.start_date
        ) THEN
			return NULL;
		end if;
		return NEW;
	END;
$$;


--
-- TOC entry 256 (class 1255 OID 18250)
-- Name: checkdoublerenting(); Type: FUNCTION; Schema: records; Owner: -
--

CREATE FUNCTION records.checkdoublerenting() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		if exists (
            Select 1
            from records.renting_records
            where room_number = New.room_number
              and hotel_id = NEW.hotel_id
              and status = 'Checked-In'
              and start_date < NEW.end_date
              and end_date > New.start_date
        ) THEN
			return NULL;
		end if;
		return NEW;
	END;
$$;


--
-- TOC entry 269 (class 1255 OID 17992)
-- Name: transformrecord(); Type: FUNCTION; Schema: records; Owner: -
--

CREATE FUNCTION records.transformrecord() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	begin
		Insert into records.booking_records(room_number, hotel_id, start_date, end_date, status) 
		values (NEW.room_number, NEW.hotel_id, NEW.start_date, NEW.end_date, 'Transformed')
		on conflict (room_number, hotel_id)		
		do update set status = 'Transformed';
		return NEW;
	end;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 17994)
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
-- TOC entry 226 (class 1259 OID 18018)
-- Name: room; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.room (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    price integer,
    capacity integer,
    view_type locations.view_type,
    is_extendable boolean,
    CONSTRAINT room_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT room_price_check CHECK ((price > 0))
);


--
-- TOC entry 235 (class 1259 OID 18043)
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
-- TOC entry 243 (class 1259 OID 18233)
-- Name: available_rooms; Type: VIEW; Schema: locations; Owner: -
--

CREATE VIEW locations.available_rooms AS
 SELECT r.room_number,
    r.price,
    r.capacity,
    r.view_type,
    r.is_extendable,
    h.name,
    h.street_number,
    h.street_name,
    h.city,
    h.province
   FROM (locations.room r
     JOIN locations.hotel h ON ((r.hotel_id = h.hotel_id)))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM records.booking_records
          WHERE ((booking_records.room_number = r.room_number) AND (booking_records.hotel_id = r.hotel_id) AND (booking_records.start_date > now()) AND (booking_records.end_date < now()) AND (booking_records.status <> 'Cancelled'::records.booking_states)))));


--
-- TOC entry 245 (class 1259 OID 18242)
-- Name: city_available; Type: VIEW; Schema: locations; Owner: -
--

CREATE VIEW locations.city_available AS
 SELECT city,
    count(DISTINCT ROW(room_number, street_number, street_name)) AS count
   FROM locations.available_rooms
  GROUP BY city;


--
-- TOC entry 246 (class 1259 OID 18246)
-- Name: hotel_capacity; Type: VIEW; Schema: locations; Owner: -
--

CREATE VIEW locations.hotel_capacity AS
 SELECT h.name,
    sum(r.capacity) AS capacity
   FROM (locations.room r
     JOIN locations.hotel h ON ((r.hotel_id = h.hotel_id)))
  GROUP BY h.name;


--
-- TOC entry 218 (class 1259 OID 17999)
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
-- TOC entry 219 (class 1259 OID 18003)
-- Name: hotel_chain_email; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_chain_email (
    chain_id integer NOT NULL,
    chain_email character varying(20) NOT NULL
);


--
-- TOC entry 220 (class 1259 OID 18006)
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
-- TOC entry 221 (class 1259 OID 18007)
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
-- TOC entry 222 (class 1259 OID 18008)
-- Name: hotel_chain_phone; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_chain_phone (
    chain_id integer NOT NULL,
    chain_phone numeric(10,0) NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 18011)
-- Name: hotel_email; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_email (
    id integer NOT NULL,
    email character varying(20) NOT NULL
);


--
-- TOC entry 224 (class 1259 OID 18014)
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
-- TOC entry 225 (class 1259 OID 18015)
-- Name: hotel_phone; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_phone (
    id integer NOT NULL,
    phone numeric(10,0) NOT NULL
);


--
-- TOC entry 244 (class 1259 OID 18238)
-- Name: province_available; Type: VIEW; Schema: locations; Owner: -
--

CREATE VIEW locations.province_available AS
 SELECT province,
    count(DISTINCT ROW(room_number, street_number, street_name)) AS count
   FROM locations.available_rooms
  GROUP BY province;


--
-- TOC entry 227 (class 1259 OID 18023)
-- Name: room_amenities; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.room_amenities (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    amenity character varying(20) NOT NULL
);


--
-- TOC entry 228 (class 1259 OID 18026)
-- Name: room_problems; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.room_problems (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    problem character varying(20) NOT NULL
);


--
-- TOC entry 229 (class 1259 OID 18029)
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
-- TOC entry 230 (class 1259 OID 18030)
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
-- TOC entry 231 (class 1259 OID 18034)
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
-- TOC entry 232 (class 1259 OID 18035)
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
-- TOC entry 233 (class 1259 OID 18039)
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
-- TOC entry 234 (class 1259 OID 18040)
-- Name: employee_role; Type: TABLE; Schema: people; Owner: -
--

CREATE TABLE people.employee_role (
    id integer NOT NULL,
    roles character varying(20) NOT NULL
);


--
-- TOC entry 236 (class 1259 OID 18047)
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
-- TOC entry 238 (class 1259 OID 18051)
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
-- TOC entry 237 (class 1259 OID 18050)
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
-- TOC entry 241 (class 1259 OID 18057)
-- Name: renting_archive; Type: TABLE; Schema: records; Owner: -
--

CREATE TABLE records.renting_archive (
    archive_id integer NOT NULL,
    original_renting_id integer NOT NULL,
    customer_name_snap character varying(60) NOT NULL,
    employee_name_snap character varying(60) NOT NULL,
    hotel_name_snap character varying(60) NOT NULL,
    room_number_snap integer NOT NULL,
    start_date_snap date NOT NULL,
    end_date_snap date NOT NULL,
    payment_amount_snap integer,
    final_status_snap records.checking_states
);


--
-- TOC entry 242 (class 1259 OID 18060)
-- Name: renting_archive_archive_id_seq; Type: SEQUENCE; Schema: records; Owner: -
--

ALTER TABLE records.renting_archive ALTER COLUMN archive_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME records.renting_archive_archive_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 239 (class 1259 OID 18052)
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
-- TOC entry 240 (class 1259 OID 18056)
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
-- TOC entry 3623 (class 0 OID 17994)
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
-- TOC entry 3624 (class 0 OID 17999)
-- Dependencies: 218
-- Data for Name: hotel_chain; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain VALUES (3, 'Selkirk', 8, 68, 'Forest Dr', 'Barrie', 'ON', 'L4N0A0');
INSERT INTO locations.hotel_chain VALUES (2, 'Blackfoot', 8, 98, 'Valley St', 'Guelph', 'ON', 'N1G0A0');
INSERT INTO locations.hotel_chain VALUES (4, 'Fairmont', 8, 20, 'Poplar St', 'Victoria', 'BC', 'V8W0A0');
INSERT INTO locations.hotel_chain VALUES (1, 'Sandman', 8, 33, 'Ash Dr', 'Halifax', 'NS', 'B3H0A0');
INSERT INTO locations.hotel_chain VALUES (0, 'Paradox', 8, 86, 'Palm Rd', 'Saskatoon', 'SK', 'S7K0A0');


--
-- TOC entry 3625 (class 0 OID 18003)
-- Dependencies: 219
-- Data for Name: hotel_chain_email; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain_email VALUES (0, 'hotel$@Chain.com');
INSERT INTO locations.hotel_chain_email VALUES (1, 'first@Chain.com');


--
-- TOC entry 3628 (class 0 OID 18008)
-- Dependencies: 222
-- Data for Name: hotel_chain_phone; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain_phone VALUES (0, 1111111111);
INSERT INTO locations.hotel_chain_phone VALUES (1, 1111111112);


--
-- TOC entry 3629 (class 0 OID 18011)
-- Dependencies: 223
-- Data for Name: hotel_email; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_email VALUES (0, 'unique@hotels.com');
INSERT INTO locations.hotel_email VALUES (1, 'unique2@hotels.com');
INSERT INTO locations.hotel_email VALUES (2, 'chicken@hotels.com');
INSERT INTO locations.hotel_email VALUES (3, 'food@hotels.com');


--
-- TOC entry 3631 (class 0 OID 18015)
-- Dependencies: 225
-- Data for Name: hotel_phone; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_phone VALUES (0, 1111111111);
INSERT INTO locations.hotel_phone VALUES (1, 1345167232);
INSERT INTO locations.hotel_phone VALUES (2, 2345167232);
INSERT INTO locations.hotel_phone VALUES (3, 2345667232);


--
-- TOC entry 3632 (class 0 OID 18018)
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
-- TOC entry 3633 (class 0 OID 18023)
-- Dependencies: 227
-- Data for Name: room_amenities; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room_amenities VALUES (0, 0, '');
INSERT INTO locations.room_amenities VALUES (1, 0, 'Trees');
INSERT INTO locations.room_amenities VALUES (1, 0, 'Blankets');


--
-- TOC entry 3634 (class 0 OID 18026)
-- Dependencies: 228
-- Data for Name: room_problems; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room_problems VALUES (0, 0, 'Legs');
INSERT INTO locations.room_problems VALUES (0, 0, 'Eyes');
INSERT INTO locations.room_problems VALUES (0, 0, 'Chicken');
INSERT INTO locations.room_problems VALUES (1, 0, 'Chicken');
INSERT INTO locations.room_problems VALUES (2, 0, 'Chicken');


--
-- TOC entry 3636 (class 0 OID 18030)
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
-- TOC entry 3638 (class 0 OID 18035)
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
-- TOC entry 3640 (class 0 OID 18040)
-- Dependencies: 234
-- Data for Name: employee_role; Type: TABLE DATA; Schema: people; Owner: -
--

INSERT INTO people.employee_role VALUES (0, 'Manager');
INSERT INTO people.employee_role VALUES (1, 'Custodian');
INSERT INTO people.employee_role VALUES (2, 'The Manager');
INSERT INTO people.employee_role VALUES (3, 'The Boss');
INSERT INTO people.employee_role VALUES (2, 'Bob');


--
-- TOC entry 3642 (class 0 OID 18047)
-- Dependencies: 236
-- Data for Name: booking_archive; Type: TABLE DATA; Schema: records; Owner: -
--



--
-- TOC entry 3641 (class 0 OID 18043)
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
-- TOC entry 3647 (class 0 OID 18057)
-- Dependencies: 241
-- Data for Name: renting_archive; Type: TABLE DATA; Schema: records; Owner: -
--

INSERT INTO records.renting_archive VALUES (1, 9001, 'Archive Customer', 'Archive Employee', 'Archive Hotel', 101, '2025-11-01', '2025-11-06', 1450, 'Checked-Out');
INSERT INTO records.renting_archive VALUES (2, 0, 'The  Customer', 'Bob  Bobson', 'Testing', 0, '2026-03-31', '2027-03-31', 1000, 'Checked-Out');


--
-- TOC entry 3645 (class 0 OID 18052)
-- Dependencies: 239
-- Data for Name: renting_records; Type: TABLE DATA; Schema: records; Owner: -
--



--
-- TOC entry 3654 (class 0 OID 0)
-- Dependencies: 220
-- Name: hotel_chain_email_chain_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_chain_email_chain_id_seq', 1, false);


--
-- TOC entry 3655 (class 0 OID 0)
-- Dependencies: 221
-- Name: hotel_chain_hotel_chain_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_chain_hotel_chain_id_seq', 3, true);


--
-- TOC entry 3656 (class 0 OID 0)
-- Dependencies: 224
-- Name: hotel_hotel_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_hotel_id_seq', 4, true);


--
-- TOC entry 3657 (class 0 OID 0)
-- Dependencies: 229
-- Name: room_room_number_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.room_room_number_seq', 19, true);


--
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 231
-- Name: customer_customer_id_seq; Type: SEQUENCE SET; Schema: people; Owner: -
--

SELECT pg_catalog.setval('people.customer_customer_id_seq', 6, true);


--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 233
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: people; Owner: -
--

SELECT pg_catalog.setval('people.employee_employee_id_seq', 4, true);


--
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 238
-- Name: booking_archive_archive_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.booking_archive_archive_id_seq', 1, false);


--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 237
-- Name: booking_records_booking_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.booking_records_booking_id_seq', 1, false);


--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 242
-- Name: renting_archive_archive_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.renting_archive_archive_id_seq', 2, true);


--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 240
-- Name: renting_records_renting_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.renting_records_renting_id_seq', 1, false);


--
-- TOC entry 3414 (class 2606 OID 18062)
-- Name: hotel_chain_email hotel_chain_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_pkey PRIMARY KEY (chain_id, chain_email);


--
-- TOC entry 3416 (class 2606 OID 18064)
-- Name: hotel_chain_phone hotel_chain_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_pkey PRIMARY KEY (chain_id, chain_phone);


--
-- TOC entry 3412 (class 2606 OID 18066)
-- Name: hotel_chain hotel_chain_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain
    ADD CONSTRAINT hotel_chain_pkey PRIMARY KEY (hotel_chain_id);


--
-- TOC entry 3418 (class 2606 OID 18068)
-- Name: hotel_email hotel_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_pkey PRIMARY KEY (id, email);


--
-- TOC entry 3407 (class 2606 OID 18070)
-- Name: hotel hotel_hotel_id_key; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_hotel_id_key UNIQUE (hotel_id);


--
-- TOC entry 3420 (class 2606 OID 18072)
-- Name: hotel_phone hotel_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_pkey PRIMARY KEY (id, phone);


--
-- TOC entry 3409 (class 2606 OID 18074)
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (hotel_id, chain_id);


--
-- TOC entry 3425 (class 2606 OID 18076)
-- Name: room_amenities room_amenities_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_pkey PRIMARY KEY (room_number, hotel_id, amenity);


--
-- TOC entry 3423 (class 2606 OID 18078)
-- Name: room room_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (room_number, hotel_id);


--
-- TOC entry 3427 (class 2606 OID 18080)
-- Name: room_problems room_problems_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_pkey PRIMARY KEY (room_number, hotel_id, problem);


--
-- TOC entry 3429 (class 2606 OID 18082)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 3431 (class 2606 OID 18084)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 3435 (class 2606 OID 18086)
-- Name: employee_role employee_role_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee_role
    ADD CONSTRAINT employee_role_pkey PRIMARY KEY (id, roles);


--
-- TOC entry 3433 (class 2606 OID 18088)
-- Name: employee employee_sin_key; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_sin_key UNIQUE (sin);


--
-- TOC entry 3440 (class 2606 OID 18092)
-- Name: booking_archive booking_archive_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_archive
    ADD CONSTRAINT booking_archive_pkey PRIMARY KEY (archive_id);


--
-- TOC entry 3437 (class 2606 OID 18090)
-- Name: booking_records booking_records_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_pkey PRIMARY KEY (booking_id);


--
-- TOC entry 3444 (class 2606 OID 18098)
-- Name: renting_archive renting_archive_original_renting_id_key; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_archive
    ADD CONSTRAINT renting_archive_original_renting_id_key UNIQUE (original_renting_id);


--
-- TOC entry 3446 (class 2606 OID 18096)
-- Name: renting_archive renting_archive_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_archive
    ADD CONSTRAINT renting_archive_pkey PRIMARY KEY (archive_id);


--
-- TOC entry 3442 (class 2606 OID 18094)
-- Name: renting_records renting_records_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_pkey PRIMARY KEY (renting_id);


--
-- TOC entry 3410 (class 1259 OID 18191)
-- Name: idx_hotel_chain_city_rating; Type: INDEX; Schema: locations; Owner: -
--

CREATE INDEX idx_hotel_chain_city_rating ON locations.hotel USING btree (chain_id, city, rating);


--
-- TOC entry 3421 (class 1259 OID 18192)
-- Name: idx_room_hotel_capacity_price; Type: INDEX; Schema: locations; Owner: -
--

CREATE INDEX idx_room_hotel_capacity_price ON locations.room USING btree (hotel_id, capacity, price);


--
-- TOC entry 3438 (class 1259 OID 18193)
-- Name: idx_booking_active_overlap; Type: INDEX; Schema: records; Owner: -
--

CREATE INDEX idx_booking_active_overlap ON records.booking_records USING btree (hotel_id, room_number, start_date, end_date) WHERE (status = 'Active'::records.booking_states);


--
-- TOC entry 3463 (class 2620 OID 18099)
-- Name: hotel addHotel; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "addHotel" AFTER INSERT ON locations.hotel FOR EACH ROW EXECUTE FUNCTION locations.addhotel();


--
-- TOC entry 3469 (class 2620 OID 18100)
-- Name: room addRoom; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "addRoom" AFTER INSERT ON locations.room FOR EACH ROW EXECUTE FUNCTION locations.addroom();


--
-- TOC entry 3467 (class 2620 OID 18101)
-- Name: hotel_chain recalchotels; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER recalchotels BEFORE UPDATE ON locations.hotel_chain FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION locations.recalculatehotels();


--
-- TOC entry 3464 (class 2620 OID 18102)
-- Name: hotel recalcrooms; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER recalcrooms BEFORE UPDATE ON locations.hotel FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION locations.recalculaterooms();


--
-- TOC entry 3465 (class 2620 OID 18103)
-- Name: hotel removeHotel; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "removeHotel" BEFORE DELETE ON locations.hotel FOR EACH ROW EXECUTE FUNCTION locations.removehotel();


--
-- TOC entry 3470 (class 2620 OID 18104)
-- Name: room removeroom; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER removeroom BEFORE DELETE ON locations.room FOR EACH ROW EXECUTE FUNCTION locations.removeroom();


--
-- TOC entry 3466 (class 2620 OID 18105)
-- Name: hotel zeroRooms; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "zeroRooms" BEFORE INSERT ON locations.hotel FOR EACH ROW WHEN ((new.number_rooms <> 0)) EXECUTE FUNCTION locations.setnumberrooms();


--
-- TOC entry 3468 (class 2620 OID 18106)
-- Name: hotel_chain zerohotels; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER zerohotels BEFORE INSERT ON locations.hotel_chain FOR EACH ROW WHEN ((new.number_hotels <> 0)) EXECUTE FUNCTION locations.setnumberhotels();


--
-- TOC entry 3472 (class 2620 OID 18109)
-- Name: renting_records archiveRentingOnCheckout; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "archiveRentingOnCheckout" AFTER UPDATE OF status ON records.renting_records FOR EACH ROW WHEN (((new.status = 'Checked-Out'::records.checking_states) AND (old.status IS DISTINCT FROM new.status))) EXECUTE FUNCTION records.archiverentingrecord();


--
-- TOC entry 3473 (class 2620 OID 18110)
-- Name: renting_records archiveRentingOnDelete; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "archiveRentingOnDelete" BEFORE DELETE ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.archiverentingrecord();


--
-- TOC entry 3471 (class 2620 OID 18195)
-- Name: booking_records checkDoubleBooking; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "checkDoubleBooking" BEFORE INSERT ON records.booking_records FOR EACH ROW EXECUTE FUNCTION records.checkdoublebooking();


--
-- TOC entry 3474 (class 2620 OID 18251)
-- Name: renting_records checkDoubleRenting; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "checkDoubleRenting" BEFORE INSERT ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.checkdoublerenting();


--
-- TOC entry 3475 (class 2620 OID 18108)
-- Name: renting_records updateBookingStatus; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "updateBookingStatus" AFTER INSERT ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.transformrecord();


--
-- TOC entry 3449 (class 2606 OID 18111)
-- Name: hotel_chain_email hotel_chain_email_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3447 (class 2606 OID 18116)
-- Name: hotel hotel_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3450 (class 2606 OID 18121)
-- Name: hotel_chain_phone hotel_chain_phone_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3451 (class 2606 OID 18126)
-- Name: hotel_email hotel_email_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3448 (class 2606 OID 18131)
-- Name: hotel hotel_manager_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3452 (class 2606 OID 18136)
-- Name: hotel_phone hotel_phone_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3454 (class 2606 OID 18141)
-- Name: room_amenities room_amenities_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3453 (class 2606 OID 18146)
-- Name: room room_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3455 (class 2606 OID 18151)
-- Name: room_problems room_problems_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3456 (class 2606 OID 18156)
-- Name: employee employee_chain_id_fkey; Type: FK CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3457 (class 2606 OID 18161)
-- Name: employee_role employee_role_id_fkey; Type: FK CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee_role
    ADD CONSTRAINT employee_role_id_fkey FOREIGN KEY (id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3458 (class 2606 OID 18216)
-- Name: booking_records booking_records_customer_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES people.customer(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3459 (class 2606 OID 18221)
-- Name: booking_records booking_records_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3460 (class 2606 OID 18201)
-- Name: renting_records renting_records_customer_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES people.customer(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3461 (class 2606 OID 18206)
-- Name: renting_records renting_records_employee_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3462 (class 2606 OID 18211)
-- Name: renting_records renting_records_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


-- Completed on 2026-04-07 13:50:23 EDT

--
-- PostgreSQL database dump complete
--

\unrestrict OEagMXS3tlk2gHYUneibELawM0jRUKERGoZxD7MfgtFhlmT4uO5OdGrhS4ydZCr

