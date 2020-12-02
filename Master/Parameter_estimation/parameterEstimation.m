
%Parameter estimation uses a least squares method to fit to estimate
%parameters for the liear model. Input is vessel, current and wind velocity
%and wave height, direction and frequency estimate.

%% Load weather and vessel states
clear('all')
% load('Mausund_tests/20200703/062402_Mausund_1806_3-Goto4/GpsFix.mat');
% load('Mausund_tests/20200703/062402_Mausund_1806_3-Goto4/EulerAngles.mat');
% load('weatherData_2020-7-3_2020-7-3.mat');
% load('Mausund_tests/20200617/113359_Mausund_wayback-Goto1/GpsFix.mat');
% load('Mausund_tests/20200617/113359_Mausund_wayback-Goto1/EulerAngles.mat');
% load('weatherData_2020-6-17_2020-6-17.mat');
load('GpsFix.mat');
load('EulerAngles.mat');
load('weatherData_2020-2-20_2020-2-20.mat');

d2r= pi/180;

%mass of vessel:

m = 230; %ajustable

%Parameters for the parameter analysis. Startinput defines the smallest
%ammounts of inputs the parameter estimation uses. tests defines how many
%different parameter estimations from startInputs to N_vals will be made.

startInputs = 1000; %ajustable
tests = 100; %ajustable

%StartStep defines a what time you want to start the sampling for parameter
%estimation. setp defines the interval between each sample step you want to
%include. endStep defines where you want to stopp the sampling. Start aned
%enstep mus be withing the range of the samples.

startStep = 20000; %ajustable
step = 6; %ajustable
endStep = 70000; %ajustable


psi_temp = EulerAngles.psi;
psi_t_temp = EulerAngles.timestamp;


% Finding vessel velocity and bearing from gps and IMU data
latitude_temp = GpsFix.lon*(d2r)^-1;
longitude_temp = GpsFix.lat*(d2r)^-1;
pos_t_temp = GpsFix.utc_time;
pos_ts_temp = GpsFix.timestamp;

psi_init = psi_temp(psi_temp ~= 0);
psi_t_init = psi_t_temp(psi_temp ~= 0);
latitude_init= latitude_temp(latitude_temp ~= 0);
longitude_init = longitude_temp(longitude_temp ~= 0);
pos_t_init = pos_t_temp(longitude_temp ~= 0);
pos_ts_init = pos_ts_temp(longitude_temp ~= 0);

longitude = latitude_init(startStep:step:endStep);
latitude = longitude_init(startStep:step:endStep);
pos_t = pos_t_init(startStep:step:endStep);
pos_ts = pos_ts_init(startStep:step:endStep);
%
psi = interp1(psi_t_init, psi_init, pos_ts,'pchip');
%


distances = Haversine_deg(latitude(1:end-1),longitude(1:end-1),latitude(2:end),longitude(2:end),6371*10^3);
bearing_vessel = bearing(d2r*latitude(1:end-1),d2r*longitude(1:end-1),d2r*latitude(2:end),d2r*longitude(2:end));
timesteps = pos_t(2:end) - pos_t(1:end-1);

speed = (distances./timesteps);
speed(isnan(speed)) = 0;
speed_b = reshape([speed'; zeros(size(speed'))],[],1);

V_n =zeros(2,size(bearing_vessel,1)); 
for i = 1:size(bearing_vessel,1)
    V_n(:,i) = rotZ_2(bearing_vessel(i))*speed_b(2*i-1:2*i);
end

%Importing weather data
windNorthList = mapDataExtraction(pos_t, latitude, longitude, latitudeMapWindCurrent, longitudeMapWindCurrent, windNorth);
clear dataMapDataExtraction
windEastList = mapDataExtraction(pos_t, latitude, longitude, latitudeMapWindCurrent, longitudeMapWindCurrent, windEast);
clear dataMapDataExtraction
windNed = [windNorthList; windEastList];
currentNorthList = mapDataExtraction(pos_t, latitude, longitude, latitudeMapWindCurrent, longitudeMapWindCurrent, currentNorth);
clear dataMapDataExtraction
currentEastList = mapDataExtraction(pos_t, latitude, longitude, latitudeMapWindCurrent, longitudeMapWindCurrent, currentEast);
clear dataMapDataExtraction
currentNed = [currentNorthList; currentEastList];
waveHeightList = mapDataExtraction(pos_t, latitude, longitude, latitudeMapWave, longitudeMapWave, waveSize);
clear dataMapDataExtraction
waveDirList = mapDataExtraction(pos_t, latitude, longitude, latitudeMapWave, longitudeMapWave, waveSize)*d2r;

eta = psi -waveDirList' + pi/2;

% Estimate parameters

N_vals = numel(psi) - 2;

endInput = N_vals;

measurementIntervals = round(linspace(startInputs,endInput,tests));




measurements = endInput;
    

A = zeros(2*measurements,6);
b = zeros(2*measurements,1);
for i =1:measurements-1
    V_wi = diag(rotZ_2(psi(i))*(-V_n(:,i) + windNed(:,i)));
    V_ci = diag(rotZ_2(psi(i))*(-V_n(:,i) + currentNed(:,i)));
    r_i = [(cos(eta(i))^2)*waveHeightList(i), (sin(eta(i))^2)*waveHeightList(i);
            0, 0];
    b_tmp = rotZ_2(psi(i))*(-V_n(:,i) + V_n(:,i+1))*(m/(timesteps(i)));
    if or(isnan(b_tmp),isinf(b_tmp))
        b_tmp = 0;
    end

    A(1 + (i-1)*2:2*i,1:6) = [V_wi, V_ci r_i];
    b(1 + (i-1)*2:2*i,1) = b_tmp;
end

x = zeros(6,tests);
j = 1;
for k = measurementIntervals
    
    x(:,j) = A(1:k,:)\b(1:k,:);
    j = j+1;
end


%     %% Calculating result variance
% 
%     varSum = zeros(2,1);
% 
%     for i =1:N_vals
%         varSum = varSum + (A(1 + (i-1)*2:2*i,1:6)*x - b(1 + (i-1)*2:2*i,1)).^2;
%     end

% var = varSum/N_vals;

%
figure(1)
plot(repelem(measurementIntervals,6,1)',x')
xlabel("Samples")
ylabel("Newtons per measurement unit")
legend("D-wf","D-ws","D-cf","D-cs","F-f","F-s")
ylim([0 200])

%%
% 
% figure(2)
% hold on
% plot(psi)
% plot(bearing_vessel)


