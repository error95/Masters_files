function [X,Y] = xyCurrent(x,y)
scaling = 0.02;

xN = (x*cos(pi/4) + y*sin(pi/4))*scaling;
yN = (-x*sin(pi/4) + y*cos(pi/4))*scaling;

Xt = sin(yN);
Yt = -sin(xN);

X = Xt*cos(pi/4) + -Yt*sin(pi/4);
Y = Xt*sin(pi/4) + Yt*cos(pi/4);
end

