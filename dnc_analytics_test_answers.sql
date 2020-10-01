-- 1
select count(*)

from TestTable

-- 2
select
Firstname,
Lastname

from Person

-- 3
select
Firstname,
count(Lastname)

from Person

group by 1

-- 4
select
Firstname,
Lastname,
Address1,
Address2,
City,
State,
Zip

from
(
select
PersonID,
Firstname,
Lastname

from Person
) as T1

inner join
(
select
PersonID,
Address1,
Address2,
City,
State,
Zip

from PersonAddress
) as T2

on T1.PersonID = T2.PersonID

-- 5
select
Firstname,
Lastname,
case when Address1 is null then 'PLACEHOLDER DATA' else Address1 end as Address1,
case when Address1 is null then 'PLACEHOLDER DATA' else Address2 end as Address2, -- Address 1 used in all case when statements under assumption that all entries in PersonAddress at least have a value for Address1 (maybe not for Address2, etc.)
case when Address1 is null then 'PLACEHOLDER DATA' else City end as City,
case when Address1 is null then 'PLACEHOLDER DATA' else State end as State,
case when Address1 is null then 'PLACEHOLDER DATA' else Zip end as Zip

from
(
select
PersonID,
Firstname,
Lastname

from Person
) as T1

left join
(
select
PersonID,
Address1,
Address2,
City,
State,
Zip

from PersonAddress
) as T2

on T1.PersonID = T2.PersonID

-- 6
CREATE TEMPORARY TABLE Person_Info_Tmp
(
  Firstname varchar(100),
  Lastname varchar(100),
  Address1 varchar(100),
  Address2 varchar(100),
  City varchar(100),
  State varchar(100),
  Zip varchar(100)
);

INSERT INTO Person_Info_Tmp
select
Firstname,
Lastname,
case when Address1 is null then 'PLACEHOLDER DATA' else Address1 end as Address1,
case when Address1 is null then 'PLACEHOLDER DATA' else Address2 end as Address2,
case when Address1 is null then 'PLACEHOLDER DATA' else City end as City,
case when Address1 is null then 'PLACEHOLDER DATA' else State end as State,
case when Address1 is null then 'PLACEHOLDER DATA' else Zip end as Zip

from
(
select
PersonID,
Firstname,
Lastname

from Person
) as T1

left join
(
select
PersonID,
Address1,
Address2,
City,
State,
Zip

from PersonAddress
) as T2

on T1.PersonID = T2.PersonID

-- 7
CREATE SCHEMA sample_schema;

CREATE TABLE Person (
  person_id int NOT NULL AUTO_INCREMENT,
  first_name varchar(100),
  last_name varchar(100),
  date_of_birth DATE,
  mother_id int,
  father_id int,
  PRIMARY KEY (person_id)
);

CREATE TABLE PersonAddress (
  address_id int NOT NULL AUTO_INCREMENT,
  address1 varchar(100),
  address2 varchar(100),
  city varchar(100),
  state char(2),
  zip numeric(5,0),
  person_id int NOT NULL,
  PRIMARY KEY (address_id),
  FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

CREATE TABLE PersonEmail (
  email_id int NOT NULL AUTO_INCREMENT,
  email_address varchar(100),
  primary_address_flag bit,
  person_id int NOT NULL,
  PRIMARY KEY (email_id),
  FOREIGN KEY (person_id) REFERENCES Person(person_id)
);

-- 8
INSERT INTO Person
VALUES (1, 'Andrew', 'Smith', '1990-01-23', 2, 3),
(2, 'Erika', 'Smith', '1970-03-13', NULL, NULL),
(3, 'Joseph', 'Smith', '1968-01-03', NULL, NULL),
(4, 'Stephanie', 'Wang', '1980-11-22', NULL, 5),
(5, 'Doug', 'Wang', '1945-06-01', 2, 3);

INSERT INTO PersonAddress
VALUES (1, '1010 N 10th St', NULL, 'Dallas', 'TX', 75232, 4),
(2, '1500 Washington Ave', 'Apt. 404', 'Minneapolis', 'MN', 55405, 2),
(3, '1500 Washington Ave', 'Apt. 404', 'Minneapolis', 'MN', 55405, 3),
(4, '1234 56th St', 'Apt. 101', 'Des Moines', 'IA', 50000, 1),
(5, '100 Palm Tree Avenue', NULL, 'Houston', 'TX', 70231, 5);

INSERT INTO PersonEmail
VALUES (1, 'andrew.smith@gmail.com', 1, 1),
(2, 'spwang@yahoo.com', 0, 4),
(3, 'smithjoseph@hotmail.com', 1, 3),
(4, 'erikajsmith@gmail.com', 1, 2),
(5, 'doug.wang53@gmail.com', 1, 5);

-- 9
select
mailing_name,
count(mailing_recipient_id) as recipient_count,
sum(open_flag) as open_count,
sum(open_flag)/count(mailing_recipient_id) as opens_per_recipient,
sum(click_flag) as click_count,
sum(click_flag)/count(mailing_recipient_id) as clicks_per_recipient,
sum(donate_flag) as number_of_donations,
sum(donate_flag)/count(mailing_recipient_id) as donations_per_recipient,
sum(transaction_amt) as sum_of_dollars_donated, -- not asked for, but I wanted to have in case a certain email received more dollars per donation than another email
sum(transaction_amt)/count(mailing_recipient_id) as dollars_donated_per_recipient

from
(
select
mailing_id,
base3.mailing_recipient_id,
base3.cons_id,
click_flag,
open_flag,
transaction_amt,
case when transaction_amt is null then 0 else 1 end as donate_flag

from
(
select
mailing_id,
base2.mailing_recipient_id,
cons_id,
click_flag,
case when open_id is null then 0 else 1 end as open_flag

from
(
select
mailing_id,
base.mailing_recipient_id,
cons_id,
case when click_id is null then 0 else 1 end as click_flag

from
(
select
mailing_id,
mailing_recipient_id,
cons_id

from mailing_recipient
) as base

left join
(
select
mailing_recipient_id,
mailing_recipient_click_id as click_id

from mailing_recipient_click

where mailing_recipient_click_type_id = 1
) as click

on base.mailing_recipient_id = click.mailing_recipient_id
) as base2

left join
(
select
mailing_recipient_id,
mailing_recipient_click_id as open_id

from mailing_recipient_click

where mailing_recipient_click_type_id = 2
) as open_

on base2.mailing_recipient_id = open_.mailing_recipient_id
) as base3

left join
(
select cons_id, transaction_amt

from cons_action_contribution
) as cons

on base3.cons_id = cons.cons_id
) as total_dataset

join
(
select
mailing_id,
mailing_name

from mailing
) mailing_name

on total_dataset.mailing_id = mailing_name.mailing_id

group by 1

-- 10
''' Based on these data, I think Mailing B should be sent out to maximize fundraising. It received the greatest numbers of donations per email sent, and received the most dollars donated per email sent.
'''

-- 11
select
mailing_name,
gender,
count(mailing_recipient_id) as recipient_count,
sum(open_flag) as open_count,
sum(open_flag)/count(mailing_recipient_id) as opens_per_recipient,
sum(click_flag) as click_count,
sum(click_flag)/count(mailing_recipient_id) as clicks_per_recipient,
sum(donate_flag) as number_of_donations,
sum(donate_flag)/count(mailing_recipient_id) as donations_per_recipient,
sum(transaction_amt) as sum_of_dollars_donated, -- not asked for, but I wanted to have in case a certain email received more dollars per donation than another email
sum(transaction_amt)/count(mailing_recipient_id) as dollars_donated_per_recipient

from
(
select
mailing_id,
base3.mailing_recipient_id,
base3.cons_id,
base3.gender,
age_id,
click_flag,
open_flag,
transaction_amt,
case when transaction_amt is null then 0 else 1 end as donate_flag

from
(
select
mailing_id,
base2.mailing_recipient_id,
cons_id,
gender,
age_id,
click_flag,
case when open_id is null then 0 else 1 end as open_flag

from
(
select
mailing_id,
base.mailing_recipient_id,
cons_id,
gender,
age_id,
case when click_id is null then 0 else 1 end as click_flag

from
(
select
mailing_id,
mailing_recipient_id,
mailing_recipient.cons_id,
gender,
age_id

from mailing_recipient

join cons
on mailing_recipient.cons_id = cons.cons_id
) as base

left join
(
select
mailing_recipient_id,
mailing_recipient_click_id as click_id

from mailing_recipient_click

where mailing_recipient_click_type_id = 1
) as click

on base.mailing_recipient_id = click.mailing_recipient_id
) as base2

left join
(
select
mailing_recipient_id,
mailing_recipient_click_id as open_id

from mailing_recipient_click

where mailing_recipient_click_type_id = 2
) as open_

on base2.mailing_recipient_id = open_.mailing_recipient_id
) as base3

left join
(
select cons_id, transaction_amt

from cons_action_contribution
) as cons

on base3.cons_id = cons.cons_id
) as total_dataset

join
(
select
mailing_id,
mailing_name

from mailing
) mailing_name

on total_dataset.mailing_id = mailing_name.mailing_id

group by 1, 2

order by 1, 2

-- 12
select
mailing_name,
case when age_id=0 then '18-35' when age_id=1 then '36-60' else '60+' end as age_group,
count(mailing_recipient_id) as recipient_count,
sum(open_flag) as open_count,
sum(open_flag)/count(mailing_recipient_id) as opens_per_recipient,
sum(click_flag) as click_count,
sum(click_flag)/count(mailing_recipient_id) as clicks_per_recipient,
sum(donate_flag) as number_of_donations,
sum(donate_flag)/count(mailing_recipient_id) as donations_per_recipient,
sum(transaction_amt) as sum_of_dollars_donated, -- not asked for, but I wanted to have in case a certain email received more dollars per donation than another email
sum(transaction_amt)/count(mailing_recipient_id) as dollars_donated_per_recipient

from
(
select
mailing_id,
base3.mailing_recipient_id,
base3.cons_id,
base3.gender,
age_id,
click_flag,
open_flag,
transaction_amt,
case when transaction_amt is null then 0 else 1 end as donate_flag

from
(
select
mailing_id,
base2.mailing_recipient_id,
cons_id,
gender,
age_id,
click_flag,
case when open_id is null then 0 else 1 end as open_flag

from
(
select
mailing_id,
base.mailing_recipient_id,
cons_id,
gender,
age_id,
case when click_id is null then 0 else 1 end as click_flag

from
(
select
mailing_id,
mailing_recipient_id,
mailing_recipient.cons_id,
gender,
age_id

from mailing_recipient

join cons
on mailing_recipient.cons_id = cons.cons_id
) as base

left join
(
select
mailing_recipient_id,
mailing_recipient_click_id as click_id

from mailing_recipient_click

where mailing_recipient_click_type_id = 1
) as click

on base.mailing_recipient_id = click.mailing_recipient_id
) as base2

left join
(
select
mailing_recipient_id,
mailing_recipient_click_id as open_id

from mailing_recipient_click

where mailing_recipient_click_type_id = 2
) as open_

on base2.mailing_recipient_id = open_.mailing_recipient_id
) as base3

left join
(
select cons_id, transaction_amt

from cons_action_contribution
) as cons

on base3.cons_id = cons.cons_id
) as total_dataset

join
(
select
mailing_id,
mailing_name

from mailing
) mailing_name

on total_dataset.mailing_id = mailing_name.mailing_id

group by 1, 2

order by 1, 2

-- 13
-- See Python and csv file

-- 14
-- see word doc.

-- 15
-- see word doc.
