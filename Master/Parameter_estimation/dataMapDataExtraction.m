function [data] = dataMapDataExtraction(timestamp, long, lat,longMap,latMap,dataMap)
    persistent lastPositionLat lastPositionLong dataMatrix latMatrix longMatrix
    [numRows,numCols] = size(longMap);
    resolution = 800;
    dataMatrixLength = 61;
    hour = round(timestamp/3600);
    
    if isempty(lastPositionLat) || resolution*dataMatrixLength/2 < Haversine_deg(lat, long, lastPositionLat, lastPositionLong,6371*10^3)
        disp("empty");
        buffer = floor(dataMatrixLength/2);
        long_lat = repmat(lat,numRows-2*buffer,numCols-2*buffer);
        long_long = repmat(long,numRows-2*buffer,numCols-2*buffer);
        pos_diff = Haversine_deg(long_lat,long_long,latMap(buffer+1:end-buffer,buffer+1:end-buffer),longMap(buffer+1:end-buffer,buffer+1:end-buffer),6371*10^3);
        [test,unbufferedIndex] = minmat(pos_diff);
        index = unbufferedIndex + [buffer buffer];
        dataMatrix = dataMap(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer,:);
        latMatrix = latMap(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer);
        longMatrix = longMap(index(1)- buffer:index(1) + buffer,index(2)- buffer:index(2) + buffer);
        lastPositionLat = lat;
        lastPositionLong = long;
    end
    
    long_lat = repmat(lat,dataMatrixLength,dataMatrixLength);
    long_long = repmat(long,dataMatrixLength,dataMatrixLength);
    pos_diff = Haversine_deg(long_lat,long_long,latMatrix,longMatrix,6371*10^3);
    [test, index] = minmat(pos_diff);
    data = dataMatrix(index(1),index(2),hour);

        
end

