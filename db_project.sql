-- Account table
CREATE TABLE Account (
	id integer identity(1, 1) not null,
	username NVARCHAR(30) UNIQUE not null,
	email NVARCHAR(30) UNIQUE not null,
	password NVARCHAR(50) not null,
	first_name NVARCHAR(20),
	last_name NVARCHAR(30),
	profile_image_url NVARCHAR(255),
	registered_at DATETIME NOT NULL DEFAULT(GETDATE()),
	last_login DATETIME NOT NULL DEFAULT(GETDATE()),
	primary key (id)
)

-- Users table
create table Users (
    account_id integer not null,
    notifications_enabled bit default 'TRUE',
    foreign key (account_id) references Account,
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

-- PaymentType table
create table PaymentType (
	id varchar(2) not null,
	name nvarchar(16) unique not null,
	primary key (id)
)

-- Codifier tables

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
('BRL','Brazilian real')

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
    foreign key (account_id) references Account,
    foreign key (payment_type) references PaymentType,
    primary key (id)
)

-- AccountLocation table
create table AccountLocation (
    account_id integer not null,
    address_id integer not null,
    foreign key (account_id) references Account,
    foreign key (address_id) references Address,
    primary key (account_id, address_id)
)

-- Transactions table
create table Transactions (
  id integer identity(1, 1) not null,
  user_id integer not null,
  amount decimal(6,2) not null,
  currency varchar(3) not null,
  status varchar(2) not null,
  created_at datetime not null default getdate(),
  foreign key (user_id) references Users,
  foreign key (currency) references Currency(ISO_code),
  foreign key (status) references Transaction_status(id),
  primary key (id)
  -- billing can be found through users
  -- payment type can be found through billing
)

-- TransactionCreators table (transaction from a user to a creator)
create table Transactions_Creators (
	id integer identity(1, 1) not null,
	transaction_id integer unique not null,
	creator_id integer not null,
	foreign key (transaction_id) references Transactions(id),
	foreign key (creator_id) references Creator,
	primary key (id)
)

-- Subscription table
create table Subscription (
	id integer identity(1, 1) not null,
	user_id integer unique not null,
	last_subscription datetime not null default getdate(),
	transaction_id integer unique not null,
	-- if there is no transaction, then this record won't exist
	-- however if user made a transaction in the past it'll be there, hence null for transaction_id
	is_active bit not null,
	auto_renewal bit not null,
	foreign key (user_id) references Users,
	foreign key (transaction_id) references Transactions,
	primary key (id)
)

-- Fundraising table
create table Fundraising (
  id integer identity(1, 1) not null,
  creator_id integer not null,
  goal_amount decimal(6,2) not null,
  title nvarchar(255) not null,
  description nvarchar(max) not null,
  published_at datetime not null default getdate(),
  foreign key (creator_id) references Creator,
  primary key (id)
  -- ? maybe the combination of goal amount and creator_id must be unique ?
)

-- TransactionFundraising
create table Transaction_Fundraising (
	id integer identity(1, 1) not null,
	transaction_id integer unique not null,
	fundraising_id integer not null,
	foreign key (transaction_id) references Transactions,
	foreign key (fundraising_id) references Fundraising,
	primary key (id),
)

-- Film table
create table Film (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    content_url varchar(255) not null,
    description nvarchar(max) not null,
    duration time not null,
    thumbnail_url varchar(255),
    created_at datetime not null default getdate(),
    primary key (id)
)

-- Episode table
create table Episode (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    description nvarchar(max) not null,
    content_url varchar(255) not null,
    number integer not null,
    season_id integer not null,
    duration time not null,
    thumbnail_url varchar(255),
    created_at datetime not null default getdate(),
    foreign key (season_id) references Season,
    primary key (id)
)

-- Series table
create table Series (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    description nvarchar(max) not null,
    thumbnail_url varchar(255),
    created_at datetime not null default getdate(),
    primary key (id)
)

-- Season table
create table Season (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    series_id integer not null,
    number integer not null,
    primary key (id),
    foreign key (series_id) references Series
)

-- LikesFilm table
create table LikesFilm (
    user_id integer not null,
    film_id integer not null,
    liked_at datetime not null default getdate(),
    foreign key (user_id) references Users,
    foreign key (film_id) references Film,
    primary key (user_id, film_id),
)

-- LikesEpisode table
create table LikesEpisode (
    user_id integer not null,
    episode_id integer not null,
    liked_at datetime not null default getdate(),
    foreign key (user_id) references Users,
    foreign key (episode_id) references Episode,
    primary key (user_id, episode_id)
)

-- LikesSeries table
create table LikesSeries (
    user_id integer not null,
    series_id integer not null,
    liked_at datetime not null default getdate(),
    foreign key (user_id) references Users,
    foreign key (series_id) references Series,
    primary key (user_id, series_id)
)

-- WatchesFilm table
create table WatchesFilm (
    user_id integer not null,
    film_id integer not null,
    watched_at datetime not null default getdate(),
    foreign key (user_id) references Users,
    foreign key (film_id) references Film,
    primary key (user_id, film_id)
)

-- WatchesEpisode table
create table WatchesEpisode (
    user_id integer not null,
    episode_id integer not null,
    watched_at datetime not null default getdate(),
    foreign key (user_id) references Users,
    foreign key (episode_id) references Episode,
    primary key (user_id, episode_id)
)

-- WatchesSeries table
create table WatchesSeries (
    user_id integer not null,
    series_id integer not null,
    watched_at datetime not null default getdate(),
    foreign key (user_id) references Users,
    foreign key (series_id) references Series,
    primary key (user_id, series_id)
)

-- Category table
create table Category (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null unique ,
    primary key (id)
)

-- SeriesCategory table
create table SeriesCategory (
    series_id integer not null,
    category_id integer not null,
    foreign key (series_id) references Series,
    foreign key (category_id) references Category,
    primary key (series_id, category_id)
)

-- FilmCategory table
create table FilmCategory (
    film_id integer not null,
    category_id integer not null,
    foreign key (film_id) references Film,
    foreign key (category_id) references Category,
    primary key (film_id, category_id)
)

-- Community table
create table Community (
    id integer identity (1, 1) not null,
    name nvarchar(255) not null,
    description nvarchar(max),
    image_url varchar(255),
    created_at datetime not null default getdate(),
    primary key (id)
)

-- CommunityContributor table
create table CommunityContributor (
    community_id integer not null,
    creator_id integer not null,
    started_at datetime not null default getdate(),
    foreign key (community_id) references Community,
    foreign key (creator_id) references Creator,
    primary key (community_id, creator_id)
)

-- CommunityMembers table
create table CommunityMember (
    creator_id integer not null,
    community_id integer not null,
    started_at datetime not null default getdate(),
    foreign key (creator_id) references Creator,
    foreign key (community_id) references Community,
    primary key (creator_id, community_id)
)

-- CreatorLink table
create table CreatorLink (
    creator_id integer not null,
    sm_type varchar(255) check (sm_type in ('Twitter', 'Instagram', 'Facebook', 'Email', 'YouTube')) not null,
    sm_link varchar(255) not null,
    foreign key (creator_id) references Creator,
    primary key (creator_id, sm_type)
)

-- CommunityPost table
create table CommunityPost (
    id integer identity (1, 1) not null,
    community_id integer not null,
    creator_id integer not null,
    title nvarchar(255) not null,
    content nvarchar(max) not null,
    created_at datetime not null default getdate(),
    primary key (id),
    foreign key (community_id, creator_id) references CommunityContributor (community_id, creator_id)
)

-- CommunityPostLike table
create table CommunityPostLike (
    creator_id integer not null,
    community_post_id integer not null,
    foreign key (creator_id) references Creator,
    foreign key (community_post_id) references CommunityPost,
    primary key (creator_id, community_post_id)
)

-- ReviewFilm table
create table ReviewFilm (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    content nvarchar(max) not null,
    created_at datetime not null default getdate(),
    rating decimal(4, 2),
    film_id integer not null,
    user_id integer not null,
    foreign key (film_id) references Film,
    foreign key (user_id) references Users,
    primary key (id)
)

-- ReviewSeries table
create table ReviewSeries (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    content nvarchar(max) not null,
    created_at datetime not null default getdate(),
    rating decimal(4, 2),
    series_id integer not null,
    user_id integer not null,
    foreign key (series_id) references Series,
    foreign key (user_id) references Users,
    primary key (id)
)

-- ReviewEpisode table
create table ReviewEpisode (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    content nvarchar(max) not null,
    created_at datetime not null default getdate(),
    rating decimal(4, 2),
    episode_id integer not null,
    user_id integer not null,
    foreign key (episode_id) references Episode,
    foreign key (user_id) references Users,
    primary key (id)
)

-- Follows table
create table Follows (
    user_id integer not null,
    creator_id integer not null,
    foreign key (user_id) references Users,
    foreign key (creator_id) references Creator,
    primary key (user_id, creator_id)
)

-- CreatorsFollow table
create table CreatorsFollow (
    creator_followed integer not null,
    creator_follower integer not null,
    started_at datetime not null default getdate(),
    foreign key (creator_followed) references Creator,
    foreign key (creator_follower) references Creator,
    primary key (creator_followed, creator_follower),
    check (creator_followed != creator_follower)
)

-- CreatorPost table
create table CreatorPost (
    id integer identity (1, 1) not null,
    creator_id integer not null,
    title nvarchar(255) not null,
    content nvarchar(max) not null,
    created_at datetime not null default getdate(),
    update_at datetime,
    foreign key (creator_id) references Creator,
    primary key (id),
)

-- CreatorPostLike table
create table CreatorPostLike (
    creator_id integer not null,
    creator_post_id integer not null,
    foreign key (creator_id) references Creator,
    foreign key (creator_post_id) references CreatorPost,
    primary key (creator_id, creator_post_id)
)

-- FilmManagement table
create table FilmManagement (
    film_id integer not null,
    visibility varchar(20) check (visibility in ('public', 'private')),
    publication_status varchar(20) check (publication_status in ('published', 'draft', 'scheduled')),
    scheduled_publish_date datetime,
    foreign key (film_id) references Film,
    primary key (film_id),
    check ((publication_status = 'scheduled' and scheduled_publish_date is not null)
        or publication_status != 'scheduled' and scheduled_publish_date is null)
)

-- EpisodeManagement table
create table EpisodeManagement (
    episode_id integer not null,
    visibility varchar(20) check (visibility in ('public', 'private')),
    publication_status varchar(20) check (publication_status in ('published', 'draft', 'scheduled')),
    scheduled_publish_date datetime,
    foreign key (episode_id) references Episode,
    primary key (episode_id),
    check ((publication_status = 'scheduled' and scheduled_publish_date is not null)
        or publication_status != 'scheduled' and scheduled_publish_date is null)
)

-- SeriesManagement table
create table SeriesManagement (
    series_id integer not null,
    visibility varchar(20) check (visibility in ('public', 'private')),
    publication_status varchar(20) check (publication_status in ('published', 'draft', 'scheduled')),
    scheduled_publish_date datetime,
    foreign key (series_id) references Series,
    primary key (series_id),
    check ((publication_status = 'scheduled' and scheduled_publish_date is not null)
        or publication_status != 'scheduled' and scheduled_publish_date is null)
)

-- CollaboratorFilm table
create table CollaboratorFilm (
    creator_id integer not null,
    film_id integer not null,
    role nvarchar(255) not null,
    foreign key (creator_id) references Creator,
    foreign key (film_id) references Film,
    primary key (creator_id, film_id)
)

-- CollaboratorSeries table
create table CollaboratorSeries (
    creator_id integer not null,
    series_id integer not null,
    role nvarchar(255) not null,
    foreign key (creator_id) references Creator,
    foreign key (series_id) references Series,
    primary key (creator_id, series_id)
)

-- CollaboratorEpisode table
create table CollaboratorEpisode (
    creator_id integer not null,
    episode_id integer not null,
    role nvarchar(255) not null,
    foreign key (creator_id) references Creator,
    foreign key (episode_id) references Episode,
    primary key (creator_id, episode_id)
)

-- UserCategory table
create table UserCategory (
    user_id integer not null,
    category_id integer not null,
    foreign key (user_id) references Users,
    foreign key (category_id) references Category,
    primary key (user_id, category_id)
)

select Series.id, Series.title, Season.id, Season.title, Season.number from Series
join Season on Series.id = Season.series_id

-- Insert Series
INSERT INTO Series (title, description, thumbnail_url)
VALUES ('Mystery Tales', 'A series of thrilling mystery stories.', 'mystery_tales_thumbnail.jpg'),
       ('Sci-Fi Chronicles', 'Explore the fascinating world of science fiction.', 'sci_fi_chronicles_thumbnail.jpg'),
       ('Adventure Island', 'An exciting adventure series set on a remote island.', 'adventure_island_thumbnail.jpg'),
       ('Drama Diaries', 'A collection of dramatic stories that touch the heart.', 'drama_diaries_thumbnail.jpg'),
       ('Comedy Corner', 'A series filled with hilarious comedic tales.', 'comedy_corner_thumbnail.jpg');

-- Insert Seasons
INSERT INTO Season (title, series_id, number)
VALUES ('Mystery Tales Season 1', 1, 1), -- done
       ('Mystery Tales Season 2', 1, 2), -- done
       ('Sci-Fi Chronicles Season 1', 2, 1),
       ('Sci-Fi Chronicles Season 2', 2, 2),
       ('Adventure Island Season 1', 3, 1),
       ('Adventure Island Season 2', 3, 2),
       ('Adventure Island Season 3', 3, 3),
       ('Drama Diaries Season 1', 4, 1),
       ('Drama Diaries Season 2', 4, 2),
       ('Comedy Corner Season 1', 5, 1),
       ('Comedy Corner Season 2', 5, 2),
       ('Comedy Corner Season 3', 5, 3);

-- Insert Episodes
-- Mystery Tales Season 1 Episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('The Haunted House', 'A group of friends explore a haunted house.', 'mystery_tales_s1e1.mp4', 1, '00:45:00', 'mystery_tales_s1e1_thumbnail.jpg', 1),
       ('The Lost Treasure', 'A treasure hunt leads to unexpected discoveries.', 'mystery_tales_s1e2.mp4', 2, '00:42:00', 'mystery_tales_s1e2_thumbnail.jpg', 1),
       ('The Secret Chamber', 'A hidden chamber reveals dark secrets.', 'mystery_tales_s2e1.mp4', 3, '00:47:00', 'mystery_tales_s2e1_thumbnail.jpg', 1),
       ('The Mysterious Stranger', 'A stranger arrives in town with a hidden agenda.', 'mystery_tales_s2e2.mp4', 4, '00:44:00', 'mystery_tales_s2e2_thumbnail.jpg', 1),
       ('The Vanishing Artist', 'A talented artist disappears under mysterious circumstances.', 'mystery_tales_s1e3.mp4', 5, '00:40:00', 'mystery_tales_s1e3_thumbnail.jpg', 1);

-- Mystery Tales Season 2 Episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('The Phantom Thief', 'A master thief eludes the authorities.', 'mystery_tales_s2e3.mp4', 1, '00:48:00', 'mystery_tales_s2e3_thumbnail.jpg', 2),
       ('The Final Trick', 'A magician`s final trick leads to a shocking revelation.', 'mystery_tales_s2e4.mp4', 2, '00:41:00', 'mystery_tales_s2e4_thumbnail.jpg', 2),
       ('The Shadow Society', 'An undercover agent infiltrates a secret society.', 'mystery_tales_s2e5.mp4', 3, '00:46:00', 'mystery_tales_s2e5_thumbnail.jpg', 2),
       ('The Hidden Clue', 'A detective finds a vital clue that cracks the case.', 'mystery_tales_s1e4.mp4', 4, '00:43:00', 'mystery_tales_s1e4_thumbnail.jpg', 2),
       ('The Cryptic Code', 'A cryptic code holds the key to solving a puzzling mystery.', 'mystery_tales_s1e5.mp4', 5, '00:44:00', 'mystery_tales_s1e5_thumbnail.jpg', 2);

-- Sci-Fi Chronicles Season 1 episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('The Time Machine', 'An inventor creates a time machine and explores the future.', 'sci_fi_chronicles_s1e1.mp4', 1, '00:50:00', 'sci_fi_chronicles_s1e1_thumbnail.jpg', 3),
       ('The Alien Encounter', 'A group of scientists make contact with an alien species.', 'sci_fi_chronicles_s1e2.mp4', 2, '00:52:00', 'sci_fi_chronicles_s1e2_thumbnail.jpg', 3),
       ('The Martian Chronicles', 'A mission to Mars uncovers a hidden civilization.', 'sci_fi_chronicles_s1e3.mp4', 3, '00:55:00', 'sci_fi_chronicles_s1e3_thumbnail.jpg', 3),
       ('The Space Station', 'Astronauts aboard a space station face an unexpected crisis.', 'sci_fi_chronicles_s1e4.mp4', 4, '00:47:00', 'sci_fi_chronicles_s1e4_thumbnail.jpg', 3),
       ('The Black Hole', 'A team of scientists investigates a mysterious black hole.', 'sci_fi_chronicles_s1e5.mp4', 5, '00:49:00', 'sci_fi_chronicles_s1e5_thumbnail.jpg', 3);

-- Sci-Fi Chronicles Season 2 episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('The Multiverse Theory', 'A scientist explores the possibility of parallel universes.', 'sci_fi_chronicles_s2e1.mp4', 1, '00:51:00', 'sci_fi_chronicles_s2e1_thumbnail.jpg', 4),
       ('The Time Paradox', 'A time traveler accidentally alters the course of history.', 'sci_fi_chronicles_s2e2.mp4', 2, '00:54:00', 'sci_fi_chronicles_s2e2_thumbnail.jpg', 4),
       ('The Quantum Leap', 'An experiment in quantum physics leads to extraordinary consequences.', 'sci_fi_chronicles_s2e3.mp4', 3, '00:53:00', 'sci_fi_chronicles_s2e3_thumbnail.jpg', 4),
       ('The Galactic War', 'An intergalactic war threatens the fate of the universe.', 'sci_fi_chronicles_s2e4.mp4', 4, '00:58:00', 'sci_fi_chronicles_s2e4_thumbnail.jpg', 4),
       ('The Android Revolution', 'A society of androids fights for their freedom.', 'sci_fi_chronicles_s2e5.mp4', 5, '00:56:00', 'sci_fi_chronicles_s2e5_thumbnail.jpg', 4);

-- Adventure Island Season 1 episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('Shipwrecked', 'A group of adventurers becomes shipwrecked on a mysterious island.', 'adventure_island_s1e1.mp4', 1, '00:45:00', 'adventure_island_s1e1_thumbnail.jpg', 5),
       ('The Jungle Maze', 'The adventurers navigate a dangerous jungle filled with traps.', 'adventure_island_s1e2.mp4', 2, '00:47:00', 'adventure_island_s1e2_thumbnail.jpg', 5),
       ('The Hidden Temple', 'The group discovers an ancient temple with hidden secrets.', 'adventure_island_s1e3.mp4', 3, '00:50:00', 'adventure_island_s1e3_thumbnail.jpg', 5),
       ('The Cursed Treasure', 'A legendary treasure is found, but it comes with a terrible curse.', 'adventure_island_s1e4.mp4', 4, '00:48:00', 'adventure_island_s1e4_thumbnail.jpg', 5),
       ('The Great Escape', 'The adventurers devise a daring plan to escape the island.', 'adventure_island_s1e5.mp4', 5, '00:46:00', 'adventure_island_s1e5_thumbnail.jpg', 5);

-- Adventure Island Season 2 episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('The Island Revisited', 'The group returns to the island to rescue a friend left behind.', 'adventure_island_s2e1.mp4', 1, '00:44:00', 'adventure_island_s2e1_thumbnail.jpg', 6),
       ('The Lost City', 'The adventurers discover the remains of a long-lost civilization.', 'adventure_island_s2e2.mp4', 2, '00:49:00', 'adventure_island_s2e2_thumbnail.jpg', 6),
       ('The Underground River', 'The group ventures into an underground river filled with danger.', 'adventure_island_s2e3.mp4', 3, '00:52:00', 'adventure_island_s2e3_thumbnail.jpg', 6),
       ('The Island`s Secret', 'The island`s true purpose is finally revealed.', 'adventure_island_s2e4.mp4', 4, '00:55:00', 'adventure_island_s2e4_thumbnail.jpg', 6),
       ('The Final Battle', 'The adventurers face off against their greatest foe.', 'adventure_island_s2e5.mp4', 5, '00:58:00', 'adventure_island_s2e5_thumbnail.jpg', 6);

-- Adventure Island Season 3 episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('The New Island', 'The adventurers embark on a new journey to a mysterious island.', 'adventure_island_s3e1.mp4', 1, '00:46:00', 'adventure_island_s3e1_thumbnail.jpg', 7),
       ('The Hidden Cave', 'A hidden cave reveals clues to the island`s past.', 'adventure_island_s3e2.mp4', 2, '00:48:00', 'adventure_island_s3e2_thumbnail.jpg', 7),
       ('The Ancient Ruins', 'The group stumbles upon ancient ruins with powerful artifacts.', 'adventure_island_s3e3.mp4', 3, '00:51:00', 'adventure_island_s3e3_thumbnail.jpg', 7),
       ('The Forbidden Zone', 'The adventurers dare to enter a forbidden part of the island.', 'adventure_island_s3e4.mp4', 4, '00:53:00', 'adventure_island_s3e4_thumbnail.jpg', 7),
       ('The Final Voyage', 'The group faces their most dangerous challenge yet.', 'adventure_island_s3e5.mp4', 5, '00:57:00', 'adventure_island_s3e5_thumbnail.jpg', 7);

-- Drama Diaries Season 1 episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('A New Beginning', 'A young woman moves to a new city to start her life anew.', 'drama_diaries_s1e1.mp4', 1, '00:42:00', 'drama_diaries_s1e1_thumbnail.jpg', 8),
       ('The Love Triangle', 'A complicated love triangle threatens friendships.', 'drama_diaries_s1e2.mp4', 2, '00:45:00', 'drama_diaries_s1e2_thumbnail.jpg', 8),
       ('The Broken Friendship', 'A misunderstanding leads to a broken friendship.', 'drama_diaries_s1e3.mp4', 3, '00:47:00', 'drama_diaries_s1e3_thumbnail.jpg', 8),
       ('The Family Secret', 'A family secret is revealed, changing relationships forever.', 'drama_diaries_s1e4.mp4', 4, '00:44:00', 'drama_diaries_s1e4_thumbnail.jpg', 8),
       ('The Unexpected Proposal', 'A surprise proposal leads to difficult decisions.', 'drama_diaries_s1e5.mp4', 5, '00:46:00', 'drama_diaries_s1e5_thumbnail.jpg', 8);

-- Drama Diaries Season 2 episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('The New Job', 'A new job brings new challenges and opportunities.', 'drama_diaries_s2e1.mp4', 1, '00:43:00', 'drama_diaries_s2e1_thumbnail.jpg', 9),
       ('The Long-Lost Friend', 'An old friend reappears, bringing up buried memories.', 'drama_diaries_s2e2.mp4', 2, '00:41:00', 'drama_diaries_s2e2_thumbnail.jpg', 9),
       ('The Heartbreak', 'Heartbreak leads to personal growth and healing.', 'drama_diaries_s2e3.mp4', 3, '00:49:00', 'drama_diaries_s2e3_thumbnail.jpg', 9),
       ('The Reconciliation', 'A broken friendship is mended through understanding and forgiveness.', 'drama_diaries_s2e4.mp4', 4, '00:47:00', 'drama_diaries_s2e4_thumbnail.jpg', 9),
       ('The Final Goodbye', 'A farewell brings closure and new beginnings.', 'drama_diaries_s2e5.mp4', 5, '00:50:00', 'drama_diaries_s2e5_thumbnail.jpg', 9);

-- Comedy Corner Season 1 episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('The Awkward Date', 'A disastrous first date leads to hilarious misunderstandings.', 'comedy_central_s1e1.mp4', 1, '00:30:00', 'comedy_central_s1e1_thumbnail.jpg', 10),
       ('The Unusual Roommate', 'A quirky roommate turns everyday life upside down.', 'comedy_central_s1e2.mp4', 2, '00:28:00', 'comedy_central_s1e2_thumbnail.jpg', 10),
       ('The Family Reunion', 'A chaotic family reunion brings out the best and worst in everyone.', 'comedy_central_s1e3.mp4', 3, '00:32:00', 'comedy_central_s1e3_thumbnail.jpg', 10),
       ('The Misadventures of Pet Sitting', 'Pet sitting turns into an adventure full of hilarious mishaps.', 'comedy_central_s1e4.mp4', 4, '00:29:00', 'comedy_central_s1e4_thumbnail.jpg', 10),
       ('The Office Prank War', 'A prank war at the office goes hilariously out of control.', 'comedy_central_s1e5.mp4', 5, '00:31:00', 'comedy_central_s1e5_thumbnail.jpg', 10);

-- Comedy Central Season 2 episodes
INSERT INTO Episode (title, description, content_url, number, duration, thumbnail_url, season_id)
VALUES ('The Wedding Disaster', 'A series of hilarious mishaps unfold at a friend`s wedding.', 'comedy_central_s2e1.mp4', 1, '00:33:00', 'comedy_central_s2e1_thumbnail.jpg', 11),
       ('The Unlucky Vacation', 'A vacation filled with comical misfortunes becomes a trip to remember.', 'comedy_central_s2e2.mp4', 2, '00:34:00', 'comedy_central_s2e2_thumbnail.jpg', 11),
       ('The Cooking Catastrophe', 'An attempt at a fancy dinner party ends in a culinary disaster.', 'comedy_central_s2e3.mp4', 3, '00:30:00', 'comedy_central_s2e3_thumbnail.jpg', 11),
       ('The Babysitting Fiasco', 'Babysitting for a neighbor takes a hilariously chaotic turn.', 'comedy_central_s2e4.mp4', 4, '00:28:00', 'comedy_central_s2e4_thumbnail.jpg', 11),
       ('The Unexpected Reunion', 'An impromptu high school reunion results in side-splitting scenarios.', 'comedy_central_s2e5.mp4', 5, '00:32:00', 'comedy_central_s2e5_thumbnail.jpg', 11);

select Series.id, Series.title, S.number, S.title, E.number, E.title from Series
join Season S on Series.id = S.series_id
join Episode E on S.id = E.season_id

-- insert films
INSERT INTO Film (title, content_url, description, duration, thumbnail_url)
VALUES
    ('The Journey Home', 'https://contenturl.com/thejourneyhome', 'A heartwarming tale about a lost dog and his adventures trying to find his way back home', '01:45:00', 'https://thumbnailurl.com/thejourneyhome'),
    ('The Last Chance', 'https://contenturl.com/thelastchance', 'A drama about a struggling musician who gets one last shot at making it big', '02:15:00', 'https://thumbnailurl.com/thelastchance'),
    ('The Great Escape', 'https://contenturl.com/thegreatescape', 'A thriller about a group of prisoners who try to escape from a maximum security prison', '02:30:00', 'https://thumbnailurl.com/thegreatescape'),
    ('The Secret Garden', 'https://contenturl.com/thesecretgarden', 'An enchanting story about a young girl who discovers a magical garden', '01:50:00', 'https://thumbnailurl.com/thesecretgarden'),
    ('The Lost City', 'https://contenturl.com/thelostcity', 'An adventure film about a group of explorers who search for a lost city in the jungle', '02:20:00', 'https://thumbnailurl.com/thelostcity'),
    ('The Perfect Match', 'https://contenturl.com/theperfectmatch', 'A romantic comedy about a couple who are perfect for each other, but can`t seem to get together', '01:55:00', 'https://thumbnailurl.com/theperfectmatch'),
    ('The Art of Deception', 'https://contenturl.com/theartofdeception', 'A crime thriller about a master thief who pulls off a daring heist', '02:10:00', 'https://thumbnailurl.com/theartofdeception'),
    ('The Price of Freedom', 'https://contenturl.com/thepriceoffreedom', 'A historical drama about the struggle for independence in a fictional country', '02:25:00', 'https://thumbnailurl.com/thepriceoffreedom'),
    ('The Road Less Traveled', 'https://contenturl.com/theroadlesstraveled', 'A coming-of-age story about a young woman who goes on a road trip to find herself', '01:40:00', 'https://thumbnailurl.com/theroadlesstraveled'),
    ('The Final Countdown', 'https://contenturl.com/thefinalcountdown', 'A science fiction film about a group of time travelers who go back in time to prevent a disaster', '02:05:00', 'https://thumbnailurl.com/thefinalcountdown'),
    ('The Dark Forest', 'https://contenturl.com/thedarkforest', 'A horror movie about a group of friends who get lost in a mysterious forest', '01:55:00', 'https://thumbnailurl.com/thedarkforest'),
    ('The Long Goodbye', 'https://contenturl.com/thelonggoodbye', 'A film noir about a private detective who gets involved in a complex case', '02:20:00', 'https://thumbnailurl.com/thelonggoodbye'),
    ('The Secret Agent', 'https://contenturl.com/thesecretagent', 'An espionage thriller about a spy who tries to prevent a terrorist attack', '02:15:00', 'https://thumbnailurl.com/thesecretagent'),
    ('The Other Side', 'https://contenturl.com/theotherside', 'A supernatural thriller about a couple who moves into a haunted house', '01:50:00', 'https://thumbnailurl.com/theotherside'),
    ('The Last Stand', 'https://contenturl.com/thelaststand', 'An action-packed film about a sheriff who must protect his town from a dangerous gang', '02:00:00', 'https://thumbnailurl.com/thelaststand'),
    ('The Great Unknown', 'https://contenturl.com/thegreatunknown', 'A mystery film about a woman who wakes up with no memory and must unravel the truth about her past', '02:10:00', 'https://thumbnailurl.com/thegreatunknown'),
    ('The Final Showdown', 'https://contenturl.com/thefinalshowdown', 'A western about two rival cowboys who face off in a high-stakes duel', '01:45:00', 'https://thumbnailurl.com/thefinalshowdown'),
    ('The Perfect Heist', 'https://contenturl.com/theperfectheist', 'A thriller about a group of thieves who plan the perfect robbery', '02:20:00', 'https://thumbnailurl.com/theperfectheist');

select * from Film;

-- inserting categories
INSERT INTO Category (title)
VALUES
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

select * from Category;

-- Connecting Content and Categories
-- Insert sample data into SeriesCategory table
INSERT INTO SeriesCategory (series_id, category_id)
VALUES
    (1, 7), -- Mystery Tales belongs to Mystery category
    (2, 9), -- Sci-Fi Chronicles belongs to Sci-Fi category
    (3, 2), -- Adventure Island belongs to Adventure category
    (4, 4), -- Drama Diaries belongs to Drama category
    (5, 3), -- Comedy Corner belongs to Comedy category
    (1, 12), -- Mystery Tales belongs to Animation category
    (2, 12), -- Sci-Fi Chronicles belongs to Animation category
    (3, 12), -- Adventure Island belongs to Animation category
    (4, 12), -- Drama Diaries belongs to Animation category
    (5, 12); -- Comedy Corner belongs to Animation category

-- Insert sample data into FilmCategory table
INSERT INTO FilmCategory (film_id, category_id)
VALUES
    (1, 7), -- The Journey Home belongs to Mystery category
    (2, 4), -- The Last Chance belongs to Drama category
    (3, 1), -- The Great Escape belongs to Action category
    (4, 5), -- The Secret Garden belongs to Fantasy category
    (5, 2), -- The Lost City belongs to Adventure category
    (6, 3), -- The Perfect Match belongs to Comedy category
    (7, 11), -- The Art of Deception belongs to 2D Animation category
    (8, 9), -- The Price of Freedom belongs to Sci-Fi category
    (9, 12), -- The Road Less Traveled belongs to Animation category
    (10, 9), -- The Final Countdown belongs to Sci-Fi category
    (11, 6), -- The Dark Forest belongs to Horror category
    (12, 4), -- The Long Goodbye belongs to Drama category
    (13, 6), -- The Secret Agent belongs to Horror category
    (14, 11), -- The Other Side belongs to 2D Animation category
    (15, 1), -- The Last Stand belongs to Action category
    (16, 7), -- The Great Unknown belongs to Mystery category
    (17, 1), -- The Final Showdown belongs to Action category
    (18, 10), -- The Perfect Heist belongs to Thriller category
    (1, 18), -- The Journey Home belongs to Thriller category
    (2, 15), -- The Last Chance belongs to Animated Series category
    (3, 17), -- The Great Escape belongs to Superhero category
    (4, 12), -- The Secret Garden belongs to Animation category
    (5, 16), -- The Lost City belongs to Children category
    (6, 13), -- The Perfect Match belongs to Family category
    (7, 14), -- The Art of Deception belongs to Blender Animation category
    (8, 18), -- The Price of Freedom belongs to Thriller category
    (9, 13), -- The Road Less Traveled belongs to Family category
    (10, 17), -- The Final Countdown belongs to Superhero category
    (12, 14), -- The Long Goodbye belongs to 3D Animation category
    (13, 17) -- The Secret Agent belongs to Superhero category

select F.title, C.title from Film F
join FilmCategory FC on F.id = FC.film_id
join Category C on C.id = FC.category_id

select S.title, C.title from Series S
join SeriesCategory SC on S.id = SC.series_id
join Category C on SC.category_id = C.id

-- Insert 15 Users into Account table
INSERT INTO Account (username, email, password, first_name, last_name, profile_image_url)
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
    ('jacob_adams', 'jacob.adams@example.com', 'j3K6fA9yX5', 'Jacob', 'Adams', 'https://example.com/profiles/jacob_adams.jpg');

select * from Account;

insert into Users (account_id)
values
    (3),
    (4),
    (5),
    (6),
    (7),
    (8),
    (9),
    (10),
    (11),
    (12),
    (13),
    (14),
    (15),
    (16),
    (17)

insert into Creator (account_id, status, bio, website)
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

insert into CollaboratorFilm (creator_id, film_id, role)
values
    (18, 1, 'Director'),
    (19, 1, 'Producer'),
    (20, 2, 'Director'),
    (21, 3, 'Director'),
    (22, 3, 'Writer'),
    (23, 4, 'Director'),
    (24, 4, 'Producer'),
    (25, 5, 'Director'),
    (26, 6, 'Director'),
    (27, 6, 'Writer'),
    (28, 7, 'Director'),
    (29, 8, 'Director'),
    (30, 8, 'Producer'),
    (31, 9, 'Director'),
    (32, 9, 'Writer'),
    (18, 10, 'Director'),
    (19, 11, 'Director'),
    (20, 11, 'Producer'),
    (21, 12, 'Director'),
    (22, 13, 'Director'),
    (23, 13, 'Writer'),
    (24, 14, 'Director'),
    (25, 15, 'Director'),
    (26, 15, 'Producer'),
    (27, 16, 'Director'),
    (28, 17, 'Director'),
    (29, 17, 'Writer'),
    (30, 18, 'Director')

select * from CollaboratorFilm

insert into CollaboratorSeries (creator_id, series_id, role)
values
    (18, 1, 'Director'),
    (19, 1, 'Writer'),
    (20, 2, 'Director'),
    (21, 2, 'Writer'),
    (22, 3, 'Director'),
    (23, 3, 'Producer'),
    (24, 4, 'Director'),
    (25, 4, 'Writer'),
    (26, 5, 'Director'),
    (27, 5, 'Producer'),
    (28, 1, 'Producer'),
    (29, 2, 'Producer'),
    (30, 3, 'Writer'),
    (31, 4, 'Producer'),
    (32, 5, 'Writer'),
    (18, 3, 'Writer'),
    (19, 4, 'Director'),
    (20, 5, 'Director'),
    (21, 1, 'Producer'),
    (22, 2, 'Director')

select id from Episode;

insert into CollaboratorEpisode (creator_id, episode_id, role)
values
    (18, 8, '2D Animator'),
    (19, 8, 'Sound Engineer'),
    (20, 9, 'Storyboard Artist'),
    (21, 9, '3D Animator'),
    (22, 10, 'Audio Mixer'),
    (23, 10, 'Script Supervisor'),
    (24, 11, 'Lighting Technician'),
    (25, 11, 'Editor'),
    (26, 12, 'Director of Photography'),
    (27, 12, 'Art Director'),
    (28, 13, 'Location Manager'),
    (29, 13, 'Production Assistant'),
    (30, 14, 'Casting Director'),
    (31, 14, 'Set Designer'),
    (32, 15, 'Costume Designer'),
    (18, 16, '3D Animator'),
    (19, 16, 'Audio Mixer'),
    (20, 17, 'Script Supervisor'),
    (21, 17, 'Lighting Technician'),
    (22, 18, 'Editor'),
    (23, 18, 'Director of Photography'),
    (24, 19, 'Art Director'),
    (25, 19, 'Location Manager'),
    (26, 20, 'Production Assistant'),
    (27, 20, 'Casting Director'),
    (28, 21, 'Set Designer'),
    (29, 21, 'Costume Designer'),
    (30, 22, '2D Animator'),
    (31, 22, 'Sound Engineer'),
    (32, 23, 'Storyboard Artist'),
    (18, 24, '3D Animator'),
    (19, 24, 'Audio Mixer'),
    (20, 25, 'Script Supervisor'),
    (21, 25, 'Lighting Technician'),
    (22, 26, 'Editor'),
    (23, 26, 'Director of Photography'),
    (24, 27, 'Art Director'),
    (25, 27, 'Location Manager'),
    (26, 28, 'Production Assistant'),
    (27, 28, 'Casting Director'),
    (28, 29, 'Set Designer'),
    (29, 29, 'Costume Designer'),
    (30, 30, '2D Animator'),
    (31, 30, 'Sound Engineer'),
    (32, 31, 'Storyboard Artist'),
    (18, 31, '3D Animator'),
    (19, 32, 'Audio Mixer'),
    (20, 32, 'Script Supervisor'),
    (21, 33, 'Lighting Technician'),
    (22, 33, 'Editor'),
    (23, 34, 'Director of Photography'),
    (24, 34, 'Art Director'),
    (25, 35, 'Location Manager'),
    (26, 35, 'Production Assistant'),
    (27, 36, 'Casting Director'),
    (28, 36, 'Set Designer'),
    (29, 37, 'Costume Designer'),
    (30, 37, '2D Animator'),
    (31, 38, 'Sound Engineer'),
    (32, 38, 'Storyboard Artist'),
    (18, 39, '3D Animator'),
    (19, 39, 'Audio Mixer'),
    (20, 40, 'Script Supervisor'),
    (21, 40, 'Lighting Technician'),
    (22, 41, 'Editor'),
    (23, 41, 'Director of Photography'),
    (24, 42, 'Art Director'),
    (25, 42, 'Location Manager'),
    (26, 43, 'Production Assistant'),
    (27, 43, 'Casting Director'),
    (28, 44, 'Set Designer'),
    (29, 44, 'Costume Designer'),
    (30, 45, '2D Animator'),
    (31, 45, 'Sound Engineer'),
    (32, 46, 'Storyboard Artist'),
    (18, 46, '3D Animator'),
    (19, 47, 'Audio Mixer'),
    (20, 47, 'Script Supervisor'),
    (21, 48, 'Lighting Technician'),
    (22, 48, 'Editor'),
    (23, 49, 'Director of Photography'),
    (24, 49, 'Art Director'),
    (25, 50, 'Location Manager'),
    (26, 50, 'Production Assistant'),
    (27, 51, 'Casting Director'),
    (28, 51, 'Set Designer'),
    (29, 52, 'Costume Designer'),
    (30, 52, '2D Animator'),
    (31, 53, 'Sound Engineer'),
    (32, 53, 'Storyboard Artist'),
    (18, 54, '3D Animator'),
    (19, 54, 'Audio Mixer'),
    (20, 55, 'Script Supervisor'),
    (21, 55, 'Lighting Technician'),
    (22, 56, 'Editor'),
    (23, 56, 'Director of Photography'),
    (24, 57, 'Art Director'),
    (25, 57, 'Location Manager'),
    (26, 58, 'Production Assistant'),
    (27, 58, 'Casting Director'),
    (28, 59, 'Set Designer'),
    (29, 59, 'Costume Designer'),
    (30, 60, '2D Animator'),
    (31, 60, 'Sound Engineer'),
    (32, 61, 'Storyboard Artist'),
    (18, 61, '3D Animator'),
    (19, 62, 'Audio Mixer'),
    (20, 62, 'Script Supervisor');

select * from CollaboratorEpisode;

insert into Community (name, description, image_url)
values
    ('Indie Animators', 'A community for independent animators to share their work, collaborate, and discuss techniques', 'https://example.com/indie_animators.jpg'),
    ('Stop Motion Magic', 'A place for stop motion animation enthusiasts to share their creations and exchange tips and tricks', 'https://example.com/stop_motion_magic.jpg'),
    ('2D Animation Hub', 'A community for 2D animators to share their work, resources, and discuss the latest trends', 'https://example.com/2d_animation_hub.jpg'),
    ('3D Animation Central', 'A community dedicated to 3D animation, showcasing work, sharing techniques, and discussing software', 'https://example.com/3d_animation_central.jpg'),
    ('Animation Sound Design', 'A community for sound designers working in animation to share their work and discuss best practices', 'https://example.com/animation_sound_design.jpg'),
    ('Animated Short Films', 'A community for creators and fans of animated short films to share and discuss their favorite works', 'https://example.com/animated_short_films.jpg'),
    ('Character Design Club', 'A community dedicated to the art of character design in animation and independent filmmaking', 'https://example.com/character_design_club.jpg'),
    ('Animation Screenwriting', 'A community for screenwriters and story artists working in animation to share their work and get feedback', 'https://example.com/animation_screenwriting.jpg'),
    ('Animation Directors Forum', 'A place for animation directors to share their experiences, discuss challenges, and collaborate on projects', 'https://example.com/animation_directors_forum.jpg'),
    ('Visual Effects in Animation', 'A community focused on visual effects in animation, including compositing, motion graphics, and special effects', 'https://example.com/visual_effects_in_animation.jpg'),
    ('Experimental Animation', 'A community for artists pushing the boundaries of animation, exploring unconventional techniques and styles', 'https://example.com/experimental_animation.jpg'),
    ('Indie Animation Funding', 'A community to discuss funding opportunities, grants, and crowdfunding for independent animation projects', 'https://example.com/indie_animation_funding.jpg'),
    ('Animation Festivals & Events', 'A community to share information about animation festivals, screenings, and events around the world', 'https://example.com/animation_festivals_events.jpg'),
    ('Animation Education & Careers', 'A community for those interested in pursuing a career in animation, discussing schools, programs, and job opportunities', 'https://example.com/animation_education_careers.jpg'),
    ('Animation Software & Tools', 'A community to discuss the latest software, tools, and technology used in animation and independent filmmaking', 'https://example.com/animation_software_tools.jpg')

select * from Community;

insert into CommunityContributor (community_id, creator_id)
values
    (1, 18), (1, 19),
    (2, 19), (2, 20), (2, 21),
    (3, 20), (3, 22), (3, 23),
    (4, 21), (4, 24), (4, 25),
    (5, 22), (5, 26), (5, 27),
    (6, 23), (6, 28), (6, 29),
    (7, 24), (7, 30), (7, 31),
    (8, 25), (8, 32), (8, 18),
    (9, 26), (9, 19), (9, 20),
    (10, 27), (10, 21), (10, 22),
    (11, 28), (11, 23), (11, 24),
    (12, 29), (12, 25), (12, 26),
    (13, 30), (13, 27), (13, 28),
    (14, 29), (14, 30), (14, 31),
    (15, 31), (15, 32)

INSERT INTO CommunityPost (community_id, creator_id, title, content)
VALUES
    (1, 18, 'My Latest Indie Animation Project', 'Hey everyone, I just finished my latest indie animation project and wanted to share it with you all. Let me know what you think!'),
    (1, 18, 'Storyboarding Tips for Independent Filmmakers', 'Creating a clear and concise storyboard is crucial for any animated project. In this post, I will share some tips that can help independent filmmakers create better storyboards.'),
    (1, 19, 'Animation Styles for Indie Filmmakers', 'As an indie filmmaker, you have a lot of creative freedom when it comes to animation styles. In this post, I will discuss various animation styles and techniques you can explore.'),
    (2, 19, 'Stop Motion Tips for Beginners', 'I have been working on stop motion animation for a few years now and thought it would be helpful to share some tips for those just starting out.'),
    (2, 20, 'Sound Design in Animation: Tips and Techniques', 'Sound design can greatly enhance the overall experience of an animated project. In this post, I will share some tips and techniques for improving sound design in your animation.'),
    (2, 21, 'Creating a Soundtrack for Your Animation', 'A memorable soundtrack can make your animation stand out. In this post, I will discuss how to create a captivating and fitting soundtrack for your animated project.'),
    (3, 20, 'Animating a Walk Cycle in 2D', 'In this post, I will share my process for animating a walk cycle in 2D, including the key poses and timing.'),
    (3, 22, 'Marketing Your Independent Animation', 'Marketing is essential for getting your animation noticed. In this post, I will share some strategies for marketing your independent animation effectively.'),
    (3, 23, 'Crowdfunding Your Animation Project', 'Crowdfunding can be a great way to fund your animation project. In this post, I will share some tips for running a successful crowdfunding campaign for your animated film.'),
    (4, 21, 'Favorite 3D Animation Software', 'What is your favorite 3D animation software and why? I have been using Blender for a while now, but I am curious to hear about other options.'),
    (4, 24, 'Creating Memorable Characters in Animation', 'In this post, I will share some tips for creating memorable and engaging characters for your animation.'),
    (4, 25, 'Exploring Different Character Design Styles', 'In this post, I will discuss different character design styles and how they can impact the overall look and feel of your animation.'),
    (5, 22, 'Sound Design for Animated Films', 'Sound design is an often overlooked aspect of animated films. In this post, I will discuss some techniques and considerations for creating immersive soundscapes.'),
    (5, 26, 'Working with Voice Actors for Your Animation', 'In this post, I will discuss how to find and work with voice actors to bring your animated characters to life.'),
    (5, 27, 'The Importance of Voice Direction in Animation', 'Proper voice direction can make a huge difference in the quality of your animation. In this post, I will discuss the importance of voice direction and share some tips for directing voice actors effectively.'),
    (6, 23, 'The Importance of Story in Animated Shorts', 'Storytelling is a crucial element in animated short films. In this post, I will discuss some tips for creating compelling narratives in your animations.'),
    (6, 28, 'Creating a Strong Story for Your Animation', 'A strong story is the backbone of any animation. In this post, I will share some tips for developing a compelling and engaging story for your animated project.'),
    (6, 29, 'The Role of Scriptwriting in Animation', 'Scriptwriting plays a crucial role in the development of an animated project. In this post, I will discuss the importance of scriptwriting in animation and share some tips for writing a great script.'),
    (7, 24, 'Character Design Tips for Animators', 'Character design is an important part of the animation process. In this post, I will share some tips and tricks for creating memorable characters.'),
    (7, 30, 'The Benefits of Collaboration in Animation', 'Collaboration can lead to amazing results in animation. In this post, I will discuss the benefits of collaborating with others in the animation industry and share some tips for successful collaborations.'),
    (7, 31, 'Building an Animation Team for Your Project', 'In this post, I will discuss how to build an effective animation team for your project and share some tips for assembling the right group of collaborators.'),
    (8, 25, 'Writing a Script for an Animated Series', 'Writing a script for an animated series can be challenging. In this post, I will share some advice on how to create engaging stories and dialogue.'),
    (8, 32, 'Best Practices for Animation Project Management', 'Managing an animation project can be challenging. In this post, I will share some best practices for managing animation projects effectively and efficiently.'),
    (8, 18, 'Tools and Techniques for Animation Project Management', 'In this post, I will discuss various tools and techniques that can help you manage your animation project more effectively.'),
    (9, 26, 'Challenges of Directing an Animated Film', 'Directing an animated film is a unique and complex process. In this post, I will discuss some of the challenges I have faced and how I overcame them.'),
    (9, 19, 'Using Color Theory in Animation', 'In this post, I will discuss how to apply color theory in animation to create visually striking and emotionally engaging projects.'),
    (9, 20, 'The Role of Lighting in Animation', 'Lighting plays an essential role in animation. In this post, I will discuss the importance of lighting and share some tips for creating effective lighting in your animated project.'),
    (10, 27, 'Visual Effects Techniques in Animation', 'In this post, I will explore some visual effects techniques that can be used in animation to create stunning and dynamic visuals.'),
    (10, 21, 'Integrating 3D Elements in 2D Animation', 'In this post, I will share some tips and techniques for seamlessly integrating 3D elements into a predominantly 2D animated project.'),
    (10, 22, 'Exploring Mixed Media Animation', 'Mixed media animation can produce visually stunning results. In this post, I will discuss various mixed media techniques that you can incorporate into your animation projects.'),
    (11, 28, 'Exploring Experimental Animation Techniques', 'Experimental animation offers a world of creative possibilities. In this post, I will discuss some innovative techniques I have been experimenting with.'),
    (11, 23, 'Creating Realistic Fluid Simulations in Animation', 'Fluid simulations can add a layer of realism to your animated projects. In this post, I will share some tips for creating realistic fluid simulations in animation.'),
    (11, 24, 'Animating Cloth and Hair: Tips and Techniques', 'In this post, I will discuss some tips and techniques for animating cloth and hair in your animated projects to achieve more realistic results.'),
    (12, 29, 'Finding Funding for Your Indie Animation', 'Funding can be a major obstacle for indie animators. In this post, I will share some resources and tips for securing funding for your animation projects.'),
    (12, 25, 'The Art of Background Design in Animation', 'Background design is an essential aspect of animation. In this post, I will share some tips and techniques for creating visually stunning and engaging background designs for your animated projects.'),
    (12, 26, 'Creating Atmospheric Effects in Animation', 'Atmospheric effects can enhance the overall look and feel of your animation. In this post, I will discuss various techniques for creating atmospheric effects in your animated projects.'),
    (13, 30, 'Upcoming Animation Festivals and Events', 'In this post, I will share information about some upcoming animation festivals and events that you might be interested in attending or submitting your work to.'),
    (13, 27, 'The Importance of Pacing in Animation', 'Pacing plays a crucial role in storytelling and viewer engagement. In this post, I will discuss the importance of pacing in animation and share some tips for maintaining proper pacing throughout your project.'),
    (13, 28, 'Using Rhythm and Timing in Animation', 'Rhythm and timing can significantly impact the effectiveness of your animation. In this post, I will share some tips and techniques for incorporating rhythm and timing into your animated projects.'),
    (14, 29, 'The Art of Lip Syncing in Animation', 'Lip syncing is an essential skill for animators. In this post, I will share some tips and techniques for creating convincing lip-sync animations for your characters.'),
    (14, 30, 'Animating Facial Expressions: Tips and Techniques', 'In this post, I will discuss some tips and techniques for animating facial expressions in your animated projects, enhancing the emotional depth of your characters.'),
    (14, 31, 'Best Animation Schools and Programs', 'Choosing the right animation school or program can be difficult. In this post, I will share my thoughts on some of the best options available.'),
    (15, 32, 'Free and Affordable Animation Software', 'Animation software can be expensive, but there are some free and affordable options out there. In this post, I will discuss some of the best options for animators on a budget.'),
    (15, 31, 'The Benefits of Pre-Visualization in Animation', 'Pre-visualization can save you time and resources in the long run. In this post, I will discuss the benefits of pre-visualization in animation and share some tips for implementing it effectively.'),
    (15, 32, 'Using Animatics to Plan Your Animation Project', 'Animatics are an invaluable tool for planning your animation project. In this post, I will discuss the role of animatics in animation and share some tips for creating effective animatics.');

select * from CommunityPost;


