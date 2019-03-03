function [B] = bhattacharyyaCoef(Entry, ImgX, ImgY)
    n = length(entry.X);
    m = length(entry.Y);
    alpha = n/(n+m);
    B = alpha*(sum(Entry.X.*ImgX)^.5) + (1 - alpha)*(sum(Entry.Y.*ImgY)^.5);
end