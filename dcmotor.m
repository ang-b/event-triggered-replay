FORCE_RERUN = true;
if exist('dcmotorparams.mat', 'file') == 2 && ~FORCE_RERUN
    load('dcmotorparams.mat')
else
    makedcmotorparams 
end

%% analysis
h = @(p) haux(p, Ad, Bd, -K);

for i=1:10
   abs(eig(h(i)));
end
%% simulation

isEvt = false;
disp("Simulating in periodic control mode");
periodicCtrlSim = sim('dcmotor_sim');

disp("Simulating in event-triggered control mode");
isEvt = true;
evtCtrlSim = sim('dcmotor_sim');

%%
close all
figure(1);
set(1, 'DefaultTextInterpreter', 'latex');
set(1, 'Unit', 'normalized', 'Position', [0 0 .4 .6]);

subplot(2,1,1)
plot(periodicCtrlSim.data.getElement('r').Values, 'LineWidth', 1.8)
title("Periodic control", 'FontSize', 15);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12);
ylabel('$r$');

subplot(2,1,2)
plot(evtCtrlSim.data.getElement('r').Values, 'LineWidth', 1.8)
title("Event-triggered control", 'FontSize', 15);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 12);
ylabel('$r$');

% print('-f1', 'comparison.eps', '-depsc2');