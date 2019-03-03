gamma = 1;
img = OTS('JPCLN001.IMG',gamma);
while gamma <= 3.1
    gamma = gamma + 0.25
    img = cat(3,img,OTS('JPCLN001.IMG',gamma));
end
montage(img);
    