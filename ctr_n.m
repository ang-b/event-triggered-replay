function Ct = ctr_n(A,B,N)
%CTR_N Summary of this function goes here
%   Detailed explanation goes here

n = size(A,1);
m = size(B,2);
% Ct = zeros(n, N*m);
% for i = 1:N
%     Ct(:,((i-1)*m+1):(m*i)) = A^(i-1) * B;
% end

% Ct = zeros(n*N, m);
% for i = 1:N
%     Ct(((i-1)*n+1):n*i,:) = A^(i-1)*B; 
% end


Ct = zeros(n,m);
for i = 1:N
   Ct = Ct + A^(i-1)*B;
end
end

