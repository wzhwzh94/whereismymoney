%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   根据当前贷款实际利率、个人估计的通货膨胀率和个人的投资年利率
%   通过分配资金,得出此资金分配方案在完成房贷还款时的净收入
%   未考虑房屋升值贬值、LPR调整、提前还款、各类手续费等
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

m = 12*30; % 贷款月数
gxi = 0.0325; % 公积金贷款年利率
sxi = 0.041; % 商业贷款年利率
inflation = 0.02; % 通货膨胀率
left_money_interest_rate = 0.032; % 个人投资的年利率

first_pay = 30; % 首付,单位:万
gdai = 0; % 公积金贷款,单位:万
sdai = 70;  % 商业贷款,单位:万
left_money = 0; % 支付首付后剩余的钱,用于投资,单位:万
rent_money = 0.25; % 房子每月带来的收入或减少的支出，如出租得到租金，或自住减少房租,单位:万

%% 计算
% 年通货膨胀率
for i = 1:m/12
    inflation_ratio_y(i) = (1/(1+inflation))^(i-1); %#ok<*SAGROW,*AGROW> 
end
inflation_ratio_m = repmat(inflation_ratio_y,12,1);
inflation_ratio_m = inflation_ratio_m(:)';

% 月供
[yg1,yg2] = fangdai(gdai,gxi,sdai,sxi,m);
plot_fangdai(yg1,yg2);
title('月供金额')

% 租金随通货膨胀上升
rent_money_inflation = rent_money./inflation_ratio_m;

% 租金抵扣月供
yg1_rent = yg1 - rent_money_inflation;
yg2_rent = yg2 - rent_money_inflation;
plot_fangdai(yg1_rent,yg2_rent);
title('实际月供：租金抵扣后的月供金额(正为支出,负为收入)')

% 月供根据年通货膨胀率换算实际价值, 实际价值: 以第一年1元为1价值
% 提前还款,可以参考这里还款'月数'对应的'累计支出',累计支出较少的贷款方式相对划算
yg1_inflation = yg1_rent.*inflation_ratio_m;
yg2_inflation = yg2_rent.*inflation_ratio_m;
plot_fangdai(yg1_inflation,yg2_inflation);
title('实际月供的实际价值(正为支出,负为收入)')

% 支出总实际价值
yg1_inflation_end = sum(yg1_inflation) + first_pay; % 等额本金
yg2_inflation_end = sum(yg2_inflation) + first_pay; % 等额本息

% 剩款总实际价值
left_money_end = left_money*((1+left_money_interest_rate)^(m/12)) * inflation_ratio_m(end);

% 房屋价值: 房屋首付+贷款总额
house_money = first_pay + gdai + sdai;

% 净收入总实际价值,
yg1_get_money_end = house_money + left_money_end - yg1_inflation_end; % 等额本金
yg2_get_money_end = house_money + left_money_end - yg2_inflation_end; % 等额本息

fprintf('等额本金净收入总价值: %f 万\n',yg1_get_money_end);
fprintf('等额本息净收入总价值: %f 万\n',yg2_get_money_end);

%% 画图
function plot_fangdai(yg1,yg2)
% "等额本金"和"等额本息"的累积还款
sumyg1(1)=yg1(1);
sumyg2(1)=yg2(1);
for i=2:length(yg1)
    sumyg1(i)=sumyg1(i-1)+yg1(i);
    sumyg2(i)=sumyg2(i-1)+yg2(i);
end

figure
x=1:length(yg1);
subplot(2,1,2);
plot(x,sumyg1,'r',x,sumyg2,'b')
axis tight
xlabel('月数')
ylabel('累计支出（万元）')
legend('等额本金','等额本息')
grid on
subplot(2,1,1);
plot(x,yg1,'r',x,yg2,'b')
axis tight
ylabel('每月支出（万元）')
legend('等额本金','等额本息')
grid on
end

%% 计算月供
function [yg1,yg2] = fangdai(gdai,gxi,sdai,sxi,m)
% “等额本金”的每月还款金额
gdai1=gdai/m;
sdai1=sdai/m;
for i=1:m
    yg1a(i)=gdai1+(gdai-gdai1*(i-1))*(gxi/12);
    yg1b(i)=sdai1+(sdai-sdai1*(i-1))*(sxi/12);
    yg1(i)=yg1a(i)+yg1b(i);
end
% “等额本息”的每月还款金额
gxii=gxi/12;
sxii=sxi/12;
for i=1:m
    yg2a(i)=(gdai*gxii*(1+gxii)^m)/((1+gxii)^m-1);
    yg2b(i)=(sdai*sxii*(1+sxii)^m)/((1+sxii)^m-1);
    yg2(i)=yg2a(i)+yg2b(i);
end
end