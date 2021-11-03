xref = [3600* 0.10472 ;0];
% xref = [1 ;0];
n = length(xref);
delta = .02*abs(xref(1));


T = 0:Ts:2;
Nsamples = length(T);

x = zeros(n, Nsamples);
u = zeros(1, Nsamples);

err = zeros(1, Nsamples);
triggers = zeros(1, Nsamples);

e = zeros(n, Nsamples);

R = @(theta) [ cos(theta) -sin(theta);
               sin(theta) cos(theta)];
           
% x(:,1) = R(pi/2)* xref * (1 + 2*delta);
x(:,1) = zeros(n,1);

gradc = @(x) 2*x';

AI = eye(n) - Ad;
AI1 = AI(1,:);
AI2 = AI(2,:);

g = AI \ [zeros(1,n); AI2];
gamma = AI \ B * K;

%% main loop

is_out = true;
xlast = zeros(n,1);
N = 5;
Ccal = pinv(ctr_n(Ad, Bd, N));

for k = 1:Nsamples-1
    err(k) = norm(x(:,k) - xref);
    if err(k) < delta && is_out 
        triggers(k) = 1;
        is_out = false;
        xlast = x(:,k);
        theta = randi([-30 30]) * pi/180;
        e(:,k) = -R(theta) * gradc(x(:,k)');
        e(:,k) = e(:,k)/norm(e(:,k));
%         u(:,k) = pinv(Bd)*(eye(n) - Ad)/norm(gamma) * ((1+eps)*delta*e(:,k)/norm(e(:,k)) + xlast);
        u(:,k) = Bd'/norm(Bd*Bd')*AI*Tx*((1 + 1e-3)*delta*e(:,k) + xlast);
%         u(:,k) =  -0.8 * K * (xlast - xref./isg_1');
    elseif err(k) >= delta
        triggers(k) = 0;
        is_out = true;
        u(:,k) = -K * (x(:,k) - xref./isg_1'); 
    else
        triggers(k) = -1;
        u(:,k) = u(:,k-1);
        ulast = u(:,k);
    end
    
    x(:,k+1) = Ad*x(:,k) + Bd*u(:,k);
end

% why is this wrong?
% xbar =2*delta*e/norm(e) + x(:,1);

%% fixed points

xifp = Tx * inv(AI) * Bd * ulast;

%%
close all

%%
figure(1)
stairs(T, x')

%%
figure(2);
subplot(2,1,1);
stem(T, triggers');
ylim([-1.5 1.5]);
subplot(2,1,2);
plot(T,u);

%%
figure(3);
plot(T, err);
hold on
line([0 T(end)], [delta delta], 'Color', [1 0 0], 'LineWidth', 1.4);
% ylim([10 30]);
% ylim('auto');