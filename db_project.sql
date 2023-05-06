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
	bio ntext,
	website varchar(2083),
	foreign key (account_id) references Account,
	primary key (account_id)
)

-- Film table
create table Film (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    content_url varchar(255) not null,
    description ntext not null,
    duration time not null,
    thumbnail_url varchar(255),
    created_at datetime not null default getdate(),
    primary key (id)
)

-- Episode table
create table Episode (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    description ntext not null,
    content_url varchar(255) not null,
    number integer not null,
    duration time not null,
    thumbnail_url varchar(255),
    created_at datetime not null default getdate()
)

-- Series table
create table Series (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    description ntext not null,
    thumbnail_url varchar(255),
    created_at datetime not null default getdate()
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
    title nvarchar(255) not null,
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
    description ntext,
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
    content ntext not null,
    created_at datetime not null default getdate(),
    primary key (id),
    foreign key (creator_id, community_id) references CommunityContributor (creator_id, community_id)
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
    content ntext not null,
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
    content ntext not null,
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
    content ntext not null,
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
    content ntext not null,
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
    foreign key (episode_id) references Film,
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
    foreign key (series_id) references Film,
    primary key (series_id),
    check ((publication_status = 'scheduled' and scheduled_publish_date is not null)
        or publication_status != 'scheduled' and scheduled_publish_date is null)
)


