function [xBest,xBestVal, allInputs] = hybrid_PSO(myFun,contInput,boolInput,seed,nParticles, maxIter)
%Particle swarm optimisation Using both continious and binary inputs to
%optimise an objective function
% 
%     INPUT: myFun - Objective function to be optimised
% 
%     OUTPUT: time - Variable describing the duration of the mission
%                    TODO: Soon to describe mission cost
%             v    - Array including velocity of the vessel between each
%                    waypoint. 
    inputs = contInput + boolInput;

    x0 = repmat(seed,1,nParticles) + 0.005*[randn(contInput,nParticles-1),zeros(contInput,1);
                                            zeros(boolInput,nParticles)]; %ajustable
    x = zeros(inputs,nParticles);
    v = zeros(contInput,nParticles);
    vb = zeros(boolInput,nParticles);
    x = x0;
    pBest = zeros(inputs,nParticles);
    pBestVal = 9999999*ones(maxIter,nParticles);

    paramTreshCont = [0.2; 0.02; 0.7; 0.0005; 0]; %ajustable
    paramTreshBool = [0.5; 0.5; 0.5; 0.5; 0.7]; %ajustable
    fVal = zeros(1,nParticles);
    for i = 1:nParticles
        test = myFun(x(:,i));
        fVal(i)= test;
    end
    newVal = (fVal<=pBestVal(1,:));
    pBestVal(1,:) = newVal.*fVal + pBestVal(1,:).*(~newVal);
    pBest = newVal.*x + pBest.*(~newVal);
    [gBestVal,gBestPos] = min(pBestVal(1,:));
    gBest = repmat(x(:,gBestPos),1,nParticles);
    gBestVal

   for j = 1:(maxIter-1)
       disp((j/maxIter)*100)
       
       %Boolean PSO velocity step
        omegaB = (rand(boolInput,nParticles)>paramTreshBool(1));
        b1 = (rand(boolInput,nParticles)>paramTreshBool(2));
        b2 = (rand(boolInput,nParticles)>paramTreshBool(3));
        b3 = (rand(1)>paramTreshBool(4));
        random = (rand(boolInput,nParticles)>paramTreshBool(5));
        vb = (omegaB&vb)|(b1&xor(pBest(contInput+1:inputs,:),x(contInput+1:inputs,:)))|(b2&xor(gBest(contInput+1:inputs,:),x(contInput+1:inputs,:)))|(b3&random);
        next = xor(x(contInput+1:inputs,:),vb);
        x(contInput+1:inputs,:) = next;
       
       %Continious PSO velocity step
        omega = paramTreshCont(1);
        c1 = paramTreshCont(2);
        c2 = paramTreshCont(3);
        c3 = paramTreshCont(4);
        random = randn(contInput,nParticles);
        v = omega*v + c1*(pBest(1:contInput,:)-x(1:contInput,:)) + c2*(gBest(1:contInput,:)-x(1:contInput,:)) + c3*random;
        next = x(1:contInput,:) + v;
        x(1:contInput,:) = next;
        
       
       
        for i = 1:nParticles
            fVal(i) = myFun(x(:,i));
        end
        newVal = (fVal<pBestVal(j,:));
        pBestVal(j+1,:) = newVal.*fVal + pBestVal(j,:).*(~newVal);
        pBest = newVal.*x + pBest.*(~newVal);
        
        [tempGBestVal,tempGBestPos] = min(pBestVal(j+1,:));
        if tempGBestVal < gBestVal
            gBestVal = tempGBestVal;
            gBest = repmat(x(:,tempGBestPos),1,nParticles);
        end
   end
       
   xBest = pBest(:,tempGBestPos);
   xBestVal = pBestVal;
   allInputs = x;
end