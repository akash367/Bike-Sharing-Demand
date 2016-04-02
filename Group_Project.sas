*-------------------------------------------------------------------------;
* Course	     : BIA652  Multivariate Data Analysis                     ;
* Developers	 : Akash Chawla (10406187)								  ;
* 				   Rohan Bhoyar (10411225)								  ;
* Comments       : Group Project   										  ;
*-------------------------------------------------------------------------;

/*
Bike Sharing Demand

Forecast use of a city bike share system

*/
* Import the CSV file with training data;
proc import datafile="D:\Stevens\Courses\BIA652\raw_data\train.csv"
     out=bike_sharing
     dbms=csv
     replace;
     getnames=yes;
	 datarow=2;
run;


*Initial Exploration Regression Analysis;
Title1 "Proc Reg for the bike_sharing dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=bike_sharing outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  holiday workingday temp atemp  humidity windspeed / 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 SLSTAY=0.05 SLENTRY=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;

*Run the PROC UNIVARIATE for the Analysis of Variables ;
Title "PROC UNIVARIATE for the Analysis of Variables";
proc univariate data =bike_sharing normaltest plot;
	var holiday workingday temp atemp  humidity windspeed ;
run;


*Separate Date and time values. Also Separate month and hour values;
data bike_sharing_01;
set bike_sharing;

if workingday=0 then holiday =1;

date=datepart(datetime);
time=timepart(datetime);

hour=hour(time);
month=month(date);

jan=0;if month=1 then jan=1;
feb=0;if month=2 then feb=1;
mar=0;if month=3 then mar=1;
apr=0;if month=4 then apr=1;
may=0;if month=5 then may=1;
jun=0;if month=6 then jun=1;
jul=0;if month=7 then jul=1;
aug=0;if month=8 then aug=1;
sep=0;if month=9 then sep=1;
oct=0;if month=10 then oct=1;
nov=0;if month=11 then nov=1;
*dec=0;    *if month=12 then dec=1;

format time time. date date9.;


spring=0; if season=1 then spring=1;
summer=0; if season=2 then summer=1;
fall=0; if season=3 then fall=1;
*winter=0;   *if season=4 then winter=1;


w_clear=0; if weather =1 then w_clear=1;
w_cloudy=0; if weather=2 then w_cloudy=1;
w_light_rain=0; if weather=3 then w_light_rain=1;
*w_heavy_rain=0;     *if weather=4 then w_heavy_rain=1;

run;


*new Second Exploration Regression Analysis after cleaning data;
Title1 "Proc Reg for the Bike Sharing Dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=bike_sharing_01 outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  holiday workingday temp atemp humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov spring summer fall w_clear  w_cloudy w_light_rain/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

run;
quit;

*Second Exploration Regression Analysis after cleaning data;
Title1 "Proc Reg for the bike_sharing dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=bike_sharing_01 outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  holiday workingday temp  humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov spring summer fall w_clear  w_light_rain / 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 SLSTAY=0.05 SLENTRY=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;
*Residual is not normal, there are some variables which are not significant in this regression.
* NEED TO CHECK DATA WHERE HUMIDITY=0 or WINDSPEED=0;


****;
/*
data bike_sharing_02;
   set bike_sharing_01(where=(humidity ~= 0 & windspeed ~=0 ));
run;
****;
*/


*replace 0 values with null;
data bike_sharing_03;
   set bike_sharing_01;
   if humidity=0 then humidity='';
if windspeed=0 then windspeed='';
run;





*replace null values with median;
proc stdize data=bike_sharing_03 out=bike_sharing_04 missing=median reponly;
  var humidity windspeed;
run;

*Plots;

proc sgplot data=bike_sharing_04;
  title "Count";
  histogram count;

  density count;
  density count / type=kernel;
  *keylegend / location=inside position=topright;
run;

proc sgplot data=bike_sharing_04;
title "Months vs Count";
  yaxis label="Count" ;
  xaxis label="Months" ;
  vbar month / response=count;
 
run;

proc sgplot data=bike_sharing_04;
title "Season vs Count";
  yaxis label="Count" ;
  xaxis label="Season" ;
  vbar Season / response=count;
 
run;

proc sgplot data=bike_sharing_04;
title "Weather vs Count";
  yaxis label="Count" ;
  xaxis label="Weather" ;
  vbar Weather / response=count;
 
run;

proc sgplot data=bike_sharing_04;
title "Temperature vs Count";
xaxis type = discrete;
  yaxis label="Count" ;
  xaxis label="Temperature" ;
  vbar temp / response=count;

run;

proc sgplot data=bike_sharing_04;
title "Boxplot for Temperature";
  hbox temp;* / category=origin;
run;

proc sgplot data=bike_sharing_04;
title "Boxplot for Humidity";
  hbox humidity;* / category=origin;
run;

proc sgplot data=bike_sharing_04;
title "Boxplot for Windspeed";
  hbox windspeed;* / category=origin;
run;



**************************************;
*TEST;
proc reg data=bike_sharing_04 outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  holiday workingday temp  humidity windspeed hour  spring summer fall w_clear  w_light_rain / 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 ; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;
*TEST;
**************************************;



*divide data into training and test sets;
data temp;
set bike_sharing_04;
n=ranuni(8);
proc sort data=temp;
  by n;
  data training testing;
   set temp nobs=nobs;
   if _n_<=.7*nobs then output training;
    else output testing;
   run;



*Third Exploration Regression Analysis after cleaning data;
Title1 "Proc Reg for the Bike Sharing Dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=Training outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=   holiday workingday temp atemp humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov spring summer fall w_clear  w_cloudy w_light_rain/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;
*********NEW Regression Analysis after removing correlated variables.
*Third Exploration Regression Analysis after cleaning data;
Title1 "Proc Reg for the Bike Sharing Dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=Training outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=   holiday workingday atemp humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov spring summer fall w_clear  w_cloudy / 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;

*********NEW Regression Analysis after removing correlated variables.
*Third Exploration Regression Analysis after cleaning data;
Title1 "Proc Reg for the Bike Sharing Dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=Training outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=    holiday atemp humidity  hour  feb  apr may  jul aug
					sep   spring summer fall w_clear  w_cloudy / 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;



*********NEW Regression Analysis after removing correlated variables.
*Third Exploration Regression Analysis after cleaning data;
Title1 "Proc Reg for the Bike Sharing Dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=Training outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=     atemp humidity  hour  may  jul aug
					sep   spring summer fall w_clear  w_cloudy / 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;




*** Normalize the training data ***;
PROC STANDARD DATA=Training
             MEAN=0 STD=1 
             OUT=bike_sharing_01_z;
  VAR  holiday workingday temp atemp humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov  spring summer fall   w_clear w_cloudy w_light_rain;
RUN;




proc princomp   data=bike_sharing_01_z  out=bike_sharing_01_pca;
 VAR  holiday workingday temp atemp  humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov  spring summer fall   w_clear w_cloudy w_light_rain ;
run;


*fourth Exploration Regression Analysis after cleaning data;
Title1 "Proc Reg for the bike_sharing dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=bike_sharing_01_pca outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  prin1 prin2 prin3 prin4 prin5 prin6 prin7 prin8 prin9 / 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 SLSTAY=0.05 SLENTRY=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;


*fifth Exploration Regression Analysis after removing 9 11 and 14;
Title1 "Proc Reg for the bike_sharing dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=bike_sharing_01_pca outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  prin1 prin2 prin3 prin4 prin5 prin6 prin7 prin8  prin10  prin12 prin13  prin15/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 SLSTAY=0.05 SLENTRY=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;


*factory Analysis;
proc factor data = bike_sharing_01_z   score corr scree residuals EIGENVECTORS  fuzz=0.3 method = principal nfactors=11
			rotate=VARIMAX   outstat=fact out=factout;
var holiday workingday temp atemp humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov  spring summer fall   w_clear w_cloudy w_light_rain ;
*PROC SCORE  DATA=bike_sharing_01_z   SCORE=fact   OUT=scores;  
run;


data factor_out2;
  set factout;
   predict_Count= int(190.22+ 56.11*Factor1 +13.53*Factor2 -6.08*Factor4 -24.23*Factor5 +60.82*Factor6 -25.20*Factor7 -6.25*Factor8 +22.09* Factor9);
   error= ABS(count-predict_Count)/count;
run; 

proc means data=factor_out2;
run;



*sixth Exploration Regression Analysis on factors;
Title1 "Proc Reg for the Bike Sharing dataset";
Title2 "Regression Analysis of Count on Factors" ;
proc reg data=factout outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  factor1  factor2 factor3 factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 ; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;


*sixth Exploration Regression Analysis on factors removing factor 3;
Title1 "Proc Reg for the Bike Sharing dataset";
Title2 "Regression Analysis of Count on Factors" ;
proc reg data=factout outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  factor1  factor2  factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 ; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;



*seventh Exploration Regression Analysis on factors after removing factor8;
Title1 "Proc Reg for the bike_sharing dataset";
Title2 "Regression Analysis of Count" ;
proc reg data=factout outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  factor1  factor2 factor3 factor4 factor5 factor6 factor7  factor9/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 SLSTAY=0.05 SLENTRY=0.05; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;



*Run the PROC UNIVARIATE for the Residual Analysis ;
Title "PROC UNIVARIATE for the Normality Analysis on Residual";
proc univariate data =reg_bike_sharingOUT normaltest plot;
	var c_Res;
	probplot c_Res / normal (mu=est sigma =est);
run;

*Run the PROC SGPLOT for plotting a histrogram for the Residual Analysis ;
Title "PROC SGPLOT for the Residual";
proc sgplot data=reg_bike_sharingOUT ;
	histogram c_Res;
  	density c_Res;
  	density c_Res / type=kernel;
run;







*** Normalize the test data ***;
PROC STANDARD DATA=Testing
             MEAN=0 STD=1 
             OUT=bike_sharing_test_01_z;
  VAR  holiday workingday temp atemp humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov  spring summer fall   w_clear w_cloudy w_light_rain;
RUN;



*factory Analysis on test data;
proc factor data = bike_sharing_test_01_z   score corr scree residuals EIGENVECTORS  fuzz=0.3 method = principal nfactors=11
			rotate=VARIMAX   outstat=fact out=factout_test;
var holiday workingday temp atemp humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov  spring summer fall   w_clear w_cloudy w_light_rain ;
*PROC SCORE  DATA=bike_sharing_01_z   SCORE=fact   OUT=scores;  
run;


*sixth Exploration Regression Analysis on factors removing factor 3;
Title1 "Proc Reg for the Bike Sharing dataset";
Title2 "Regression Analysis of Count on Factors" ;
proc reg data=factout_test outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  factor1  factor2  factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 ; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;


*New Exploration Regression Analysis on factors removing factor 3;
Title1 "Proc Reg for the Bike Sharing dataset";
Title2 "Regression Analysis of Count on Factors" ;
proc reg data=factout_test outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  factor1    factor4 factor5 factor6  factor8 factor9 factor10 factor11/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 ; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;


****************WHOLE DATASET;

*** Normalize the test data ***;
PROC STANDARD DATA=bike_sharing_04
             MEAN=0 STD=1 
             OUT=bike_sharing_all_01_z;
  VAR  holiday workingday temp atemp humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov  spring summer fall   w_clear w_cloudy w_light_rain;
RUN;



*factory Analysis on test data;
proc factor data = bike_sharing_all_01_z   score corr scree residuals EIGENVECTORS  fuzz=0.3 method = principal nfactors=11
			rotate=VARIMAX   outstat=fact out=factout_all;
var holiday workingday temp atemp humidity windspeed hour jan feb mar apr may jun jul aug
					sep oct nov  spring summer fall   w_clear w_cloudy w_light_rain ;
*PROC SCORE  DATA=bike_sharing_01_z   SCORE=fact   OUT=scores;  
run;


*sixth Exploration Regression Analysis on factors removing factor 3;
Title1 "Proc Reg for the Bike Sharing dataset";
Title2 "Regression Analysis of Count on Factors" ;
proc reg data=factout_all outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  factor1  factor2  factor4 factor5 factor6 factor7 factor8 factor9 factor10 factor11/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 ; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;


*New Exploration Regression Analysis on factors removing factor 3;
Title1 "Proc Reg for the Bike Sharing dataset";
Title2 "Regression Analysis of Count on Factors" ;
proc reg data=factout_all outest=est_bike_sharing  PLOTS(MAXPOINTS=15000 );
	model count=  factor1    factor4 factor5 factor6  factor8 factor9 factor10 factor11/ 
		dwProb pcorr1 VIF selection=MAXR ALPHA=0.05 ; 
OUTPUT OUT = reg_bike_sharingOUT PREDICTED=PRCDT RESIDUAL=c_Res
L95M=c_l95m U95M=c_u95m L95=C_l95 U95=C_u95 
rstudent=C_rstudent h=lev cookd=Cookd dffits=dffit 
STDP=C_spredicted STDR=C_s_residual STUDENT=C_student;

*model count=   temp  humidity windspeed / ;

run;
quit;

data factor_out2;
  set factout;
   predict_Count= int(191.57+ 63.70*Factor1 -7.67*Factor4 +60.58*Factor5 +14.66*Factor6 -4.09*Factor8 -13.42*Factor9 +15.23*Factor10 +15.36* Factor11);
   *error= ABS(count-predict_Count)/count;
run; 

proc means data=factor_out2;
run;


