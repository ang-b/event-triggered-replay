%% motor parameters
% J = 10;
% b = 0.1;
% 
% Kt = 10;
% Ke = Kt/25;
% 
% l = 5e-2;   
% r = 25;

b = 0.019;
J = 1;
Ke = 1.1895;
Kt = Ke;
l = 1.32442e-2;
r = 3.2645;

%% CT state space representation
% state is [omega; i]

A = [-b/J, Kt/J; -Ke/l, -r/l];
B = [0; 1/l];
C = [1, 1];

%% discretization
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

L = place(Ad', Cd', [0.6, 0.5]).';

%% event-triggering stuff

delta = 1e-2;
N = 1/(0.784815); % this could be dependent on delta

%% analysis
h = @(p) haux(p, Ad, Bd, -K);

for i=1:10
   abs(eig(h(i))) 
end
%% simulation

isEvt = false;
disp("Simulating in event triggering mode");
periodicCtrlSim = sim('dcmotor_sim');

disp("Simulating in periodic control mode");
isEvt = true;
evtCtrlSim = sim('dcmotor_sim');

%%
figure;
subplot(2,1,1)
plot(periodicCtrlSim.data.getElement('r').Values)
title("Periodic control");
subplot(2,1,2)
plot(evtCtrlSim.data.getElement('r').Values)
title("Event-triggered control");