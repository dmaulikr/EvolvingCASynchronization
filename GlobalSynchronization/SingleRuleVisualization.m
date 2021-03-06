% display output
output = 1;

% the size of our array of cells
latticeSize=149;
% neighborhood radius
radius = 3;
% rule size
ruleSize= radius*2 +1;
% number of time steps
max=150;

a=zeros(1,latticeSize);
newa=zeros(1,latticeSize);

% the ruleset data object
ruleSet = CARuleset;

% patterns
ruleSet.patterns = flipud(combn([0 1],ruleSize));

% assign rule here transformations
%ruleSet.transformations = [0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 1 0 0 1 0 1 0 0 0 1];
ruleSet.transformations = [0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 1 0 0 0 0 1 0 1 1 0 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 0 0 1 0 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1];

%randomize initial configuration
a = randint(1, latticeSize, [0 1]);
%a(50) = 1;

% calculate if more 0 or 1 to have a check for final state
sumInitialState = sum(a);

% output
if(output)
    if(sumInitialState > latticeSize/2)
        disp(['should converge to black - sum = ' num2str(sumInitialState)])
    else
        disp(['should converge to white - sum = ' num2str(sumInitialState)])
    end
end

%assign initial configuration to the grid
GRID(1,:)=a;

% initialize the grid except 1st row (initial configuration)
for i=2:max,
    GRID(i,:)=zeros(1,latticeSize);
end

%spit out first frame
spy(GRID, 'k')
M(1) = getframe;

%brace yourself - this is the main loop
g=1;
while (g<max),
    
    %run the chosen rule foreach cell for a given time step g
    %boundary cells are being ignored in this example
    for i=1:latticeSize,
        % retrieve pattern in the local 'hood
        localPattern = circularSubarray(a, i-radius, i+radius);
        % find the transformation rule for the given local pattern
        for c=1:2^ruleSize,
            if(isequal(ruleSet.patterns(c, :), localPattern))
                newa(i) = ruleSet.transformations(c);
                break
            end
        end
    end
    
    % assign new states
    g=g+1;
    a=newa;
    GRID(g,:)=a;
    
    %push a snapshot to a frame
    spy(GRID, 'k')
    M(g) = getframe;
    
    % check if correctly synced or stable configuration and break if so
    sumCurrentState = sum(GRID(g,:));
    sumPreviousState = sum(GRID(g-1,:));
    isStableConfig = isequal(GRID(g,:), GRID(g-1,:));
    oscillating = 0;
    
    if(isStableConfig)
        % stable config reached, do nothing in this case
        % just increase totalSteps counter and break current iteration
        totalsteps = totalsteps + g;
        % some output first)
        if(output)
            disp(['not good - stable config reached in ' num2str(g) ' time steps'])
        end
        break;
    elseif(sumCurrentState == latticeSize && sumPreviousState == 0)
        % all black and previously all white
        % if 2 steps before is all black again we are oscillating
        if(g>=3 && sum(GRID(g-2,:)) == latticeSize)
            oscillating = 1;
        end
    elseif (sumCurrentState == 0 && sumPreviousState == latticeSize)
        % all white and previously all black
        % if 2 steps before is all white again we are oscillating
        if(g>=3 && sum(GRID(g-2,:)) == 0)
            oscillating = 1;
        end
    end
    
    if(oscillating)
        % some output
        if(output)
            disp(['correctly oscillating in ' num2str(g) ' time steps'])
        end
        % break and go to next iteration
        % break;
    end
    
end

%last frame - final state of the matrix
%spy(GRID, 'k')
%M(max) = getframe;

%playback
movie(M,0)