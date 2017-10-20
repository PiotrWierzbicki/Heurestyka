clear;
noOfNodes  = 60;
%rand('state', 0);
figure(1);
clf;
hold on;
L = 1000;
R = 200; % maximum range;
netXloc = rand(1,noOfNodes)*L;
netYloc = rand(1,noOfNodes)*L;
for i = 1:noOfNodes
    plot(netXloc(i), netYloc(i), '.');
    text(netXloc(i), netYloc(i), num2str(i));
    for j = 1:noOfNodes
        distance = sqrt((netXloc(i) - netXloc(j))^2 + (netYloc(i) - netYloc(j))^2);
        if distance <= R
            matrix(i, j) = 1;   % there is a link;
            matrix(j, i) = 1;   % there is a link;
            line([netXloc(i) netXloc(j)], [netYloc(i) netYloc(j)], 'LineStyle', ':');
        else
            matrix(i, j) = inf;
            matrix(j, i) = inf;
        end;
    end;
end;


activeNodes = [];
for i = 1:noOfNodes,
    % initialize the farthest node to be itself;
    farthestPreviousHop(i) = i;     % used to compute the RTS/CTS range;
    farthestNextHop(i) = i;
end;

[path, totalCost, farthestPreviousHop, farthestNextHop] = dijkstra(noOfNodes, matrix, 1, 15, farthestPreviousHop, farthestNextHop);
path
totalCost
if length(path) ~= 0
    for i = 1:(length(path)-1)
        line([netXloc(path(i)) netXloc(path(i+1))], [netYloc(path(i)) netYloc(path(i+1))], 'Color','r','LineWidth', 0.50, 'LineStyle', '-.');
    end;
end;
hold off;
return;
