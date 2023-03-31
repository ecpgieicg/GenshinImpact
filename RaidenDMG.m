function [x,fval,exitflag,output]=RaidenDMG(X)

if exist('X','var')
	x=-Q1DMG_crit_avg(X);
else

nvars=118;
%% constraint 1
nonlcon=[];
intcon=1:nvars;
%% constraint 2, 3, 4.2
Aeq=[ones(1,5),zeros(1,113);...
	zeros(1,5),ones(1,6),zeros(1,107);...
	zeros(1,11),ones(1,7),zeros(1,100);...
	zeros(1,18),ones(1,10),zeros(1,90);...
	zeros(1,28),ones(1,10),zeros(1,80);...
	zeros(1,38),ones(1,10),zeros(1,70);...
	zeros(1,48),ones(1,10),zeros(1,60);...
	zeros(1,58),ones(1,10),zeros(1,50);...
	zeros(1,68),ones(1,10),zeros(1,40);...
	zeros(1,78),ones(1,10),zeros(1,30);...
	zeros(1,88),ones(1,10),zeros(1,20);...
	zeros(1,98),ones(1,10),zeros(1,10);...
	zeros(1,108),ones(1,10)];
beq=[1;1;1;4;4;4;4;4;9;9;9;9;9];
tol=1e-3;
A=[Aeq;-Aeq];
b=[beq+tol;-beq+tol];
%% constraint 4.1, 5
lb=[zeros(118,1)];
ub=[ones(68,1);6*ones(50,1)];

%% flatten certain dimensions, ie. eliminate some possibilities
ub([1,3,4])=0;
ub([6,8,9,11])=0;
ub([12,14,15,18])=0;
IND=[1,2,3,4,6,7];
for i=18:10:108
	ub(IND+i)=0;
end
IND=[5,8,9,10];
for i=18:10:108
	lb(IND+i)=1;
end

[x,fval,exitflag,output]=ga(@Q1DMG_crit_avg,nvars,A,b,[],[],lb,ub,nonlcon,intcon);

end

end

function out = Q1DMG_crit_avg(x)
% main stat options are in order of: HP%, ATK%, DEF%, EM, ER, eDMG%, pDMG%, CritR, CritD, HB
% sub stat options are in order of: HP, ATK, DEF, HP%, ATK%, DEF%, EM, ER, CritR, CritD
%									9,  10,  11,  12,  13, , 14,   15, 16, 17,    18
% x1-5: sand pc main stat
% x6-11: goblet pc main stat
% x12-18: head pc main stat
% x19-28: artifact1 sub stat choice
% x29-38: artifact2 sub stat choice
% x39-48: artifact3 sub stat choice
% x49-58: artifact4 sub stat choice
% x59-68: artifact5 sub stat choice
% x69-78: artifact1 sub stat scale
% x79-88: artifact2 sub stat scale
% x89-98: artifact3 sub stat scale
% x99-108: artifact4 sub stat scale
% x109-118: artifact5 sub stat scale
% constraints: 
%	1) all coeff integers
%	2) main stat coeff add to 1 per pc
%	3) artifact sub stat choice coeff add to 4 per artifact
%	4.1) artifact sub stat scale coeff constrained between 0-6
%	4.2) artifact sub stat scale coeff add to 9 per artifact
%	4.3) if a sub stat choice coeff is 1, the corresponding sub stat scale coeff cannot be 0 <-- will ignore and let optimization solver do their thing
%	5) all choice coeff min 0, max 1


%% best possible level up per substat every 4 artifact level
ATKsub=19.45;
pATKsub=5.83/100;
ERsub=6.48/100;
CritRsub=3.89/100;
CritDsub=7.77/100;
%%%

%% stats without weapon or artifact set effects
ER=1+...				% base
	32/100+...			% Character Ascension Stat
	50.1/100+...		% Engulfing Lightning base ER
	20/100+...			% Emblem Set 2pc
	x(5)*51.8/100+...	% sand pc ER main stat
	ERsub*(x(26)*x(76)+...	% artifact1 ER sub stat
		x(36)*x(86)+...		% artifact2 ER sub stat
		x(46)*x(96)+...		% artifact3 ER sub stat
		x(56)*x(106)+...		% artifact4 ER sub stat
		x(66)*x(116));		% artifact5 ER sub stat

baseATK=337+...	% character base
		608;	% Engulfing Lightning base

ATK=baseATK*(1+...					% base
			min(0.8,(ER-1)*.28)+...	% Engulfing Lightning R1
			x(2)*46.6/100+...		% sand pc ATK main stat
			x(7)*46.6/100+...		% goblet pc ATK main stat
			x(13)*46.6/100+...		% head pc ATK main stat
			pATKsub*(x(23)*x(73)+...	% artifact1 ATK% sub stat
					x(33)*x(83)+...		% artifact2 ATK% sub stat
					x(43)*x(93)+...		% artifact3 ATK% sub stat
					x(53)*x(103)+...	% artifact4 ATK% sub stat
					x(63)*x(113)))+...	% artifact5 ATK% sub stat
	311+...							% feather ATK
	ATKsub*(x(20)*x(70)+...		% artifact1 ATK sub stat
			x(30)*x(80)+...		% artifact2 ATK sub stat
			x(40)*x(90)+...		% artifact3 ATK sub stat
			x(50)*x(100)+...	% artifact4 ATK sub stat
			x(60)*x(110));...	% artifact5 ATK sub stat

%%% NOTE: elemental & physical need to be selected here per character.
DMGbonus=x(10)*46.6/100+...	% goblet pc eDMG main stat
			(ER-1)*0.4;		% Raiden talent: Enlightened One

CritR=0.05+...				% character base
		x(16)*31.1/100+...	% head pc CritR main stat
		CritRsub*(x(27)*x(77)+...	% artifact1 CritR sub stat
				x(37)*x(87)+...		% artifact2 CritR sub stat
				x(47)*x(97)+...		% artifact3 CritR sub stat
				x(57)*x(107)+...	% artifact4 CritR sub stat
				x(67)*x(117));...	% artifact5 CritR sub stat

CritD=0.5+...				% character base
		x(17)*62.2/100+...	% head pc CritD main stat
		CritDsub*(x(28)*x(78)+...	% artifact1 CritD sub stat
				x(38)*x(88)+...		% artifact2 CritD sub stat
				x(48)*x(98)+...		% artifact3 CritD sub stat
				x(58)*x(108)+...	% artifact4 CritD sub stat
				x(68)*x(118));...	% artifact5 CritD sub stat
%%%

%% additional stats from weapon, artifact set, team buff effects
a_ER=30/100;	% Engulfing Lightning R1
a_ATK=baseATK*min(0.8-min(0.8,(ER-1)*.28),a_ER*.28);	% Engulfing Lightning R1
a_DMGbonus=a_ER*0.4+...					% Raiden talent: Enlightened One
			60*0.3/100+...				% 60 resolve
			min(0.75,(ER+a_ER)*.25);	% Emblem Set 4pc effect
%%%

skill_multiplier=(851.7+8.26*60)/100;

DMG_no_crit=(ATK+a_ATK)*(1+DMGbonus+a_DMGbonus)*skill_multiplier;

DMG_crit_avg=DMG_no_crit*(1+min(1,CritR)*CritD);

out=-DMG_crit_avg;	% find minimum

end