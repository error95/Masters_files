function [current_velocity,current_direction] = current(x,y)
scaling = 0.02;
xN = (x*cos(pi/4) + y*sin(pi/4))*scaling;
yN = (-x*sin(pi/4) + y*cos(pi/4))*scaling;

Xt = sin(yN);
Yt = -sin(xN);

dx = Xt*cos(pi/4) + -Yt*sin(pi/4);
dy = Xt*sin(pi/4) + Yt*cos(pi/4);

current_velocity = sqrt(dx^2 + dy^2);
current_direction = atan2(dy,dx);
end

