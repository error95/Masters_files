function [R] = LatLongRot(lat,long)
    R = [ - sin(lat)*cos(long), -sin(long) -cos(lat)*cos(long);
        -sin(lat)*sin(long), cos(long), -cos(lat)*sin(long);
        cos(lat), 0, -sin(long)];
end

