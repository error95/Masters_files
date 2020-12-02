function [currentX, currentY] = current_t(x,y,t)
    
    rad = 0.02*2*pi;
    currentSpeed = 1.2;
    if y > 0
%             currentX = (1 - exp(-y))*currentSpeed*sin(t*rad);
            currentX = currentSpeed*cos(t*rad);
%             currentX = y*currentSpeed*sin(t*rad);
            currentY = 0;
    else
        currentX = -currentSpeed*sin(t*rad);
%         currentX = -(1 - exp(y))*currentSpeed*sin(t*rad);
        currentY = 0;
    end

end

