-- Account table
CREATE TABLE Account (
	id integer identity(1, 1) not null,
	username NVARCHAR UNIQUE not null,
	email NVARCHAR UNIQUE not null,
	account_type NVARCHAR CHECK (account_type IN('User', 'Creator')) not null,
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
	id integer primary key identity(1, 1) not null,
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
    duration time not null,
    thumbnail_url varchar(255),
    created_at datetime not null default getdate(),
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
