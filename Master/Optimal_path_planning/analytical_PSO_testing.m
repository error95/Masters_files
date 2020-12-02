%Analytical test for the PSO where the weather input is created by the user
clear all
addpath('Analytical models')
%Start lat and start long does not have anyting with latitue and longitude
%in the analytical model. It is just regular x and y cooridanetes, but old
%names are kept to keep it similar to the weather foreacst pso
start_lat = -80;
start_long = -80;
end_lat = 280;
end_long = 80;

%Inesrt the ammount of waypoints/positions you want on the path solution:
positions = 20; %ajustable
% Possible bug with few points


save('constraints.mat','start_lat','start_long','end_lat','end_long')

lat_goals = []'; %ajustable
long_goals = []'; %ajustable
rad_goals = []'; %ajustable
val_goals = []'; %ajustable
num_goals = size(lat_goals,1);

save('measurement_goals.mat','lat_goals','long_goals','rad_goals','val_goals','num_goals')

latitude_points = [start_lat;lat_goals;end_lat];
longitude_points = [start_long;long_goals;end_long];

[latitude,longitude] = pathCreator(latitude_points,longitude_points,positions);

seed = [latitude(2:end-1)',longitude(2:end-1)', ones(1,positions-2)]';
[inputs,~] = size(seed);
nParticles = 100; %ajustable
maxIter = 400; %ajustable
contInput = 2*(positions-2);
boolInput = positions-2;

[default] = analytical_mission_cost(seed);
default


%%
[x_2, x_val_2, allInputs] = hybrid_PSO(@analytical_mission_cost,contInput,boolInput,seed,nParticles, maxIter);
%  [x_2, x_val_2]= fminsearch(@analytical_mission_cost,seed);
%%
result_lat = [start_lat; x_2(1:inputs/3); end_lat];
result_long = [start_long; x_2(inputs/3 +1:inputs*(2/3)); end_long];
%
figure(1)
plot([start_lat;result_lat;end_lat],[start_long;result_long;end_long])
fullTitle = append("Estimated Optimal path: ", num2str(min(min(x_val_2))), " seconds");
title(fullTitle)
xlabel("Meters")
ylabel("Meters")


allResultsLat = [repelem(start_lat,1,nParticles);  allInputs(1:inputs/3,:); repelem(end_lat,1,nParticles)];
allResultsLong = [repelem(start_long,1,nParticles); allInputs(inputs/3 +1:inputs*(2/3),:); repelem(end_long,1,nParticles)];
figure(2)
plot(allResultsLat, allResultsLong)
title("Particle paths")
xlabel("Meters")
ylabel("Meters")


figure(3)
X = repmat((1:maxIter)',1,nParticles+1);
defaultMtx = repmat(default,maxIter,1);
plot(X,[x_val_2,defaultMtx]);
title("Estimated duration of path")
xlabel("Iterations")
ylabel("Time (seconds)")

%%
hold on
figure(4)
plot(result_lat,result_long)
axis equal

%%

sensor = [0;x_2(inputs*(2/3) + 1:inputs);0];
bar(sensor)
