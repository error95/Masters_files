d2r = pi/180;
latitude = linspace(63.435535,63.591103,30);
longitude = linspace(10.181745,10.643170,30);

load('weatherData_2020-2-20_2020-2-20.mat');

[latitudeGrid, longitudeGrid] = meshgrid(latitude,longitude);

[gridLat,gridLong] = size(latitudeGrid);

latitudeVector = reshape(latitudeGrid,[],1);
longitudeVector = reshape(longitudeGrid,[],1);
samplingTime = 3600*12;
numSamples = size(longitudeVector,1);
feasabilityNorth = zeros(numSamples,1);
feasabilityEast = feasabilityNorth;
feasabilitySouth = feasabilityNorth;
feasabilityWest = feasabilityNorth;

time = repelem(samplingTime, numSamples);


%% Importing weather data
windNorthList = mapDataExtraction(time, latitudeVector, longitudeVector, latitudeMapWindCurrent, longitudeMapWindCurrent, windNorth);
clear dataMapDataExtraction
windEastList = mapDataExtraction(time, latitudeVector, longitudeVector, latitudeMapWindCurrent, longitudeMapWindCurrent, windEast);
clear dataMapDataExtraction
windNed = [windNorthList; windEastList];
currentNorthList = mapDataExtraction(time, latitudeVector, longitudeVector, latitudeMapWindCurrent, longitudeMapWindCurrent, currentNorth);
clear dataMapDataExtraction
currentEastList = mapDataExtraction(time, latitudeVector, longitudeVector, latitudeMapWindCurrent, longitudeMapWindCurrent, currentEast);
clear dataMapDataExtraction
currentNed = [currentNorthList; currentEastList];
waveHeightList = mapDataExtraction(time, latitudeVector, longitudeVector, latitudeMapWave, longitudeMapWave, waveSize);
clear dataMapDataExtraction
waveDirList = mapDataExtraction(time, latitudeVector, longitudeVector, latitudeMapWave, longitudeMapWave, waveSize)*d2r;


%% Making map
for i = 1:numSamples
    test = windNorthList(i) + currentNorthList(i) + waveHeightList(i);
    if isnan(test)
        feasabilityNorth(i) = test;
        feasabilityEast(i) =  test;
        feasabilitySouth(i) = test;
        feasabilityWest(i) = test;
    else
        feasabilityNorth(i) = weatherToVelocity(currentNed(:,i),windNed(:,i),[waveHeightList(i) waveDirList(i)],0);
        feasabilityEast(i) =  weatherToVelocity(currentNed(:,i),windNed(:,i),[waveHeightList(i) waveDirList(i)],pi/2);
        feasabilitySouth(i) = weatherToVelocity(currentNed(:,i),windNed(:,i),[waveHeightList(i) waveDirList(i)],pi);
        feasabilityWest(i) =  weatherToVelocity(currentNed(:,i),windNed(:,i),[waveHeightList(i) waveDirList(i)],3*pi/2);
        
        feasabilityNorth(i) = max(feasabilityNorth(i)*isreal(feasabilityNorth(i)),0);
        feasabilityEast(i) = max(feasabilityEast(i)*isreal(feasabilityEast(i)),0);
        feasabilitySouth(i) = max(feasabilitySouth(i)*isreal(feasabilitySouth(i)),0);
        feasabilityWest(i) = max(feasabilityWest(i)*isreal(feasabilityWest(i)),0);
    end
end

feasabilityNorthMap = reshape(feasabilityNorth,gridLat,gridLong);
feasabilityEastMap = reshape(feasabilityEast,gridLat,gridLong);
feasabilitySouthMap = reshape(feasabilitySouth,gridLat,gridLong);
feasabilityWestMap = reshape(feasabilityWest,gridLat,gridLong);
waveHeight = reshape(waveHeightList,gridLat,gridLong);


%%
figure(1)
surf(latitudeGrid, longitudeGrid,feasabilityNorthMap)
title("North (m/s)")
xlabel("Latitude (Deg)")
ylabel("Longitude (Deg)")
figure(2)
surf(latitudeGrid, longitudeGrid,feasabilityEastMap)
title("West (m/s)")
xlabel("Latitude (Deg)")
ylabel("Longitude (Deg)")
figure(3)
surf(latitudeGrid, longitudeGrid,feasabilitySouthMap)
title("South (m/s)")
xlabel("Latitude (Deg)")
ylabel("Longitude (Deg)")
figure(4)
surf(latitudeGrid, longitudeGrid, feasabilityWestMap)
xlabel("Latitude (Deg)")
ylabel("Longitude (Deg)")
title("East (m/s)")
figure(5)
surf(latitudeGrid, longitudeGrid, waveHeight)
xlabel("Latitude (Deg)")
ylabel("Longitude (Deg)")
title("Wave Height")




