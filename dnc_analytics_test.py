import mysql.connector
import csv

cnx = mysql.connector.connect(user='paul', password='C22itbcti.',
                              host='DESKTOP-5L37TAN',
                              database='dnc')

cursor = cnx.cursor()

query = ('''select
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
''')

cursor.execute(query)

with open("question_13.csv", "w", newline ='') as csv_file:
    csv_writer = csv.writer(csv_file)
    csv_writer.writerow([i[0] for i in cursor.description])
    csv_writer.writerows(cursor)
    
    