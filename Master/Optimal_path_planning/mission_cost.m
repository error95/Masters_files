function [time,v,sun] = mission_cost(input)
%Function calculating the mission cost of a mission
% 
%     INPUT: input - An array describing Longitude and Latitude for each
%            waypoint and the control input for each waypint
% 
%     OUTPUT: time - Variable describing the duration of the mission
%                    TODO: Soon to describe mission costqfgwervwrqwrfr\!!!!!!!
%             v    - Array including velocity of the vessel between each
%                    waypoint. 

persistent windEastForecast windNorthForecast currentNorthForecast currentEastForecast waveSizeForecast waveDirForecast
persistent latitudeMapWaveMap longitudeMapWaveMap latitudeMapWindCurrentMap longitudeMapWindCurrentMap
persistent lat_start long_start lat_end long_end
persistent goals_lat goals_long goals_rad goals_val goals_num
persistent lastPositionLatWindCur lastPositionLongWindCur latMatrixWindCur longMatrixWindCur
persistent  dataMatrixWindEast dataMatrixCurEast dataMatrixWindNorth dataMatrixCurNorth
persistent lastPositionLatWav lastPositionLongWav dataMatrixWavHeight dataMatrixWavDir latMatrixWav longMatrixWav
if isempty(windEastForecast)
    load('weatherData_2020-2-20_2020-2-20.mat')
    windEastForecast = windEast;
    windNorthForecast = windNorth;
    currentNorthForecast = currentNorth;
    currentEastForecast = currentEast;
    waveSizeForecast = waveSize;
    waveDirForecast = waveDir;
    latitudeMapWaveMap = latitudeMapWave;
    longitudeMapWaveMap = longitudeMapWave;
    latitudeMapWindCurrentMap = latitudeMapWindCurrent;
    longitudeMapWindCurrentMap = longitudeMapWindCurrent;
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
latitude = [lat_start; input(1:inputs/3);lat_end];
longitude = [long_start; input(inputs/3 + 1: inputs*(2/3)); long_end];
sensor = [0;input(inputs*(2/3) + 1:inputs);0];

% implement solar radiation map
% implement energy states
% implement data transmission map
% tune all cost parameters
% ???
% sucsess
[steps,~] = size(longitude);
maxHours = size(currentEastForecast,3);
deg2rad = pi/180;
theGoals = goals_val;
r = 6371000;
t = zeros(1,steps);
v = zeros(steps-1,1);
sun =zeros(1,steps-1);
val = 0;
hourlyCost = 1000;



for i = 1:steps - 1
    seconds = t(i);
    hour = round(seconds/3600)+1;
    if hour > maxHours
        time = 9999999;
        return
    end

    lat = latitude(i);
    long = longitude(i);
    
    % Find position on weather map
        
    [numRows,numCols] = size(latitudeMapWindCurrentMap);
    resolution = 800;
    dataMatrixLength = 101; % has to be odd number
    
    if isempty(lastPositionLatWindCur) || (resolution*dataMatrixLength*0.5 < Haversine_deg(lat, long, lastPositionLatWindCur, lastPositionLongWindCur,6371*10^3))
        %disp("Loading Current and Wind Matrix");
        buffer = floor(dataMatrixLength/2);
        long_lat = repmat(lat,numRows-2*buffer,numCols-2*buffer);
        long_long = repmat(long,numRows-2*buffer,numCols-2*buffer);
        pos_diff = Haversine_deg(long_lat,long_long,latitudeMapWindCurrentMap(buffer+1:end-buffer,buffer+1:end-buffer),longitudeMapWindCurrentMap(buffer+1:end-buffer,buffer+1:end-buffer),6371*10^3);
        [test,unbufferedIndex] = minmat(pos_diff);
        index = unbufferedIndex + [buffer buffer];
        dataMatrixWindEast = windEastForecast(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        dataMatrixWindNorth = windNorthForecast(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        dataMatrixCurEast = currentEastForecast(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        dataMatrixCurNorth = currentNorthForecast(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        latMatrixWindCur = latitudeMapWindCurrentMap(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        longMatrixWindCur = longitudeMapWindCurrentMap(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        lastPositionLatWindCur = latitudeMapWindCurrentMap(index(1),index(2));
        lastPositionLongWindCur = longitudeMapWindCurrentMap(index(1),index(2));
    end
    
    long_lat = repmat(lat,dataMatrixLength,dataMatrixLength);
    long_long = repmat(long,dataMatrixLength,dataMatrixLength);
    pos_diff = Haversine_deg(long_lat,long_long,latMatrixWindCur,longMatrixWindCur,6371*10^3);
    [~, index] = minmat(pos_diff);
    wndEast = dataMatrixWindEast(index(1),index(2),hour);
    wndNorth = dataMatrixWindNorth(index(1),index(2),hour);
    curEast = dataMatrixCurEast(index(1),index(2),hour);
    curNorth = dataMatrixCurNorth(index(1),index(2),hour);
    
    
    
    [numRows,numCols] = size(latitudeMapWaveMap);
    
    if isempty(lastPositionLatWav) || resolution*dataMatrixLength/2 < Haversine_deg(lat, long, lastPositionLatWav, lastPositionLongWav,6371*10^3)
        %disp("Loading Wave matrix");
        buffer = floor(dataMatrixLength/2);
        long_lat = repmat(lat,numRows-2*buffer,numCols-2*buffer);
        long_long = repmat(long,numRows-2*buffer,numCols-2*buffer);
        pos_diff = Haversine_deg(long_lat,long_long,latitudeMapWaveMap(buffer+1:end-buffer,buffer+1:end-buffer),longitudeMapWaveMap(buffer+1:end-buffer,buffer+1:end-buffer),6371*10^3);
        [~,unbufferedIndex] = minmat(pos_diff);
        index = unbufferedIndex + [buffer buffer];
        dataMatrixWavHeight = waveSizeForecast(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        dataMatrixWavDir = waveDirForecast(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        latMatrixWav = latitudeMapWaveMap(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        longMatrixWav = longitudeMapWaveMap(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        lastPositionLatWav = latitudeMapWaveMap(index(1),index(2));
        lastPositionLongWav = longitudeMapWaveMap(index(1),index(2));
    end
    
    long_lat = repmat(lat,dataMatrixLength,dataMatrixLength);
    long_long = repmat(long,dataMatrixLength,dataMatrixLength);
    pos_diff = Haversine_deg(long_lat,long_long,latMatrixWav,longMatrixWav,6371*10^3);
    [~, index] = minmat(pos_diff);
    wavHeight = dataMatrixWavHeight(index(1),index(2),hour);
    wavDir = dataMatrixWavDir(index(1),index(2),hour);
    
   
        
    
    % Find Mission goal Values. 
    goal_dist = Haversine_deg(goals_long, goals_lat, repmat(long,goals_num,1),repmat(lat,goals_num,1),r);
    inside  = (goal_dist<goals_rad)*sensor(i);
    val = val + sum(inside.*theGoals);
    theGoals = theGoals.*(~inside);
  
    % - Describe full function (possibly newton method??
    course = bearing(latitude(i)*deg2rad,longitude(i)*deg2rad,latitude(i+1)*deg2rad,longitude(i+1)*deg2rad);
    testSum = curNorth + curEast + wndNorth + wndEast + wavHeight + wavDir;
    if isnan(testSum)
        disp("Crash");
        time = 9999999;
        return
    else
        v(i) = weatherToVelocity([curNorth; curEast],[wndNorth; wndEast], [wavHeight; wavDir],-course);
        distance = Haversine_deg(latitude(i+1),longitude(i+1),latitude(i),longitude(i),r);
        if (v(i) < 0)||(~isreal(v(i)))
            time = 9999999;
            return    
        end
    end
    t(i+1) = t(i) + distance/v(i);
    
    % Calculating Battery energy
    sun(i) = cos(solar_angle(long,lat,hour/24));
end
if isnan( t(steps) - val)
    time = 9999999;
else
    time = (t(steps))/3600*hourlyCost - val + sum(sensor)*100;
end

end

