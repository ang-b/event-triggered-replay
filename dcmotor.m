if (exist('dcmotorparams.mat', 'file') == 2)
    load('dcmotorparams.mat')
else
    makedcmotorparams 
end

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