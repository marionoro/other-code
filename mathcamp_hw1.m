% 2
t=1000; %size (+1) 
mp = [1 0 -1];
N=5;
Y=zeros(t,N);
i=1;
y0=zeros(t,1);
   while i<=N;
       for j=2:t
           e = mp((rand(t,1)<1/3) + (rand(t,1)<2/3)+1);
           y0(j,1)=y0(j-1,1)+e(j);
       end
       Y(:,i)=y0;
       y0=zeros(t,1);
       i=i+1;
   end
   plot(Y(:,[1 2 3 4 5]));
     
%Markov Chains
% 1
p = 0.3
q = 0.2

transitionMatrix = diag(repmat([1-p-q],1,200));

for i = 1:199
    transitionMatrix(i,i+1) = p;
    transitionMatrix(i+1,i) = q;
end

transitionMatrix(1,1) = 1-p;
transitionMatrix(200,200) = 1-q;
transitionMatrix

% 2
pi_0 = [1,repmat(0,1,199)]
pi_1000 = pi_0 * transitionMatrix^1000;

pi_1000

% 3
epsilon_mean = p - q
epsilon_var = p^2 + p - 2 * p * q + q + q^2
    
theory_mean = 0 + 1000 * epsilon_mean
theory_var = 1000 * epsilon_var

bar(1:length(pi_1000),pi_1000)

hold on

plot([0:1:200], normpdf([0:1:200],theory_mean,sqrt(theory_var)))

hold off

% 5.2
% 
k_ss = 0.1867
N = 200
w_grid = linspace(0.05 * k_ss, 1.2 * k_ss, N)

V0 = repmat(0, 200,1)'

M = 10000
m=0;
tol=1;
beta = 0.98
alpha = 1/3
delta = 1
z = 1
k0 = 0.05*k_ss
k_t = w_grid'*ones(1,N)
k_t_plus_one = ones(N,1)*w_grid

c_t = (z*((k_t).^(alpha))) + ((1-delta).*(k_t)) - (k_t_plus_one)


w_grid

intermed_matrix = 1e-10.* (c_t < 0) + c_t.*(c_t >= 0)

V1 = repmat(0, 200,1)'

while (tol>1e-5 && m<M)
    m = m+1
    V0=V1;
    V1 = max(log(intermed_matrix) + beta.*ones(N,1)*V0,[],2)';
%    V1(1:5)
    tol = max(abs(V1-V0));
end

A = max(log(intermed_matrix) + beta.*ones(N,1)*V0,[],1)'

max(w_grid' .* (A == max(A)))
% ^ This returns the steady state of capital
