%% flags
clearvars

flags.FORCE_PARAMS = true;
flags.PRINT_FIGS = false;
flags.RUN_SIM = true;

%% simulation
if flags.RUN_SIM
    if exist('dcmotorparams.mat', 'file') == 2 && ~flags.FORCE_PARAMS
        load('dcmotorparams.mat')
    else
        makedcmotorparams 
    end
    warning off

    isEvt = false;
    disp("Simulating in periodic control mode");
    periodicCtrlSim = sim('dcmotor_sim');

    disp("Simulating in event-triggered control mode");
    isEvt = true;
    evtCtrlSim = sim('dcmotor_sim');
    warning on
    save('dcsim.mat');
    tmp = rmfield(load('dcsim.mat'), 'flags');
    % Resave, '-struct' flag tells MATLAB to store the fields as distinct variables
    save('dcsim.mat', '-struct', 'tmp');
elseif exist('dcsim.mat','file') == 2
    load('dcsim.mat')
else    
    error("No sim data file, please run simulation");
end


%% residual threshold
t = evtCtrlSim.tout;
r0 = spref;
sr = 0.3;
Mr = 17.5;

rbar = max(Mr*sr.^t, 1e-10);

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
lw = 1.6;
ttlfs = 15;
tckfs = 12;

figNames = {'comparison.eps';
            'alarms.eps';
            'states.eps';
            'trigger.eps';
            'phases.eps'};
        
printer = @(i)  print(['-f' num2str(i)], figNames{i}, '-depsc2');

timeText = 'Time (seconds)';

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
ylabel('$\|r\|$');
legend({'$\|r\|$', '$\bar{r}$'}, 'interpreter', 'latex', 'location', 'nw');
grid on

subplot(2,1,2)
plot(t, evtResNorm, t, rbar, '--', 'LineWidth', lw);
title("Event-triggered control", 'FontSize', ttlfs);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
ylabel('$\|r\|$');
ylim([0 5e-2]);
xlabel(timeText);
legend({'$\|r\|$', '$\bar{r}$'}, 'interpreter', 'latex', 'location', 'nw');
grid on

if flags.PRINT_FIGS, printer(fi), end %#ok<*UNRCH>

%% plot: alarms
fi = 2;
try close(fi), end

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .6]);

subplot(2,1,1)
plot(t, periodicResNorm > rbar, 'LineWidth', lw);
title("Periodic control", 'FontSize', ttlfs);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
ylabel('Alarm signal');
ylim([-0.1 1.1]);
grid on

subplot(2,1,2)
plot(t, evtResNorm > rbar, 'LineWidth', lw);
title("Event-triggered control", 'FontSize', ttlfs);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
ylabel('Alarm signal');
xlabel(timeText);
ylim([-0.1 1.1]);
grid on

if flags.PRINT_FIGS, printer(fi), end %#ok<*UNRCH>

%% plot: controlled state
fi = 3;
try close(fi), end

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .4]);
plot(t,periodicCtrlSim.data.getElement('x').Values.Data(:,1), 'LineWidth', lw);
hold on
grid on
plot(t,periodicCtrlSim.data.getElement('ref').Values.Data(:,1),'--', 'LineWidth', lw);
legend({'Speed', 'Speed reference'}, 'Location', 'nw','interpreter', 'latex', 'fontsize', tckfs);
ylim([-0.1 35]);
set(gca,'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
xlabel(timeText, 'Interpreter', 'latex');
ylabel('motor speed (rad/s)', 'Interpreter', 'latex');

if flags.PRINT_FIGS, printer(fi), end %#ok<*UNRCH>

%% plot: threshold error
fi = 4;
try close(fi), end

terr = evtCtrlSim.data.getElement('trig_err').Values;
tdelta = evtCtrlSim.data.getElement('delta_sin').Values;

figure(fi);
set(fi, 'DefaultTextInterpreter', 'latex');
set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .4]);
plot(terr, 'LineWidth', lw);
hold on
grid on
plot(tdelta, '--', 'LineWidth', lw);
ylim([0 6]);
ylabel('$\|\hat{x} - \bar x\|$','interpreter','latex');
legend({'Trigger error', 'Threshold'}, 'Location', 'nw','interpreter', 'latex', 'fontsize', tckfs);
set(gca,'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
xlabel(timeText,'Interpreter', 'latex');

axes('Position', [0.55 0.6 0.33 0.3]);
box on
zoom_i = find(t >= 10 & t <= 10.2);
plot(t(zoom_i), terr.Data(zoom_i,:), 'LineWidth', lw);
hold on
grid on
plot(t(zoom_i), tdelta.Data(zoom_i,:), '--', 'LineWidth', lw);
set(gca,'TickLabelInterpreter', 'latex');

if flags.PRINT_FIGS, printer(fi), end %#ok<*UNRCH>

%% plot: attack phase
% fi = 5;
% try close(fi), end
% 
% figure(fi);
% set(fi, 'DefaultTextInterpreter', 'latex');
% set(fi, 'Units', 'normalized', 'Position', [0 0 .4 .4]);
% plot(evtCtrlSim.data.getElement('phase').Values, 'LineWidth', lw);
% xlabel(timeText,'Interpreter', 'latex');
% set(gca,'TickLabelInterpreter', 'latex', 'FontSize', tckfs);
% [~, ylabs] = enumeration('AttackPhase');
% yticklabels(ylabs);
% yticks([0 1 2]);
% ylim([-0.1 2.1]);
% % ylabel('Attack phase', 'interpreter', 'latex');
% % title('');
% ylabel('');
% title('Attack Phases', 'interpreter', 'latex', 'fontsize', ttlfs);
% grid on
% 
% if flags.PRINT_FIGS, printer(fi), end %#ok<*UNRCH>

%% utilities
function y = sigNorm(s, p)
    y = zeros(size(s,1),1);     
    for k = 1:size(s,1)
        y(k) = norm(s(k,:), p);
    end
end

