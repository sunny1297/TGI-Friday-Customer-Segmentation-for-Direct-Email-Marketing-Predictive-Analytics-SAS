LIBNAME UTD 'E:\Users\fgw180000\Downloads'; run;

LIBNAME UTD 'E:\Users\fgw180000\Downloads\Project Data and Coding'; run;

data dataset;
set 'E:\Users\fgw180000\Downloads\Project Data and Coding\dataset.sas7bdat';
run;

**// RFM Model;

data n1dataset;
set dataset;
if days_between_trans <= 10 then Recency = 3;
else if days_between_trans >= 41 then Recency = 1;
else if 10 < days_between_trans < 41 then Recency = 2;
Cards;
input day_between_trans;
run;

data n2dataset;
set n1dataset;
if items_tot <= 9 then Frequency = 1;
else if items_tot >= 24 then Frequency = 3;
else if 9 < items_tot < 24 then Frequency = 2;
cards;
input items_tot;
run;

data n4dataset;
set n2dataset;
if net_sales_tot <= 55.92 then Monetary = 1;
else if net_sales_tot >= 141.74 then Monetary = 3;
else if 55.92 < net_sales_tot < 141.75 then Monetary = 2;
cards;
input net_sales_tot;
run;

proc freq data = n3dataset;
tables Recency*Frequency*Monetary/ NOPERCENT NOROW NOCOL;
run;

data n3dataset;
set n4dataset;
RFMscore = sum(Recency*0.5 + Frequency*0.25 + Monetary*0.25);
run;

proc corr data=n3dataset;
var Recency Frequency Monetary;
run;

**// Clustering;

proc cluster data=n3dataset method=ward pseudo trim=10 k=50 print=15;
run;

proc fastclus data = n3dataset out= ndataset maxc=7 maxiter=20;
var fd_cat_alcoh		fd_cat_app			fd_cat_bev
fd_cat_brunc		fd_cat_buffe		fd_cat_burg
fd_cat_combo		fd_cat_dess			fd_cat_drink
fd_cat_h_ent		fd_cat_kids			fd_cat_l_ent
fd_cat_other		fd_cat_side			fd_cat_soupsal
fd_cat_steak	rest_loc_bar		rest_loc_Rest		rest_loc_rm_serv
rest_loc_Take_out		rest_loc_unkn
time_breakfast		time_dinner			time_late_nite
time_lunch;
run;

data newdataset;
set ndataset;
if CLUSTER = 1 then NCLUSTER = 1;
else if CLUSTER = 2 then NCLUSTER = 3;
else if CLUSTER = 3 then NCLUSTER = 2;
else if CLUSTER = 4 then NCLUSTER = 3;
else if CLUSTER = 5 then NCLUSTER = 3;
else if CLUSTER = 6 then NCLUSTER = 2;
else if CLUSTER = 7 then NCLUSTER = 4;
cards;
input CLUSTER;
run;

proc freq data=newdataset;
tables NCLUSTER / plots=freqplot;
run;

**// Decision Tree for Segment Profiling;

proc hpsplit data=newdataset maxdepth=3;
class NCLUSTER;
model NCLUSTER = fd_cat_alcoh	fd_cat_app	fd_cat_bev
fd_cat_brunc	fd_cat_buffe	fd_cat_burg
fd_cat_combo	fd_cat_dess		fd_cat_drink
fd_cat_h_ent	fd_cat_kids		fd_cat_l_ent
fd_cat_other	fd_cat_side		fd_cat_soupsal
fd_cat_steak;
run;

proc hpsplit data=newdataset maxdepth=3;
class NCLUSTER;
model NCLUSTER =time_breakfast	time_dinner		time_late_nite
time_lunch rest_loc_bar	rest_loc_Rest	rest_loc_rm_serv
rest_loc_Take_out	rest_loc_unkn;
prune none;
run;

**// Price Elasticity;
 
**// Price Elasticity Cluster 1;
data regclus1;
set newdataset;
if NCLUSTER = '2' then delete;
else if NCLUSTER = '3' then delete;
else if NCLUSTER = '4' then delete;
Quan = log(items_tot);
Price = log(net_amt_p_item);
run;
proc means data=regclus1;
var Quan Price;
run;
proc genmod data=regclus1;
model Quan = Price days_between_trans email_click_rate email_open_rate/ dist= poisson;
run;

**// Price Elasticity Cluster 2;
data regclus2;
set newdataset;
if NCLUSTER = '1' then delete;
if NCLUSTER = '3' then delete;
if NCLUSTER = '4' then delete;
Quan = log(items_tot);
Price = log(net_amt_p_item);
run;
proc means data=regclus2;
var Quan Price;
run;
proc genmod data=regclus2;
model Quan = Price days_between_trans email_click_rate email_open_rate/ dist= poisson;
run;

**// Price Elasticity Cluster 3;
data regclus3;
set newdataset;
if NCLUSTER = '1' then delete;
if NCLUSTER = '2' then delete;
if NCLUSTER = '4' then delete;
Quan = log(items_tot);
Price = log(net_amt_p_item);
run;
proc means data=regclus3;
var Quan Price;
run;
proc genmod data=regclus3;
model Quan = Price days_between_trans email_click_rate email_open_rate/ dist= poisson;
run;

**// Price Elasticity Cluster 4;
data regclus4;
set newdataset;
if NCLUSTER = '1' then delete;
if NCLUSTER = '3' then delete;
if NCLUSTER = '2' then delete;
Quan = log(items_tot);
Price = log(net_amt_p_item);
run;
proc means data=regclus4;
var Quan Price;
run;
proc genmod data=regclus4;
model Quan = Price days_between_trans email_click_rate email_open_rate/ dist= poisson;
run;
