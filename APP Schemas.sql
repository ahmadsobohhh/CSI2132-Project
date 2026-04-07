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
-- TOC entry 885 (class 1247 OID 17950)
-- Name: view_type; Type: TYPE; Schema: locations; Owner: -
--

CREATE TYPE locations.view_type AS ENUM (
    'Sea',
    'Mountain'
);


--
-- TOC entry 888 (class 1247 OID 17956)
-- Name: gid; Type: TYPE; Schema: people; Owner: -
--

CREATE TYPE people.gid AS ENUM (
    'SSN',
    'SIN',
    'Driver'
);


--
-- TOC entry 891 (class 1247 OID 17964)
-- Name: gid9; Type: TYPE; Schema: people; Owner: -
--

CREATE TYPE people.gid9 AS ENUM (
    'SSN',
    'SIN'
);


--
-- TOC entry 894 (class 1247 OID 17970)
-- Name: booking_states; Type: TYPE; Schema: records; Owner: -
--

CREATE TYPE records.booking_states AS ENUM (
    'Active',
    'Transformed',
    'Cancelled'
);


--
-- TOC entry 897 (class 1247 OID 17978)
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
-- TOC entry 257 (class 1255 OID 18252)
-- Name: blockinsert(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.blockinsert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		if exists (select 1 from people.employee_role where roles = 'Manager' and id = new.manager_id) then
			return new;
		else
			return null;
		end if;
	END;
$$;


--
-- TOC entry 256 (class 1255 OID 18253)
-- Name: blockupdate(); Type: FUNCTION; Schema: locations; Owner: -
--

CREATE FUNCTION locations.blockupdate() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	BEGIN
		if exists (select 1 from people.employee_role where roles = 'Manager' and id = new.manager_id) then
			return new;
		else
			return old;
		end if;
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
-- TOC entry 270 (class 1255 OID 17993)
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
-- TOC entry 258 (class 1255 OID 18250)
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
-- TOC entry 271 (class 1255 OID 17992)
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
-- TOC entry 3658 (class 0 OID 0)
-- Dependencies: 220
-- Name: hotel_chain_email_chain_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_chain_email_chain_id_seq', 1, false);


--
-- TOC entry 3659 (class 0 OID 0)
-- Dependencies: 221
-- Name: hotel_chain_hotel_chain_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_chain_hotel_chain_id_seq', 3, true);


--
-- TOC entry 3660 (class 0 OID 0)
-- Dependencies: 224
-- Name: hotel_hotel_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_hotel_id_seq', 5, true);


--
-- TOC entry 3661 (class 0 OID 0)
-- Dependencies: 229
-- Name: room_room_number_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.room_room_number_seq', 19, true);


--
-- TOC entry 3662 (class 0 OID 0)
-- Dependencies: 231
-- Name: customer_customer_id_seq; Type: SEQUENCE SET; Schema: people; Owner: -
--

SELECT pg_catalog.setval('people.customer_customer_id_seq', 6, true);


--
-- TOC entry 3663 (class 0 OID 0)
-- Dependencies: 233
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: people; Owner: -
--

SELECT pg_catalog.setval('people.employee_employee_id_seq', 4, true);


--
-- TOC entry 3664 (class 0 OID 0)
-- Dependencies: 238
-- Name: booking_archive_archive_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.booking_archive_archive_id_seq', 1, false);


--
-- TOC entry 3665 (class 0 OID 0)
-- Dependencies: 237
-- Name: booking_records_booking_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.booking_records_booking_id_seq', 1, false);


--
-- TOC entry 3666 (class 0 OID 0)
-- Dependencies: 242
-- Name: renting_archive_archive_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.renting_archive_archive_id_seq', 2, true);


--
-- TOC entry 3667 (class 0 OID 0)
-- Dependencies: 240
-- Name: renting_records_renting_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.renting_records_renting_id_seq', 1, false);


--
-- TOC entry 3416 (class 2606 OID 18062)
-- Name: hotel_chain_email hotel_chain_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_pkey PRIMARY KEY (chain_id, chain_email);


--
-- TOC entry 3418 (class 2606 OID 18064)
-- Name: hotel_chain_phone hotel_chain_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_pkey PRIMARY KEY (chain_id, chain_phone);


--
-- TOC entry 3414 (class 2606 OID 18066)
-- Name: hotel_chain hotel_chain_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain
    ADD CONSTRAINT hotel_chain_pkey PRIMARY KEY (hotel_chain_id);


--
-- TOC entry 3420 (class 2606 OID 18068)
-- Name: hotel_email hotel_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_pkey PRIMARY KEY (id, email);


--
-- TOC entry 3409 (class 2606 OID 18070)
-- Name: hotel hotel_hotel_id_key; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_hotel_id_key UNIQUE (hotel_id);


--
-- TOC entry 3422 (class 2606 OID 18072)
-- Name: hotel_phone hotel_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_pkey PRIMARY KEY (id, phone);


--
-- TOC entry 3411 (class 2606 OID 18074)
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (hotel_id, chain_id);


--
-- TOC entry 3427 (class 2606 OID 18076)
-- Name: room_amenities room_amenities_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_pkey PRIMARY KEY (room_number, hotel_id, amenity);


--
-- TOC entry 3425 (class 2606 OID 18078)
-- Name: room room_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (room_number, hotel_id);


--
-- TOC entry 3429 (class 2606 OID 18080)
-- Name: room_problems room_problems_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_pkey PRIMARY KEY (room_number, hotel_id, problem);


--
-- TOC entry 3431 (class 2606 OID 18082)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 3433 (class 2606 OID 18084)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 3437 (class 2606 OID 18086)
-- Name: employee_role employee_role_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee_role
    ADD CONSTRAINT employee_role_pkey PRIMARY KEY (id, roles);


--
-- TOC entry 3435 (class 2606 OID 18088)
-- Name: employee employee_sin_key; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_sin_key UNIQUE (sin);


--
-- TOC entry 3442 (class 2606 OID 18092)
-- Name: booking_archive booking_archive_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_archive
    ADD CONSTRAINT booking_archive_pkey PRIMARY KEY (archive_id);


--
-- TOC entry 3439 (class 2606 OID 18090)
-- Name: booking_records booking_records_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_pkey PRIMARY KEY (booking_id);


--
-- TOC entry 3446 (class 2606 OID 18098)
-- Name: renting_archive renting_archive_original_renting_id_key; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_archive
    ADD CONSTRAINT renting_archive_original_renting_id_key UNIQUE (original_renting_id);


--
-- TOC entry 3448 (class 2606 OID 18096)
-- Name: renting_archive renting_archive_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_archive
    ADD CONSTRAINT renting_archive_pkey PRIMARY KEY (archive_id);


--
-- TOC entry 3444 (class 2606 OID 18094)
-- Name: renting_records renting_records_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_pkey PRIMARY KEY (renting_id);


--
-- TOC entry 3412 (class 1259 OID 18191)
-- Name: idx_hotel_chain_city_rating; Type: INDEX; Schema: locations; Owner: -
--

CREATE INDEX idx_hotel_chain_city_rating ON locations.hotel USING btree (chain_id, city, rating);


--
-- TOC entry 3423 (class 1259 OID 18192)
-- Name: idx_room_hotel_capacity_price; Type: INDEX; Schema: locations; Owner: -
--

CREATE INDEX idx_room_hotel_capacity_price ON locations.room USING btree (hotel_id, capacity, price);


--
-- TOC entry 3440 (class 1259 OID 18193)
-- Name: idx_booking_active_overlap; Type: INDEX; Schema: records; Owner: -
--

CREATE INDEX idx_booking_active_overlap ON records.booking_records USING btree (hotel_id, room_number, start_date, end_date) WHERE (status = 'Active'::records.booking_states);


--
-- TOC entry 3465 (class 2620 OID 18099)
-- Name: hotel addHotel; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "addHotel" AFTER INSERT ON locations.hotel FOR EACH ROW EXECUTE FUNCTION locations.addhotel();


--
-- TOC entry 3473 (class 2620 OID 18100)
-- Name: room addRoom; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "addRoom" AFTER INSERT ON locations.room FOR EACH ROW EXECUTE FUNCTION locations.addroom();


--
-- TOC entry 3466 (class 2620 OID 18255)
-- Name: hotel block_hotel_alter; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER block_hotel_alter BEFORE UPDATE ON locations.hotel FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION locations.blockupdate();


--
-- TOC entry 3467 (class 2620 OID 18254)
-- Name: hotel block_hotel_insert; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER block_hotel_insert BEFORE INSERT ON locations.hotel FOR EACH ROW EXECUTE FUNCTION locations.blockinsert();


--
-- TOC entry 3471 (class 2620 OID 18101)
-- Name: hotel_chain recalchotels; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER recalchotels BEFORE UPDATE ON locations.hotel_chain FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION locations.recalculatehotels();


--
-- TOC entry 3468 (class 2620 OID 18102)
-- Name: hotel recalcrooms; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER recalcrooms BEFORE UPDATE ON locations.hotel FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION locations.recalculaterooms();


--
-- TOC entry 3469 (class 2620 OID 18103)
-- Name: hotel removeHotel; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "removeHotel" BEFORE DELETE ON locations.hotel FOR EACH ROW EXECUTE FUNCTION locations.removehotel();


--
-- TOC entry 3474 (class 2620 OID 18104)
-- Name: room removeroom; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER removeroom BEFORE DELETE ON locations.room FOR EACH ROW EXECUTE FUNCTION locations.removeroom();


--
-- TOC entry 3470 (class 2620 OID 18105)
-- Name: hotel zeroRooms; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "zeroRooms" BEFORE INSERT ON locations.hotel FOR EACH ROW WHEN ((new.number_rooms <> 0)) EXECUTE FUNCTION locations.setnumberrooms();


--
-- TOC entry 3472 (class 2620 OID 18106)
-- Name: hotel_chain zerohotels; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER zerohotels BEFORE INSERT ON locations.hotel_chain FOR EACH ROW WHEN ((new.number_hotels <> 0)) EXECUTE FUNCTION locations.setnumberhotels();


--
-- TOC entry 3476 (class 2620 OID 18109)
-- Name: renting_records archiveRentingOnCheckout; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "archiveRentingOnCheckout" AFTER UPDATE OF status ON records.renting_records FOR EACH ROW WHEN (((new.status = 'Checked-Out'::records.checking_states) AND (old.status IS DISTINCT FROM new.status))) EXECUTE FUNCTION records.archiverentingrecord();


--
-- TOC entry 3477 (class 2620 OID 18110)
-- Name: renting_records archiveRentingOnDelete; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "archiveRentingOnDelete" BEFORE DELETE ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.archiverentingrecord();


--
-- TOC entry 3475 (class 2620 OID 18195)
-- Name: booking_records checkDoubleBooking; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "checkDoubleBooking" BEFORE INSERT ON records.booking_records FOR EACH ROW EXECUTE FUNCTION records.checkdoublebooking();


--
-- TOC entry 3478 (class 2620 OID 18251)
-- Name: renting_records checkDoubleRenting; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "checkDoubleRenting" BEFORE INSERT ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.checkdoublerenting();


--
-- TOC entry 3479 (class 2620 OID 18108)
-- Name: renting_records updateBookingStatus; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "updateBookingStatus" AFTER INSERT ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.transformrecord();


--
-- TOC entry 3451 (class 2606 OID 18111)
-- Name: hotel_chain_email hotel_chain_email_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3449 (class 2606 OID 18116)
-- Name: hotel hotel_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3452 (class 2606 OID 18121)
-- Name: hotel_chain_phone hotel_chain_phone_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3453 (class 2606 OID 18126)
-- Name: hotel_email hotel_email_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3450 (class 2606 OID 18131)
-- Name: hotel hotel_manager_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3454 (class 2606 OID 18136)
-- Name: hotel_phone hotel_phone_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3456 (class 2606 OID 18141)
-- Name: room_amenities room_amenities_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3455 (class 2606 OID 18146)
-- Name: room room_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3457 (class 2606 OID 18151)
-- Name: room_problems room_problems_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3458 (class 2606 OID 18156)
-- Name: employee employee_chain_id_fkey; Type: FK CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3459 (class 2606 OID 18161)
-- Name: employee_role employee_role_id_fkey; Type: FK CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee_role
    ADD CONSTRAINT employee_role_id_fkey FOREIGN KEY (id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3460 (class 2606 OID 18216)
-- Name: booking_records booking_records_customer_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES people.customer(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3461 (class 2606 OID 18221)
-- Name: booking_records booking_records_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3462 (class 2606 OID 18201)
-- Name: renting_records renting_records_customer_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES people.customer(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3463 (class 2606 OID 18206)
-- Name: renting_records renting_records_employee_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3464 (class 2606 OID 18211)
-- Name: renting_records renting_records_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


-- Completed on 2026-04-07 16:31:42 EDT

--
-- PostgreSQL database dump complete
--

\unrestrict jCdqD8OyWWSgaVQ7Iqm955cpCf0VGkCNn5snwMhuiN1rbsAw9HYlWQ7UkygwlxQ

