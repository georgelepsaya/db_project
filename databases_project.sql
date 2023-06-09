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

