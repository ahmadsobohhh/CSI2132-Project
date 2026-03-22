/*
create type VIEW_TYPE as enum ('Sea', 'Mountain');
create type GID9 as enum ('SSN', 'SIN');
create type GID as enum ('SSN', 'SIN', 'Driver');
create type BOOKING_STATES as enum ('Active', 'Transformed', 'Cancelled');
create type CHECKING_STATES as enum ('Checked-In', 'Checked-Out');
*/

create schema Locations
	create table Hotel_Chain(
		Hotel_Chain_ID INTEGER primary key not null,
		Name VARCHAR(20),
		Number_Hotels INTEGER,
		Street_number INTEGER,
		Street_name VARCHAR(20),
		City VARCHAR(20),
		Province VARCHAR(20),
		Postal_Code VARCHAR(20)
	)
	create table Hotel_Chain_Email(
		Hotel_Chain_ID INTEGER primary key references Hotel_Chain not null,
		Hotel_Chain_Email VARCHAR(20) primary key not null
	)
	create table Hotel_Chain_Phone(
		Hotel_Chain_ID INTEGER primary key references Hotel_Chain not null,
		Hotel_Chain_Phone DECIMAL(10, 0) primary key not null
	)
	create table Hotel(
		Hotel_ID INTEGER primary key not null,
		Hotel_Chain_ID INTEGER primary key references Hotel_Chain not null,
		Manager_ID INTEGER references People.Employee(Employee_ID) not null,
		Rating INTEGER,
		Number_Rooms INTEGER,
		Name INTEGER,
		Street_number INTEGER,
		Street_name VARCHAR(20),
		City VARCHAR(20),
		Province VARCHAR(20),
		Postal_Code VARCHAR(20)
	)
	create table Hotel_Email(
		Hotel_ID INTEGER primary key references Hotel not null,
		Hotel_Email VARCHAR(20) primary key not null
	)
	create table Hotel_Phone(
		Hotel_ID INTEGER primary key references Hotel not null,
		Hotel_Phone Decimal(10, 0) primary key not null
	)
	create table Room(
		Room_Number INTEGER primary key not null,
		Hotel_ID INTEGER primary key references Hotel not null,
		Price INTEGER,
		Capacity INTEGER,
		View_Type VARCHAR(20), -- VIEW_TYPE,
		Is_Etendable BOOL
	)
	create table Room_Amenities(
		Room_Number INTEGER primary key references Room not null,
		Hotel_ID INTEGER primary key references Hotel not null,
		Amenity VARCHAR(20) primary key not null
	)
	create table Room_Problems(
		Room_Number INTEGER primary key references Room not null,
		Hotel_ID INTEGER primary key references Hotel not null,
		Problem VARCHAR(20) primary key not null
	);

create schema People
	create table Employee(
		Employee_ID INTEGER primary key not null,
		Hotel_ID Integer references Locations.Hotel,
		First_Name VARCHAR(20),
		Middle_Name VARCHAR(20),
		Last_Name VARCHAR(20),
		Street_number INTEGER,
		Street_name VARCHAR(20),
		City VARCHAR(20),
		Province VARCHAR(20),
		Postal_Code VARCHAR(20),
		SIN DECIMAL(9, 0) UNIQUE, 
		Government_ID VARCHAR(20) -- GID9
	)
	create table Employee_Role(
		Employee_ID INTEGER primary key references Employee not null,
		Roles VARCHAR(20) primary key not null
	)
	create table Customer(
		Customer_ID INTEGER primary key not null,
		irst_Name VARCHAR(20),
		Middle_Name VARCHAR(20),
		Last_Name VARCHAR(20),
		Street_number INTEGER,
		Street_name VARCHAR(20),
		City VARCHAR(20),
		Province VARCHAR(20),
		Postal_Code VARCHAR(20),
		Registration_Date DATE default now(),
		ID_Type VARCHAR(20), -- GID,
		ID_Number INTEGER unique
	);

create schema Records
	create table Booking_Records(
		Booking_ID INTEGER primary key,
		Room_Number INTEGER not null,
		Hotel_ID INTEGER not null,
		Customer_ID Integer not null,
		Start_Date Date not null,
		End_Date Date not null,
		Status VARCHAR(20) -- BOOKING_STATES
	)
	create table Renting_Records(
		Booking_ID INTEGER primary key,
		Room_Number INTEGER not null,
		Hotel_ID INTEGER not null,
		Customer_ID INTEGER not null,
		Emplyee_ID INTEGER not null,
		Start_Date DATE,
		End_Date DATE,
		Payment_Amount INTEGER,
		Status VARCHAR(20) -- CHECKING_STATES
	);
