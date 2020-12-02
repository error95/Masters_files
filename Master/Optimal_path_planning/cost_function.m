function [cost] = cost_function(fullInput)

    persistent mapsize one_matrix x_map y_map x_centre y_centre A varX varY X Y value
    persistent currentMtx position_matrix startingPosition start inputs timesteps freezone
    persistent stepSize
    
    [fullSize,~] = size(fullInput);
    input = fullInput(fullSize/2 + 1:fullSize);
    discInput = fullInput(1:fullSize/2);
    if isempty(x_centre)
         [timesteps,~] = size(input);
         stepSize = 1;
        
        
        
        
        mapsize = [600,600];
        one_matrix = ones(mapsize(1),mapsize(2));

        x_map = 1:mapsize(1);
        y_map = 1:mapsize(2);
        x_centre = [280 270];
        y_centre = [280 270];
        [~,n_points] = size(x_centre);
        A = 1;
        varX = 1;
        varY = 1;
        freezone = zeros(mapsize(1),mapsize(2));
        [X,Y] = meshgrid(x_map,y_map);
        value = zeros(mapsize(1),mapsize(2));
        value(321:350,321:350) = -5*ones(30,30);
        freezone(301:310,301:310) = -0*ones(10);
%         for i = 1:n_points
%             value = value -A*exp( -(((X - x_centre(i)*one_matrix).^2)/(2*varX) + ((Y - y_centre(i)*one_matrix).^2)/(2*varY)));
%         end

        %General variables
        startingPosition = [300,300];
    current = [ 0 0];
    currentMtx = kron(ones(timesteps,1),current);
    position_matrix = triu(ones(timesteps,timesteps))';
    start = kron(ones(timesteps,1),startingPosition);
    
    end
    
    
   
    
    
    actuator_input = position_matrix*input;
    
    velocities = [cos(actuator_input), sin( actuator_input)]*stepSize + currentMtx;
    
    positions = position_matrix*velocities + start;
    
    
    positions_round = round(positions);
    
    map = zeros(mapsize(1),mapsize(2));
    
    
    for i = 1:timesteps
        map(positions_round(i,1),positions_round(i,2)) = map(positions_round(i,1),positions_round(i,2)) + discInput(i);
        truth_map = map>0;
    end
    
    cost = sum(truth_map.*value,'all') + sum(map.*freezone,'all') + sum(abs(fullInput));
end

    
    