%% flags

FORCE_RERUN = false;
PRINT_FIGS = true;

%% setup
if exist('dcmotorparams.mat', 'file') == 2 && ~FORCE_RERUN
    load('dcmotorparams.mat')
else
    makedcmotorparams 
end

%% simulation
warning off

isEvt = false; %#ok<NASGU>
disp("Simulating in periodic control mode");
periodicCtrlSim = sim('dcmotor_sim');

disp("Simulating in event-triggered control mode");
isEvt = true;
evtCtrlSim = sim('dcmotor_sim');

warning on

%% plot: general setup
lw = 1.8;
ttlfs = 15;
tckfs = 12;

figNames = {'comparison.eps'; 
            'states.eps';
            'trigger.eps'};

%% plot: residuals
fi = 1;
try close(fi), end

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .6]);

subplot(2,1,1)
plot(periodicCtrlSim.data.getElement('r').Values, 'LineWidth', lw)
title("Periodic control", 'FontSize', ttlfs);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
ylabel('$r$');

subplot(2,1,2)
plot(evtCtrlSim.data.getElement('r').Values, 'LineWidth', lw)
title("Event-triggered control", 'FontSize', ttlfs);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
ylabel('$r$');

if PRINT_FIGS 
     print(['-f' num2str(fi)], figNames{fi}, '-depsc2'); %#ok<*UNRCH>
end

%% plot: controlled state
fi = 2;
try close(fi), end

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .6]);
plot(evtCtrlSim.data.getElement('x').Values, 'LineWidth', lw);
hold on
plot(evtCtrlSim.data.getElement('ref').Values, 'LineWidth', lw);
ylim([-0.1 1.2]);

if PRINT_FIGS 
     print(['-f' num2str(fi)], figNames{fi}, '-depsc2'); %#ok<*UNRCH>
end

%% plot: threshold error
fi = 3;
try close(fi), end

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .6]);
plot(evtCtrlSim.data.getElement('trig_err').Values, 'LineWidth', lw);
hold on
plot(evtCtrlSim.data.getElement('delta_sin').Values, 'LineWidth', lw);
ylim([0 0.1]);
legend({'Trigger error', 'Threshold'}, 'Location', 'ne');

if PRINT_FIGS 
     print(['-f' num2str(fi)], figNames{fi}, '-depsc2'); %#ok<*UNRCH>
end
