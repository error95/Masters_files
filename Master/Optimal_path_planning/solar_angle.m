function [alpha] = solar_angle(longitude_deg,latitude_deg,day)
    
    longitude = longitude_deg*(pi/180);
    latitude = latitude_deg*(pi/180);
    midsummer = 173;
    mid_day = 12;
    declination_angle = 0.39795*cos(0.98563*(day - midsummer)*(pi/180));
    hour_angle = 15*(day*24 - mid_day);
    relative_longitude = (hour_angle - longitude)*(pi/180);
    alpha_val = asin(sin(declination_angle)*sin(latitude) + cos(declination_angle)*cos(relative_longitude)*sin(latitude));
    if ~isreal(alpha_val)
        alpha = pi/2;
    else
        alpha = alpha_val;
    end
    
end

