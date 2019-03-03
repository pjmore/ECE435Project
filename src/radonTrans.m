function [x,y]= radonTrans(img)
x = sum(img,2);
y = sum(img,1);
end