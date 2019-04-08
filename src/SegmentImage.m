function [mask] = SegmentImage(img,probMask,alpha_1,alpha_2,alpha_3)
N = size(img,1);
%Allocate a upper triangular sparce adjacency matrix for the graph model.
Adj = spalloc(N^2 + 2,N^2 + 2,4*N^2 - 2*N );
% background vertice index N^2+1
% foreground vertic index = N^2+2
bg = N^2+1;
fg = N^2+2;
fg_virtual = mean(img(probMask == 1),'all');
bg_virtual = mean(img(probMask == 0),'all');
img = double(img);
Imax = max(img,[],'all');

for i=1:N
    for j = 1:N
        k = N*(j-1) + i;
        kup = N*(j-2) + 1;
        kdown = (N*j) + 1;
        % Checking that index is valid and assiging the edge weight to be
        % the data term of the energy equation in a 4-neighborhood
        
        if i - 1 > 0
            Adj(k-1,k) = alpha_2*exp(-(img(j,i) - img(j,i-1))^2);
        end
        if i + 1 <= N
            Adj(k,k+1) = alpha_2*exp(-(img(j,i) - img(j,i+1))^2);
        end
        if j + 1 <= N
            Adj(k,kdown) = alpha_2*exp(-(img(j,i) - img(j+1,i))^2);
        end
        if j - 1 > 0
            Adj(kup,k) = alpha_2*exp(-(img(j,i) - img(j-1,i))^2);
        end
        % Assigning the lung model and the 
        Adj(k,N^2+1) = alpha_3*probMask(j,i) + alpha_1*abs(img(j,i) - fg_virtual)/Imax;
        Adj(k,N^2+2) = alpha_3*(1- probMask(j,i)) + + alpha_1*abs(img(j,i) - bg_virtual)/Imax;
    end
end
G = graph(Adj,'upper');
%perform max-flow min-cut
[~,~,~,ct] = maxflow(G,fg,bg);
mask = zeros(N,N);
% Map graph indexes back to pixel locations
for l = 1:length(ct)
   i = mod(ct(l),N);
   if i == 0
       i = N;
   end
   j = (ct(l) - i)/N + 1;
   mask(j,i) = 1;
end
% Remove the final row from the image. It gets added during the segmentaion
% and corresponds the the virtual terminal that represents the foreground
mask = mask(1:end-1,:);
end
