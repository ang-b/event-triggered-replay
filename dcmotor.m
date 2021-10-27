%% flags
clearvars

FORCE_RERUN = false;
PRINT_FIGS = false;

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

%% residual threshold
t = evtCtrlSim.tout;
r0 = spref;
sr = 0.3;
Mr = 17.5;

rbar = max(sr.^t, 1e-10);

% 
% kflag = false;
% for k = 1:length(t)
%     rbar(k) = norm((Ad - L*Cd)^k); 
%     if rbar(k) < sr^k && ~kflag
% %         k0 = k;
%         kflag = true;
%     end
% end


%% plot: general setup
lw = 1.4;
ttlfs = 15;
tckfs = 12;

figNames = {'comparison.eps';
            'alarms.eps';
            'states.eps';
            'trigger.eps'};
        
printer = @(i)  print(['-f' num2str(fi)], figNames{fi}, '-depsc2');

%% plot: residuals
fi = 1;
try close(fi), end

periodicResNorm = sigNorm(periodicCtrlSim.data.getElement('r').Values.Data, 2);
evtResNorm = sigNorm(evtCtrlSim.data.getElement('r').Values.Data, 2);

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .6]);

subplot(2,1,1)
plot(t, periodicResNorm, t, rbar, '--', 'LineWidth', lw);
title("Periodic control", 'FontSize', ttlfs);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
ylabel('$r$');

subplot(2,1,2)
plot(t, evtResNorm, t, rbar, '--', 'LineWidth', lw);
title("Event-triggered control", 'FontSize', ttlfs);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
ylabel('$r$');

if PRINT_FIGS, printer(fi), end %#ok<*UNRCH>

%% plot: alarms
fi = fi+1;
try close(fi), end

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .6]);

subplot(2,1,1)
plot(t, periodicResNorm > rbar, 'LineWidth', lw);
title("Periodic control", 'FontSize', ttlfs);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
ylabel('$r$');

subplot(2,1,2)
plot(t, evtResNorm > rbar, 'LineWidth', lw);
title("Event-triggered control", 'FontSize', ttlfs);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
ylabel('$r$');

if PRINT_FIGS, printer(fi), end %#ok<*UNRCH>

%% plot: controlled state
fi = fi+1;
try close(fi), end

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .6]);
plot(evtCtrlSim.data.getElement('x').Values, 'LineWidth', lw);
hold on
plot(evtCtrlSim.data.getElement('ref').Values, 'LineWidth', lw);
% ylim([-0.1 1.2]);

if PRINT_FIGS, printer(fi), end %#ok<*UNRCH>

%% plot: threshold error
fi = fi+1;
try close(fi), end

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .6]);
plot(evtCtrlSim.data.getElement('trig_err').Values, 'LineWidth', lw);
hold on
plot(evtCtrlSim.data.getElement('delta_sin').Values, 'LineWidth', lw);
% ylim([0 0.1]);
legend({'Trigger error', 'Threshold'}, 'Location', 'ne');

if PRINT_FIGS, printer(fi), end %#ok<*UNRCH>

%% utilities
function y = sigNorm(s, p)
    y = zeros(size(s,1),1);     
    for k = 1:size(s,1)
        y(k) = norm(s(k,:), p);
    end
end

