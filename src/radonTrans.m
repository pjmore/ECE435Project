function [x,y]= radonTrans(img)
% Performs the partial radon transform across the x and y dimensions. More
% partial transforms could be added to increase the ability to contend with
% rotations and offsets
x = sum(img,2);
y = sum(img,1);
end