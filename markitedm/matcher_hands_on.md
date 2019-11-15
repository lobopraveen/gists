[IHS Markit](https://ihsmarkit.com/products/edm.html) defines Enterprise Data Management (EDM) as

> EDM is a data management platform for acquiring, validating and distributing trade, operational, risk, financial and customer data. It creates a single version of the truth in a consistent, transparent and fully audited environment. Firms benefit from greater control, ongoing compliance and transparency of their data.

Markit has it's own product for Enterprise Data Management called Markit EDM. I have fairly decent exposure to this tool including passing Markit's core introduction and advanced course. Any MEDM person worth their salt would agree that the Data Matcher is the heart of the MEDM. It is also one of the complicated components that is daunting and gets out of hand easily at which point no one wants to touch it! I had limited experience with the matcher as it was already setup by the time I came on board the project and it was being managed by a few other people. This whole post is about my hands-on with the Data Matcher to gain more experience with the component.

Please note that the entire thing below was carelessly jotted down which I cleaned up after a year or so. You might find a lot of case mismatches, abbreviations, and even some random sentences where it really didn't make any sense to me. I'm not trying to make it 100% accurate but just documenting it as is so that if I ever get a hold of an MEDM instance I can follow along. If you are currently working in MEDM, this might make a whole lot of sense to you!

Warning: Markit introduced a replacement for the Data Matcher called the Core Matcher in their 11.x release. It is much faster, less cumbersome, and easier to manage. This page is not about the Core Matcher; yuo probably don't even want to read this junk!

### Abbreviations

- ZX - is a prefix I used just so I can sort the objects easil towards the bottom in the list.
- ZXMCHR - Code for Matcher - MCHR with ZX prefix
- BB - Bloomberg
- PNT - Point
- BRS - BlackRock

### Observations

I listed down the observations shown below as I was going through the setup and different scenarios as described in the post below starting from the Setup. If it doesn't make sense now, come back after going though the whole thing.

- Each matcher gets `CADIS.DM_ZXMCHR_INBOX`, `CADIS.DM_ZXMCHR_KEYS`, `CADIS.DM_ZXMCHR_SEARCH` views. Inbox views are created for individual sources as well.

- Each source gets `CADIS.DM_ZXMCHR_ZXSOURCE_INFO`, `CADIS.DM_ZXMCHR_ZXSOURCE_INFOALL`, `CADIS.DM_ZXMCHR_ZXSOURCE_OUT` views.
- `CADIS_PROC` gets the main tables - `DM_MATCHPOINTx` and `DM_MP4_SOURCExxx` where x is a digit.
- CADIS data matcher views store all columns from the source even if the columns are unchecked in the rule columns stage
- Added master table as reference input without any rules and no data shows up in the CADIS DM INFO, INFOALL, OUT views.
- CADIS DM_*CODE*\_KEYS view (match point keys) has the CADIS ID, obsolete, and exists? column for each source and changed by.
- The exists column was true even after the row was deleted from the source but false after running the matcher.  
- DM_*CODE*\_SEARCH shows acceptor's name in the last modified column! It removes the row if the input row is deleted without even running the matcher.
- All other places show data matcher if you accept its proposal. If you change the proposal then it shows your name.
- Each source gets some random number and MEDM creates CADIS_PROD schema > DM_... tables with that number. It gives keys and revisions.
- Revision table is where the key is stored even when the source record is deleted when not asked (unchecked) to remove CADIS ID association. If it is checked then it deletes it from revision table also hence a new CADIS ID if it comes back again.

### Setup for hands on
- 4 sources. 1 master table.
- Master is not required as input source usually. Three others sources are BB, BRS, and PNT.
- Master table - `zxMasterSMF (AssetID, bbgid, cusip, BRScusip, pointid, isin, country, currency)`
 - master table has CADIS ID called AssetID and keys for each source i.e. bbgid, BRScusip, and pointid.
 - reference input
 - dups not allowed but appear in inbox
 - include CADIS revision
 - re-present manual overrides
 - generate all possible matches.
- BB table - `zxbbsmf (bbgid, cusip, isin, country, currency)`
 - normal input
 - dups not allowed but appear in inbox
 - def will not show in inbox
 - pass to matcher if subsequent run results in a different match
 - include CADIS revision , re-present manual overrides, generate all possible matches.
- BRS table - `zxbrssmf (brscusip, isin, country, currency)`
 - normal input
 - dups not allowed but appear in inbox
 - def will show in inbox
 - pass to matcher if subsequent run results in diff match
 - include CADIS revision
 - re-present manual overrides
 - generate all possible matches
- PNT table - `zxPointSMF (Pointid, cusip, isin, country, currency)`
 - normal input
 - dups allowed
 - pass to matcher if subsequent run results in diff match
 - include CADIS revision
 - if a record is no longer present
 - remove associate with assigned CADIS id
- Uncheck everything not needed in match rules in the rule columns.


### Rules
- master
 - has no rules
- BB
 - bbgid on master at 100%
- BRS
 - threshold set to 75
 - brscusip on master at 100%
 - BRScusip to bb cusip + isins at 90
 - just isin on bb at 80
 - rule type insert 76% if country is russia
 - rule type dedup on brscusip
- PNT
 - threshold set to 70
 - pointid on master at 100%
 - cusip + isin on bb at 70%
 - just cusip or isin match on bb at 65


### Day 1

Think of the `INSERT` statements into BB, BRS, and PNT tables as the incoming records from that source that has been validated already.

```sql
insert into zxbbsmf (bbgid, cusip, isin, country, currency)
values ('bb1', 'cusip1', 'isin1', 'us', 'usd')
       ('bb2', 'cusip2', 'isin2', 'us', 'usd')
````

Default 1000 & 1001.  0 confidence.

I wanted it to start at 1001. Realign didn't work and it is not straight forward to restart the matcher. I ended up meddling with the CADIS tables to reset. Then reran to start at 1001.

Let's say we take matcher output and master the data. The inserts into the master table would look like below. Treat all `INSERT` and `UPDATE` statements into the master table as the result of the matcher output and result of mastering process.

```sql
insert into zxMasterSMF (AssetID,bbgid,cusip,BRScusip,pointid,isin,country,currency)
values (1001, 'bb1', 'cusip1', null, null, 'isin1', 'us', 'usd'),
       (1002, 'bb2', 'cusip2', null, null, 'isin2', 'us', 'usd')
```

Let's say we received BRS inputs on same day.

```sql
insert into zxbrssmf (brscusip, isin, country, currency)
values ('brs1', 'isin1', 'us', 'usd'),
       ('brs2', 'isin2', 'us', 'usd')
```

Matched properly. high confidence 80%.

The result of mastering process would update the BRScusip on the master table.

```sql
update zxMasterSMF set BRScusip = 'brs1' where AssetID = 1001
update zxMasterSMF set BRScusip = 'brs2' where AssetID = 1002
```

### Day 2

```sql
delete from zxbbsmf where bbgid = 'bb1'
```

This deleted the row from `OUT` and `INFO` views but `INFOALL` view had the record with null in all columns from source and `CADIS_system_` & `CADIS` revision columns turned to null.

Match point key still said true for bb exists column!?


```sql
delete from zxbbsmf where bbgid = 'bb2'

insert into zxbbsmf (bbgid, cusip, isin, country, currency)
values ('bb2', 'cusip2', 'isin2', 'canada', 'csd'),
       ('bb3', 'cusip3', 'isin3', 'india', 'inr')

insert into zxbrssmf (brscusip, isin, country, currency)
values ('cusip3', 'isin3brs','us', 'usd')   
```

Mastering didn't change `CADIS`. 1001 gets updated and 1003 gets created as expected.

```sql
update zxMasterSMF set country = 'canada', currency = 'csd' where AssetID = 1001

insert into zxMasterSMF (AssetID, bbgid, cusip, BRScusip, pointid, isin, country, currency)
values (1003, 'bb3','cusip3', null,null,'isin3','india', 'inr')
```

This gives a low confidence match. provisional 1. After accepting, only the search view shows my id rest all say matcher.

```sql
update zxMasterSMF set BRScusip = 'cusip3' where AssetID = 1003
```


### Day 3

```sql
insert into zxbbsmf (bbgid, cusip, isin, country, currency)
values ('bb4', 'cusip4', 'isin4', 'pak', 'pnr'),
       ('bb5', 'cusip5', 'isin5', 'pak', 'pnr')

insert into zxbrssmf (brscusip, isin, country, currency)
values ('cusip4', 'isin4','pak', 'usd')
```

This leads to default insertion.

```sql
insert into zxMasterSMF (AssetID, bbgid, cusip, BRScusip, pointid, isin, country, currency)
values (1004, 'bb4','cusip4', null, null, 'isin4', 'pak', 'pnr'),
       (1005, 'bb5','cusip5', null, null, 'isin5', 'pak', 'pnr')
```

High confidence match. no inbox.

```sql
update zxMasterSMF set BRScusip = 'cusip4' where AssetID = 1004
```

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (4, 'cusip4', 'isin4pnt', 'us', 'usd'),
       (5, 'cusip5pnt', 'isin5', 'us', 'usd')
```

Both low confidence & end up in inbox . Accept.

```sql
update zxMasterSMF set Pointid = 4 where AssetID = 1004
update zxMasterSMF set Pointid = 5 where AssetID = 1005  
```

Let's say,
```sql
delete from zxPointSMF  where Pointid = 5
```

No change without running matcher. `INFOALL` view turned all nulls, other views didn't show the record.

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (5, 'cusip5pnt', 'isin5', 'us', 'usd')
```

No change without running matcher. All views showed data like nothing happened.

```sql
delete from zxPointSMF  where Pointid = 5
```

Run matcher. Deleted the row from `INFOALL` as well because of the remove association property

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (5, 'cusip4', 'isin4', 'us', 'usd')
```

Results in high confidence match but in inbox because of duplicate. There is already a 1004 with the same cusip + isin. Accept.

```sql
update zxMasterSMF set Pointid = 5 where AssetID = 1004
```

Then run without any changes on pnt. Nothing happens. Since pointid 5 on the master is now pointing to 1004 and 1005, I thought it would say subsequent run different match but it doesn't. May be because I don't have any rules on the master source?!

```sql
update zxPointSMF set cusip = null where Pointid = 4
```

Run matcher on pnt. `INFOALL` table got updated with null cusip. Came up now as subsequent run no match. It is because master source has no rules!

```sql
update zxPointSMF set cusip = 'cusip5' where Pointid = 4
```

Just to see if it now says different match. Yes, it does! Other possible matches shows 1005 which is as expected.

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (50, 'cusip50pnt', 'isin50', 'us', 'usd')

update zxMasterSMF set Pointid = 50 where AssetID = 1001
```

I thought 50 would match on master but it doesn't! It seems nothing matches master as there are no rules. It seems to be matching only on the internal table and not the the real source table in inbox. Default insertion 1006

```sql
insert into zxMasterSMF (AssetID, bbgid, cusip, BRScusip, pointid, isin, country, currency)
values (1006, null, 'cusip50pnt', null, null, 'isin50', 'us', 'usd')
```

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (51, 'cusip50pnt', 'isin50','us', 'usd')
```

In inbox 1007. Don't accept it yet.

```sql
update zxPointSMF set cusip = 'cusip4', isin = 'isin4' where Pointid = 51
```

Run update without accepting anything in inbox. The item outstanding still says 1007 default insert in inbox.

Run matcher. Nothing happens! But other possible matches show 1004. 1007 in KEYS view was marked obsolete.

The revision table in CADIS_proc schema shows the trail of how CADIS id is changing. It has two rows for 51 - 1007 & 1004 in that order.

Accepted to 1004. Shows up as Manual user insertion (marked as new) low confidence

`dm_code_search` view says proposed is also 1004 haha! It was 1007 before. After manual it changed to 1004. Doesn't sound right. Or may be because I ran update and then matcher.

Manual realign point id 4 to 1001 just because.

Actually can't do 1001 as it has been deleted from bb source and we don't have rules on master source. Do 1003.
Realign done. It says manual user match. low confidence.

Run matcher. Should show up in inbox.

Doesn't. As the re-present to matcher option is off.

```sql
update zxPointSMF set cusip = 'cusip5', isin = 'isin5' where Pointid = 4  
```

Now I should see subsequent diff match. But it doesn't show up. Re-present is off.


### Day 4

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (3, 'cusip3', 'isin3', 'us', 'usd')
```

Run matcher. Showed up as high confidence dup. Because there is 1003 already.

Misaligned it to 1002. Says manual user insertion marked as new and low confidence.

Ran matcher. Now it says subsequent diff match to 1003. Makes sense.

Manually realigned stays but realignment from inbox doesn't.

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (10, 'cusip10', 'isin10', 'us', 'usd'),
       (11, 'cusip10', 'isin10', 'usdup', 'usddup')
```

Shows up as 2 new. Accepted 10 as 1008. Realigned 11 to 1008 instead of accepting 1009. 1009 got marked as obsolete.


Ran matcher. Said subsequent no match. Marked as new and saved. Got new CADIS 1010. Says manual insertion - low confidence

Ran matcher - subsequent no match. Just accepted as is. Keeps coming up.

Diff between this and one before is that the one before doesn't show up as it says default insertion.

```sql
insert into zxbbsmf (bbgid, cusip, isin, country, currency)
values ('bb10', 'cusip10', 'isin10', 'us', 'usd')
```

This got new CADIS as 1011. The master table is not being referenced! There is no reciprocal rule from bb to pnt. Otherwise this would have ended up in the inbox due to multiple matches.

1008 and 1010 came up in inbox with subsequent diff match as they both now match to 1011


### Day next

```sql
insert into zxbrssmf (brscusip, isin, country, currency)
values ('bcusip6', 'isin6brs', 'us', 'usd'),
       ('bcusip66', 'isin6brs', 'us', 'usd'),
       ('bcusip7', 'isin7brs', 'russia', 'rbl'),
       ('bcusip8', 'isin8brs', 'russia', 'rbl'),
       ('bcusip88', 'isin8brs', 'russia', 'rbl')
```

Inserted last three as 1012, 1013, and 1014 because of russia insert rule. First two ended up in inbox with default insertion. 1015 & 1016 accept all.

Changed rule type dedupe to check on isin as on brscusip can't be tested. Table has brscusip as pk so no dup there!

1015 and 1016 came up as subsequent diff match. Tried to assign 1016 to 1015 but errors out as source says no dups allowed.

1013 & 1014 didn't show up as dups because russia is at 76 and dedupe at 75. Accept but they show up in run. Don't accept. Uncheck re-present to matcher. Accept and then re-run. No change. Same thing. Keeps showing up.

```sql
update  zxbrssmf set isin = 'isin66brs' where BRScusip = 'bcusip66'
```

Run matcher. No issues now.

```sql
insert into zxbrssmf (brscusip, isin, country, currency)
values ('bcusip666', 'isin6brs', 'us', 'usd')
```

I thought it'd say dup not allowed so adding diff id and inbox but NOPE! Rule type dedup took precedence and assigned isin6brs 1015 and no inbox!

Moved dedup on isin to 77 so russia is 76 confidence

Rerun. Now 1015 & 1016 show up as subsequent diff match.

```sql
delete from zxBBsmf where bbgid = 'bb10'
```

All that matched on bb10 come up as subsequent no match. Just accept. This repeats.

```sql
insert into zxbbsmf (bbgid, cusip, isin, country, currency)
values ('bb10', 'cusip10', 'isin10', 'us', 'usd')
```

Nothing shows up in inbox now.

```sql
delete from zxPointSMF where Pointid = 33

insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (33, 'cusip33', 'isin33', 'us', 'usd')
```  

Now 33 gets new CADIS id. Old is obsolete. This is because I ask it to not store once source drops the record. So if we are matching pos (?) then I can have id on id rule type dedup and it will dedup.

Rule type insert will insert as long as it is highest confidence. Even if you say no dups.

Changed pnt cusip and isin match to be high confidence.

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (44, 'cusip5', 'isin4', 'us', 'usd')
```

High confidence multiple match.

```sql
insert into zxbbsmf (bbgid, cusip, isin, country, currency)
values ('bb123', 'cusip123', 'isin123', 'canada', 'csd'),
       ('bb124', 'cusip124', 'isin124', 'india', 'inr')
```

Def insert.

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (123, 'cusip124', 'isin123', 'us', 'usd')
```

Insert on cusip match. So multiple high confidence match to different ids don't show in the inbox.

```sql
delete from zxBBsmf where cusip = 'cusip5' or isin ='isin4'
```

Run matcher. All that matched with above rows show up as subsequent no match.

Add rules to master - just enable complimentary on bbgid, brsid, pnt id ones.

```sql
insert into zxMasterSMF (AssetID, bbgid, cusip, BRScusip, pointid, isin, country, currency)
values (1018, 'bb124','cusip124', null,123,'isin124','india', 'inr')
```
Then run matcher once. Now it should store all relationships. Also, point id 5 and 50 come up as subsequent diff match. Expected. Doing nothing.

```sql
delete from zxbbsmf where bbgid = 'bb124'
```

Run matcher. Nothing changes. Even when bb record was deleted. Because point id maps.

```sql
update zxMasterSMF set pointid = 1230 where bbgid = 'bb124'
```

Now it goes provisional. Says subsequent no match. Accept and comes back again.

```sql
update zxMasterSMF set pointid = 123 where bbgid = 'bb124'
```

Now matcher. Doesn't show up.

```sql
update zxMasterSMF set pointid = 1230 where bbgid = 'bb124'
```

Now it goes provisional. Says subsequent no match. Don't accept.

```sql
update zxMasterSMF set pointid = 123 where bbgid = 'bb124'
```

Subsequent no match. So didn't change. Just accept and rerun matcher. Doesn't show up.
Shows 100% match on master on bbgid


Find that CADIS updated changed when source monitoring is on.

IDG

```sql
insert into "CADIS"."DM_ZXMCHR_ZXBBSMF_IDG" (bbgid) values ('bb224'), /*224*/ ('bb420')
```

Run matcher. Nothing. Need to run matcher id generator process. After that out and info tables don't get bb420 . Info all does get a line but only CADIS id filled in. Reason says id generator. CADIS proc source000 and revision tables get the records. bb224 gets 1019 & bb420 gets 1020.

```sql
insert into zxbbsmf (bbgid, cusip, isin, country, currency)
values ('bb420', 'cusip420', 'isin420', 'india', 'inr')
```

Even before running matcher, show up in out and info tables. I think they use inner join.

Run matcher. No change.

```sql
insert into CADIS.DM_ZXMCHR_ZXBRSSMF_IDG (BRScusip) values ('brs420')
```

New CADIS id 1021 from id generator.

```sql
insert into zxMasterSMF(AssetID, bbgid, cusip, BRScusip, pointid, isin, country, currency)
values ('1020', 'bb420', 'cusip420', 'brs420', 420, 'isin420', 'some country', 'some money')
```

Run matcher. Nothing happens. Master view says high confidence bbgid match.

```sql
insert into zxbrssmf (brscusip, isin, country, currency)
values ('brs420', 'isin420', 'india', 'inr')
```

Subsequent diff match. Realign to 1021 to 1020 and 1021 becomes obsolete.


```sql
delete from CADIS.DM_ZXMCHR_ZXBRSSMF_IDG
insert into CADIS.DM_ZXMCHR_ZXBRSSMF_IDG (BRScusip) values ('brs420')
insert into CADIS.DM_ZXMCHR_ZXBRSSMF_IDG (BRScusip) values ('brs430')

update zxMasterSMF set BRScusip = 'brs430' where BRScusip = 'brs1' --1020  
```

Run IDG. Get brs420 as 1020 correct. brs430 gets 1022 instead of 1006 from master source. So, it basically just gets a new one.

```sql
update zxMasterSMF set BRScusip = 'brs007' where AssetID = 1019

insert into zxbrssmf (brscusip, isin, country, currency)
values ('brs007', 'isin007', 'india', 'inr')
```

Run matcher. Got 1019 assigned. So IDG can be used if absolutely certain that new id is needed. Can change pk of source from sql and then verify create. No issues.  Works. No need to verify create either.

Retire point.  This record only matches point id.

```sql
insert into zxMasterSMF (AssetID, bbgid, cusip, BRScusip, pointid, isin, country, currency)
values (1011, 'bb10', 'cusip10x', null, 11, 'isin10x', 'us', 'usd')
```

Run matcher. Doesn't show up anywhere.  Nothing happens.

```sql
update zxMasterSMF set bbgid = 'bb10' where bbgid = 'bb10x'
```

Run matcher. No shows up. So retired source won't even be referenced.

```sql
insert into zxPointSMF (Pointid, cusip, isin, country, currency)
values (444, 'cusip444', 'isin444', 'us', 'usd')
```

Run matcher on all input. Nothing happens.

```sql
delete from zxBBsmf where cusip = 'cusip124'
```

Run matcher. point had a record that matched only on cusip124

No change.

Accepted an inbox item after source retired - warning but then accepted. re-run of matcher didn't bring it up again like it used before retiring the matcher.

```sql
select * from zxPointSMF

update zxPointSMF set Pointid = 555 where Pointid = 50
```

Master has a match only on this. Run matcher. Nothing!

```sql
update zxMasterSMF set pointid = 555 where pointid = 50
```

Run matcher. 50 had mapped to point but now it is 555 but it still doesn't look for new match.

To remove input, all rules that use it need to be deleted. delete.
Run matcher. Now the 50/555 came up saying subsequent no match

...
