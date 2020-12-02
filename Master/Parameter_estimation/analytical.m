% Analytical mission to test parameter estimation
current_dir = pi/2;
current_speed = 1;
wave_dir = pi;
H = 1;
wind_dir = 1.2*pi;
wind_speed = 1;
m = 250;

   
D_w = [1, 0;
        0, 2];

D_c = [10, 0;
       0, 20];
    
K_f = 30;
K_s = 40;

V_c = rotZ_2(current_dir)*[current_speed;0];
V_w = rotZ_2(wind_dir)*[wind_speed;0];

timestep = 1;
duration = 10000;
timesteps = 0:timestep:duration;
steps = numel(timesteps);
psi=(0:(steps-1))*(2*pi)/(100);
eta = psi - wave_dir;
V_n = zeros(2,steps);
m_a_b = zeros(2*steps,1);

for i = 1:steps-1
    m_a_b(2*i-1:2*i) = ( D_c*rotZ_2(psi(i))*(V_c - V_n(:,i)) + D_w*rotZ_2(psi(i))*(V_w - V_n(:,i)) + [((cos(eta(i))^2)*K_f + (sin(eta(i))^2)*K_s)*(H^2); 0]);
    a_n = rotZ_2(-psi(i))*m_a_b(2*i-1:2*i)*(1/m);
    
    V_n(:,i+1) = V_n(:,i) + a_n*timestep;
    
end
V_n = V_n + randn(size(V_n))*0.01;

M_a_n = a_n*m;

% P_x = timestep.*tril(ones(steps))*V_n(1,:)';
% P_y = timestep.*tril(ones(steps))*V_n(2,:)';
% P = [P_x, P_y]';
% plot(P_x,P_y)

%% Estimate parameters

N_vals = numel(psi) - 2;

A = zeros(2*N_vals,6);
b = zeros(2*N_vals,1);
for i =1:N_vals-1
    V_wi = diag(rotZ_2(psi(i))*(-V_n(:,i) + V_w));
    V_ci = diag(rotZ_2(psi(i))*(-V_n(:,i) + V_c));
    r_i = [(cos(eta(i))^2)*H^2, (sin(eta(i))^2)*H^2;
            0, 0];
    A(1 + (i-1)*2:2*i,1:6) = [V_wi, V_ci r_i];
    b(1 + (i-1)*2:2*i,1) = rotZ_2(psi(i))*(-V_n(:,i) + V_n(:,i+1))*(m/(timestep));
end
x = A\b;

%% Calculating result variance

varSum = zeros(2,1);

for i =1:N_vals
    varSum = varSum + (A(1 + (i-1)*2:2*i,1:6)*x - b(1 + (i-1)*2:2*i,1)).^2;
end

var = varSum/N_vals;



