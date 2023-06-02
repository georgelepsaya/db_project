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
	account_id integer identity(3, 1) not null,
	username nvarchar(30) unique not null,
	email nvarchar(30) unique not null,
	password nvarchar(50) not null,
	first_name nvarchar(20),
	last_name nvarchar(30),
	profile_image_url nvarchar(255),
	registered_at datetime not null default(getdate()),
	last_login datetime not null default(getdate()),
	primary key (account_id)
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
    address_id integer identity (1, 1) not null,
    country nvarchar(255) not null,
    city nvarchar(255) not null,
    state nvarchar(50) not null,
    postal_code varchar(10) not null,
    primary key (address_id)
)

-- Billing table
create table Billing (
    billing_id integer identity (1, 1) not null,
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
    primary key (billing_id)
)

-- Transactions table
create table Transactions (
  transaction_id integer identity(1, 1) not null,
  account_id integer not null,
  amount decimal(6,2) not null,
  currency varchar(3) not null,
  status varchar(2) not null,
  created_at datetime not null default getdate(),
  foreign key (account_id) references Account,
  foreign key (currency) references Currency(ISO_code),
  foreign key (status) references Transaction_status(id),
  primary key (transaction_id)
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
    series_id integer,
    season integer,
    number integer,
    foreign key (content_id) references Content(content_id),
    foreign key (series_id) references Content(content_id),
    primary key (content_id)
)

-- Category table
create table Categories (
    category_id integer identity (1, 1) not null,
    title nvarchar(255) not null unique ,
    primary key (category_id)
)

-- Subscription table
create table Subscription (
	subscription_id integer identity(1, 1) not null,
	user_id integer unique not null,
	last_billing_date datetime not null default getdate(),
	next_billing_date datetime not null default getdate(),
	transaction_id integer unique not null,
	is_active bit not null,
	auto_renewal bit not null,
	foreign key (user_id) references Account,
	foreign key (transaction_id) references Transactions,
	primary key (subscription_id)
)

-- User Interests
create table UserInterests (
    user_id integer not null,
    category_id integer not null,
    foreign key (user_id) references Account,
    foreign key (category_id) references Categories,
    primary key (user_id, category_id)
)

-- Follows table
create table Follows (
    user_id integer not null,
    creator_id integer not null,
    foreign key (user_id) references Content,
    foreign key (creator_id) references Creator,
    primary key (user_id, creator_id)
)

-- ReviewContent table
create table ReviewContent (
    review_id integer identity (1, 1) not null,
    content_id integer not null,
    title nvarchar(255) not null,
    content nvarchar(max) not null,
    created_at datetime not null default getdate(),
    rating integer not null check (rating > 1 and rating < 11),
    user_id integer not null,
    foreign key (content_id) references Content,
    foreign key (user_id) references Account,
    primary key (review_id)
)

-- WatchList table
create table WatchList (
    account_id integer not null,
    content_id integer not null,
    liked_at datetime not null default getdate(),
    foreign key (account_id) references Account,
    foreign key (content_id) references Content,
    primary key (account_id, content_id)
)

-- CreatorFollow table
create table CreatorsFollow (
    creator_followed integer not null,
    creator_follower integer not null,
    started_at datetime not null default getdate(),
    foreign key (creator_followed) references Creator,
    foreign key (creator_follower) references Creator,
    primary key (creator_followed, creator_follower),
    check (creator_followed != creator_follower)
)

-- ContentManagement table
create table ContentManagement (
    content_id integer not null,
    visibility varchar(20) check (visibility in ('public', 'private')),
    publication_status varchar(20) check (publication_status in ('published', 'draft', 'scheduled')),
    scheduled_publish_date datetime,
    foreign key (content_id) references Content,
    primary key (content_id),
    check ((publication_status = 'scheduled' and scheduled_publish_date is not null)
        or publication_status != 'scheduled' and scheduled_publish_date is null)
)

-- ContentCategory table
create table ContentCategory (
    content_id integer not null,
    category_id integer not null,
    foreign key (content_id) references Content,
    foreign key (category_id) references Categories,
    primary key (content_id, category_id)
)

-- ContentCollaborators table
create table CollaboratorFilm (
    creator_id integer not null,
    content_id integer not null,
    role nvarchar(255) not null,
    foreign key (creator_id) references Creator,
    foreign key (content_id) references Content,
    primary key (creator_id, content_id)
)

