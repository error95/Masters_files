function [data] = waveMapDataExtraction(long, lat, dataMap,longMap,latMap,hour)
  
    persistent lastPositionLat lastPositionLong dataMatrix 
    [numRows,numCols] = size(longMap);
    resolution = 800;
    dataMatrixLength = 5;
    if isempty(lastPositionLat) || resolution*dataMatrixLength/2 < Haversine_deg(lat, long, lastPositionLat, lastPositionLong)
        buffer = floor(dataMatrixLength/2);
        long_lat = repmat(lat,numRows,numCols);
        long_long = repmat(long,numRows,numCols);
        pos_diff = Haversine_deg(long_lat,long_long,latMap,longMap,6371*10^3);
        [~, index] = minmat(pos_diff);
        dataMatrix = dataMap(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        data = dataMatrix(index(1),index(2),hour);
    else
        long_lat = repmat(lat,numRows,numCols);
        long_long = repmat(long,numRows,numCols);
        pos_diff = Haversine_deg(long_lat,long_long,latMap,longMap,6371*10^3);
        [~, index] = minmat(pos_diff);
        data = dataMatrix(index(1),index(2),hour);
    end
end

