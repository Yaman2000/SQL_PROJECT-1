select *from data1;
select *from data4;


---find total no. of rows

select count(*) from data1;
select count(*) from data4;

--dataset for jharkhand and bihar
--use filter condition

select *from data1 where state in('jharkhand', 'bihar');

--cal total population of india
select sum(population) as pop from data4;

--avg growth for a year

select avg(growth)*100 as growth from data1;

--identifty avg growth by state wise
select state,avg(growth)*100  as growth from data1 group by state; 

--identify avg sex ratio from dataset2
select state, avg(sex_ratio) as avg_Sex from data2 group by state order by avg_Sex asc;

--avg literacy rate which is greater than 90(having clause used in aggregate function)
select state, round(avg(Literacy),0) 
as avg_Literacy
from data2 
group by state
having round(avg(Literacy),0)>90
order by avg_Literacy desc;

---top three states which display the highest growth ratio
select top 3 state, avg(growth)*100
as avg_growth
from data2 group by state
order by avg_growth desc; 


----bottom 3 states displaying the lowest sex ratio
select top 3 state, avg(sex_ratio)
as avg_sex
from data2 
group by state
order by avg_sex asc;


--top and bottom 3 states in literacy rate displayed in a table
drop table if exists #top_states_1; 
create table #top_states_1
(state nvarchar(255),
topstate float
)

insert into #top_states_1
select state, round(avg(Literacy),0) 
as avg_Literacy
from data2 
group by state
order by avg_Literacy desc;


--display the topstaes table
select *from #top_states_1;

--order the topstate order in desc
select *from #top_states_1 order by #top_states_1.topstate desc;

---PERFORM SAMETHING FOR FINDING THE BOTTOM STATES


drop table if exists #BOTTOM_states_1; 
create table #BOTTOM_states_1
(state nvarchar(255),
BOTTOMstate float
)

insert into #BOTTOM_states_1
select state, round(avg(Literacy),0) 
as avg_Literacy
from data2 
group by state
order by avg_Literacy desc;


--display the topstaes table
select *from #BOTTOM_states_1;

--order the topstate order in desc
select *from #BOTTOM_states_1 order by #BOTTOM_states_1.BOTTOMstate desc;
  

--COMBINE THESE TWO TABLES INTO SINGLE TABLE
--use union operator

--use a method of subquery
select *from (
select top 3 * from #top_states_1 order by #top_states_1.topstate desc) a

union
select *from(
select top 3 * from #BOTTOM_states_1 order by #BOTTOM_states_1.BOTTOMstate asc) b;




--classify the data which is having state having starting letter a
select *from data1 where state like 'a%';


--classify the state starting with letter a and ending with letter h

select distinct state from data1 where state like 'a%h';



--joining both table
select a.district,a.state,
a.growth,a.sex_ratio,
b.population from data1 a
inner join 
data4 b on a.district=b.district;





--female/males=sex_ratio

--female+ males = population
--find the number of females

--females = population-males
--males = population/(sex_ratio+1)

select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males,
round((c.population* c.sex_ratio)/(c.sex_ratio+1),0) female
from (select a.district,a.state,
a.growth,a.sex_ratio,
b.population from data1 a

INNER JOIN

data4 b on a.district=b.district) c;


--identify statewise population male and female
select d.state, sum(d.males) total_males, sum(d.female) total_female
from (select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males,
round((c.population* c.sex_ratio)/(c.sex_ratio+1),0) female
from (select a.district,a.state,
a.growth,a.sex_ratio,
b.population from data1 a

INNER JOIN

data4 b on a.district=b.district) c) d
group by d.state;

--STATE WHICH IS HAVING HIGH LITERACY RATE

select d.district,d.state,round(d.literacy_ratio*d.population,0) as literate_people, 
round((1-d.literacy_ratio)*d.population,0) as illetrate_people
from(
select a.district,a.state,
a.literacy as literacy_ratio,
a.growth,a.sex_ratio,
b.population from data1 a

INNER JOIN

data4 b on a.district=b.district) d;


--litracy_ratio = total_literate_people/total_population

--illetrate_people = 1-(literacy_ratio * total_population)



--population in previous censes
--previous_cencus+growth*previous_census=population

--previous_census = population/1+growth
select c.state, c.district, round(population/(1+growth),0) as previous_censes,c.population as current_senses_population from(
select a.district,a.state,
a.growth,a.sex_ratio,
b.population from data1 a

INNER JOIN

data4 b on a.district=b.district) c;




select sum(m.previous_censes) as previous_censes, sum(current_censes_population) as current_censes_population from(
select e.state, sum(e.previous_censes) as previous_censes, sum(current_censes_population) as current_censes_population from(
select c.state, c.district, round(c.population/(1+c.growth),0) as previous_censes,c.population as current_censes_population from(
select a.district,a.state,
a.growth,a.sex_ratio,
b.population from data1 a

INNER JOIN

data4 b on a.district=b.district) c)e group by e.state)m;


--population vs area

select q.*, r.* from(
select '1' as keyy,n.* from(
select sum(m.previous_censes) as previous_censes, sum(current_censes_population) as current_censes_population from(
select e.state, sum(e.previous_censes) as previous_censes, sum(current_censes_population) as current_censes_population from(
select c.state, c.district, round(c.population/(1+c.growth),0) as previous_censes,c.population as current_censes_population from(
select a.district,a.state,
a.growth,a.sex_ratio,
b.population from data1 a

INNER JOIN

data4 b on a.district=b.district) c)e group by e.state)m)n)q 

inner join(

select '1' as keyy,z. *from(
select sum(Area_km2) as total_area from data4) z) r on q.keyy=r.keyy;


--top three districts from each state which is having high literacy rate using window function


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) rnk from data1) a

where a.rnk in (1,2,3) order by state;












