function [rotZ] = rotZ_2(psi)

    [n,~] = size(psi);
    rotZ = zeros(2*n,2*n);
    for i = 1:n
        rotZ(1 + (i-1)*2:2*i,1 + (i-1)*2:2*i) = [cos(psi(i)), -sin(psi(i));
                                                 sin(psi(i)), cos(psi(i))];
    end
    
        
end

