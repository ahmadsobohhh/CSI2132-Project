--
-- PostgreSQL database dump
--

\restrict eP0Bv59O8nPFjSrehKIMOKir5KOLamybZmJvbQwHzHRJRTjp0Ieja2RqIanGIV6

-- Dumped from database version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.13 (Ubuntu 16.13-0ubuntu0.24.04.1)

-- Started on 2026-03-31 21:55:15 EDT

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
-- TOC entry 7 (class 2615 OID 17477)
-- Name: locations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA locations;


--
-- TOC entry 5 (class 2615 OID 17478)
-- Name: people; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA people;


--
-- TOC entry 6 (class 2615 OID 17479)
-- Name: records; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA records;


--
-- TOC entry 873 (class 1247 OID 17481)
-- Name: view_type; Type: TYPE; Schema: locations; Owner: -
--

CREATE TYPE locations.view_type AS ENUM (
    'Sea',
    'Mountain'
);


--
-- TOC entry 876 (class 1247 OID 17486)
-- Name: gid; Type: TYPE; Schema: people; Owner: -
--

CREATE TYPE people.gid AS ENUM (
    'SSN',
    'SIN',
    'Driver'
);


--
-- TOC entry 879 (class 1247 OID 17494)
-- Name: gid9; Type: TYPE; Schema: people; Owner: -
--

CREATE TYPE people.gid9 AS ENUM (
    'SSN',
    'SIN'
);


--
-- TOC entry 882 (class 1247 OID 17500)
-- Name: booking_states; Type: TYPE; Schema: records; Owner: -
--

CREATE TYPE records.booking_states AS ENUM (
    'Active',
    'Transformed',
    'Cancelled'
);


--
-- TOC entry 885 (class 1247 OID 17508)
-- Name: checking_states; Type: TYPE; Schema: records; Owner: -
--

CREATE TYPE records.checking_states AS ENUM (
    'Checked-In',
    'Checked-Out'
);


--
-- TOC entry 244 (class 1255 OID 17674)
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
-- TOC entry 241 (class 1255 OID 17671)
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
-- TOC entry 243 (class 1255 OID 17686)
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
-- TOC entry 242 (class 1255 OID 17685)
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
-- TOC entry 245 (class 1255 OID 17673)
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
-- TOC entry 246 (class 1255 OID 17672)
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
-- TOC entry 239 (class 1255 OID 17664)
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
-- TOC entry 240 (class 1255 OID 17665)
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
-- TOC entry 248 (class 1255 OID 17707)
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
-- TOC entry 247 (class 1255 OID 17649)
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


--
-- Archive renting records on checkout or delete so historical data is preserved.
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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 217 (class 1259 OID 17513)
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
-- TOC entry 218 (class 1259 OID 17518)
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
-- TOC entry 219 (class 1259 OID 17521)
-- Name: hotel_chain_email; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_chain_email (
    chain_id integer NOT NULL,
    chain_email character varying(20) NOT NULL
);


--
-- TOC entry 233 (class 1259 OID 17653)
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
-- TOC entry 232 (class 1259 OID 17652)
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
-- TOC entry 220 (class 1259 OID 17524)
-- Name: hotel_chain_phone; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_chain_phone (
    chain_id integer NOT NULL,
    chain_phone numeric(10,0) NOT NULL
);


--
-- TOC entry 221 (class 1259 OID 17527)
-- Name: hotel_email; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_email (
    id integer NOT NULL,
    email character varying(20) NOT NULL
);


--
-- TOC entry 231 (class 1259 OID 17651)
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
-- TOC entry 222 (class 1259 OID 17530)
-- Name: hotel_phone; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.hotel_phone (
    id integer NOT NULL,
    phone numeric(10,0) NOT NULL
);


--
-- TOC entry 223 (class 1259 OID 17533)
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
-- TOC entry 224 (class 1259 OID 17538)
-- Name: room_amenities; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.room_amenities (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    amenity character varying(20) NOT NULL
);


--
-- TOC entry 225 (class 1259 OID 17541)
-- Name: room_problems; Type: TABLE; Schema: locations; Owner: -
--

CREATE TABLE locations.room_problems (
    room_number integer NOT NULL,
    hotel_id integer NOT NULL,
    problem character varying(20) NOT NULL
);


--
-- TOC entry 234 (class 1259 OID 17654)
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
-- TOC entry 226 (class 1259 OID 17544)
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
-- TOC entry 235 (class 1259 OID 17655)
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
-- TOC entry 227 (class 1259 OID 17548)
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
-- TOC entry 236 (class 1259 OID 17656)
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
-- TOC entry 228 (class 1259 OID 17552)
-- Name: employee_role; Type: TABLE; Schema: people; Owner: -
--

CREATE TABLE people.employee_role (
    id integer NOT NULL,
    roles character varying(20) NOT NULL
);


--
-- TOC entry 229 (class 1259 OID 17555)
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
-- TOC entry 231 (class 1259 OID 17559)
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
-- TOC entry 238 (class 1259 OID 17658)
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
-- TOC entry 239 (class 1259 OID 17659)
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
-- TOC entry 230 (class 1259 OID 17558)
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
-- TOC entry 237 (class 1259 OID 17657)
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
-- TOC entry 2411 (class 1259 OID 19991)
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
-- TOC entry 2412 (class 1259 OID 19992)
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
-- TOC entry 3586 (class 0 OID 17755)
-- Dependencies: 217
-- Data for Name: hotel; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel VALUES (3, 1, 4, 7, 0, 'The Reckoning', 54, 'Dirt Rd.', 'Middle Of Nowhere', 'Ontario', 'L1PC2C');
INSERT INTO locations.hotel VALUES (0, 0, 0, 0, 10, 'Testing', 0, '', '', '', '');
INSERT INTO locations.hotel VALUES (1, 0, 1, 10, 5, 'The Slumber', 124, 'Alphabet St.', 'Test City', 'Atlantis', 'A1AA1A');
INSERT INTO locations.hotel VALUES (2, 0, 0, 7, 5, 'The Wakening', 12, 'Last St.', 'First City', 'Ontario', 'J1NC2C');
INSERT INTO locations.hotel VALUES (4, 1, 4, 8, 0, 'The Retconning', 55, 'Dirt Rd.', 'Middle Of Nowhere', 'Ontario', 'L1PC2C');


--
-- TOC entry 3578 (class 0 OID 17518)
-- Dependencies: 218
-- Data for Name: hotel_chain; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain VALUES (2, 'Test Chain 3', 0, 123, 'Alphabet St.', 'Test city', 'Atlantis', 'A1AA1A');
INSERT INTO locations.hotel_chain VALUES (719, NULL, 0, NULL, NULL, NULL, NULL, NULL);
INSERT INTO locations.hotel_chain VALUES (0, 'Test Chain', 3, 123, 'Alphabet St.', 'Test city', 'Atlantis', 'A1AA1A');
INSERT INTO locations.hotel_chain VALUES (1, 'Test Chain 2', 2, 123, 'Alphabet St.', 'Test city', 'Atlantis', 'A1AA1A');
INSERT INTO locations.hotel_chain VALUES (3, 'Only Name', 0, NULL, 'Last St.', NULL, NULL, NULL);


--
-- TOC entry 3579 (class 0 OID 17521)
-- Dependencies: 219
-- Data for Name: hotel_chain_email; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain_email VALUES (0, 'hotel$@Chain.com');
INSERT INTO locations.hotel_chain_email VALUES (1, 'first@Chain.com');
INSERT INTO locations.hotel_chain_email VALUES (2, 'second@Chain.com');


--
-- TOC entry 3580 (class 0 OID 17524)
-- Dependencies: 220
-- Data for Name: hotel_chain_phone; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_chain_phone VALUES (0, 1111111111);
INSERT INTO locations.hotel_chain_phone VALUES (1, 1111111112);
INSERT INTO locations.hotel_chain_phone VALUES (2, 9999999999);


--
-- TOC entry 3581 (class 0 OID 17527)
-- Dependencies: 221
-- Data for Name: hotel_email; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_email VALUES (0, 'unique@hotels.com');
INSERT INTO locations.hotel_email VALUES (1, 'unique2@hotels.com');
INSERT INTO locations.hotel_email VALUES (2, 'chicken@hotels.com');
INSERT INTO locations.hotel_email VALUES (3, 'food@hotels.com');


--
-- TOC entry 3582 (class 0 OID 17530)
-- Dependencies: 222
-- Data for Name: hotel_phone; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.hotel_phone VALUES (0, 1111111111);
INSERT INTO locations.hotel_phone VALUES (1, 1345167232);
INSERT INTO locations.hotel_phone VALUES (2, 2345167232);
INSERT INTO locations.hotel_phone VALUES (3, 2345667232);


--
-- TOC entry 3583 (class 0 OID 17533)
-- Dependencies: 223
-- Data for Name: room; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room VALUES (3, 0, 2, 1, 'Sea', false);
INSERT INTO locations.room VALUES (4, 0, 2, 1, 'Sea', false);
INSERT INTO locations.room VALUES (6, 0, 2, 1, 'Sea', false);
INSERT INTO locations.room VALUES (8, 0, 2, 1, 'Sea', false);
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


--
-- TOC entry 3584 (class 0 OID 17538)
-- Dependencies: 224
-- Data for Name: room_amenities; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room_amenities VALUES (0, 0, '');
INSERT INTO locations.room_amenities VALUES (1, 0, 'Trees');
INSERT INTO locations.room_amenities VALUES (1, 0, 'Blankets');
INSERT INTO locations.room_amenities VALUES (3, 0, 'Blankets');


--
-- TOC entry 3585 (class 0 OID 17541)
-- Dependencies: 225
-- Data for Name: room_problems; Type: TABLE DATA; Schema: locations; Owner: -
--

INSERT INTO locations.room_problems VALUES (0, 0, 'Legs');
INSERT INTO locations.room_problems VALUES (0, 0, 'Eyes');
INSERT INTO locations.room_problems VALUES (0, 0, 'Chicken');
INSERT INTO locations.room_problems VALUES (1, 0, 'Chicken');
INSERT INTO locations.room_problems VALUES (2, 0, 'Chicken');
INSERT INTO locations.room_problems VALUES (3, 0, 'Chicken');


--
-- TOC entry 3586 (class 0 OID 17544)
-- Dependencies: 226
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
-- TOC entry 3587 (class 0 OID 17548)
-- Dependencies: 227
-- Data for Name: employee; Type: TABLE DATA; Schema: people; Owner: -
--

INSERT INTO people.employee VALUES (0, 0, 0, 'Bob', '', 'Bobson', 123, 'Alphabet St.', 'Test City', 'Atlantis', 'A1AA1A', 1, 'SSN');
INSERT INTO people.employee VALUES (1, 0, NULL, 'Bob 2', ':', 'The Second Coming', 123, 'Alphabet St.', 'Test City', 'Atlantis', 'A1AA1A', 2, 'SSN');
INSERT INTO people.employee VALUES (2, NULL, NULL, 'Inigo', NULL, 'Montonya', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO people.employee VALUES (3, 1, NULL, 'Person of Interest', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1738, 'SIN');
INSERT INTO people.employee VALUES (4, 1, 1, '2nd Person', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 999999999, 'SSN');


--
-- TOC entry 3588 (class 0 OID 17552)
-- Dependencies: 228
-- Data for Name: employee_role; Type: TABLE DATA; Schema: people; Owner: -
--

INSERT INTO people.employee_role VALUES (0, 'Manager');
INSERT INTO people.employee_role VALUES (1, 'Custodian');
INSERT INTO people.employee_role VALUES (2, 'The Manager');
INSERT INTO people.employee_role VALUES (3, 'The Boss');
INSERT INTO people.employee_role VALUES (2, 'Bob');


--
-- TOC entry 3589 (class 0 OID 17555)
-- Dependencies: 229
-- Data for Name: booking_records; Type: TABLE DATA; Schema: records; Owner: -
--

INSERT INTO records.booking_records VALUES (1, 1, 0, 1, '2026-03-31', '2026-04-01', 'Active');
INSERT INTO records.booking_records VALUES (2, 2, 0, 2, '2026-03-31', '2026-04-01', 'Active');
INSERT INTO records.booking_records VALUES (3, 10, 1, 4, '2026-03-31', '2026-04-05', 'Active');
INSERT INTO records.booking_records VALUES (4, 11, 1, 5, '2024-04-05', '2026-04-05', 'Cancelled');
INSERT INTO records.booking_records VALUES (5, 11, 1, 5, '2026-04-01', '2026-04-05', 'Active');
INSERT INTO records.booking_records VALUES (0, 0, 0, 0, '2026-03-31', '2027-03-31', 'Transformed');


--
-- TOC entry 3590 (class 0 OID 17558)
-- Dependencies: 230
-- Data for Name: renting_records; Type: TABLE DATA; Schema: records; Owner: -
--

INSERT INTO records.renting_records VALUES (0, 0, 0, 0, 0, '2026-03-31', '2027-03-31', 1000, 'Checked-In');


--
-- TOC entry 3609 (class 0 OID 19991)
-- Dependencies: 2411
-- Data for Name: renting_archive; Type: TABLE DATA; Schema: records; Owner: -
--

INSERT INTO records.renting_archive VALUES (1, 9001, 'Archive Customer', 'Archive Employee', 'Archive Hotel', 101, '2025-11-01', '2025-11-06', 1450, 'Checked-Out');


--
-- TOC entry 3615 (class 0 OID 0)
-- Dependencies: 220
-- Name: hotel_chain_email_chain_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_chain_email_chain_id_seq', 1, false);


--
-- TOC entry 3605 (class 0 OID 0)
-- Dependencies: 232
-- Name: hotel_chain_hotel_chain_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_chain_hotel_chain_id_seq', 3, true);


--
-- TOC entry 3606 (class 0 OID 0)
-- Dependencies: 231
-- Name: hotel_hotel_id_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.hotel_hotel_id_seq', 4, true);


--
-- TOC entry 3607 (class 0 OID 0)
-- Dependencies: 234
-- Name: room_room_number_seq; Type: SEQUENCE SET; Schema: locations; Owner: -
--

SELECT pg_catalog.setval('locations.room_room_number_seq', 19, true);


--
-- TOC entry 3608 (class 0 OID 0)
-- Dependencies: 235
-- Name: customer_customer_id_seq; Type: SEQUENCE SET; Schema: people; Owner: -
--

SELECT pg_catalog.setval('people.customer_customer_id_seq', 6, true);


--
-- TOC entry 3609 (class 0 OID 0)
-- Dependencies: 236
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: people; Owner: -
--

SELECT pg_catalog.setval('people.employee_employee_id_seq', 4, true);


--
-- TOC entry 3610 (class 0 OID 0)
-- Dependencies: 238
-- Name: booking_archive_archive_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.booking_archive_archive_id_seq', 1, false);


--
-- TOC entry 3622 (class 0 OID 0)
-- Dependencies: 237
-- Name: booking_records_booking_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.renting_records_renting_id_seq', 1, false);


--
-- TOC entry 3623 (class 0 OID 0)
-- Dependencies: 240
-- Name: renting_records_renting_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.renting_records_renting_id_seq', 1, false);


--
-- TOC entry 3624 (class 0 OID 0)
-- Dependencies: 2412
-- Name: renting_archive_archive_id_seq; Type: SEQUENCE SET; Schema: records; Owner: -
--

SELECT pg_catalog.setval('records.renting_archive_archive_id_seq', 1, true);


--
-- TOC entry 3388 (class 2606 OID 17562)
-- Name: hotel_chain_email hotel_chain_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_pkey PRIMARY KEY (chain_id, chain_email);


--
-- TOC entry 3390 (class 2606 OID 17564)
-- Name: hotel_chain_phone hotel_chain_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_pkey PRIMARY KEY (chain_id, chain_phone);


--
-- TOC entry 3386 (class 2606 OID 17566)
-- Name: hotel_chain hotel_chain_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain
    ADD CONSTRAINT hotel_chain_pkey PRIMARY KEY (hotel_chain_id);


--
-- TOC entry 3392 (class 2606 OID 17568)
-- Name: hotel_email hotel_email_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_pkey PRIMARY KEY (id, email);


--
-- TOC entry 3382 (class 2606 OID 17570)
-- Name: hotel hotel_hotel_id_key; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_hotel_id_key UNIQUE (hotel_id);


--
-- TOC entry 3394 (class 2606 OID 17572)
-- Name: hotel_phone hotel_phone_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_pkey PRIMARY KEY (id, phone);


--
-- TOC entry 3384 (class 2606 OID 17574)
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (hotel_id, chain_id);


--
-- TOC entry 3398 (class 2606 OID 17576)
-- Name: room_amenities room_amenities_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_pkey PRIMARY KEY (room_number, hotel_id, amenity);


--
-- TOC entry 3396 (class 2606 OID 17578)
-- Name: room room_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (room_number, hotel_id);


--
-- TOC entry 3400 (class 2606 OID 17580)
-- Name: room_problems room_problems_pkey; Type: CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_pkey PRIMARY KEY (room_number, hotel_id, problem);


--
-- TOC entry 3402 (class 2606 OID 17582)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 3404 (class 2606 OID 17584)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 3408 (class 2606 OID 17586)
-- Name: employee_role employee_role_pkey; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee_role
    ADD CONSTRAINT employee_role_pkey PRIMARY KEY (id, roles);


--
-- TOC entry 3406 (class 2606 OID 17588)
-- Name: employee employee_sin_key; Type: CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_sin_key UNIQUE (sin);


--
-- TOC entry 3410 (class 2606 OID 17590)
-- Name: booking_records booking_records_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_records
    ADD CONSTRAINT booking_records_pkey PRIMARY KEY (booking_id);


--
-- TOC entry 3411 (class 2606 OID 17591)
-- Name: booking_archive booking_archive_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.booking_archive
    ADD CONSTRAINT booking_archive_pkey PRIMARY KEY (archive_id);


--
-- TOC entry 3412 (class 2606 OID 17592)
-- Name: renting_records renting_records_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_records
    ADD CONSTRAINT renting_records_pkey PRIMARY KEY (renting_id);


--
-- Name: renting_archive renting_archive_pkey; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_archive
    ADD CONSTRAINT renting_archive_pkey PRIMARY KEY (archive_id);


--
-- Name: renting_archive renting_archive_original_renting_id_key; Type: CONSTRAINT; Schema: records; Owner: -
--

ALTER TABLE ONLY records.renting_archive
    ADD CONSTRAINT renting_archive_original_renting_id_key UNIQUE (original_renting_id);


--
-- TOC entry 3433 (class 2620 OID 17852)
-- Name: hotel addHotel; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "addHotel" AFTER INSERT ON locations.hotel FOR EACH ROW EXECUTE FUNCTION locations.addhotel();


--
-- TOC entry 3430 (class 2620 OID 17679)
-- Name: room addRoom; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "addRoom" AFTER INSERT ON locations.room FOR EACH ROW EXECUTE FUNCTION locations.addroom();


--
-- TOC entry 3428 (class 2620 OID 17692)
-- Name: hotel_chain recalchotels; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER recalchotels BEFORE UPDATE ON locations.hotel_chain FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION locations.recalculatehotels();


--
-- TOC entry 3425 (class 2620 OID 17691)
-- Name: hotel recalcrooms; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER recalcrooms BEFORE UPDATE ON locations.hotel FOR EACH ROW WHEN ((pg_trigger_depth() = 0)) EXECUTE FUNCTION locations.recalculaterooms();


--
-- TOC entry 3426 (class 2620 OID 17683)
-- Name: hotel removeHotel; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "removeHotel" BEFORE DELETE ON locations.hotel FOR EACH ROW EXECUTE FUNCTION locations.removehotel();


--
-- TOC entry 3431 (class 2620 OID 17684)
-- Name: room removeroom; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER removeroom BEFORE DELETE ON locations.room FOR EACH ROW EXECUTE FUNCTION locations.removeroom();


--
-- TOC entry 3427 (class 2620 OID 17687)
-- Name: hotel zeroRooms; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER "zeroRooms" BEFORE INSERT ON locations.hotel FOR EACH ROW WHEN ((new.number_rooms <> 0)) EXECUTE FUNCTION locations.setnumberrooms();


--
-- TOC entry 3429 (class 2620 OID 17699)
-- Name: hotel_chain zerohotels; Type: TRIGGER; Schema: locations; Owner: -
--

CREATE TRIGGER zerohotels BEFORE INSERT ON locations.hotel_chain FOR EACH ROW WHEN ((new.number_hotels <> 0)) EXECUTE FUNCTION locations.setnumberhotels();


--
-- TOC entry 3432 (class 2620 OID 17708)
-- Name: renting_records checkDoubleBooking; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "checkDoubleBooking" BEFORE INSERT ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.checkdoublebooking();


--
-- TOC entry 3433 (class 2620 OID 17650)
-- Name: renting_records updateBookingStatus; Type: TRIGGER; Schema: records; Owner: -
--

CREATE TRIGGER "updateBookingStatus" AFTER INSERT ON records.renting_records FOR EACH ROW EXECUTE FUNCTION records.transformrecord();


--
-- Archive when a renting is checked out.
--
CREATE TRIGGER "archiveRentingOnCheckout"
AFTER UPDATE OF status ON records.renting_records
FOR EACH ROW
WHEN ((NEW.status = 'Checked-Out') AND (OLD.status IS DISTINCT FROM NEW.status))
EXECUTE FUNCTION records.archiverentingrecord();


--
-- Archive before a renting row is deleted.
--
CREATE TRIGGER "archiveRentingOnDelete"
BEFORE DELETE ON records.renting_records
FOR EACH ROW
EXECUTE FUNCTION records.archiverentingrecord();


--
-- TOC entry 3419 (class 2606 OID 17862)
-- Name: hotel_chain_email hotel_chain_email_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_email
    ADD CONSTRAINT hotel_chain_email_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3413 (class 2606 OID 17598)
-- Name: hotel hotel_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3416 (class 2606 OID 17603)
-- Name: hotel_chain_phone hotel_chain_phone_chain_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_chain_phone
    ADD CONSTRAINT hotel_chain_phone_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3417 (class 2606 OID 17608)
-- Name: hotel_email hotel_email_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_email
    ADD CONSTRAINT hotel_email_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3414 (class 2606 OID 17613)
-- Name: hotel hotel_manager_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel
    ADD CONSTRAINT hotel_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES people.employee(employee_id) ON DELETE CASCADE;


--
-- TOC entry 3418 (class 2606 OID 17618)
-- Name: hotel_phone hotel_phone_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.hotel_phone
    ADD CONSTRAINT hotel_phone_id_fkey FOREIGN KEY (id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3420 (class 2606 OID 17623)
-- Name: room_amenities room_amenities_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_amenities
    ADD CONSTRAINT room_amenities_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3419 (class 2606 OID 17628)
-- Name: room room_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room
    ADD CONSTRAINT room_hotel_id_fkey FOREIGN KEY (hotel_id) REFERENCES locations.hotel(hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3421 (class 2606 OID 17633)
-- Name: room_problems room_problems_room_number_hotel_id_fkey; Type: FK CONSTRAINT; Schema: locations; Owner: -
--

ALTER TABLE ONLY locations.room_problems
    ADD CONSTRAINT room_problems_room_number_hotel_id_fkey FOREIGN KEY (room_number, hotel_id) REFERENCES locations.room(room_number, hotel_id) ON DELETE CASCADE;


--
-- TOC entry 3422 (class 2606 OID 17638)
-- Name: employee employee_chain_id_fkey; Type: FK CONSTRAINT; Schema: people; Owner: -
--

ALTER TABLE ONLY people.employee
    ADD CONSTRAINT employee_chain_id_fkey FOREIGN KEY (chain_id) REFERENCES locations.hotel_chain(hotel_chain_id) ON DELETE CASCADE;


--
-- TOC entry 3423 (class 2606 OID 17643)
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


--
-- 2c) Database queries
--

-- Query 1 (availability by filters): available rooms in a date range with optional hotel/chain/area filters.
-- Uses NOT EXISTS to exclude overlapping active bookings and in-progress rentings.
SELECT
    h.name AS hotel_name,
    h.city,
    h.province,
    r.hotel_id,
    r.room_number,
    r.capacity,
    r.price,
    r.view_type
FROM locations.room r
JOIN locations.hotel h ON h.hotel_id = r.hotel_id
WHERE h.chain_id = 1
  AND h.city = 'Montréal'
  AND r.capacity >= 2
  AND r.price <= 300
  AND NOT EXISTS (
      SELECT 1
      FROM records.booking_records b
      WHERE b.hotel_id = r.hotel_id
        AND b.room_number = r.room_number
        AND b.status = 'Active'
        AND b.start_date < DATE '2026-04-10'
        AND b.end_date > DATE '2026-04-05'
  )
  AND NOT EXISTS (
      SELECT 1
      FROM records.renting_records rr
      WHERE rr.hotel_id = r.hotel_id
        AND rr.room_number = r.room_number
        AND rr.status = 'Checked-In'
        AND rr.start_date < DATE '2026-04-10'
        AND rr.end_date > DATE '2026-04-05'
  )
ORDER BY r.price, r.capacity DESC;


-- Query 2 (aggregation): number of rooms and average price per hotel in each city.
SELECT
    h.city,
    h.name AS hotel_name,
    COUNT(*) AS total_rooms,
    ROUND(AVG(r.price), 2) AS avg_room_price,
    MAX(r.capacity) AS max_capacity
FROM locations.hotel h
JOIN locations.room r ON r.hotel_id = h.hotel_id
GROUP BY h.city, h.name
ORDER BY h.city, total_rooms DESC;


-- Query 3 (nested query): customers who have at least one booking at hotels rated above the global average rating.
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM people.customer c
WHERE c.customer_id IN (
    SELECT b.customer_id
    FROM records.booking_records b
    JOIN locations.hotel h ON h.hotel_id = b.hotel_id
    WHERE h.rating > (
        SELECT AVG(rating)
        FROM locations.hotel
        WHERE rating IS NOT NULL
    )
)
ORDER BY c.customer_id;


-- Query 4 (operational report): employee check-ins/rentings volume and revenue collected.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(rr.renting_id) AS total_rentings,
    COALESCE(SUM(rr.payment_amount), 0) AS total_payments
FROM people.employee e
LEFT JOIN records.renting_records rr ON rr.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_rentings DESC, total_payments DESC;


-- Query 5 (renting archive): archived rentings by hotel with aggregated archived revenue.
SELECT
    ra.hotel_name_snap,
    COUNT(*) AS archived_rentings,
    COALESCE(SUM(ra.payment_amount_snap), 0) AS archived_revenue,
    MIN(ra.start_date_snap) AS first_archived_start,
    MAX(ra.end_date_snap) AS last_archived_end
FROM records.renting_archive ra
GROUP BY ra.hotel_name_snap
ORDER BY archived_rentings DESC, archived_revenue DESC;


-- Completed on 2026-03-31 21:55:15 EDT

--
-- PostgreSQL database dump complete
--

\unrestrict eP0Bv59O8nPFjSrehKIMOKir5KOLamybZmJvbQwHzHRJRTjp0Ieja2RqIanGIV6

