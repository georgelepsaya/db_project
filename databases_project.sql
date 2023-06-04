-- Disable foreign key constraints
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Drop tables
DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql += 'DROP TABLE [' + TABLE_SCHEMA + '].[' + TABLE_NAME + '];'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

EXEC sp_executesql @sql;

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
create table Accounts (
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
create table Creators (
	account_id integer not null,
	status nvarchar(30),
	bio nvarchar(max),
	website varchar(2083),
	foreign key (account_id) references Accounts,
	primary key (account_id)
)

-- CreatorPost table
create table Post (
    id integer identity (1, 1) not null,
    creator_id integer not null,
    title nvarchar(255) not null,
    content nvarchar(max) not null,
    created_at datetime not null default getdate(),
    update_at datetime,
    foreign key (creator_id) references Creators,
    primary key (id)
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
    foreign key (account_id) references Accounts,
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
  foreign key (account_id) references Accounts,
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
    visibility varchar(20) check (visibility in ('public', 'private')),
    publication_status varchar(20) check (publication_status in ('published', 'draft', 'scheduled')),
    scheduled_publish_date datetime,
    check ((publication_status = 'scheduled' and scheduled_publish_date is not null)
        or publication_status != 'scheduled' and scheduled_publish_date is null),
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
    primary key (content_id),
    check (content_id != series_id)
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
	account_id integer unique not null,
	last_billing_date datetime not null default getdate(),
	next_billing_date datetime not null default getdate(),
	transaction_id integer unique not null,
	is_active bit not null,
	auto_renewal bit not null,
	foreign key (account_id) references Accounts,
	foreign key (transaction_id) references Transactions,
	primary key (subscription_id)
)

-- Fundraising table
create table Fundraising (
  id integer identity(1, 1) not null,
  creator_id integer not null,
  goal_amount decimal(6,2) not null,
  title nvarchar(255) not null,
  description nvarchar(max) not null,
  published_at datetime not null default getdate(),
  foreign key (creator_id) references Creators,
  primary key (id)
)

-- ReviewEpisode table
create table Review (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    content nvarchar(max) not null,
    created_at datetime not null default getdate(),
    rating integer not null check (rating > 1 and rating < 11),
    episode_id integer not null,
    account_id integer not null,
    foreign key (episode_id) references Episode,
    foreign key (account_id) references Accounts,
    primary key (id)
)

-- User Interests
create table UserInterests (
    account_id integer not null,
    category_id integer not null,
    foreign key (account_id) references Accounts,
    foreign key (category_id) references Categories,
    primary key (account_id, category_id)
)

-- Follows table
create table Follows (
    user_id integer not null,
    creator_id integer not null,
    foreign key (user_id) references Content,
    foreign key (creator_id) references Creators,
    primary key (user_id, creator_id)
)

-- WatchList table
create table WatchList (
    account_id integer not null,
    content_id integer not null,
    liked_at datetime not null default getdate(),
    foreign key (account_id) references Accounts,
    foreign key (content_id) references Content,
    primary key (account_id, content_id)
)

-- CreatorFollow table
create table CreatorFollows (
    creator_followed integer not null,
    creator_follower integer not null,
    started_at datetime not null default getdate(),
    foreign key (creator_followed) references Creators,
    foreign key (creator_follower) references Creators,
    primary key (creator_followed, creator_follower),
    check (creator_followed != creator_follower)
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
create table ContentCollaborators (
    creator_id integer not null,
    content_id integer not null,
    role nvarchar(255) not null,
    foreign key (creator_id) references Creators,
    foreign key (content_id) references Content,
    primary key (creator_id, content_id)
)

-- Insert into Accounts table
INSERT INTO Accounts (username, email, password, first_name, last_name, profile_image_url)
VALUES
    ('john_doe', 'john.doe@example.com', 'gizmo42Plat', 'John', 'Doe', 'https://example.com/profiles/john_doe.jpg'),
    ('jane_doe', 'jane.doe@example.com', 'xYl0tik23s', 'Jane', 'Doe', 'https://example.com/profiles/jane_doe.jpg'),
    ('michael_smith', 'michael.smith@example.com', 'Qr8abLem9F', 'Michael', 'Smith', 'https://example.com/profiles/michael_smith.jpg'),
    ('emily_johnson', 'emily.johnson@example.com', '9oJ3xWq1Ht', 'Emily', 'Johnson', 'https://example.com/profiles/emily_johnson.jpg'),
    ('chris_brown', 'chris.brown@example.com', 'iSw7mzRcP4', 'Chris', 'Brown', 'https://example.com/profiles/chris_brown.jpg'),
    ('sarah_jackson', 'sarah.jackson@example.com', 'z6KJ2VgXap', 'Sarah', 'Jackson', 'https://example.com/profiles/sarah_jackson.jpg'),
    ('kevin_williams', 'kevin.williams@example.com', 'B8dR5YfLq0', 'Kevin', 'Williams', 'https://example.com/profiles/kevin_williams.jpg'),
    ('laura_davis', 'laura.davis@example.com', 'h3FtVl1GzS', 'Laura', 'Davis', 'https://example.com/profiles/laura_davis.jpg'),
    ('ryan_jones', 'ryan.jones@example.com', 'U9y6EaWpDx', 'Ryan', 'Jones', 'https://example.com/profiles/ryan_jones.jpg'),
    ('olivia_thompson', 'olivia.thompson@example.com', 'r4KjM5QbNc', 'Olivia', 'Thompson', 'https://example.com/profiles/olivia_thompson.jpg'),
    ('matt_taylor', 'matt.taylor@example.com', 'C8L0G1SvXy', 'Matt', 'Taylor', 'https://example.com/profiles/matt_taylor.jpg'),
    ('emma_anderson', 'emma.anderson@example.com', '6oFZwYh7Jk', 'Emma', 'Anderson', 'https://example.com/profiles/emma_anderson.jpg'),
    ('joshua_martin', 'joshua.martin@example.com', 'R2I5Bn1Qx9', 'Joshua', 'Martin', 'https://example.com/profiles/joshua_martin.jpg'),
    ('sophia_white', 'sophia.white@example.com', 'T8mE3V6UaP', 'Sophia', 'White', 'https://example.com/profiles/sophia_white.jpg'),
    ('brandon_garcia', 'brandon.garcia@example.com', '7oD5Wq8LbM', 'Brandon', 'Garcia', 'https://example.com/profiles/brandon_garcia.jpg'),
    ('kate_miller', 'kate.miller@example.com', '3jKs7fTq9m', 'Kate', 'Miller', 'https://example.com/profiles/kate_miller.jpg'),
    ('alex_moore', 'alex.moore@example.com', 'a5H8wS6cL1', 'Alex', 'Moore', 'https://example.com/profiles/alex_moore.jpg'),
    ('grace_lee', 'grace.lee@example.com', '2oY9uX7rA0', 'Grace', 'Lee', 'https://example.com/profiles/grace_lee.jpg'),
    ('ethan_clark', 'ethan.clark@example.com', 'e1T6zU3pD8', 'Ethan', 'Clark', 'https://example.com/profiles/ethan_clark.jpg'),
    ('lily_lewis', 'lily.lewis@example.com', 'i4G2mQ9vX6', 'Lily', 'Lewis', 'https://example.com/profiles/lily_lewis.jpg'),
    ('jack_young', 'jack.young@example.com', 'j5K0fS7bN3', 'Jack', 'Young', 'https://example.com/profiles/jack_young.jpg'),
    ('chloe_hall', 'chloe.hall@example.com', 'c8L1gA5wY2', 'Chloe', 'Hall', 'https://example.com/profiles/chloe_hall.jpg'),
    ('noah_patel', 'noah.patel@example.com', 'n9R6tV3uZ0', 'Noah', 'Patel', 'https://example.com/profiles/noah_patel.jpg'),
    ('isabella_green', 'isabella.green@example.com', 'i7E2hQ1sD4', 'Isabella', 'Green', 'https://example.com/profiles/isabella_green.jpg'),
    ('liam_turner', 'liam.turner@example.com', 'l8F1jK5rA9', 'Liam', 'Turner', 'https://example.com/profiles/liam_turner.jpg'),
    ('oliver_carter', 'oliver.carter@example.com', 'o3G6bM9yZ7', 'Oliver', 'Carter', 'https://example.com/profiles/oliver_carter.jpg'),
    ('amelia_parker', 'amelia.parker@example.com', 'a4H5wS1xU6', 'Amelia', 'Parker', 'https://example.com/profiles/amelia_parker.jpg'),
    ('william_wright', 'william.wright@example.com', 'w9I0tY3pV8', 'William', 'Wright', 'https://example.com/profiles/william_wright.jpg'),
    ('mia_thomas', 'mia.thomas@example.com', 'm2J7zK1rB6', 'Mia', 'Thomas', 'https://example.com/profiles/mia_thomas.jpg'),
    ('jacob_adams', 'jacob.adams@example.com', 'j3K6fA9yX5', 'Jacob', 'Adams', 'https://example.com/profiles/jacob_adams.jpg')

select * from Accounts

-- Insert into Creators
insert into Creators (account_id, status, bio, website)
values
    (18, 'Animator', '2D animator specializing in character-driven stories and whimsical worlds.', 'https://www.example.com/creators/animator1'),
    (19, 'Filmmaker', 'Independent filmmaker creating thought-provoking short films and documentaries.', 'https://www.example.com/creators/filmmaker1'),
    (20, 'Stop Motion Artist', 'Crafting imaginative stop-motion animation films using handmade puppets and sets.', 'https://www.example.com/creators/stopmotion1'),
    (21, 'Visual Effects Artist', 'Blending live-action and CGI elements to create stunning visual effects for films.', 'https://www.example.com/creators/vfx1'),
    (22, 'Animator', '3D animator focusing on character animation and storytelling in a variety of styles.', 'https://www.example.com/creators/animator2'),
    (23, 'Filmmaker', 'Passionate about exploring human connections and emotions through short films.', 'https://www.example.com/creators/filmmaker2'),
    (24, 'Motion Graphics Designer', 'Creating eye-catching motion graphics and title sequences for independent films.', 'https://www.example.com/creators/motiongraphics1'),
    (25, 'Animator', 'Experimental animator blending traditional and digital techniques to create unique visuals.', 'https://www.example.com/creators/animator3'),
    (26, 'Filmmaker', 'Documentary filmmaker capturing inspiring stories and shining a light on important issues.', 'https://www.example.com/creators/filmmaker3'),
    (27, 'Animation Director', 'Directing and producing engaging animated films that appeal to all ages.', 'https://www.example.com/creators/animationdirector1'),
    (28, 'Storyboard Artist', 'Creating compelling storyboards that bring film and animation projects to life.', 'https://www.example.com/creators/storyboardartist1'),
    (29, 'Animator', 'Specializing in hand-drawn animation with a focus on fluid and expressive characters.', 'https://www.example.com/creators/animator4'),
    (30, 'Filmmaker', 'Exploring the boundaries of narrative filmmaking through innovative storytelling techniques.', 'https://www.example.com/creators/filmmaker4'),
    (31, 'CGI Artist', 'Creating visually striking 3D animations and digital environments for films.', 'https://www.example.com/creators/cgiartist1'),
    (32, 'Animator', 'Versatile animator skilled in both 2D and 3D animation with a strong focus on storytelling.', 'https://www.example.com/creators/animator5');

select * from Creators

