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

%% CT state space representation
% state is [omega; i]

A = [-b/J, Kt/J; -Ke/l, -r/l];
B = [0; 1/l];
C = [1, 1];

%% discretization, control and observer 
Ts = 1e-3;
Ad = eye(2) + A*Ts;
Bd = B*Ts;
Cd = C; 

O = obsv(Ad,Cd);
fprintf("Observability rank: %d\n", rank(O));

cpoles = [0.98 + 0.01i, 0.98 - 0.01i];
K = place(Ad, Bd, cpoles);

z = tf('z', Ts);

x0 = zeros(2,1);

L = place(Ad', Cd', [0.6, 0]).';

% event triggering threshold
delta = 1e-2;

% computing the feed-forward gain adjustment
sys = ss(Ad, Bd, [Cd; eye(2)], 0, Ts);
obsv = ss(Ad - L*Cd, [L Bd], eye(2), zeros(2,2), Ts);
ctrl = ss(0, zeros(1,2) , 1, -K, -1);

ctrl.u = 'uc';
ctrl.y = 'u';

sys.u = 'u';
sys.y = {'meas', 'x1', 'x2'};

obsv.u = {'meas', 'u'};
obsv.y = 'xhat';

sum_ref = sumblk('uc = xhat - xref', 2);

T = connect(ctrl, sys, obsv, sum_ref, 'xref', 'x1');
N = dcgain(T);

% gain correction for parameter set II
% N = 1/(0.784815); % this could be dependent on delta
isEvt = false;

% save('dcmotorparams.mat');