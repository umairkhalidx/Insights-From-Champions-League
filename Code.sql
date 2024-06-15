create database Assignment_3;
use Assignment_3;


create table stadium
(
	ID int,
	name varchar(30),
	city varchar(30),
	capacity int,

	constraint stadium_id primary key(ID)
	
);


create table stadium_loc
(
	city varchar(30),
	country varchar(30),

	constraint std_loc_PK primary key(city)
	--city is considered as a FK with stadium similary as EMP and Dept
);

create table team
(
	ID int,
	name varchar(30),
	country varchar(30),
	Home_stadium_id int,

	constraint team_id primary key(ID),
	constraint h_m_id foreign key (home_stadium_id) references stadium(ID) on delete cascade on update cascade
);


create table player
(
	ID varchar(30),
	first_name varchar(30),
	last_name varchar(30),
	nationality varchar(30),
	DOB date,
	team_id int,
	jersey_number int,
	position varchar(30),
	height int,
	weight int,
	foot varchar(2),

	constraint player_id primary key(ID),
	constraint t_id_player foreign key (team_id) references team(ID) on delete cascade on update cascade

);

create table manager
(
	ID int,
	first_name varchar(30),
	last_name varchar(30),
	nationality varchar(30),
	DOB date,
	team_id int,

	constraint manager_id primary key(ID),
	constraint t_id_manager foreign key (team_id) references team(ID) on delete cascade on update cascade


);


create table match
(
	ID varchar(30),
	Date_time datetime,
	home_team_id int,
	away_team_id int,
	stadium_id int,
	home_team_score int,
	away_team_score int,
	penalty_shoot_out int,
	attendance int,

	constraint match_id primary key (ID),
	constraint h_t_id foreign key (home_team_id) references team(ID),
	constraint a_t_id foreign key (away_team_id) references team(ID),
	constraint st_id foreign key (stadium_id) references stadium(ID) on delete cascade on update cascade

);

create table match_time
(
	Date_time datetime,
	season varchar(30),

	constraint match_time_PK primary key(Date_time,season)
	--Date_time is considered as a FK with match similary as EMP and Dept
);
create table goal
(
	ID varchar(30),
	match_id varchar(30),
	player_id varchar(30),
	duration int,
	assist varchar(30),
	goal_des varchar(50),

	constraint goal_id primary key(ID),
	constraint m_id foreign key (match_id) references match(ID) on delete cascade on update cascade,
	constraint p_id foreign key (player_id) references player(ID) ,
	constraint assis foreign key (assist) references player(ID)  
);


BULK INSERT team 
from 'C:\Users\Umair Khalid\Desktop\A3\teams.csv'
with
(
fieldterminator = ',',
ROWTERMINATOR = '0x0a',
firstrow = 2 , KEEPNULLS
);


BULK INSERT stadium
from 'C:\Users\Umair Khalid\Desktop\A3\stadiums.csv'
with
(
fieldterminator = ',',
ROWTERMINATOR = '0x0a',
firstrow = 2 , KEEPNULLS
);

BULK INSERT stadium_loc
from 'C:\Users\Umair Khalid\Desktop\A3\stadiums_location.csv'
with
(
fieldterminator = ',',
ROWTERMINATOR = '0x0a',
firstrow = 2 , KEEPNULLS
);


BULK INSERT player
from 'C:\Users\Umair Khalid\Desktop\A3\players.csv'
with
(
fieldterminator = ',',
ROWTERMINATOR = '0x0a',
firstrow = 2 , KEEPNULLS
);


BULK INSERT manager
from 'C:\Users\Umair Khalid\Desktop\A3\managers.csv'
with
(
fieldterminator = ',',
ROWTERMINATOR = '0x0a',
firstrow = 2 , KEEPNULLS
);



BULK INSERT match
from 'C:\Users\Umair Khalid\Desktop\A3\matches.csv'
with
(
fieldterminator = ',',
ROWTERMINATOR = '0x0a',
firstrow = 2 , KEEPNULLS
);


BULK INSERT match_time
from 'C:\Users\Umair Khalid\Desktop\A3\matches_time.csv'
with
(
fieldterminator = ',',
ROWTERMINATOR = '0x0a',
firstrow = 2 , KEEPNULLS
);

BULK INSERT goal
from 'C:\Users\Umair Khalid\Desktop\A3\goals.csv'
with
(
fieldterminator = ',',
ROWTERMINATOR = '0x0a',
firstrow = 2 , KEEPNULLS
);


--All the players that have played under a specific manager.
--=========================================================== QUERY 1===================================================================================
select P.first_name,P.last_name,P.DOB,P.nationality from team T
join manager M on M.team_id = T.ID
join player P on t.ID = P.team_id
where M.ID=30;
--======================================================================================================================================================



--All the matches that have been played in a specific country.
--=========================================================== QUERY 2===================================================================================
select M.ID,M.attendance,sl.country from match M
join stadium S on S.ID = M.stadium_id
join stadium_loc as sl on S.city = sl.city
where sl.country = 'Italy';
--======================================================================================================================================================




--All the teams that have won more than 3 matches in their home stadium. (Assume a team wins only if they scored more goals then other team)
--=========================================================== QUERY 3===================================================================================
select T.ID,T.country,T.name,count(*) as WINS from team T
join match M on T.ID = M.home_team_id AND T.Home_stadium_id = M.stadium_id
where M.home_team_score > M.away_team_score
group by T.ID,T.country, T.name
having count(*) > 3
--======================================================================================================================================================



--All the teams with foreign managers.
--=========================================================== QUERY 4===================================================================================
select M.ID,concat(M.first_name,' ',M.last_name)as NAME,M.DOB,M.nationality from manager M
join team T on M.team_id = T.ID
where M.nationality != t.country;
--======================================================================================================================================================



--All the matches that were played in stadiums with seating capacity greater than 60,000.
--=========================================================== QUERY 5===================================================================================
select M.ID,M.stadium_id,S.capacity,M.attendance from match M
join stadium S on M.stadium_id = S.ID
where S.capacity > 60000;
--======================================================================================================================================================



--All Goals made without an assist in 2020 by players having height greater than 180 cm.
--=========================================================== QUERY 6===================================================================================
select G.ID,G.player_id,G.assist,P.first_name,P.last_name,P.height from goal G
join match M on G.match_id = M.ID
join player P on P.ID = G.player_id
join match_time as MT on M.Date_time = MT.Date_time
where year(Mt.Date_time)=2020 AND G.assist is NULL AND P.height>180
--======================================================================================================================================================




--All Russian teams with win percentage less than 50% in home matches.
--=========================================================== QUERY 7===================================================================================
select T.ID,T.NAME,T.country,sum(case when (M.home_team_score > M.away_team_score) then 1 else 0 end)  * 100 / count(*) as WIN_PERCENTAGE from team T 
join match M on T.ID = M.home_team_id 
where T.country = 'Russia' AND T.Home_stadium_id = M.stadium_id
group by T.ID,T.name,T.country  
having
sum(case when (M.home_team_score > M.away_team_score) then 1 else 0 end) * 100 / count(*) < 50;
--======================================================================================================================================================




--All Stadiums that have hosted more than 6 matches with host team having a win percentage less than 50%.
--=========================================================== QUERY 8===================================================================================
select S.ID,S.city,S.name,T.ID,T.name, count(*) as NO_OF_MATCHES,(sum(case when (M.home_team_score > M.away_team_score AND M.home_team_id = T.ID) then 1 else 0 end)) * 100 / count(*) as WIN_PERCENTAGE
from stadium S
join match M on M.stadium_id = S.ID 
join team T on M.home_team_id = T.ID
group by S.ID,S.city,S.name,T.ID,T.name
having count(*) > 6 AND sum(case when (M.home_team_score > M.away_team_score AND M.home_team_id = T.ID) then 1 else 0 end) * 100 / count(*) < 50
order by S.ID
--======================================================================================================================================================



--The season with the greatest number of left-foot goals.
--=========================================================== QUERY 9===================================================================================
select top 1 MT.season,count(*) as NO_OF_GOALS from goal G
join match M on M.ID = G.match_id
join match_time as MT on M.Date_time = MT.Date_time
where G.goal_des like 'left%'
group by MT.season
order by NO_OF_GOALS desc;
--======================================================================================================================================================



--The country with maximum number of players with at least one goal.
--=========================================================== QUERY 10===================================================================================
select top 1 T.country,count(*) as NUM_OF_PLAYERS from goal G
join player P on P.ID = G.player_id
join team T on P.team_id = T.ID
group by T.country
order by NUM_OF_PLAYERS desc;
 --======================================================================================================================================================


--All the stadiums with greater number of left-footed shots than right-footed shots.
--=========================================================== QUERY 11===================================================================================
select S.ID,S.name,count(case when G.goal_des like 'left%' then 1 end) as LEFT_FOOTED_SHOTS,
count(case when G.goal_des like 'right%'then 1 end) as RIGHST_FOOTED_SHOTS from stadium S
join match M on M.stadium_id = S.ID
join goal G on G.match_id =M.ID
group by S.ID,S.name
having count(case when G.goal_des like 'left%' then 1 end) > count(case when G.goal_des like 'right%'then 1 end)
order by S.ID

--======================================================================================================================================================



--All matches that were played in country with maximum cumulative stadium seating capacity order by recent first.
--=========================================================== QUERY 12===================================================================================
select M.ID,M.stadium_id,M.attendance from match M
join stadium S on S.ID = M.stadium_id 
join stadium_loc as ST on S.city = ST.city
where ST.country = 
(
  select top 1 country
  from stadium join stadium_loc on stadium.city = stadium_loc.city
  group by stadium_loc.country
  order by sum(stadium.capacity) desc
)
order by M.ID desc;
--======================================================================================================================================================



--The player duo with the greatest number of goal-assist combination (i.e. pair of players that have assisted each other in more goals than any other duo).
--=========================================================== QUERY 13===================================================================================
select top 1 player1.ID, concat(player1.first_name,' ', player1.last_name) as FIRST_PLAYER,
player2.ID, concat(player2.first_name,' ', player2.last_name) as SECOND_PLAYER,count(*) as GOAL_ASSIST_COMBINATIONS
from
(
    select G.player_id, G.assist
    from goal G
    join player P1 on G.player_id = P1.ID
    join player P2 on G.assist = P2.ID 
    
	union all

    select G.assist, G.player_id
    from goal G
    join player P1 on G.player_id = P1.ID
    join player P2 on G.assist = P2.ID 
) as combinations
join player player1 on player1.ID = combinations.player_id
join player player2 on player2.ID = combinations.assist
group by player1.ID, player1.first_name, player1.last_name, player2.ID, player2.first_name, player2.last_name
order by GOAL_ASSIST_COMBINATIONS desc;
--======================================================================================================================================================



--The team having players with more header goal percentage than any other team in 2020.
--=========================================================== QUERY 14===================================================================================
select top 1 table1.ID,table1.name,table1.country,table1.goal_des,(table1.GOALS_FROM_HEADER * 100/table2.TOTAL_GOALS)  as HEADER_PERCENTAGE 
from 
(
select T.ID,T.name,T.country,G.goal_des,count(*) AS GOALS_FROM_HEADER from goal G
join player P on P.ID = G.player_id
join team T on T.ID = P.team_id
join match as M on G.match_id = M.ID
join match_time as MT on M.Date_time = MT.Date_time
where G.goal_des = 'header'  and year(Mt.Date_time)=2020
group by T.ID,T.name,T.country,G.goal_des 
) as table1
join 
(
select T.ID,T.name,count(*) AS TOTAL_GOALS from goal G
join player P on P.ID = G.player_id
join team T on T.ID = P.team_id
join match as M on G.match_id = M.ID
join match_time as MT on M.Date_time = MT.Date_time
where year(Mt.Date_time)=2020
group by T.ID,T.name
) as table2 on table1.ID = table2.ID
join team T on table2.ID = T.ID
order by (table1.GOALS_FROM_HEADER * 100/table2.TOTAL_GOALS) desc
--======================================================================================================================================================



--The most successful manager of UCL (2016-202).
--=========================================================== QUERY 15===================================================================================
select top 1 MAN.ID,concat(MAN.first_name,' ',MAN.last_name) as NAME,MAN.nationality,MAN.DOB,count(*) as MATCHES_WON from match M
join team T on M.home_team_id = T.ID OR M.away_team_id = T.ID
join manager MAN on MAN.team_id = T.ID
where 
(
      (M.home_team_id = t.ID AND M.home_team_score > M.away_team_score) 
	  OR
      (M.away_team_id = t.ID AND M.away_team_score > M.home_team_score)
)
group by MAN.ID,MAN.first_name,MAN.last_name,MAN.nationality,MAN.DOB
order by MATCHES_WON desc;

--======================================================================================================================================================




--The winner teams for each season of UCL (2016-2022). 
--=========================================================== QUERY 16===================================================================================
select season, name
from
(
		select MT.season, T.name, row_number() over (partition by MT.season order by MT.Date_time desc) as row_num
		from match M join team T on T.ID = M.home_team_id OR T.ID = M.away_team_id
		join match_time MT on M.Date_time= MT.Date_time 
		where 
		( 
					(M.home_team_id = T.ID AND M.home_team_score > M.away_team_score)
					OR 
					(M.away_team_id = T.ID AND M.away_team_score > M.home_team_score)
				)
		group by MT.season, MT.Date_time,T.name

 )as subquery where row_num = 1;

--======================================================================================================================================================
