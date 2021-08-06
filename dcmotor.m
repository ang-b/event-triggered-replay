load('dcmotorparams.mat')

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
plot(EvtCtrlSim.data.getElement('r').Values)
title("Event-triggered control");