function [time] = analytical_mission_cost(input)
%Function calculating the mission cost of a mission
% 
%     INPUT: input - An array describing Longitude and Latitude for each
%            waypoint and the control input for each waypint
% 
%     OUTPUT: time - Variable describing the duration of the mission
%                    TODO: Soon to describe mission costqfgwervwrqwrfr\!!!!!!!
%             v    - Array including velocity of the vessel between each
%                    waypoint. 

persistent lat_start long_start lat_end long_end
persistent goals_lat goals_long goals_rad goals_val goals_num
if isempty(lat_start)
    load('constraints.mat')
    lat_start = start_lat;
    long_start = start_long;
    lat_end = end_lat;
    long_end = end_long;
    load('measurement_goals.mat')
    goals_lat = lat_goals;
    goals_long = long_goals;
    goals_rad = rad_goals;
    goals_val = val_goals;
    goals_num = num_goals;
end

[inputs,~] = size(input);
x = [lat_start; input(1:inputs/3);lat_end];
y = [long_start; input(inputs/3 + 1: inputs*(2/3)); long_end];
sensor = [0;input(inputs*(2/3) + 1:inputs);0];

% implement solar radiation map
% implement energy states
% implement data transmission map
% tune all cost parameters
% ???
% sucsess
[steps,~] = size(x);
theGoals = goals_val;
t = zeros(1,steps);
v = zeros(steps-1,1);
sun =zeros(1,steps-1);

sensorCost = 20;

val = 0;



for i = 1:steps - 1
    seconds = t(i);
    hour = round(seconds/3600) + 10;
    hour_real = seconds/3600 + 10;
    x_i = x(i);
    y_i = y(i);

    
    % Find Mission goal Values. 
    goal_dist = sqrt((goals_long - repmat(y_i,goals_num,1)).^2 + (goals_lat - repmat(x_i,goals_num,1)).^2);
    inside  = (goal_dist<goals_rad)*sensor(i);
    val = val + sum(inside.*theGoals);
    theGoals = theGoals.*(~inside);
    
    % - Get current
    [currentX, currentY] = xyCurrent(x_i,y_i);
    % - Get wind
    [wnd_spd, wnd_dir] = windy(x_i,y_i);
    % - Get waves
    ww_spd = 1;
    ww_dir = 0;

    course = atan2(y(i+1) - y_i,x(i+1) - x_i);

    v(i) = weatherToVelocity([currentX, currentY],[0; 0], [ww_spd; ww_dir],course);
    distance = sqrt((y(i+1) - y_i)^2 + (x(i+1) - x_i)^2);
    if (v(i) < 0)||(~isreal(v(i)))
        t(steps) = 9999999;
        break
    end
    t(i+1) = t(i) + distance/v(i);
    
    % Calculating Battery energy
    sun(i) = cos(solar_angle(y_i,x_i,hour_real/24));
end

if isnan( t(steps) - val)
    time = 9999999;
else
    time = t(steps) - val + sensorCost*sum(sensor);
end



end
