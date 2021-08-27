function Y = haux(p, A, B, K)
%HX Summary of this function goes here
%   Detailed explanation goes here
Y = A^p;
for t = 0:p-1
    Y = Y + A^(p-t-1)*B*K;
end