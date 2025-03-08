use ipl;
select * from ipl_bidding_details;

# Answer1


select bidder_id,schedule_id,bid_status,
row_number()over(partition by bidder_id),
ifnull(bid_status= 'won',1)chances,
sum(ifnull(bid_status= 'won',1))over(partition by bidder_id)won,
count(bid_status)over(partition by bidder_id), 
 (sum(ifnull(bid_status= 'won',1))over(partition by bidder_id)/(count(bid_status)over(partition by bidder_id) )) *100  as percentage
 from ipl_bidding_details;

select distinct bidder_id,(sum(ifnull(bid_status= 'won',1))over(partition by bidder_id)/(count(bid_status)over(partition by bidder_id) )) *100  
as win_percentage  from ipl_bidding_details;

#Answer 2



select distinct ipls.stadium_id,ipls.stadium_name,count(ims.match_id)over(partition by stadium_id),
i
from ipl_stadium ipls join ipl_match_schedule ims
on ipls.stadium_id = ims.stadium_id;

#Answer 3




select * ,((toss_and_match_win/total_matches)*100)  wt_percentage from
(select distinct ipls.stadium_id,ipls.stadium_name,count(ims.match_id)over(partition by stadium_id) total_matches,
count(if(toss_winner = match_winner,1,null))over(partition by stadium_id) as toss_and_match_win
from ipl_stadium ipls join ipl_match_schedule ims
on ipls.stadium_id = ims.stadium_id
join IPL_MATCH im
on ims.match_id = im.match_id) temp;

#Answer 4




select  distinct it.team_id,it.team_name,count(ibd.bid_team)over(partition by team_id) total_bid
from ipl_team it join ipl_bidding_details ibd
on it.team_id = ibd.bid_team;

# Answer 5

select * from ipl_match;

select if(match_winner = 1,team_id1,team_id2)as team_id,win_details from ipl_match;

# Answer 6

 select team_name,total,win,(total-win)loss from        
(select distinct count(if(match_winner = 1,team_id1,team_id2))over(partition by team_id) as win, it.team_name, 
(Select count(match_id) from IPL_MATCH where team_id1 = it.team_id OR team_id2 = it.TEAM_ID) as total 
from ipl_match im join IPL_TEAM it 
on if(match_winner = 1,team_id1,team_id2) = it.team_id)t;


#Answer 7



select ip.player_id,ip.player_name 
from ipl_player ip join ipl_team_players itp
on ip.player_id = itp.player_id
where team_id = 6 and player_role = 'bowler';

#Answer 8

select distinct team_id,count(if(player_role = 'all-rounder',1,null))over(partition by team_id) all_rounder from IPL_TEAM_PLAYERS order by all_rounder desc;

#Answer 9


select ibp.bidder_id,ibd.bid_status,year(ibd.bid_date),sum(ibp.total_points)over(partition by bidder_id) total_points
from ipl_bidder_points ibp join ipl_bidding_details ibd
on ibp.bidder_id = ibd.bidder_id
join ipl_match_schedule ims
on ibd.schedule_id = ims.schedule_id
where bid_team = (select team_id from ipl_team where team_name = 'Chennai Super Kings')  and bid_status = 'won' 
and stadium_id in (Select stadium_id from ipl_stadium where stadium_name =  'M. Chinnaswamy Stadium')
order by year(ibd.bid_date),total_points desc;


#Answer 10

select player_name,substr(wkt,5,3) w  from
(select player_id,player_name,substr(performance_dtls,instr(performance_dtls,'wkt-'),instr(performance_dtls,' Dot')-instr(performance_dtls,'wkt-')) as wkt  from ipl_player)t;

#Answer 11

select  * , ((ww/total)*100) win_toss_percentage from 
 ( select  distinct ibd.bidder_id,count(if(bid_team = if(im.toss_winner = 1,im.team_id1,im.team_id2),1,null))over(partition by bidder_id) ww,count(bidder_id)over(partition by bidder_id) total from ipl_bidding_details ibd left join IPL_MATCH_SCHEDULE ims on ibd.schedule_id = ims.schedule_id 
  left join ipl_match im on ims.match_id = im.match_id)temp;

#Answer 12


select tournmt_id,tournmt_name,datediff(to_date,from_date)duration,max(datediff(to_date,from_date))over() max_duration from ipl_tournament;

#Answer 13


select distinct ibd.bidder_id,ibd.bidder_name,year(iplbd.bid_date),month(iplbd.bid_date),sum(ibp.total_points)over(partition by bidder_id,month(bid_date))
from ipl_bidder_details ibd join ipl_bidding_details iplbd
on ibd.bidder_id = iplbd.bidder_id
join ipl_bidder_points ibp
on iplbd.bidder_id = ibp.bidder_id
where year(iplbd.bid_date) = 2017;

#Answer 14
select  ibd.bidder_id, month(bid_date) as m,(Select bidder_name from ipl_bidder_details where bidder_id = ibd.bidder_id) as name,'2017' as year,
     ( select sum(total_points)over(partition by bidder_id, m) from IPL_BIDDER_POINTS where bidder_id = ibd.bidder_id and month(bid_date) = m) as total     
  from IPL_BIDDING_DETAILS ibd where year(bid_date) = 2017 group by bidder_id, m, name, year, total;



#Answer 15

# for highest
select * from
(select *,rank()over(order by total desc) as rnk from
(select distinct ibd.bidder_id,ibd.bidder_name,year(iplbd.bid_date),sum(ibp.total_points)over(partition by bidder_id) total
from ipl_bidder_details ibd join ipl_bidding_details iplbd
on ibd.bidder_id = iplbd.bidder_id
join ipl_bidder_points ibp
on iplbd.bidder_id = ibp.bidder_id
where year(iplbd.bid_date) = 2018)temp)t
where rnk <=3;

# for lowest
select * from
(select *,rank()over(order by total asc) as rnk from
(select distinct ibd.bidder_id,ibd.bidder_name,year(iplbd.bid_date),sum(ibp.total_points)over(partition by bidder_id) total
from ipl_bidder_details ibd join ipl_bidding_details iplbd
on ibd.bidder_id = iplbd.bidder_id
join ipl_bidder_points ibp
on iplbd.bidder_id = ibp.bidder_id
where year(iplbd.bid_date) = 2018)temp)t
where rnk <=3;


# Answer 16
create table student_details(student_id int primary key,
							student_name varchar(20) not null,
                            mail_id varchar(20) unique,
                            mobile_no varchar(10)unique not null );
                            
create table student_details_backup(student_id int ,
							 foreign key (student_id) references student_details(student_id) on update cascade,
							student_name varchar(20),
                            mail_id varchar(20),
                            mobile_no varchar(10));
                            
                            
         
 
         
         
         
         
         
         
         

  
  
  
  