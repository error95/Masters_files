function [wind_velocity,wind_direction] = windy(x,y)
centre = [0;0];
dx = 0;
dy = 0;

wind_velocity = sqrt(dx^2 + dy^2)*0;
wind_direction = atan2(dy,dx) + pi/2;
end