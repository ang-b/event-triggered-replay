%test ReplayAttacker

t = linspace(0,10);
u = rand(100,1);
y = rand(100,1);

%% Test 1: recording does not change sequence
phase = AttackPhase.RECORD;
tildeu = zeros(100,1);
tildey = zeros(100,1);

A = ReplayAttacker();
kr = 50;
tildeu(1:kr-1) = u(1:kr-1);
tildey(1:kr-1) = y(1:kr-1);

for k = kr:100
    [tildeu(k), tildey(k)] = A.step(u(k),y(k), phase); 
end

assert(all(u == tildeu));
assert(all(y == tildey));

%% Test 2: idle does not change sequence
phase = AttackPhase.IDLE;
tildeu = zeros(100,1);
tildey = zeros(100,1);

A = ReplayAttacker();
kr = 50;
tildeu(1:kr-1) = u(1:kr-1);
tildey(1:kr-1) = y(1:kr-1);

for k = kr:100
    [tildeu(k), tildey(k)] = A.step(u(k),y(k), phase); 
end

assert(all(u == tildeu));
assert(all(y == tildey));

%% Test 3: playback plays back
phase = AttackPhase.RECORD;
tildeu = zeros(100,1);
tildey = zeros(100,1);

A = ReplayAttacker();
Tr = 1:20;
ka = 81;
expu = [u(1:ka-1); u(Tr)];
expy = [y(1:ka-1); y(Tr)];

for k = 1:100
    if k == Tr(end) + 1
        phase = AttackPhase.IDLE;
    elseif k == ka
        phase = AttackPhase.PLAYBACK;
    end
        
    [tildeu(k), tildey(k)] = A.step(u(k),y(k), phase); 
end

assert(all(expu == tildeu));
assert(all(expy == tildey));