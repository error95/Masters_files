function [data] = mapDataExtraction(timestamp, latitude, longitude, latitude_map, longitude_map, map_data)
    [n_positions,~] = size(latitude);
    data = zeros(1,n_positions);


    for i = 1:n_positions
        
        data(i) = dataMapDataExtraction(timestamp(i), latitude(i), longitude(i), latitude_map, longitude_map, map_data);
    end
end

