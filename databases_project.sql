-- -- Disable foreign key constraints
-- EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
--
-- -- Drop tables
-- DECLARE @sql NVARCHAR(MAX) = '';
--
-- SELECT @sql += 'DROP TABLE [' + TABLE_SCHEMA + '].[' + TABLE_NAME + '];'
-- FROM INFORMATION_SCHEMA.TABLES
-- WHERE TABLE_TYPE = 'BASE TABLE';
--
-- EXEC sp_executesql @sql;

-- PaymentType table
create table PaymentType (
	id varchar(2) not null,
	name nvarchar(16) unique not null,
	primary key (id)
)

-- insert payment types
insert into PaymentType values
('AE','American_Express'),
('VI','Visa'),
('MA','Mastercard'),
('DI','Discover'),
('JC','JCB'),
('DC','Diners_Club'),
('UN','UnionPay'),
('PA','PayPal'),
('AP','Apple_Pay'),
('GO','Google_Pay'),
('AL','AliPay'),
('WC','WeChat_Pay')

-- TransactionStatus table
create table Transaction_status (
	id varchar(2) not null,
	name nvarchar(9) unique not null,
	primary key (id)
)

-- insert transaction status values
insert into Transaction_status values
('PE','pending'),
('CO','completed'),
('FA','failed'),
('RE','refunded')

-- Currency table
create table Currency (
	ISO_code varchar(3) primary key not null,
	details nvarchar(20) unique not null
)

-- insert currency values
insert into Currency values
('USD','United States dollar'),
('EUR','Euro dollar'),
('JPY','Japanese yen'),
('GBP','Pound sterling'),
('AUD','Australian dollar'),
('CAD','Canadian dollar'),
('CHF','Switzerland franc'),
('CNY','Chinese yuan'),
('HKD','Hong Kong dollar'),
('NZD','New Zealand dollar'),
('SGD','Singapore dollar'),
('SEK','Swedish krona'),
('KRW','South Korean won'),
('MXN','Mexican peso'),
('INR','Indian rupee'),
('RUB','Russian ruble'),
('ZAR','South African rand'),
('TRY','Turkish lira'),
('BRL','Brazilian real'),
('DKK','Danish krone')

-- Account table
create table Accounts (
	account_id integer identity(3, 1) not null,
	username nvarchar(30) unique not null,
	email nvarchar(30) unique not null,
	password nvarchar(50) not null,
	first_name nvarchar(20),
	last_name nvarchar(30),
	account_type varchar(8) check (account_type in ('user', 'creator')),
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
    content_url varchar(255),
    duration time,
    thumbnail_url varchar(255),
    series_id integer,
    season_number integer,
    episode_number integer,
    visibility varchar(20) check (visibility in ('public', 'private')),
    publication_status varchar(20) check (publication_status in ('published', 'draft', 'scheduled')),
    scheduled_publish_date datetime,
    created_at datetime not null default getdate(),
    foreign key (series_id) references Content(content_id),
    primary key (content_id),
    check ((publication_status = 'scheduled' and scheduled_publish_date is not null)
        or publication_status != 'scheduled' and scheduled_publish_date is null),
    constraint CK_Content_Type_Check check (
        (content_type = 'Film' and content_url is not null and duration is not null) or
        (content_type = 'Series' and content_url is null and duration is null) or
        (content_type = 'Episode' and series_id is not null and season_number is not null and episode_number is not null)
    )
)

-- Season table
create table Season (
    series_id integer not null,
    season_number integer not null,
    season_title varchar(255) not null,
    foreign key (series_id) references Content(content_id),
    primary key (series_id, season_number)
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
  collected decimal(6,2) not null,
  title nvarchar(255) not null,
  description nvarchar(max) not null,
  published_at datetime not null default getdate(),
  foreign key (creator_id) references Creators,
  primary key (id)
)

-- ReviewTable
create table Review (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    content nvarchar(max) not null,
    created_at datetime not null default getdate(),
    rating integer not null check (rating > 1 and rating < 11),
    content_id integer not null,
    account_id integer not null,
    foreign key (content_id) references Content,
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
    foreign key (user_id) references Accounts,
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
INSERT INTO Accounts (username, email, password, first_name, last_name, account_type, profile_image_url)
VALUES
    ('john_doe', 'john.doe@example.com', 'gizmo42Plat', 'John', 'Doe', 'user', 'https://example.com/profiles/john_doe.jpg'),
    ('jane_doe', 'jane.doe@example.com', 'xYl0tik23s', 'Jane', 'Doe', 'user', 'https://example.com/profiles/jane_doe.jpg'),
    ('michael_smith', 'michael.smith@example.com', 'Qr8abLem9F', 'Michael', 'Smith', 'user', 'https://example.com/profiles/michael_smith.jpg'),
    ('emily_johnson', 'emily.johnson@example.com', '9oJ3xWq1Ht', 'Emily', 'Johnson', 'user', 'https://example.com/profiles/emily_johnson.jpg'),
    ('chris_brown', 'chris.brown@example.com', 'iSw7mzRcP4', 'Chris', 'Brown', 'user', 'https://example.com/profiles/chris_brown.jpg'),
    ('sarah_jackson', 'sarah.jackson@example.com', 'z6KJ2VgXap', 'Sarah', 'Jackson', 'user', 'https://example.com/profiles/sarah_jackson.jpg'),
    ('kevin_williams', 'kevin.williams@example.com', 'B8dR5YfLq0', 'Kevin', 'Williams', 'user', 'https://example.com/profiles/kevin_williams.jpg'),
    ('laura_davis', 'laura.davis@example.com', 'h3FtVl1GzS', 'Laura', 'Davis', 'user', 'https://example.com/profiles/laura_davis.jpg'),
    ('ryan_jones', 'ryan.jones@example.com', 'U9y6EaWpDx', 'Ryan', 'Jones', 'user', 'https://example.com/profiles/ryan_jones.jpg'),
    ('olivia_thompson', 'olivia.thompson@example.com', 'r4KjM5QbNc', 'Olivia', 'Thompson', 'user', 'https://example.com/profiles/olivia_thompson.jpg'),
    ('matt_taylor', 'matt.taylor@example.com', 'C8L0G1SvXy', 'Matt', 'Taylor', 'user', 'https://example.com/profiles/matt_taylor.jpg'),
    ('emma_anderson', 'emma.anderson@example.com', '6oFZwYh7Jk', 'Emma', 'Anderson', 'user', 'https://example.com/profiles/emma_anderson.jpg'),
    ('joshua_martin', 'joshua.martin@example.com', 'R2I5Bn1Qx9', 'Joshua', 'Martin', 'user', 'https://example.com/profiles/joshua_martin.jpg'),
    ('sophia_white', 'sophia.white@example.com', 'T8mE3V6UaP', 'Sophia', 'White', 'user', 'https://example.com/profiles/sophia_white.jpg'),
    ('brandon_garcia', 'brandon.garcia@example.com', '7oD5Wq8LbM', 'Brandon', 'Garcia', 'user', 'https://example.com/profiles/brandon_garcia.jpg'),
    ('kate_miller', 'kate.miller@example.com', '3jKs7fTq9m', 'Kate', 'Miller', 'creator', 'https://example.com/profiles/kate_miller.jpg'),
    ('alex_moore', 'alex.moore@example.com', 'a5H8wS6cL1', 'Alex', 'Moore', 'creator', 'https://example.com/profiles/alex_moore.jpg'),
    ('grace_lee', 'grace.lee@example.com', '2oY9uX7rA0', 'Grace', 'Lee', 'creator', 'https://example.com/profiles/grace_lee.jpg'),
    ('ethan_clark', 'ethan.clark@example.com', 'e1T6zU3pD8', 'Ethan', 'Clark', 'creator', 'https://example.com/profiles/ethan_clark.jpg'),
    ('lily_lewis', 'lily.lewis@example.com', 'i4G2mQ9vX6', 'Lily', 'Lewis', 'creator', 'https://example.com/profiles/lily_lewis.jpg'),
    ('jack_young', 'jack.young@example.com', 'j5K0fS7bN3', 'Jack', 'Young', 'creator', 'https://example.com/profiles/jack_young.jpg'),
    ('chloe_hall', 'chloe.hall@example.com', 'c8L1gA5wY2', 'Chloe', 'Hall', 'creator', 'https://example.com/profiles/chloe_hall.jpg'),
    ('noah_patel', 'noah.patel@example.com', 'n9R6tV3uZ0', 'Noah', 'Patel', 'creator', 'https://example.com/profiles/noah_patel.jpg'),
    ('isabella_green', 'isabella.green@example.com', 'i7E2hQ1sD4', 'Isabella', 'Green', 'creator', 'https://example.com/profiles/isabella_green.jpg'),
    ('liam_turner', 'liam.turner@example.com', 'l8F1jK5rA9', 'Liam', 'Turner', 'creator', 'https://example.com/profiles/liam_turner.jpg'),
    ('oliver_carter', 'oliver.carter@example.com', 'o3G6bM9yZ7', 'Oliver', 'Carter', 'creator', 'https://example.com/profiles/oliver_carter.jpg'),
    ('amelia_parker', 'amelia.parker@example.com', 'a4H5wS1xU6', 'Amelia', 'Parker', 'creator', 'https://example.com/profiles/amelia_parker.jpg'),
    ('william_wright', 'william.wright@example.com', 'w9I0tY3pV8', 'William', 'Wright', 'creator', 'https://example.com/profiles/william_wright.jpg'),
    ('mia_thomas', 'mia.thomas@example.com', 'm2J7zK1rB6', 'Mia', 'Thomas', 'creator', 'https://example.com/profiles/mia_thomas.jpg'),
    ('jacob_adams', 'jacob.adams@example.com', 'j3K6fA9yX5', 'Jacob', 'Adams', 'creator', 'https://example.com/profiles/jacob_adams.jpg')

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

-- Insert into Content: Series
-- Insert Series
insert into Content (content_type, title, description, thumbnail_url)
values ('Series', 'Mystery Tales', 'A series of thrilling mystery stories.', 'mystery_tales_thumbnail.jpg'),
       ('Series', 'Sci-Fi Chronicles', 'Explore the fascinating world of science fiction.', 'sci_fi_chronicles_thumbnail.jpg'),
       ('Series', 'Adventure Island', 'An exciting adventure series set on a remote island.', 'adventure_island_thumbnail.jpg'),
       ('Series', 'Drama Diaries', 'A collection of dramatic stories that touch the heart.', 'drama_diaries_thumbnail.jpg'),
       ('Series', 'Comedy Corner', 'A series filled with hilarious comedic tales.', 'comedy_corner_thumbnail.jpg');

select * from Content

-- Insert into Seasons
insert into Season (season_title, series_id, season_number)
values ('Mystery Tales Season 1', 8, 1),
       ('Mystery Tales Season 2', 8, 2),
       ('Sci-Fi Chronicles Season 1', 9, 1),
       ('Sci-Fi Chronicles Season 2', 9, 2),
       ('Adventure Island Season 1', 10, 1),
       ('Adventure Island Season 2', 10, 2),
       ('Adventure Island Season 3', 10, 3),
       ('Drama Diaries Season 1', 11, 1),
       ('Drama Diaries Season 2', 11, 2),
       ('Comedy Corner Season 1', 12, 1),
       ('Comedy Corner Season 2', 12, 2),
       ('Comedy Corner Season 3', 12, 3);

select * from Season

select * from Content where content_type = 'Series'

-- Insert into Content: Episodes - Mystery Tales Season 1
insert into Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
values ('Episode', 'The Haunted House', 'A group of friends explore a haunted house.', 'mystery_tales_s1e1.mp4', 8, 1, 1, '00:45:00', 'mystery_tales_s1e1_thumbnail.jpg'),
       ('Episode', 'The Lost Treasure', 'A treasure hunt leads to unexpected discoveries.', 'mystery_tales_s1e2.mp4', 8, 1, 2, '00:42:00', 'mystery_tales_s1e2_thumbnail.jpg'),
       ('Episode', 'The Secret Chamber', 'A hidden chamber reveals dark secrets.', 'mystery_tales_s2e1.mp4', 8, 1, 3, '00:47:00', 'mystery_tales_s2e1_thumbnail.jpg'),
       ('Episode', 'The Mysterious Stranger', 'A stranger arrives in town with a hidden agenda.', 'mystery_tales_s2e2.mp4', 8, 1, 4, '00:44:00', 'mystery_tales_s2e2_thumbnail.jpg'),
       ('Episode', 'The Vanishing Artist', 'A talented artist disappears under mysterious circumstances.', 'mystery_tales_s1e3.mp4', 8, 1, 5, '00:40:00', 'mystery_tales_s1e3_thumbnail.jpg');

-- Mystery Tales Season 2 Episodes
insert into Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
values ('Episode', 'The Phantom Thief', 'A master thief eludes the authorities.', 'mystery_tales_s2_e1.mp4', 8, 2, 1, '00:48:00', 'mystery_tales_s2e3_thumbnail.jpg'),
       ('Episode', 'The Final Trick', 'A magician`s final trick leads to a shocking revelation.', 'mystery_tales_s2_e2.mp4', 8, 2, 2, '00:41:00', 'mystery_tales_s2e4_thumbnail.jpg'),
       ('Episode', 'The Shadow Society', 'An undercover agent infiltrates a secret society.', 'mystery_tales_s2_e3.mp4', 8, 2, 3, '00:46:00', 'mystery_tales_s2e5_thumbnail.jpg'),
       ('Episode', 'The Hidden Clue', 'A detective finds a vital clue that cracks the case.', 'mystery_tales_s2_e4.mp4', 8, 2, 4, '00:43:00', 'mystery_tales_s1e4_thumbnail.jpg'),
       ('Episode', 'The Cryptic Code', 'A cryptic code holds the key to solving a puzzling mystery.', 'mystery_tales_s2_e5.mp4', 8, 2, 5, '00:44:00', 'mystery_tales_s1e5_thumbnail.jpg');

-- Sci-Fi Chronicles Season 1 episodes
insert into Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
values ('Episode', 'The Time Machine', 'An inventor creates a time machine and explores the future.', 'sci_fi_chronicles_s1e1.mp4', 9, 1, 1, '00:50:00', 'sci_fi_chronicles_s1e1_thumbnail.jpg'),
       ('Episode', 'The Alien Encounter', 'A group of scientists make contact with an alien species.', 'sci_fi_chronicles_s1e2.mp4', 9, 1, 2, '00:52:00', 'sci_fi_chronicles_s1e2_thumbnail.jpg'),
       ('Episode', 'The Martian Chronicles', 'A mission to Mars uncovers a hidden civilization.', 'sci_fi_chronicles_s1e3.mp4', 9, 1, 3, '00:55:00', 'sci_fi_chronicles_s1e3_thumbnail.jpg'),
       ('Episode', 'The Space Station', 'Astronauts aboard a space station face an unexpected crisis.', 'sci_fi_chronicles_s1e4.mp4', 9, 1, 4, '00:47:00', 'sci_fi_chronicles_s1e4_thumbnail.jpg'),
       ('Episode', 'The Black Hole', 'A team of scientists investigates a mysterious black hole.', 'sci_fi_chronicles_s1e5.mp4', 9, 1, 5, '00:49:00', 'sci_fi_chronicles_s1e5_thumbnail.jpg');

-- Sci-Fi Chronicles Season 2 episodes
INSERT INTO Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
VALUES ('Episode', 'The Multiverse Theory', 'A scientist explores the possibility of parallel universes.', 'sci_fi_chronicles_s2e1.mp4', 9, 2, 1, '00:51:00', 'sci_fi_chronicles_s2e1_thumbnail.jpg'),
       ('Episode', 'The Time Paradox', 'A time traveler accidentally alters the course of history.', 'sci_fi_chronicles_s2e2.mp4', 9, 2, 2, '00:54:00', 'sci_fi_chronicles_s2e2_thumbnail.jpg'),
       ('Episode', 'The Quantum Leap', 'An experiment in quantum physics leads to extraordinary consequences.', 'sci_fi_chronicles_s2e3.mp4', 9, 2, 3, '00:53:00', 'sci_fi_chronicles_s2e3_thumbnail.jpg'),
       ('Episode', 'The Galactic War', 'An intergalactic war threatens the fate of the universe.', 'sci_fi_chronicles_s2e4.mp4', 9, 2, 4, '00:58:00', 'sci_fi_chronicles_s2e4_thumbnail.jpg'),
       ('Episode', 'The Android Revolution', 'A society of androids fights for their freedom.', 'sci_fi_chronicles_s2e5.mp4', 9, 2, 5, '00:56:00', 'sci_fi_chronicles_s2e5_thumbnail.jpg');

-- Adventure Island Season 1 episodes
INSERT INTO Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
VALUES ('Episode', 'Shipwrecked', 'A group of adventurers becomes shipwrecked on a mysterious island.', 'adventure_island_s1e1.mp4', 10, 1, 1, '00:45:00', 'adventure_island_s1e1_thumbnail.jpg'),
       ('Episode', 'The Jungle Maze', 'The adventurers navigate a dangerous jungle filled with traps.', 'adventure_island_s1e2.mp4', 10, 1, 2, '00:47:00', 'adventure_island_s1e2_thumbnail.jpg'),
       ('Episode', 'The Hidden Temple', 'The group discovers an ancient temple with hidden secrets.', 'adventure_island_s1e3.mp4', 10, 1, 3, '00:50:00', 'adventure_island_s1e3_thumbnail.jpg'),
       ('Episode', 'The Cursed Treasure', 'A legendary treasure is found, but it comes with a terrible curse.', 'adventure_island_s1e4.mp4', 10, 1, 4, '00:48:00', 'adventure_island_s1e4_thumbnail.jpg'),
       ('Episode', 'The Great Escape', 'The adventurers devise a daring plan to escape the island.', 'adventure_island_s1e5.mp4', 10, 1, 5, '00:46:00', 'adventure_island_s1e5_thumbnail.jpg');

-- Adventure Island Season 2 episodes
INSERT INTO Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
VALUES ('Episode', 'The Island Revisited', 'The group returns to the island to rescue a friend left behind.', 'adventure_island_s2e1.mp4', 10, 2, 1, '00:44:00', 'adventure_island_s2e1_thumbnail.jpg'),
       ('Episode', 'The Lost City', 'The adventurers discover the remains of a long-lost civilization.', 'adventure_island_s2e2.mp4', 10, 2, 2, '00:49:00', 'adventure_island_s2e2_thumbnail.jpg'),
       ('Episode', 'The Underground River', 'The group ventures into an underground river filled with danger.', 'adventure_island_s2e3.mp4', 10, 2, 3, '00:52:00', 'adventure_island_s2e3_thumbnail.jpg'),
       ('Episode', 'The Island`s Secret', 'The island`s true purpose is finally revealed.', 'adventure_island_s2e4.mp4', 10, 2, 4, '00:55:00', 'adventure_island_s2e4_thumbnail.jpg'),
       ('Episode', 'The Final Battle', 'The adventurers face off against their greatest foe.', 'adventure_island_s2e5.mp4', 10, 2, 5, '00:58:00', 'adventure_island_s2e5_thumbnail.jpg');

-- -- Adventure Island Season 3 episodes
INSERT INTO Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
VALUES ('Episode', 'The New Island', 'The adventurers embark on a new journey to a mysterious island.', 'adventure_island_s3e1.mp4', 10, 3, 1, '00:46:00', 'adventure_island_s3e1_thumbnail.jpg'),
       ('Episode', 'The Hidden Cave', 'A hidden cave reveals clues to the island`s past.', 'adventure_island_s3e2.mp4', 10, 3, 2, '00:48:00', 'adventure_island_s3e2_thumbnail.jpg'),
       ('Episode', 'The Ancient Ruins', 'The group stumbles upon ancient ruins with powerful artifacts.', 'adventure_island_s3e3.mp4', 10, 3, 3, '00:51:00', 'adventure_island_s3e3_thumbnail.jpg'),
       ('Episode', 'The Forbidden Zone', 'The adventurers dare to enter a forbidden part of the island.', 'adventure_island_s3e4.mp4', 10, 3, 4, '00:53:00', 'adventure_island_s3e4_thumbnail.jpg'),
       ('Episode', 'The Final Voyage', 'The group faces their most dangerous challenge yet.', 'adventure_island_s3e5.mp4', 10, 3, 5, '00:57:00', 'adventure_island_s3e5_thumbnail.jpg');

-- Drama Diaries Season 1 episodes
INSERT INTO Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
VALUES ('Episode', 'A New Beginning', 'A young woman moves to a new city to start her life anew.', 'drama_diaries_s1e1.mp4', 11, 1, 1, '00:42:00', 'drama_diaries_s1e1_thumbnail.jpg'),
       ('Episode', 'The Love Triangle', 'A complicated love triangle threatens friendships.', 'drama_diaries_s1e2.mp4', 11, 1, 2, '00:45:00', 'drama_diaries_s1e2_thumbnail.jpg'),
       ('Episode', 'The Broken Friendship', 'A misunderstanding leads to a broken friendship.', 'drama_diaries_s1e3.mp4', 11, 1, 3, '00:47:00', 'drama_diaries_s1e3_thumbnail.jpg'),
       ('Episode', 'The Family Secret', 'A family secret is revealed, changing relationships forever.', 'drama_diaries_s1e4.mp4', 11, 1, 4, '00:44:00', 'drama_diaries_s1e4_thumbnail.jpg'),
       ('Episode', 'The Unexpected Proposal', 'A surprise proposal leads to difficult decisions.', 'drama_diaries_s1e5.mp4', 11, 1, 5, '00:46:00', 'drama_diaries_s1e5_thumbnail.jpg');

-- Drama Diaries Season 2 episodes
INSERT INTO Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
VALUES ('Episode', 'The New Job', 'A new job brings new challenges and opportunities.', 'drama_diaries_s2e1.mp4', 11, 2, 1, '00:43:00', 'drama_diaries_s2e1_thumbnail.jpg'),
       ('Episode', 'The Long-Lost Friend', 'An old friend reappears, bringing up buried memories.', 'drama_diaries_s2e2.mp4', 11, 2, 2, '00:41:00', 'drama_diaries_s2e2_thumbnail.jpg'),
       ('Episode', 'The Heartbreak', 'Heartbreak leads to personal growth and healing.', 'drama_diaries_s2e3.mp4', 11, 2, 3, '00:49:00', 'drama_diaries_s2e3_thumbnail.jpg'),
       ('Episode', 'The Reconciliation', 'A broken friendship is mended through understanding and forgiveness.', 'drama_diaries_s2e4.mp4', 11, 2, 4, '00:47:00', 'drama_diaries_s2e4_thumbnail.jpg'),
       ('Episode', 'The Final Goodbye', 'A farewell brings closure and new beginnings.', 'drama_diaries_s2e5.mp4', 11, 2, 5, '00:50:00', 'drama_diaries_s2e5_thumbnail.jpg');

-- Comedy Corner Season 1 episodes
INSERT INTO Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
VALUES ('Episode', 'The Awkward Date', 'A disastrous first date leads to hilarious misunderstandings.', 'comedy_central_s1e1.mp4', 12, 1, 1, '00:30:00', 'comedy_central_s1e1_thumbnail.jpg'),
       ('Episode', 'The Unusual Roommate', 'A quirky roommate turns everyday life upside down.', 'comedy_central_s1e2.mp4', 12, 1, 2, '00:28:00', 'comedy_central_s1e2_thumbnail.jpg'),
       ('Episode', 'The Family Reunion', 'A chaotic family reunion brings out the best and worst in everyone.', 'comedy_central_s1e3.mp4', 12, 1, 3, '00:32:00', 'comedy_central_s1e3_thumbnail.jpg'),
       ('Episode', 'The Misadventures of Pet Sitting', 'Pet sitting turns into an adventure full of hilarious mishaps.', 'comedy_central_s1e4.mp4', 12, 1, 4, '00:29:00', 'comedy_central_s1e4_thumbnail.jpg'),
       ('Episode', 'The Office Prank War', 'A prank war at the office goes hilariously out of control.', 'comedy_central_s1e5.mp4', 12, 1, 5, '00:31:00', 'comedy_central_s1e5_thumbnail.jpg');

-- Comedy Central Season 2 episodes
INSERT INTO Content (content_type, title, description, content_url, series_id, season_number, episode_number, duration, thumbnail_url)
VALUES ('Episode', 'The Wedding Disaster', 'A series of hilarious mishaps unfold at a friend`s wedding.', 'comedy_central_s2e1.mp4', 12, 2, 1, '00:33:00', 'comedy_central_s2e1_thumbnail.jpg'),
       ('Episode', 'The Unlucky Vacation', 'A vacation filled with comical misfortunes becomes a trip to remember.', 'comedy_central_s2e2.mp4', 12, 2, 2, '00:34:00', 'comedy_central_s2e2_thumbnail.jpg'),
       ('Episode', 'The Cooking Catastrophe', 'An attempt at a fancy dinner party ends in a culinary disaster.', 'comedy_central_s2e3.mp4', 12, 2, 3, '00:30:00', 'comedy_central_s2e3_thumbnail.jpg'),
       ('Episode', 'The Babysitting Fiasco', 'Babysitting for a neighbor takes a hilariously chaotic turn.', 'comedy_central_s2e4.mp4', 12, 2, 4, '00:28:00', 'comedy_central_s2e4_thumbnail.jpg'),
       ('Episode', 'The Unexpected Reunion', 'An impromptu high school reunion results in side-splitting scenarios.', 'comedy_central_s2e5.mp4', 12, 2, 5, '00:32:00', 'comedy_central_s2e5_thumbnail.jpg');

-- Insert Films
-- (title, content_url, description, duration, thumbnail_url)
INSERT INTO Content (content_type, title, content_url, description, duration, thumbnail_url)
VALUES
    ('Film', 'The Journey Home', 'https://contenturl.com/thejourneyhome', 'A heartwarming tale about a lost dog and his adventures trying to find his way back home', '01:45:00', 'https://thumbnailurl.com/thejourneyhome'),
    ('Film', 'The Last Chance', 'https://contenturl.com/thelastchance', 'A drama about a struggling musician who gets one last shot at making it big', '02:15:00', 'https://thumbnailurl.com/thelastchance'),
    ('Film', 'The Great Escape', 'https://contenturl.com/thegreatescape', 'A thriller about a group of prisoners who try to escape from a maximum security prison', '02:30:00', 'https://thumbnailurl.com/thegreatescape'),
    ('Film', 'The Secret Garden', 'https://contenturl.com/thesecretgarden', 'An enchanting story about a young girl who discovers a magical garden', '01:50:00', 'https://thumbnailurl.com/thesecretgarden'),
    ('Film', 'The Lost City', 'https://contenturl.com/thelostcity', 'An adventure film about a group of explorers who search for a lost city in the jungle', '02:20:00', 'https://thumbnailurl.com/thelostcity'),
    ('Film', 'The Perfect Match', 'https://contenturl.com/theperfectmatch', 'A romantic comedy about a couple who are perfect for each other, but can`t seem to get together', '01:55:00', 'https://thumbnailurl.com/theperfectmatch'),
    ('Film', 'The Art of Deception', 'https://contenturl.com/theartofdeception', 'A crime thriller about a master thief who pulls off a daring heist', '02:10:00', 'https://thumbnailurl.com/theartofdeception'),
    ('Film', 'The Price of Freedom', 'https://contenturl.com/thepriceoffreedom', 'A historical drama about the struggle for independence in a fictional country', '02:25:00', 'https://thumbnailurl.com/thepriceoffreedom'),
    ('Film', 'The Road Less Traveled', 'https://contenturl.com/theroadlesstraveled', 'A coming-of-age story about a young woman who goes on a road trip to find herself', '01:40:00', 'https://thumbnailurl.com/theroadlesstraveled'),
    ('Film', 'The Final Countdown', 'https://contenturl.com/thefinalcountdown', 'A science fiction film about a group of time travelers who go back in time to prevent a disaster', '02:05:00', 'https://thumbnailurl.com/thefinalcountdown'),
    ('Film', 'The Dark Forest', 'https://contenturl.com/thedarkforest', 'A horror movie about a group of friends who get lost in a mysterious forest', '01:55:00', 'https://thumbnailurl.com/thedarkforest'),
    ('Film', 'The Long Goodbye', 'https://contenturl.com/thelonggoodbye', 'A film noir about a private detective who gets involved in a complex case', '02:20:00', 'https://thumbnailurl.com/thelonggoodbye'),
    ('Film', 'The Secret Agent', 'https://contenturl.com/thesecretagent', 'An espionage thriller about a spy who tries to prevent a terrorist attack', '02:15:00', 'https://thumbnailurl.com/thesecretagent'),
    ('Film', 'The Other Side', 'https://contenturl.com/theotherside', 'A supernatural thriller about a couple who moves into a haunted house', '01:50:00', 'https://thumbnailurl.com/theotherside'),
    ('Film', 'The Last Stand', 'https://contenturl.com/thelaststand', 'An action-packed film about a sheriff who must protect his town from a dangerous gang', '02:00:00', 'https://thumbnailurl.com/thelaststand'),
    ('Film', 'The Great Unknown', 'https://contenturl.com/thegreatunknown', 'A mystery film about a woman who wakes up with no memory and must unravel the truth about her past', '02:10:00', 'https://thumbnailurl.com/thegreatunknown'),
    ('Film', 'The Final Showdown', 'https://contenturl.com/thefinalshowdown', 'A western about two rival cowboys who face off in a high-stakes duel', '01:45:00', 'https://thumbnailurl.com/thefinalshowdown'),
    ('Film', 'The Perfect Heist', 'https://contenturl.com/theperfectheist', 'A thriller about a group of thieves who plan the perfect robbery', '02:20:00', 'https://thumbnailurl.com/theperfectheist');

-- Insert into Categories
insert into Categories (title)
values
    ('Action'),
    ('Adventure'),
    ('Comedy'),
    ('Drama'),
    ('Fantasy'),
    ('Horror'),
    ('Mystery'),
    ('Romance'),
    ('Sci-Fi'),
    ('Thriller'),
    ('2D Animation'),
    ('3D Animation'),
    ('2D + 3D Animation'),
    ('Blender Animation'),
    ('Animation'),
    ('Anime'),
    ('Family'),
    ('Superhero'),
    ('Musical'),
    ('Animated Series'),
    ('Children'),
    ('Classics'),
    ('Coming of Age'),
    ('Crime'),
    ('Documentary'),
    ('Epics'),
    ('Family-Friendly'),
    ('Historical'),
    ('Holiday'),
    ('Independent'),
    ('Music'),
    ('Period Pieces'),
    ('Political'),
    ('Sports');

insert into ContentCategory (content_id, category_id)
values
    (8, 7), -- Mystery Tales belongs to Mystery category
    (9, 9), -- Sci-Fi Chronicles belongs to Sci-Fi category
    (10, 2), -- Adventure Island belongs to Adventure category
    (11, 4), -- Drama Diaries belongs to Drama category
    (12, 3), -- Comedy Corner belongs to Comedy category
    (8, 12), -- Mystery Tales belongs to Animation category
    (9, 12), -- Sci-Fi Chronicles belongs to Animation category
    (10, 12), -- Adventure Island belongs to Animation category
    (11, 12), -- Drama Diaries belongs to Animation category
    (12, 12); -- Comedy Corner belongs to Animation category

-- Films
insert into ContentCategory (content_id, category_id)
values
    (63, 7), -- The Journey Home belongs to Mystery category
    (64, 4), -- The Last Chance belongs to Drama category
    (65, 1), -- The Great Escape belongs to Action category
    (66, 5), -- The Secret Garden belongs to Fantasy category
    (67, 2), -- The Lost City belongs to Adventure category
    (68, 3), -- The Perfect Match belongs to Comedy category
    (69, 11), -- The Art of Deception belongs to 2D Animation category
    (70, 9), -- The Price of Freedom belongs to Sci-Fi category
    (71, 12), -- The Road Less Traveled belongs to Animation category
    (72, 9), -- The Final Countdown belongs to Sci-Fi category
    (73, 6), -- The Dark Forest belongs to Horror category
    (74, 4), -- The Long Goodbye belongs to Drama category
    (75, 6), -- The Secret Agent belongs to Horror category
    (76, 11), -- The Other Side belongs to 2D Animation category
    (77, 1), -- The Last Stand belongs to Action category
    (78, 7), -- The Great Unknown belongs to Mystery category
    (79, 1), -- The Final Showdown belongs to Action category
    (80, 10), -- The Perfect Heist belongs to Thriller category
    (63, 18), -- The Journey Home belongs to Thriller category
    (64, 15), -- The Last Chance belongs to Animated Series category
    (65, 17), -- The Great Escape belongs to Superhero category
    (66, 12), -- The Secret Garden belongs to Animation category
    (67, 16), -- The Lost City belongs to Children category
    (68, 13), -- The Perfect Match belongs to Family category
    (69, 14), -- The Art of Deception belongs to Blender Animation category
    (70, 18), -- The Price of Freedom belongs to Thriller category
    (71, 13), -- The Road Less Traveled belongs to Family category
    (72, 17), -- The Final Countdown belongs to Superhero category
    (74, 14), -- The Long Goodbye belongs to 3D Animation category
    (75, 17) -- The Secret Agent belongs to Superhero category

select * from Accounts where account_type = 'user'

select * from Categories order by category_id

-- Insert into UserInterests
insert into UserInterests (account_id, category_id)
values (3, 34), (3, 33), (3, 32),
       (4, 31), (4, 30), (4, 29),
       (5, 28), (5, 27), (5, 26),
       (6, 25), (6, 24), (6, 23),
       (7, 22), (7, 21), (7, 20),
       (8, 19), (8, 18), (8, 17),
       (9, 16), (9, 15), (9, 14),
       (10, 13), (10, 12), (10, 11),
       (11, 10), (11, 9), (11, 8),
       (12, 7), (12, 6), (12, 5),
       (13, 4), (13, 3), (13, 2),
       (14, 1), (14, 34), (14, 33),
       (15, 32), (15, 31), (15, 30),
       (16, 29), (16, 28), (16, 27),
       (17, 26), (17, 25), (17, 24)

-- Insert into Post
insert into Post (creator_id, title, content)
values
    (18, 'My Animation Journey', 'Sharing my experiences and lessons learned throughout my animation journey.'),
    (19, 'Storyboarding Techniques', 'Exploring various storyboarding techniques to enhance your animation projects.'),
    (20, '2D Animation Tips', 'A collection of tips and tricks for 2D animators.'),
    (21, '3D Modeling Essentials', 'Learn the essentials of 3D modeling for animation and visual effects.'),
    (22, 'Character Design Inspiration', 'A showcase of inspiring character designs for animation.'),
    (23, 'Indie Film Distribution', 'A guide to distributing your independent film and reaching a wider audience.'),
    (24, 'Sound Design for Animation', 'Understanding the importance of sound design in animation and how to get started.'),
    (25, 'Stop Motion Animation', 'Exploring the world of stop motion animation and how to create your own.'),
    (26, 'Visual Effects Breakdowns', 'A behind-the-scenes look at visual effects in animation and film.'),
    (27, 'Writing for Animation', 'Developing engaging stories and scripts for animated projects.'),
    (28, 'Color Theory in Animation', 'An in-depth look at the use of color theory in animation.'),
    (29, 'Freelance Animation Business', 'Tips for starting and managing a freelance animation business.'),
    (30, 'Animating with Blender', 'A guide to creating animations using the open-source software Blender.'),
    (31, 'Motion Graphics Techniques', 'Expand your animation skills with these motion graphics techniques.'),
    (32, 'Indie Film Funding', 'A guide to finding and securing funding for your independent film projects.'),
    (18, 'Animation Portfolio Tips', 'How to build a strong animation portfolio to showcase your skills and attract clients.'),
    (19, 'Background Design in Animation', 'Discover the importance of background design in animation and how to create engaging environments.'),
    (20, '2D Rigging in After Effects', 'A tutorial on 2D character rigging using After Effects and the Duik plugin.'),
    (21, '3D Animation Principles', 'An introduction to the 12 principles of animation as they apply to 3D animation.'),
    (22, 'Creating Memorable Characters', 'A guide to creating memorable and relatable characters for your animation projects.'),
    (23, 'Indie Film Marketing', 'Strategies for effectively marketing your independent film and building an audience.'),
    (24, 'Foley Art in Animation', 'An overview of foley art and how it can enhance the audio experience in animation.'),
    (25, 'Claymation Techniques', 'Learn the art of claymation and how to create your own stop-motion animated films using clay.'),
    (26, 'Compositing in Nuke', 'A beginner`s guide to compositing and visual effects using Nuke.'),
    (27, 'Adapting a Story for Animation', 'How to adapt an existing story or book into an animated project.'),
    (28, 'Lighting Techniques in Animation', 'Understanding the role of lighting in animation and how to create visually appealing scenes.'),
    (29, 'Managing Client Expectations', 'Tips for managing client expectations and building strong working relationships in freelance animation.'),
    (30, 'Texturing in Substance Painter', 'A tutorial on creating realistic textures for 3D models using Substance Painter.'),
    (31, 'Cinematic Typography', 'An exploration of typography in motion graphics and its impact on storytelling.'),
    (32, 'Crowdfunding for Indie Films', 'A guide to using crowdfunding platforms to fund your independent film projects.');

insert into Follows (user_id, creator_id)
values
    (3, 18),
    (3, 19),
    (3, 20),
    (4, 18),
    (4, 21),
    (4, 22),
    (5, 19),
    (5, 23),
    (5, 24),
    (6, 20),
    (6, 25),
    (6, 26),
    (7, 21),
    (7, 27),
    (7, 28),
    (8, 22),
    (8, 29),
    (8, 30),
    (9, 23),
    (9, 31),
    (9, 32),
    (10, 24),
    (10, 18),
    (10, 19),
    (11, 25),
    (11, 20),
    (11, 21),
    (12, 26),
    (12, 22),
    (12, 23),
    (13, 27),
    (13, 24),
    (13, 25),
    (14, 28),
    (14, 26),
    (14, 27),
    (15, 28),
    (15, 29),
    (16, 30),
    (16, 31),
    (17, 31),
    (17, 32),
    (17, 18);

insert into CreatorFollows (creator_followed, creator_follower)
values
    (18, 19),
    (18, 20),
    (18, 21),
    (19, 18),
    (19, 22),
    (20, 18),
    (20, 19),
    (20, 23),
    (21, 18),
    (21, 22),
    (21, 24),
    (22, 19),
    (22, 21),
    (22, 25),
    (23, 20),
    (23, 26),
    (24, 21),
    (24, 27),
    (25, 22),
    (25, 28),
    (26, 23),
    (26, 29),
    (27, 24),
    (27, 30),
    (28, 25),
    (28, 31),
    (29, 26),
    (29, 32),
    (30, 27),
    (30, 31),
    (31, 28),
    (31, 30),
    (32, 29),
    (32, 31);

select * from Content
select * from Accounts where account_type = 'user'
-- Insert into WatchList
insert into WatchList (account_id, content_id) values
    (3, 20),
    (3, 30),
    (3, 58),
    (3, 76),
    (4, 15),
    (4, 29),
    (4, 35),
    (4, 63),
    (4, 70),
    (5, 12),
    (5, 38),
    (5, 41),
    (5, 58),
    (6, 26),
    (6, 37),
    (6, 50),
    (6, 69),
    (6, 75),
    (7, 10),
    (7, 19),
    (7, 33),
    (7, 47),
    (7, 56),
    (7, 67),
    (8, 18),
    (8, 23),
    (8, 42),
    (8, 55),
    (8, 64),
    (8, 78),
    (9, 16),
    (9, 31),
    (9, 45),
    (9, 60),
    (9, 72),
    (10, 11),
    (10, 26),
    (10, 39),
    (10, 55),
    (10, 65),
    (10, 79),
    (11, 17),
    (11, 28),
    (11, 41),
    (11, 53),
    (11, 64),
    (11, 73),
    (12, 15),
    (12, 30),
    (12, 46),
    (12, 57),
    (12, 69),
    (12, 80),
    (13, 9),
    (13, 21),
    (13, 34),
    (13, 50),
    (13, 62),
    (13, 74),
    (14, 13),
    (14, 27),
    (14, 39),
    (14, 53),
    (14, 66),
    (14, 78),
    (15, 10),
    (15, 22),
    (15, 36),
    (15, 51),
    (15, 64),
    (15, 77),
    (16, 11),
    (16, 25),
    (16, 37),
    (16, 49),
    (16, 61),
    (16, 73),
    (16, 80),
    (17, 12),
    (17, 24),
    (17, 36),
    (17, 48),
    (17, 59),
    (17, 70),
    (17, 80);

-- Insert Into ContentCollaborators
select * from Content where content_type = 'Film'
select * from Content where content_type = 'Series'
select title from Content where content_type = 'Episode'
select * from Creators
select * from Season

INSERT INTO ContentCollaborators (creator_id, content_id, role)
VALUES
-- Series type of content (content_id: 8 to 12)
(18, 8, 'Animation Director'),
(19, 8, 'Storyboard Artist'),
(20, 8, 'Character Designer'),
(21, 9, 'Animation Supervisor'),
(22, 9, 'Background Artist'),
(23, 9, 'Animator'),
(24, 10, 'Visual Effects Artist'),
(25, 10, 'Sound Designer'),
(26, 10, 'Editor'),
(27, 11, 'Writer'),
(28, 11, 'Composer'),
(29, 11, 'Voice Actor'),
(30, 12, 'Producer'),
(31, 12, 'Cinematographer'),
(32, 12, 'Production Designer'),

-- Film type of content (content_id: 63 to 80)
(18, 63, 'Animation Director'),
(19, 63, 'Storyboard Artist'),
(20, 63, 'Character Designer'),
(21, 64, 'Animation Supervisor'),
(22, 64, 'Background Artist'),
(23, 64, 'Animator'),
(24, 65, 'Visual Effects Artist'),
(25, 65, 'Sound Designer'),
(26, 65, 'Editor'),
(27, 66, 'Writer'),
(28, 66, 'Composer'),
(29, 66, 'Voice Actor'),
(30, 67, 'Producer'),
(31, 67, 'Cinematographer'),
(32, 67, 'Production Designer'),
(18, 68, 'Animation Director'),
(19, 68, 'Storyboard Artist'),
(20, 68, 'Character Designer'),
(21, 69, 'Animation Supervisor'),
(22, 69, 'Background Artist'),
(23, 69, 'Animator'),
(24, 70, 'Visual Effects Artist'),
(25, 70, 'Sound Designer'),
(26, 70, 'Editor'),
(27, 71, 'Writer'),
(28, 71, 'Composer'),
(29, 71, 'Voice Actor'),
(30, 72, 'Producer'),
(31, 72, 'Cinematographer'),
(32, 72, 'Production Designer'),
(18, 73, 'Animation Director'),
(19, 73, 'Storyboard Artist'),
(20, 73, 'Character Designer'),
(21, 74, 'Animation Supervisor'),
(22, 74, 'Background Artist'),
(23, 74, 'Animator'),
(24, 75, 'Visual Effects Artist'),
(25, 75, 'Sound Designer'),
(26, 75, 'Editor'),
(27, 76, 'Writer'),
(28, 76, 'Composer'),
(29, 76, 'Voice Actor'),
(30, 77, 'Producer'),
(31, 77, 'Cinematographer'),
(32, 77, 'Production Designer'),
(18, 78, 'Animation Director'),
(19, 78, 'Storyboard Artist'),
(20, 78, 'Character Designer'),
(21, 79, 'Animation Supervisor'),
(22, 79, 'Background Artist'),
(23, 79, 'Animator'),
(24, 80, 'Visual Effects Artist'),
(25, 80, 'Sound Designer'),
(26, 80, 'Editor'),

-- Episodes of content (content_id: 13 to 62)
(18, 13, 'Animation Director'),
(19, 13, 'Storyboard Artist'),
(20, 13, 'Character Designer'),
(21, 14, 'Animation Supervisor'),
(22, 14, 'Background Artist'),
(23, 14, 'Animator'),
(24, 15, 'Visual Effects Artist'),
(25, 15, 'Sound Designer'),
(26, 15, 'Editor'),
(27, 16, 'Writer'),
(28, 16, 'Composer'),
(29, 16, 'Voice Actor'),
(30, 17, 'Producer'),
(31, 17, 'Cinematographer'),
(32, 17, 'Production Designer'),
(18, 18, 'Animation Director'),
(19, 18, 'Storyboard Artist'),
(20, 18, 'Character Designer'),
(21, 19, 'Animation Supervisor'),
(22, 19, 'Background Artist'),
(23, 19, 'Animator'),
(24, 20, 'Visual Effects Artist'),
(25, 20, 'Sound Designer'),
(26, 20, 'Editor'),
(27, 21, 'Writer'),
(28, 21, 'Composer'),
(29, 21, 'Voice Actor'),
(30, 22, 'Producer'),
(31, 22, 'Cinematographer'),
(32, 22, 'Production Designer'),
(18, 23, 'Animation Director'),
(19, 23, 'Storyboard Artist'),
(20, 23, 'Character Designer'),
(21, 24, 'Animation Supervisor'),
(22, 24, 'Background Artist'),
(23, 24, 'Animator'),
(24, 25, 'Visual Effects Artist'),
(25, 25, 'Sound Designer'),
(26, 25, 'Editor'),
(27, 26, 'Writer'),
(28, 26, 'Composer'),
(29, 26, 'Voice Actor'),
(30, 27, 'Producer'),
(31, 27, 'Cinematographer'),
(32, 27, 'Production Designer'),
(18, 28, 'Animation Director'),
(19, 28, 'Storyboard Artist'),
(20, 28, 'Character Designer'),
(21, 29, 'Animation Supervisor'),
(22, 29, 'Background Artist'),
(23, 29, 'Animator'),
(24, 30, 'Visual Effects Artist'),
(25, 30, 'Sound Designer'),
(26, 30, 'Editor'),
(27, 31, 'Writer'),
(28, 31, 'Composer'),
(29, 31, 'Voice Actor'),
(30, 32, 'Producer'),
(31, 32, 'Cinematographer'),
(32, 32, 'Production Designer'),
(18, 33, 'Animation Director'),
(19, 33, 'Storyboard Artist'),
(20, 33, 'Character Designer'),
(21, 34, 'Animation Supervisor'),
(22, 34, 'Background Artist'),
(23, 34, 'Animator'),
(24, 35, 'Visual Effects Artist'),
(25, 35, 'Sound Designer'),
(26, 35, 'Editor'),
(27, 36, 'Writer'),
(28, 36, 'Composer'),
(29, 36, 'Voice Actor'),
(30, 37, 'Producer'),
(31, 37, 'Cinematographer'),
(32, 37, 'Production Designer'),
(18, 38, 'Animation Director'),
(19, 38, 'Storyboard Artist'),
(20, 38, 'Character Designer'),
(21, 39, 'Animation Supervisor'),
(22, 39, 'Background Artist'),
(23, 39, 'Animator'),
(24, 40, 'Visual Effects Artist'),
(25, 40, 'Sound Designer'),
(26, 40, 'Editor'),
(27, 41, 'Writer'),
(28, 41, 'Composer'),
(29, 41, 'Voice Actor'),
(30, 42, 'Producer'),
(31, 42, 'Cinematographer'),
(32, 42, 'Production Designer'),
(18, 43, 'Animation Director'),
(19, 43, 'Storyboard Artist'),
(20, 43, 'Character Designer'),
(21, 44, 'Animation Supervisor'),
(22, 44, 'Background Artist'),
(23, 44, 'Animator'),
(24, 45, 'Visual Effects Artist'),
(25, 45, 'Sound Designer'),
(26, 45, 'Editor'),
(27, 46, 'Writer'),
(28, 46, 'Composer'),
(29, 46, 'Voice Actor'),
(30, 47, 'Producer'),
(31, 47, 'Cinematographer'),
(32, 47, 'Production Designer'),
(18, 48, 'Animation Director'),
(19, 48, 'Storyboard Artist'),
(20, 48, 'Character Designer'),
(21, 49, 'Animation Supervisor'),
(22, 49, 'Background Artist'),
(23, 49, 'Animator'),
(24, 50, 'Visual Effects Artist'),
(25, 50, 'Sound Designer'),
(26, 50, 'Editor'),
(27, 51, 'Writer'),
(28, 51, 'Composer'),
(29, 51, 'Voice Actor'),
(30, 52, 'Producer'),
(31, 52, 'Cinematographer'),
(32, 52, 'Production Designer'),
(18, 53, 'Animation Director'),
(19, 53, 'Storyboard Artist'),
(20, 53, 'Character Designer'),
(21, 54, 'Animation Supervisor'),
(22, 54, 'Background Artist'),
(23, 54, 'Animator'),
(24, 55, 'Visual Effects Artist'),
(25, 55, 'Sound Designer'),
(26, 55, 'Editor'),
(27, 56, 'Writer'),
(28, 56, 'Composer'),
(29, 56, 'Voice Actor'),
(30, 57, 'Producer'),
(31, 57, 'Cinematographer'),
(32, 57, 'Production Designer'),
(18, 58, 'Animation Director'),
(19, 58, 'Storyboard Artist'),
(20, 58, 'Character Designer'),
(21, 59, 'Animation Supervisor'),
(22, 59, 'Background Artist'),
(23, 59, 'Animator'),
(24, 60, 'Visual Effects Artist'),
(25, 60, 'Sound Designer'),
(26, 60, 'Editor'),
(27, 61, 'Writer'),
(28, 61, 'Composer'),
(29, 61, 'Voice Actor'),
(30, 62, 'Producer'),
(31, 62, 'Cinematographer'),
(32, 62, 'Production Designer');

select * from Content where content_type = 'Episode'
select * from Accounts where account_type = 'user'

-- Series Reviews
insert into Review (title, content, rating, content_id, account_id)
values
    ('Amazing Series', 'I loved every moment of it. The storyline was captivating, and the characters were so well-developed.', 10, 8, 3),
    ('Decent Series', 'It was a decent watch, but some episodes felt slow.', 7, 8, 4),
    ('Captivating Story', 'The plot kept me hooked from beginning to end. Excellent storytelling.', 9, 9, 5),
    ('A bit overrated', 'I think the series is good but not as great as everyone says.', 6, 9, 6),
    ('Emotional Rollercoaster', 'This series took me on an emotional journey, and I loved it.', 9, 10, 7),
    ('Good, but not great', 'I enjoyed watching it, but I wouldn`t watch it again.', 6, 10, 8),
    ('Amazing Animation', 'The animation and art style in this series are simply stunning.', 8, 11, 9),
    ('Great character development', 'I loved how the characters grew throughout the series.', 9, 11, 10),
    ('A must-watch', 'Absolutely loved it! Highly recommended for everyone.', 10, 12, 11),
    ('Interesting concept', 'The concept of the series is unique, and it kept me interested.', 8, 12, 12);

-- Film Reviews
insert into Review (title, content, rating, content_id, account_id)
values ('Amazing journey', 'I loved every minute of The Journey Home. The animation and story were superb!', 9, 68, 3),
    ('Heartwarming', 'The Journey Home really tugged at my heartstrings. A must-watch for dog lovers.', 8, 69, 4),
    ('Incredible performance', 'The acting in The Last Chance was top-notch, and the story kept me engaged.', 9, 70, 5),
    ('Stunning visuals', 'The Great Escape had me on the edge of my seat the entire time! Fantastic cinematography.', 10, 71, 6),
    ('Magical and delightful', 'The Secret Garden is a beautiful film that can be enjoyed by the whole family.', 8, 72, 7),
    ('A thrilling adventure', 'The Lost City is a perfect blend of action, adventure, and mystery. Highly recommended.', 9, 73, 8),
    ('Hilarious and heartwarming', 'The Perfect Match is a feel-good movie with a great cast and a charming story.', 8, 74, 9),
    ('Suspenseful and well-written', 'The Art of Deception kept me guessing until the end. Fantastic plot!', 9, 75, 10),
    ('Powerful and moving', 'The Price of Freedom is a beautifully crafted film that tells a compelling story.', 10, 76, 11),
    ('Thought-provoking', 'The Road Less Traveled is a relatable and inspiring coming-of-age tale.', 8, 77, 12),
    ('Innovative sci-fi', 'The Final Countdown is a thrilling time-travel adventure with a great cast and an engaging story.', 9, 78, 13),
    ('Terrifying and atmospheric', 'The Dark Forest is a chilling horror film that will keep you on the edge of your seat.', 8, 79, 14),
    ('A stylish noir', 'The Long Goodbye is a captivating detective story with a great atmosphere and a gripping plot.', 9, 80, 15),
    ('Action-packed and suspenseful', 'The Secret Agent is a well-crafted espionage thriller that keeps you hooked.', 8, 81, 16),
    ('Spooky and well-acted', 'The Other Side is a great supernatural thriller with a strong cast and a creepy atmosphere.', 7, 82, 17),
    ('Non-stop action', 'The Last Stand is an adrenaline-fueled thrill ride with plenty of intense action sequences.', 8, 83, 3),
    ('A gripping mystery', 'The Great Unknown is a fascinating mystery film that keeps you guessing until the very end.', 9, 84, 4),
    ('Intense and suspenseful', 'The Final Showdown is a gritty western with a memorable duel and a riveting story.', 8, 85, 5),
    ('Clever and thrilling', 'The Perfect Heist is an exciting thriller with a well-thought-out plot and a great cast.', 9, 85, 6);

-- Episode Reviews
insert into Review (title, content, rating, content_id, account_id)
values ('A strong start', 'The first episode really sets the stage for an amazing series.', 9, 13, 3),
    ('Not bad', 'This episode was a little slow, but it was still enjoyable.', 7, 14, 4),
    ('Unexpected twist', 'The twist in this episode caught me off guard. Loved it!', 9, 15, 5),
    ('Good character development', 'This episode focused on character development, which I appreciated.', 8, 16, 6),
    ('Intense action', 'The action in this episode was non-stop, making it a thrilling watch.', 9, 17, 7),
    ('A little boring', 'I found this episode to be a bit dull and slow-paced.', 5, 18, 8),
    ('Emotionally charged', 'This episode had me in tears by the end. Beautifully done.', 10, 19, 9),
    ('An important episode', 'This episode delves deeper into the series main themes, making it a must-watch.', 8, 20, 10),
    ('Great humor', 'This episode was hilarious and light-hearted, a nice break from the heavier content.', 9, 21, 11),
    ('Exciting cliffhanger', 'The episode ends on a high note, leaving you wanting more.', 8, 22, 12),
    ('Solid storyline', 'The plot continues to thicken, and I am eager to see what happens next.', 8, 23, 13),
    ('Nice character growth', 'Character development continues to be a strong point in this series.', 7, 24, 14),
    ('Surprising reveal', 'The big reveal in this episode was a game changer!', 10, 25, 15),
    ('Intriguing mystery', 'This episode presents a new mystery that keeps viewers hooked.', 8, 26, 16),
    ('Suspenseful episode', 'The tension builds up throughout the episode, making it exciting to watch.', 9, 27, 17),
    ('Entertaining and funny', 'This episode offered a good mix of humor and drama.', 8, 28, 3),
    ('Thought-provoking themes', 'The themes explored in this episode were deep and thought-provoking.', 9, 29, 4),
    ('Interesting character arcs', 'The characters continue to evolve in interesting ways.', 7, 30, 5),
    ('Plot twist', 'This episode included a plot twist I did not see coming!', 8, 31, 6),
    ('Action-packed', 'A fast-paced episode with lots of action sequences.', 9, 32, 7),
    ('A bit slow', 'The pacing was a bit slow, but it was still an enjoyable episode.', 6, 33, 8),
    ('Heartfelt moments', 'This episode included emotional scenes that tugged at my heartstrings.', 9, 34, 9),
    ('Dramatic tension', 'The drama and tension in this episode kept me engaged throughout.', 8, 35, 10),
    ('Humorous interlude', 'A lighthearted episode that provided some much-needed comic relief.', 7, 36, 11),
    ('Gripping cliffhanger', 'This episode leaves you on the edge of your seat, eager for the next installment.', 9, 37, 12),
    ('Engaging storyline', 'The plot thickens and becomes even more captivating in this episode.', 8, 38, 13),
    ('Excellent character development', 'This episode does an excellent job of developing its characters.', 8, 39, 14),
    ('Unexpected turn', 'A surprising turn of events left me eager for more.', 9, 40, 15),
    ('Intricate plot', 'The plot becomes more complex, making for a captivating watch.', 8, 41, 16),
    ('Tense episode', 'The suspense in this episode had me on the edge of my seat.', 9, 42, 17),
    ('Entertaining and well-paced', 'This episode was well-paced and enjoyable from start to finish.', 8, 43, 3),
    ('Deep themes explored', 'I appreciated the thought-provoking themes presented in this episode.', 9, 44, 4),
    ('Interesting character dynamics', 'The evolving character relationships kept me engaged.', 7, 45, 5),
    ('Shocking twist', 'I did not see the twist in this episode coming!', 9, 46, 6),
    ('Action and excitement', 'This episode was filled with exciting action scenes.', 8, 47, 7),
    ('A bit of a letdown', 'This episode was not as strong as previous ones, but still had its moments.', 6, 48, 8),
    ('Emotional impact', 'This episode was emotionally charged and left a lasting impression.', 10, 49, 9),
    ('Drama and intrigue', 'The dramatic tension in this episode kept me hooked.', 8, 50, 10),
    ('Comic relief', 'A funny episode that provided a nice break from the drama.', 7, 51, 11),
    ('Edge-of-your-seat suspense', 'A suspenseful episode that had me eagerly anticipating the next one.', 9, 52, 12),
    ('Compelling story', 'The storyline continues to captivate and draw me in.', 8, 53, 13),
    ('Strong character arcs', 'The character development in this episode was top-notch.', 8, 54, 14),
    ('Unforeseen events', 'This episode was full of surprising and unexpected developments.', 9, 55, 15),
    ('Complex narrative', 'The narrative becomes more intricate, making for a riveting watch.', 8, 56, 16),
    ('Nail-biting tension', 'This episode was full of suspense and kept me on the edge of my seat.', 9, 57, 17),
    ('Engaging and well-paced', 'A well-paced episode that kept my attention throughout.', 8, 58, 3),
    ('Provocative themes', 'Thought-provoking themes were explored in this episode.', 9, 59, 4),
    ('Fascinating character interactions', 'The evolving character dynamics in this episode were intriguing.', 7, 60, 5),
    ('Unexpected plot twist', 'This episode featured a shocking twist I didn`t see coming!', 9, 61, 6),
    ('Action-packed excitement', 'This episode was full of thrilling action sequences.', 8, 62, 7),
    ('Somewhat disappointing', 'This episode didn`t quite live up to my expectations, but it had its moments.', 6, 63, 8),
    ('Emotionally powerful', 'This episode was incredibly moving and left a lasting impact.', 10, 64, 9),
    ('Dramatic and engaging', 'The drama in this episode kept me thoroughly engaged.', 8, 65, 10),
    ('Light-hearted and funny', 'A humorous episode that provided some much-needed comic relief.', 7, 66, 11),
    ('Suspenseful and thrilling', 'This episode had me on the edge of my seat, eager for the next installment.', 9, 67, 12);

-- Insert into Transactions
insert into Transactions (account_id, amount, currency, status, created_at)
values (3, 9, 'USD', 'CO', '2023-05-01 12:00:00'),
    (4, 9, 'USD', 'CO', '2023-05-02 10:30:00'),
    (5, 9, 'USD', 'PE', '2023-05-03 14:15:00'),
    (6, 9, 'USD', 'FA', '2023-05-04 16:45:00'),
    (7, 9, 'USD', 'CO', '2023-05-05 18:20:00'),
    (8, 8.04, 'EUR', 'CO', '2023-05-06 11:00:00'),
    (9, 8.04, 'EUR', 'CO', '2023-05-07 09:45:00'),
    (10, 8.04, 'EUR', 'CO', '2023-05-08 08:30:00'),
    (11, 8.04, 'EUR', 'CO', '2023-05-09 07:15:00'),
    (12, 8.04, 'EUR', 'CO', '2023-05-10 13:00:00'),
    (13, 8.04, 'EUR', 'PE', '2023-05-11 15:30:00'),
    (14, 8.04, 'EUR', 'RE', '2023-05-12 14:00:00'),
    (15, 60.86, 'DKK', 'CO', '2023-05-13 11:45:00'),
    (16, 8.04, 'EUR', 'CO', '2023-05-14 10:15:00'),
    (17, 8.04, 'EUR', 'PE', '2023-05-15 12:30:00'),
	(3, 1.00, 'USD', 'PE', '2023-05-01 12:00:00'),
    (4, 299.50, 'USD', 'CO', '2023-05-02 10:30:00'),
    (5, 34.00, 'USD', 'CO', '2023-05-03 14:15:00'),
    (6, 100.00, 'USD', 'CO', '2023-05-04 16:45:00'),
    (7, 12.50, 'USD', 'CO', '2023-05-05 18:20:00'),
    (8, 166.00, 'EUR', 'FA', '2023-05-06 11:00:00'),
    (9, 36.00, 'EUR', 'CO', '2023-05-07 09:45:00'),
    (10, 23.00, 'EUR', 'CO', '2023-05-08 08:30:00'),
    (11, 17.00, 'EUR', 'PE', '2023-05-09 07:15:00'),
    (12, 8.00, 'EUR', 'CO', '2023-05-10 13:00:00'),
    (13, 100.00, 'EUR', 'PE', '2023-05-11 15:30:00'),
    (14, 3.00, 'EUR', 'CO', '2023-05-12 14:00:00'),
    (15, 14.50, 'DKK', 'CO', '2023-05-13 11:45:00'),
    (16, 367.00, 'EUR', 'CO', '2023-05-14 10:15:00'),
    (17, 2.00, 'EUR', 'PE', '2023-05-15 12:30:00')

-- Active subscriptions
insert into Subscription (account_id, transaction_id, is_active, auto_renewal) values
(3, 1, 1, 1),
(4, 2, 1, 1),
(5, 3, 1, 0),
(6, 4, 1, 0),
(7, 5, 1, 1),
(8, 6, 1, 1),
(9, 7, 1, 0)

-- Inactive subscriptions
insert into Subscription (account_id, transaction_id, last_billing_date, is_active, auto_renewal)
values
(11, 15, '2022-02-25 14:30:00', 0, 0),
(12, 16, '2022-01-01 10:15:00', 0, 0),
(13, 17, '2022-03-12 08:45:00', 0, 0),
(14, 18, '2022-04-05 12:00:00', 0, 0),
(15, 19, '2022-05-15 16:20:00', 0, 0),
(16, 20, '2022-07-01 11:30:00', 0, 0),
(17, 21, '2022-06-10 09:00:00', 0, 0)

INSERT INTO Address (country, city, state, postal_code)
VALUES ('United States', 'New York', 'New York', '10001'),
       ('United States', 'Los Angeles', 'California', '90001'),
       ('United States', 'Chicago', 'Illinois', '60601'),
       ('United States', 'Houston', 'Texas', '77001'),
       ('United States', 'Phoenix', 'Arizona', '85001'),
       ('United Kingdom', 'London', 'England', 'SW1A 1AA'),
       ('France', 'Paris', 'Île-de-France', '75001'),
       ('Germany', 'Berlin', 'Berlin', '10115'),
       ('Spain', 'Madrid', 'Madrid', '28001'),
       ('Italy', 'Rome', 'Lazio', '00100'),
       ('Netherlands', 'Amsterdam', 'North Holland', '1011 AA'),
       ('Belgium', 'Brussels', 'Brussels', '1000'),
       ('Ireland', 'Dublin', 'Leinster', 'D01 R2PO'),
       ('Sweden', 'Stockholm', 'Stockholm', '111 21'),
       ('Denmark', 'Copenhagen', 'Capital Region', '1050'),
       ('Poland', 'Warsaw', 'Masovian', '00-001'),
       ('Austria', 'Vienna', 'Vienna', '1010'),
       ('Switzerland', 'Zurich', 'Zurich', '8001'),
       ('Greece', 'Athens', 'Attica', '10431'),
       ('Norway', 'Oslo', 'Oslo', '0151'),
       ('Finland', 'Helsinki', 'Uusimaa', '00100'),
       ('Portugal', 'Lisbon', 'Lisbon', '1100-148'),
       ('Czech Republic', 'Prague', 'Prague', '110 00'),
       ('Hungary', 'Budapest', 'Central Hungary', '1011'),
       ('Slovakia', 'Bratislava', 'Bratislava', '811 01'),
       ('Slovenia', 'Ljubljana', 'Central Slovenia', '1000'),
       ('Croatia', 'Zagreb', 'City of Zagreb', '10000'),
       ('Bulgaria', 'Sofia', 'Sofia', '1000'),
       ('Romania', 'Bucharest', 'Bucharest', '010001'),
       ('Latvia', 'Riga', 'Riga', 'LV-1050'),
       ('Estonia', 'Tallinn', 'Harju', '10115');

INSERT INTO Billing (account_id, payment_type, card_last_digits, expiration, address_id)
VALUES (3, 'AE', '1234', '2024-12-31', 1),
       (4, 'VI', '5678', '2025-11-30', 2),
       (5, 'MA', '9012', '2026-10-31', 3),
       (6, 'DI', '3456', '2027-09-30', 4),
       (7, 'JC', '7890', '2028-08-31', 5),
       (8, 'DC', '1234', '2024-07-31', 6),
       (9, 'UN', '5678', '2025-06-30', 7),
       (10, 'PA', '9012', '2026-05-31', 8),
       (11, 'AP', '3456', '2027-04-30', 9),
       (12, 'GO', '7890', '2028-03-31', 10),
       (13, 'AL', '1234', '2024-02-28', 11),
       (14, 'WC', '5678', '2025-01-31', 12),
       (15, 'AE', '9012', '2026-12-31', 13),
       (16, 'VI', '3456', '2027-11-30', 14),
       (17, 'MA', '7890', '2028-10-31', 15),
       (18, 'DI', '1234', '2024-09-30', 16),
       (19, 'JC', '5678', '2025-08-31', 17),
       (20, 'DC', '9012', '2026-07-31', 18),
       (21, 'UN', '3456', '2027-06-30', 19),
       (22, 'PA', '7890', '2028-05-31', 20),
       (23, 'AP', '1234', '2024-04-30', 21),
       (24, 'GO', '5678', '2025-03-31', 22),
       (25, 'AL', '9012', '2026-02-28', 23),
       (26, 'WC', '3456', '2027-01-31', 24),
       (27, 'AE', '7890', '2028-12-31', 25),
       (28, 'VI', '1234', '2024-11-30', 26),
       (29, 'MA', '5678', '2025-10-31', 27),
       (30, 'DI', '9012', '2026-09-30', 28),
       (31, 'JC', '3456', '2027-08-31', 29),
       (32, 'DC', '7890', '2028-07-31', 30);

insert into Fundraising (creator_id, goal_amount, collected, title, description)
values
    (26, 7000.00, 120.00, 'Indie Film Production', 'Help us fund the production of our independent feature film that explores themes of love and identity in modern society.'),
    (19, 5000.00, 1500.00, 'Animation Short Film', 'Support our team of talented animators as we create a visually stunning short film that explores the beauty and complexity of the natural world.'),
    (28, 9000.00, 4300.00, 'Film Festival Submission Fees', 'We need your help to cover the submission fees for our independent film to various film festivals around the world.'),
    (30, 3000.00, 230.00, 'Stop-Motion Animation Series', 'Join us in creating a new stop-motion animation series that tells the story of a group of friends on a journey of self-discovery and adventure.')

-- All Selects to check
-- select * from Transactions
-- select * from Fundraising
-- select * from Subscription
-- select * from Billing
-- select * from Review
-- select * from Accounts
-- select * from Creators
-- select * from Follows
-- select * from CreatorFollows
-- select * from Post
-- select * from ContentCollaborators
-- select * from Content
-- select * from Season
-- select * from WatchList
-- select * from ContentCategory
-- select * from UserInterests
-- select * from Categories
-- select * from Address

-- Reports

-- 1. Select films, ranked by review ratings; and their creators
select dense_rank() over (order by avg(RF.rating*1.0) desc) Rank,
    C.content_id, C.title as Title, C.description as Description, avg(RF.rating*1.0) as Average_Rating
from Content C
join Review RF on C.content_id = RF.content_id
where content_type = 'Film'
group by C.content_id, C.title, C.description;

-- 3. Select ranked most discussed content, based on the number of reviews
with RankedByReviews as (
    select C.content_id C_id, count(*) ReviewCount
    from Content C
    join Review R2 on C.content_id = R2.content_id
    group by C.content_id
)
select
    dense_rank() over (order by ReviewCount desc) Rank,
    C_id, C.title, C.description, ReviewCount
from RankedByReviews
join Content C on C.content_id = C_id

-- 4. 