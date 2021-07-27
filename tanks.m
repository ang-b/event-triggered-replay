%% linearized model

Area = [1 1];
a = (2.5e-2)^2*60;
g = 9.81;

h0 = 1;
Ti = @(h, A) (A/a * sqrt(2*h/g));

A = [-1/Ti(1, Area(1))            0; ...
    Area(1)/Area(2)/Ti(h0,Area(1)) -1/Ti(h0,Area(2))];

B = [1/Area(1); 0];

C = [0 1];

E = [0; -1/Area(2)];

O = obsv(A,C);
fprintf("Observability rank: %d\n", rank(O));

L = place(A', C', [-100 -2])';

%% demand profile

t = 0:.1:24;
Tstart = 8;
Tend = 20;
y = tanh(t - Tstart) + tanh(Tend - t);
c = min(1, 1.8 - cos(pi/28*(t - 14)));
d = c.*y;
d = d/max(d);

% plot(t,d)

% d2sim = [t' d'];
clear d2sim
d2sim.time = [];
d2sim.signals.values = d';
d2sim.signals.dimensions = 1;