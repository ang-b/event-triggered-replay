%test ReplayAttacker

t = linspace(0,10);
u = rand(100,1);
y = rand(100,1);

%% Test 1: recording does not change sequence
phase = AttackPhase.RECORD;
tildeu = zeros(100,1);
tildey = zeros(100,1);
rho = zeros(100,1);

A = ReplayAttacker();
kr = 50;
tildeu(1:kr-1) = u(1:kr-1);
tildey(1:kr-1) = y(1:kr-1);

for k = kr:100
    [tildeu(k), tildey(k)] = A.step(u(k),rho(k),y(k), phase); 
end

assert(all(u == tildeu));
assert(all(y == tildey));

%% Test 2: idle does not change sequence
phase = AttackPhase.IDLE;
tildeu = zeros(100,1);
tildey = zeros(100,1);
rho = zeros(100,1);

A = ReplayAttacker();
kr = 50;
tildeu(1:kr-1) = u(1:kr-1);
tildey(1:kr-1) = y(1:kr-1);

for k = kr:100
    [tildeu(k), tildey(k)] = A.step(u(k),rho(k),y(k), phase); 
end

assert(all(u == tildeu));
assert(all(y == tildey));

%% Test 3: playback plays back
phase = AttackPhase.RECORD;
tildeu = zeros(100,1);
tildey = zeros(100,1);
rho = zeros(100,1);

A = ReplayAttacker();
Tr = 1:20;
ka = 81;
rho(ka:100) = cos(1/pi * (ka:100));
expu = [u(1:ka-1); rho(ka:100)];
expy = [y(1:ka-1); y(Tr)];

for k = 1:100
    if k == Tr(end) + 1
        phase = AttackPhase.IDLE;
    elseif k == ka
        phase = AttackPhase.PLAYBACK;
    end
        
    [tildeu(k), tildey(k)] = A.step(u(k),rho(k),y(k), phase); 
end

assert(all(expu == tildeu));
assert(all(expy == tildey));

%% Test 4: playback is correct for repetition

% phase = AttackPhase.RECORD;
tildeu = zeros(100,1);
tildey = zeros(100,1);
rho = zeros(100,1);

A = ReplayAttacker();
Tr = 1:20;
Ta = {41:60, 81:100};
rho(Ta{1}) = cos(1/pi * Ta{1});
rho(Ta{2}) = cos(1/pi * Ta{2});
expu = [u(1:Ta{1}(1)-1); ...
        rho(Ta{1}); ...
        u(Ta{1}(end)+1:Ta{2}(1)-1); ...
        rho(Ta{2})];
expy = [y(1:Ta{1}(1)-1); ...
        y(Tr); ...
        y(Ta{1}(end)+1:Ta{2}(1)-1); ...
        y(Tr)];
phase = [repmat(AttackPhase.RECORD, [numel(Tr) 1]); ...
         repmat(AttackPhase.IDLE, [Ta{1}(1)-Tr(end)-1 1]); ...
         repmat(AttackPhase.PLAYBACK, [numel(Ta{1}) 1]); ...
         repmat(AttackPhase.IDLE, [Ta{2}(1)-Ta{1}(end)-1 1]); ...
         repmat(AttackPhase.PLAYBACK, [numel(Ta{2}) 1]);];
         
for k = 1:100        
    [tildeu(k), tildey(k)] = A.step(u(k),rho(k),y(k), phase(k)); 
end

assert(all(expu == tildeu));
assert(all(expy == tildey));