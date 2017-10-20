% Liczy odleglo�� liniow� przy zadanych współrzędnych:
%   x1, x2 - szerokości geograficzne
%   y1, y2 - długości geograficzne

function [d] = dist(x1, x2, y1, y2)
    d = 6371*acos(sind(x1)*sind(x2) + cosd(x1)*cosd(x2)*cosd(y2-y1))
end