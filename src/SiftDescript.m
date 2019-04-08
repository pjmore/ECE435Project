function [SIFT_desc] = SiftDescript(win)
   % given an input matrix that is divisible by four on both lengths a SIFT
   % descriptor vector is made.
   L = size(win,1);
   SIFT_desc = zeros(1,8*(L/4)^2);
   for i = 1:(L/4)
       for j = 1:(L/4)
           SIFT_desc((i+j- 2)*8 + 1:(i+j-1)*8) = sHist(win((j-1)*4 + 1:j*4,(i-1)*4+1:i*4),8,pi/4);
       end
   end
end

function [sift_hist] = sHist(data,iter,width)
    sift_hist = zeros(1,iter);
    for i = 1:iter
        sift_hist(i)= sum(sum(data()>= (i-1)*width & data()<= i*width));
    end
end