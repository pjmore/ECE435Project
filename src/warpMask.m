function [warpedMask] = warpMask(U,V,mask)
%Given flow vectors U and V the flow at any pixel p(x,y) is given by
%w(p)=(U(x),V(y))
% This shifts the pixels by w(p) and preference is given to non-zero values
% when shifting
size(mask);
N = size(mask,1);
warpedMask = zeros(N,N);
for i = 1:size(mask,1)
    for j = 1:size(mask,2)
        if j+V(j)>0 && j+V(j) <=N && i+U(i) >0 && i+U(i) <=N
            warpedMask(j,i) = max(mask(j+V(j),i+U(i)),warpedMask(j,i));
        end
    end
end

