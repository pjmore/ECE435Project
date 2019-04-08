function [Res] = winFunc(A,winSize,fun)
% Applies some function fun over some matrix A using a windows size winSize
% Allows vector returns from fun
sizeY = size(A,1);
sizeX = size(A,2);
h = size(A,3);
if sizeY < winSize(1) || sizeX<winSize(2)
    throw(MException('slNfunc:The size of the window''s dimensions was larger than the input matrix'));
end
center = floor((winSize + 1)/2);
lenTopY = center(1) - 1;
lenBotY = winSize(1) - lenTopY -1;
lenLeftX = center(2) - 1;
lenRightX = winSize(2)-lenLeftX-1;
for j = sizeY:-1:1
    YTop = max(lenTopY - j + 1,0);
    YBot = max(j+lenBotY - sizeY,0);
    for i = sizeX:-1:1
        XLeft = max(lenLeftX - i+1,0);
        XRight = max(i+lenRightX - sizeX,0);
        % A bit sphagetti but given the filter is overflowing the matrix
        % being operated on by 1 on the left and one on the top, this code
        % will first concat zeros on the sides, As an example let the window size be
        % [2 2] and the only elment within the window be a one at [2,2]
        % horizontal concat [1] to [0 1]
        % Then the vertical component is concatenated [0 1] to [0 0; 0 1]
        Res(j,i,:) = fun([zeros(YTop,winSize(1),h)...%Vertical Concatination starts
            ;cat(2,zeros(winSize(2)-YBot-YTop,XLeft,h),...
            A(max(1,j-lenTopY):min(sizeY,j+lenBotY),max(1,i-lenLeftX):min(sizeX,i+lenRightX),:),...
            zeros(winSize(2)-YBot-YTop,XRight,h))...%end of horizontal concat
            ;zeros(YBot,winSize(1),h)]); 
    end
end
end