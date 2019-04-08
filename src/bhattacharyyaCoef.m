function [B] = bhattacharyyaCoef(Entry, ImgX, ImgY)
%% Calculates the average bhattacharyya coeffecient between two images
    n = length(Entry.X);
    m = length(Entry.Y);
    alpha = n/(n+m);
    B = alpha*(sum(Entry.X.*ImgX)^.5) + (1 - alpha)*(sum(Entry.Y.*ImgY)^.5);
end