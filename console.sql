
-- Season table
create table Season (
    id integer identity (1, 1) not null,
    title nvarchar(255) not null,
    series_id integer not null,
    number integer not null,
    primary key (id)
)

-- Content table
create table Content (
    id integer identity (1, 1) not null,
    type varchar(10) not null check (type in ('film', 'episode', 'series')),
    title nvarchar(255) not null,
    description text not null,
    thumbnail_url varchar(255) not null,
    content_url varchar(255),
    duration time,
    season_id integer,
    number integer,
    created_at datetime not null default getdate(),
    foreign key (season_id) references Season,
    primary key (id),
    constraint CK_Content_Type_Check check (
        (type = 'film' and content_url is not null and duration is not null) or
        (type = 'episode' and season_id is not null and number is not null and content_url is not null and duration is not null) or
        (type = 'series')
    )
)

alter table Season add
foreign key (series_id) references Content;

insert into Content(type, title, description, thumbnail_url)
values ('series', 'New Series', 'Description', 'thumb')

select * from Content;
select * from Season;

insert into Season(title, series_id, number) values ('S1', 6, 1);

insert into Content(type, title, description, thumbnail_url, duration, content_url, season_id, number)
values ('episode', 'Episode Title', 'Description', 'thumb/url', '01:20:00', 'content/url', 1, 6)

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

-- User table
create table Users (
    account_id integer not null,
    foreign key (account_id) references Account,
    primary key (account_id)
)

-- LikesContent table
create table LikesContent (
    user_id integer not null,
    content_id integer not null,
    content_type varchar(10) not null,
    foreign key (user_id) references Users(account_id),
    foreign key (content_id, content_type) references Content(content_id, type),
    primary key (user_id, content_id, content_type),
)

insert into Content(type, title, description, thumbnail_url)
values ('film', 'Name', 'description', 'url/path');

select * from Content;