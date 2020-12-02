function [velocity] =  weatherToVelocity(current,wind,waves,course)
    %TODO: MAKE A MORE CORRECT VELOCITY FUNCTION
    fCurrent = 57; %ajustable
    fWind = 5; %ajustable
    
    K = fWind/fCurrent;
    v_weather = (current + wind*K)/(1 + K);
    
    %%Correct it to wave coordinates
    
    X0 = angle_mtx(waves(2))*v_weather; 
    x0 = X0(1);
    y0 = X0(2);
    course_0 = [cos(-waves(2) +course); -sin(-waves(2) +course)];
    a = course_0(2)/course_0(1);
   %TODO: add an if clause 
%     a_tresh = 9999;
%     if abs(a) > a_tresh
%         
    
    
    % Wave velociy to angle decription
    f_eff = 200/(fCurrent + fWind); %ajustable
    s_eff = 150/(fCurrent + fWind); %ajustable
    c = f_eff*waves(1);
    d = s_eff*waves(1);
    b = 0;
    
    a_0 = (1/(c^2)) + (a^2)/(d^2);
    b_0 = (-2*x0)/(c^2) + (2*a*b - 2*a*y0)/(d^2);
    c_0 = (x0)^2/(c^2) + (b^2 - 2*b*y0 + (y0)^2)/(d^2) - 1;
    solution = roots([a_0,b_0,c_0]);
    
    v1 = [solution(1),a*solution(1)]';
    v2 = [solution(2),a*solution(2)]';
    v_course = [cos(course),-sin(course)]';
    
    velocity = max(dot(v1,v_course),dot(v2,v_course));
    
    
end

function [X] = angle_mtx(angle)
    X = [cos(angle), -sin(angle);
         sin(angle) cos(angle)];
end
