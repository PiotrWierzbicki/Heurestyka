for i =1:17
    for j=1:17
        w=suurballe2(A,linksnumerical,i,j) == dijkstra(noOfNodes,1./A,i,j, farthestPreviousHop, farthestNextHop);
        [i,j,sum(w)==length(w)]
    end
end

%% alternatywy

for i =1:17
    for j=1:17
        gplot(A,[x,y],'-o');
        [p,b]=suurballe2(A,linksnumerical,i,j);
        
        line(x(p),y(p), 'Color', 'g','LineWidth', 5,'Marker','.','MarkerSize', 20);
        line(x(b),y(b), 'Color', 'r','LineWidth', 5,'Marker','.','MarkerSize', 20);
        %waitforbuttonpress
        pause(1)
    end
end
