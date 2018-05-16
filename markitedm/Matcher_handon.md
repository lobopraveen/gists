-- each matcher gets CADIS.DM_ZXMCHR_INBOX, _KEYS, _SEARCH views. inbox viewsare created for individual sources as well
-- each source gets CAID.DM_ZXMCHR_ZXSOURCE_INFO, INFOALL, _OUT views.
-- CADIS_PROC gets  the main tables - DM_MATCHPOINTx and DM_MP4_SOURCExxx where x is a digit. 
--cadis data matcher views store all columns from source even if coluns are unchecked in the rule columns stage 
-- added master table as ref input wihtout any rules and no data shows up in cadis dm info, all, out views. 
-- cadis dm_code_keys view (match point keys) has cadis id, obsolete, and exists? columdn for each source and changed by. 
--          the exists was true even after row deleted from source but false after running matcher.  
-- dm_code_search shows acceptros name in last modified. it removes row in input row is deleted without even running matcher 
-- all other places show datamatcher is you accept its proposal. if yuo chcange hten it shows your name 
--  each source gets some random number and memd creates cadis_prod schema -> DM_... tables with that number. it gives keys and revisions. 
-- revision table where the key is stored evenw when the src rec is deletd when not asked to remove cadis id association.  if it is checked then it deletes
-- from revision table aslo hence new cadis id if it comes back again 

--setup
-- 4 sources. 1 master table. not required usually*.  three others. BB BRS PNT 
-- Master - ref input, Dups not allowed but appear in inbox, include cadis revision , re-present manual overrides, generate all possible matches
-- BB normal input, dups not allowed but appear in inbox, def will not show in inxbox, pass to matcher if subsequent run results in diff match, include cadis revision , re-present manual overrides, generate all possible matches
-- BRS normal input, dups not allowed but appear in inbox, def will how in inxbox, pass to matcher if subsequent run results in diff match, include cadis revision , re-present manual overrides, generate all possible matches
-- PNT normal input, dups allowed, pass to matcher if subsequent run results in diff match, include cadis revision , if a record is no longer present, reomve assocaite with assigned cadis id.
-- uncheck everything not needed in match rules in the rul ecolumns

-- bbgid, brscusip, pointid are keys for tohse those tables
-- master has cadis and keys for each source

--rules
-- mater has no rules
-- BB - bbgid on master at 100%
-- BRS threshold 75 - brscusip on master at 100%, BRScusipt o bb cusip + isins at 90, just isin on bb at 80, rule type insert 76% if country is russia, rule type dedup on brscusip 
-- Point threshold 70 - pointdi on master at 100%, cusip + isin on bb at 70%, just cusip or isin match on bb at 65


--day 1
insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb1', 'cusip1', 'isin1','us', 'usd')
insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb2', 'cusip2', 'isin2','us', 'usd')
--default 1000 & 1001 .  0 cnofidence. 
-- i wanted it to start at 1001. realign didn't work and it is not straight forward to restart the matcher. I ended up meddling with the cadis 
-- tables to reset. then reran to start at 1001
insert into zxMasterSMF (AssetID,bbgid,cusip,BRScusip,pointid,isin,country,currency) 
values (1001, 'bb1','cusip1', null,null,'isin1','us', 'usd'), 
       (1002, 'bb2','cusip2', null,null,'isin2','us', 'usd')

insert into zxbrssmf (brscusip, isin, country, currency) values ('brs1', 'isin1','us', 'usd')
insert into zxbrssmf (brscusip, isin, country, currency) values ('brs2', 'isin2','us', 'usd')

-- match properly. high ocnfidence 80%
update zxMasterSMF set BRScusip = 'brs1' where AssetID = 1001
update zxMasterSMF set BRScusip = 'brs2' where AssetID = 1002

-- day 2
delete from zxbbsmf where bbgid = 'bb1'
 -- this deleted the row from out and info views but infoall view had the record with null in all columns from 
 -- source and cadis_system_ and cadis revision columns turned to null.
 -- match point key still said true for bb exists column!? 
delete from zxbbsmf where bbgid = 'bb2'
insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb2', 'cusip2', 'isin2','canada', 'csd') 
insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb3', 'cusip3', 'isin3','india', 'inr')

insert into zxbrssmf (brscusip, isin, country, currency) values ('cusip3', 'isin3brs','us', 'usd')   

-- mastering. cadis didnt cahnge 
update zxMasterSMF set country = 'canada', currency = 'csd' where AssetID = 1001

--new id created as expected 
insert into zxMasterSMF (AssetID,bbgid,cusip,BRScusip,pointid,isin,country,currency) 
values (1003, 'bb3','cusip3', null,null,'isin3','india', 'inr') 

-- low confidence. provisional 1. after accepting, only _search view shows my id rest all say matcher 
update zxMasterSMF set BRScusip = 'cusip3' where AssetID = 1003 
--
-- day 3
insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb4', 'cusip4', 'isin4','pak', 'pnr')
insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb5', 'cusip5', 'isin5','pak', 'pnr')

insert into zxbrssmf (brscusip, isin, country, currency) values ('cusip4', 'isin4','pak', 'usd')

--default insertion 
insert into zxMasterSMF (AssetID,bbgid,cusip,BRScusip,pointid,isin,country,currency) 
values (1004, 'bb4','cusip4', null,null,'isin4','pak', 'pnr'), 
       (1005, 'bb5','cusip5', null,null,'isin5','pak', 'pnr')

--hihg confidense. no inbox
update zxMasterSMF set BRScusip = 'cusip4' where AssetID = 1004 

insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (4, 'cusip4', 'isin4pnt','us', 'usd')
insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (5, 'cusip5pnt', 'isin5','us', 'usd')
--both low confidence & in inbox . accept 
update zxMasterSMF set Pointid = 4 where AssetID = 1004 
update zxMasterSMF set Pointid = 5 where AssetID = 1005  

delete from zxPointSMF  where Pointid = 5
-- no change without runing mactaher. INFOALL view turned all nulls , other views didnt show the reocrd. 
insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (5, 'cusip5pnt', 'isin5','us', 'usd')
--no change without runing mactaher. all views showed data like nothing happend
delete from zxPointSMF  where Pointid = 5
-- run matcher. dleted the row from info all as well. bcz of remove associateion property 
insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (5, 'cusip4', 'isin4','us', 'usd')
-- results in high confidence match but in ibox bcs os dup. there is already 1004 with same cusip + isin . accept
update zxMasterSMF set Pointid = 5 where AssetID = 1004 
-- then run without any changes on pnt. nothing happens. since point id 5 on master is now pointing to 1004 and 1005,
--  i thought it would say subsequent run diff match but it doesnt. 
-- may be because I dont have any rules on the master source 

update zxPointSMF set cusip = null where Pointid = 4 
-- run matcher on pnt. INFO all table got udpated with null cusip. came up now as subsequent run no match. 
-- it is because master source has no rules!
update zxPointSMF set cusip = 'cusip5' where Pointid = 4  -- just see if it now says diff match
-- yes, it does! other possible matches shows 1005 which is as expected 


insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (50, 'cusip50pnt', 'isin50','us', 'usd')
update zxMasterSMF set Pointid = 50 where AssetID = 1001
-- i thought 50 would match on master but it doesn.t it seems nothing matches master as there are no rules. it seems to be mathcing
-- only on internal table and not the the real soruce table
-- in inbox. default insertion 1006 

insert into zxMasterSMF (AssetID,bbgid,cusip,BRScusip,pointid,isin,country,currency) 
values (1006, null,'cusip50pnt', null,null,'isin50','us', 'usd')


insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (51, 'cusip50pnt', 'isin50','us', 'usd')
-- in inbox 1007. dont accept 
update zxPointSMF   set cusip = 'cusip4', isin = 'isin4' where Pointid = 51
-- run udpate wihtout acceting anythign in inbox. the item outstanding still says 1007 default insert in inbox
-- run matcher. nothign happens! but other possible matches show 1004. 1007 in KEYS view was marked obsolete. 
-- the revision table in cadis_proc schema shows the trail of how cadis id is chanigning. ithas two rows for 51 - 1007 & 1004 in that order 
-- accepted to 1004. shows up as Manual user insertion (marked as new) low confidece
-- dm_code_search view says proposed is also 1004 haha! it was 1007 before. after manual it changed ot 1004. doesnt sound right. or may be 
-- bcz i ran update and them matcher. 

-- manual realign point id 4 to 1001 . just because.
-- actually can't do 1001 as it has been deleted fom bb source and we dont have rules on amster source. do 1003
-- realign done. it says manual user match. low confidence 

-- run matcher
-- should show up in inbox. doesn't. as the re-present to matcher option is off. 

update zxPointSMF   set cusip = 'cusip5', isin = 'isin5' where Pointid = 4  
-- now i should see subsequent diff match. BUT it doesnt show up. re-present is off. 


--day 4
insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (3, 'cusip3', 'isin3','us', 'usd')
-- run matcher. showed up as high confidence dup. becase there is 1003 already. 
-- misalgined it to 1002. says manual user insertion marked as newand low confidence 
-- ran mathcer now it says subsequencet diff match to 1003. makes sense. 
-- manually re aligned stays but realignment from inbox doesn't.

insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (10, 'cusip10', 'isin10','us', 'usd')
insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (11, 'cusip10', 'isin10','usdup', 'usddup')
-- shows up as 2 new. accepted 10 as 1008. realigned 11 to 1008 instaead of accepting 1009. 1009 got marked as obsolete. 
-- ran matcher. said subsequent no match. marked as new and saved. got new cadis 1010. said manual insetion - low confidence 
-- ran matcher - subsequnet no match. just accpeted as is. keeps coming up.
-- diff between this and one before is that the one before doenst show up as it says default insertion .

insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb10', 'cusip10', 'isin10','us', 'usd')
-- this got new cadis is 1011. the master table is not being referenced! ther is no recisprocla rule from bb to pnt. otheriwse
-- this would hae ened up in in box due to multiple matches
-- 1008 and 1010 came up in inbox with subsequent diff match as they both now match to 1011


-- day 
insert into zxbrssmf (brscusip, isin, country, currency) values ('bcusip6', 'isin6brs','us', 'usd')
insert into zxbrssmf (brscusip, isin, country, currency) values ('bcusip66', 'isin6brs','us', 'usd')
insert into zxbrssmf (brscusip, isin, country, currency) values ('bcusip7', 'isin7brs','russia', 'rbl')
insert into zxbrssmf (brscusip, isin, country, currency) values ('bcusip8', 'isin8brs','russia', 'rbl')
insert into zxbrssmf (brscusip, isin, country, currency) values ('bcusip88', 'isin8brs','russia', 'rbl')
-- insertred last three as 1012, 1013, 1014 because of russia insert rule. 
-- first two ended up in inbox with default insertion. 1015 & 1016
--accept all.

-- changed rule type dedupe to check on isin as on brscusip can't be tested. tbl has brscusip as pk so no dup there! 
-- 1015 and 1016 came up as subsequent diff match.
-- tried to assign 1016 to 1015 but erros our as source says no dups allowed.
-- 1013 & 1014 didnt show up as dups because russia is at 76 and dedule at 75.
-- accept but they show up in run. dont accept.
-- uncheck re-present to mathcer. accept and then re-run. no change. same thing. keeps showing up. 
-- 
update  zxbrssmf set isin = 'isin66brs' where BRScusip = 'bcusip66'
-- run matcher.  no isues now.
insert into zxbrssmf (brscusip, isin, country, currency) values ('bcusip666', 'isin6brs','us', 'usd')
-- i though it'd say dup not allowed so adding diff id and inbox but NOPE! rule type dedup took precedence and assigned  
-- isin6brs 1015 and no inbox! 
--

-- moved dedup on isin to 77 so russia is 76 confidence 
-- rerun. now 1015 & 1016 dhow up as subsequent diff mathc. 

delete from zxBBsmf where bbgid = 'bb10'
-- all that matchedon bb10 come up as subseq no mathc. just accept . this repeats
insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb10', 'cusip10', 'isin10','us', 'usd')
-- nothign shows un in inbox now.
delete from zxPointSMF where Pointid = 33
insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (33, 'cusip33', 'isin33','us', 'usd')
-- now 33 gets new cadis id. old is  obsolete. this is beacuse i ask it to not store once src drops the record 

-- so if we ar ematching pos then i can have id on id rule type dedup and it will dedup. 
-- rule type isnert iwll isnert as long as it is highest confidence. even if you say no dups.
-- 

-- changded pnt cusip and isin match to be high confidence.
insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (44, 'cusip5', 'isin4','us', 'usd')
-- high confidnce multiple match 
insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb123', 'cusip123', 'isin123','canada', 'csd') 
insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb124', 'cusip124', 'isin124','india', 'inr')
-- def insert
insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (123, 'cusip124', 'isin123','us', 'usd')
-- insert on cusip match. so multiple high confidnce match to diff ids dont show in inbox.

delete from zxBBsmf where cusip = 'cusip5' or isin ='isin4'
-- run matcher. all that matched with above rows show up subseq no match 

-- add rules to master - just enable complimentary on bbgid, brsid, pnt id ones. 
insert into zxMasterSMF (AssetID,bbgid,cusip,BRScusip,pointid,isin,country,currency) 
values (1018, 'bb124','cusip124', null,123,'isin124','india', 'inr')
-- then run matcher once. now it shoudl store lal relationships  
-- also point id 5 and 50 comes up as subse diff match . expected.  doing nothing. 
delete from zxbbsmf where bbgid = 'bb124'
--run matcher
-- nothing changes. even when bb record was dleeted. becaue point id maps 
update zxMasterSMF set pointid = 1230 where bbgid = 'bb124'
-- now it goes provisional. says subsequent no match. accept and comes back again.  
update zxMasterSMF set pointid = 123 where bbgid = 'bb124'
-- now matcher. doesnt show up
update zxMasterSMF set pointid = 1230 where bbgid = 'bb124'
-- now it goes provisional. says subsequent no match. dont accept. 
update zxMasterSMF set pointid = 123 where bbgid = 'bb124'
-- subsquene No match. so didnt change. just accept and rerun matcher. doesnt show up.  
-- shows 100% match on master on bbgid



-- find that cadis updated changer when source monitoring is on 

--IDG

insert into      "CADIS"."DM_ZXMCHR_ZXBBSMF_IDG" (bbgid) values ('bb224'), /*224*/ ('bb420')

-- run matcher. nothing. need to run matcher id gen process. after that 
-- out and info tables dont get bb420 . info all doe get a line but only cadis id filled in. reason says id gen
-- cadis proc source000 and revision tables get the records. 
--bb224 gets 1019 & bb420 gets 1020 

insert into zxbbsmf (bbgid, cusip, isin, country, currency) values ('bb420', 'cusip420', 'isin420','india', 'inr')
-- even before running matcher , show up in out and info tables. i think they use inner join 
-- run matcher. no  chnage. 

insert into cadis.DM_ZXMCHR_ZXBRSSMF_IDG (BRScusip) values ('brs420')
-- new cadis id 1021 frmo id gen
insert into zxMasterSMF(AssetID, bbgid, cusip, BRScusip, pointid, isin, country, currency) 
                  values ('1020', 'bb420', 'cusip420', 'brs420', 420, 'isin420', 'some country', 'some money')

-- run matcher. nothign happens. master view says high confidence bbgid match

insert into zxbrssmf (brscusip, isin, country, currency) values ('brs420', 'isin420','india', 'inr')
-- subsquent diff mathc . realign to 1021  to 1020 and 1021 becomes obsolete
--

delete from cadis.DM_ZXMCHR_ZXBRSSMF_IDG
insert into cadis.DM_ZXMCHR_ZXBRSSMF_IDG (BRScusip) values ('brs420')
insert into cadis.DM_ZXMCHR_ZXBRSSMF_IDG (BRScusip) values ('brs430')
update zxMasterSMF set BRScusip = 'brs430' where BRScusip = 'brs1' --1020  

--run idg. get brs420 as 1020 correct. brs430 gets 1022 instead of 1006 from master source. so, it basically just gets a new one.
-- 

update zxMasterSMF set BRScusip = 'brs007' where AssetID = 1019
insert into zxbrssmf (brscusip, isin, country, currency) values ('brs007', 'isin007','india', 'inr')

-- run matcher. got 1019 assigned. 
-- so idg can be used if absolutely certain that new id is needed. 

-- can change pk of source from sql and then verif y create. no issues. works.  no need ot vc either 

-- retire point. this record only amatches point id 
insert into zxMasterSMF (AssetID,bbgid,cusip,BRScusip,pointid,isin,country,currency) 
values (1011, 'bb10','cusip10x', null,11,'isin10x','us', 'usd')
-- run matcher. doesnt show up anywehre. nothign happens
update zxMasterSMF set bbgid = 'bb10' where bbgid = 'bb10x'
-- run matcher . no wshows up. so retired source wont even be referenced. 


insert into zxPointSMF (Pointid, cusip, isin, country, currency) values (444, 'cusip444', 'isin444','us', 'usd')
-- run matcher on all input. nothing happens. 

delete from zxBBsmf where cusip = 'cusip124'

-- run matche.r point had a record that mathceddon ly on cusip124
-- no change.

-- accpeted an inbox item after source retired - warning but then accpeted. re run of matcher didnt bring it upa gain like it used before reitring the matcher. 

select* from zxPointSMF
update zxPointSMF set Pointid = 555 where Pointid = 50
-- master has a match only on this . run matecher. nothing!
update zxMasterSMF set pointid = 555 where pointid = 50
-- run matcher. 50 had mapped to point but now it is 555 but it still doenst look for new match. 

-- to remove input, all rules that us eit need to be dleetd.. delte. 
 -- run mathcer not the 50/555  came up saying subsequent no match 
