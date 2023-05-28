-- PaymentType table
create table PaymentType (
	id varchar(2) not null,
	name nvarchar(16) unique not null,
	primary key (id)
)

-- TransactionStatus table
create table Transaction_status (
	id varchar(2) not null,
	name nvarchar(9) unique not null,
	primary key (id)
)

-- Currency table
create table Currency (
	ISO_code varchar(3) primary key not null,
	details nvarchar(20) unique not null
)

-- Account table
create table Account (
	id integer identity(3, 1) not null,
	username nvarchar(30) unique not null,
	email nvarchar(30) unique not null,
	password nvarchar(50) not null,
	first_name nvarchar(20),
	last_name nvarchar(30),
	profile_image_url nvarchar(255),
	registered_at datetime not null default(getdate()),
	last_login datetime not null default(getdate()),
	primary key (id)
)

-- Creator table
create table Creator (
	account_id integer not null,
	status nvarchar(30),
	bio nvarchar(max),
	website varchar(2083),
	foreign key (account_id) references Account,
	primary key (account_id)
)

-- Address table
create table Address (
    id integer identity (1, 1) not null,
    country nvarchar(255) not null,
    city nvarchar(255) not null,
    state nvarchar(50) not null,
    postal_code varchar(10) not null,
    primary key (id)
)

-- Billing table
create table Billing (
    id integer identity (1, 1) not null,
    account_id integer not null,
    payment_type varchar(2) not null,
    card_last_digits varchar(4) not null,
    expiration date not null,
    created_at datetime not null default(getdate()),
    updated_at datetime not null default(getdate()),
    address_id integer not null,
    foreign key (account_id) references Account,
    foreign key (payment_type) references PaymentType,
    foreign key (address_id) references Address,
    primary key (id)
)

-- Transactions table
create table Transactions (
  id integer identity(1, 1) not null,
  account_id integer not null,
  amount decimal(6,2) not null,
  currency varchar(3) not null,
  status varchar(2) not null,
  created_at datetime not null default getdate(),
  foreign key (account_id) references Account,
  foreign key (currency) references Currency(ISO_code),
  foreign key (status) references Transaction_status(id),
  primary key (id)
)

-- Content table
create table Content (
    content_id integer identity (8, 1) not null,
    content_type varchar(10) check (content_type in ('Film', 'Series', 'Episode')),
    title nvarchar(255) not null,
    description nvarchar(max) not null,
    content_url varchar(255) not null,
    duration time not null,
    thumbnail_url varchar(255),
    created_at datetime not null default getdate(),
    primary key (content_id)
)

-- Episode table
create table Episode (
    content_id integer,
    foreign key (content_id) references Content(content_id),
    primary key (content_id)
)

-- Category table
create table Category (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null unique ,
    primary key (id)
)

