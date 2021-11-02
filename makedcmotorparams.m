%% motor parameters

% parameters from Saab (2001)
b = 1e-4;
J = 1.4e-4;
Ke = 0.556;
Kt = Ke;
l = 0.658;
r = 32.91;

% parameter set II
% b = 0.019;
% J = 1;
% Ke = 1.1895;
% Kt = Ke;
% l = 1.32442e-2;
% r = 3.2645;

spref = 200* 0.10472; % rad 2 rpm
% spref = 1;

%% CT state space representation
% state is [omega; i]

A = [-b/J, Kt/J; -Ke/l, -r/l];
B = [0; 1/l];
C = [1, 1];

n = size(A,1);

%% discretization, control and observer 
Ts = 1e-3;
Ad = eye(2) + A*Ts;
Bd = B*Ts;
Cd = C; 

m = rank(Bd);

O = obsv(Ad,Cd);
fprintf("Observability rank: %d\n", rank(O));

% faster response, less overshoot
cpoles = [0.8 + 0.01i, 0.8 - 0.01i];
% slower response, more overshoot
% cpoles = [0.98 + 0.01i, 0.98 - 0.01i];
% controller performance does not seem to impact detectablity much
K = place(Ad, Bd, cpoles);

z = tf('z', Ts);

x0 = zeros(2,1);

L = place(Ad', Cd', [0.3, 0.1]).';

% event triggering parameters
delta = 5e-2 * abs(spref);
isEvt = true; % this is for unmanaged simulations

%% compute feedforward gain (automatic)

% sys = ss(Ad, Bd, [Cd; eye(2)], 0, Ts);
% obs = ss(Ad - L*Cd, [L Bd], eye(2), zeros(2,2), Ts);
% ctr = ss(0, zeros(1,2) , 1, -K, -1);
% 
% ctr.u = 'uc';
% ctr.y = 'u';
% 
% sys.u = 'u';
% sys.y = {'meas', 'x1', 'x2'};
% 
% obs.u = {'meas', 'u'};
% obs.y = 'xhat';
% 
% sum_ref = sumblk('uc = xhat - xref', 2);
% 
% T = connect(ctr, sys, obs, sum_ref, 'xref', 'x1');

%% compute feedfoward gain (analytic)

Rd = Bd*K;
Abar = [Ad, -Rd; L*Cd, Ad-L*Cd-Rd];
Rbar = repmat(Rd, 2, 1);
Cbar = [eye(size(Ad,1)), zeros(size(Ad,1))];

N = (eye(size(Abar,1)) - Abar) \ Rbar;
isg = N(1:n,1:n);
isg_1 = N(1,:);

AI = eye(n) - Ad;
AI1 = AI(1,:);
AI2 = AI(2,:);

g = AI \ [zeros(1,n); AI2];
gamma = AI \ B * K;

save('dcmotorparams.mat');

%% other parameters

U = Cbar / (eye(size(Abar,1)) - Abar) * repmat(Bd, 2, 1);

%% factorization method

[Qf,Lf] = qr(AI.');
Qf = Qf.';
Lf = Lf.';

% assume the system is in form [0; B1]

Q1 = Qf(1:n-m, :);
Q2 = Qf(n-m+1:end, :);

L1 = Lf(1:n-m,1:n-m);
L2 = Lf(n-m+1:end,1:n-m);
L3 = Lf(n-m+1:end,n-m+1:end);

X = Q2'*inv(L3)*L2*Q1 + Q2.'*Q2;

invLBlock = [inv(L1) 0; -inv(L3)*L2*inv(L1) inv(L3)];

%% inverse dynamics

% C1 = [Bd Ad*Bd];
% 
% for k = n:10
%     k
%     u = pinv(ctr_n(Ad, Bd, k)) * (delta * [-1;0] + (eye(n) - Ad^k)*[1;0])
% end