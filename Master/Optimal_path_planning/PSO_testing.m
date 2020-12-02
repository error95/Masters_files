clear all

start_lat = 63.467275; %ajustable
start_long = 10.383189; %ajustable
end_lat = 63.467275; %ajustable
end_long = 10.383189; %ajustable
save('constraints.mat','start_lat','start_long','end_lat','end_long')

lat_goals = [63.522433 63.517534]'; %ajustable 
long_goals = [10.260966 10.494425]'; %ajustable
rad_goals = [1000 1000]'; %ajustable
val_goals = [1000 1000]'; %ajustable
num_goals = size(lat_goals,1);

save('measurement_goals.mat','lat_goals','long_goals','rad_goals','val_goals','num_goals')

latitude_points = [start_lat;lat_goals;end_lat];
longitude_points = [start_long;long_goals;end_long];

positions = 20; %ajustable
% Possible bug with few points
[latitude,longitude] = pathCreator(latitude_points,longitude_points,positions);

seed = [latitude(2:end-1)',longitude(2:end-1)', 0*ones(1,positions-2)]';
[inputs,~] = size(seed);
nParticles = 100; %ajustable
maxIter = 50; %ajustable
contInput = 2*(positions-2);
boolInput = positions-2;

[default,~,sun] = mission_cost(seed);
default


%%
[x_2, x_val_2, allInputs] = hybrid_PSO(@mission_cost,contInput,boolInput,seed,nParticles, maxIter);
%[x_2, x_val_2]= fminsearch(@mission_cost,seed);
%%
result_lat = [start_lat; x_2(1:inputs/3); end_lat];
result_long = [start_long; x_2(inputs/3 +1:inputs*(2/3)); end_long];
%%
 figure(1)
 plot([start_lat;result_lat;end_lat],[start_long;result_long;end_long])
 title("Optimal Path - Trondheim Fjord - Time Invariant")

figure(2)
X = repmat((1:maxIter)',1,nParticles+1);
defaultMtx = repmat(default,maxIter,1);
plot(X,[x_val_2,defaultMtx]);
title("Particle Cost - Trondheim Fjord - Time Invariant")

allResultsLat = [repelem(start_lat,1,nParticles);  allInputs(1:inputs/3,:); repelem(end_lat,1,nParticles)];
allResultsLong = [repelem(start_long,1,nParticles); allInputs(inputs/3 +1:inputs*(2/3),:); repelem(end_long,1,nParticles)];
figure(3)
plot(allResultsLat, allResultsLong)
title("Particle Paths - Trondheim Fjord - Time Invariant")
xlabel("Latitude")
ylabel("Longitude")

figure(4)
sensor = [0;x_2(inputs*(2/3) + 1:inputs);0];
bar(sensor)
title("Sensor Usage - Trondheim Fjord - Time Invariant")
xlabel("Waypoint")
ylim([0 2])

figure(5)

geoplot([start_lat;result_lat;end_lat],[start_long;result_long;end_long])
title("Optimal Path - Trondheim Fjord - Time Invariant")
geolimits([63.2 64.5],[10 11])




