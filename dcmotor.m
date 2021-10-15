FORCE_RERUN = false;
if exist('dcmotorparams.mat', 'file') == 2 && ~FORCE_RERUN
    load('dcmotorparams.mat')
else
    makedcmotorparams 
end

%% simulation

warning off

isEvt = false;
disp("Simulating in periodic control mode");
periodicCtrlSim = sim('dcmotor_sim');

disp("Simulating in event-triggered control mode");
isEvt = true;
evtCtrlSim = sim('dcmotor_sim');

warning on

%% plots
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


%% printing
PRINT_FIGS = false;

if PRINT_FIGS 
    print('-f1', 'comparison.eps', '-depsc2');
end