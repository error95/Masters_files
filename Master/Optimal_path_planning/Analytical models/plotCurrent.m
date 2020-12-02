x = -100*pi:pi*8:100*pi;
y = x;



[X, Y] = meshgrid(x,y);

[xCurrent,yCurrent] = xyCurrent(X,Y);
figure(4)
quiver(X,Y,xCurrent,yCurrent);
