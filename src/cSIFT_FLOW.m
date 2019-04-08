function [U,V] = cSIFT_FLOW(im1,im2,gamma,alpha,t,d,MaxIter)
%#codegen
%% for codgen to c/c++
% Creates object containing all the necessary data
self.im1 = im1;
self.im2 = im2;
self.gamma = gamma;
self.alpha = alpha;
self.t = t;
self.d = d;
N = size(im1,1);
self.N = N;
win = N/8;
M = win*2+1;
self.M =M;
self.win = win;
%Initilizing message matrices
% Each x,y coordinate in this matrix stores all of the outbound
% messages from that pixel
self.Umsg = ones(N,N,5*M);
self.Vmsg = ones(N,N,5*M);
self.U = zeros(N,1) + win + 1;
self.V = zeros(N,1) + win + 1;
[U,V] = Run(self,MaxIter);
end

% 
% Left(0)
%       Up(1)
%       Right(2)
%       Down(3)
%       Across(4)


function [u,v] = Run(self,MaxIter)
%#codegen
%% Runs Loopy belief propagation for the maximum number of iterations and 
% returns the optimal solutions for the flow vectors
for Iteration = 1:MaxIter
    UpdateMessages(self);
    OptimalSolution(self);
end
u = (self.U - self.win - 1);
v = (self.V - self.win - 1);
end



function UpdateMessages(self)
%#codegen
%% Updates all of the intralayer messages
for i = 1:self.N
    for j = 1:self.N
        msgUpdate(self,i,j,0,1);
        msgUpdate(self,i,j,1,1);
        msgUpdate(self,i,j,2,1);
        msgUpdate(self,i,j,3,1);
        
        msgUpdate(self,i,j,0,2);
        msgUpdate(self,i,j,1,2);
        msgUpdate(self,i,j,2,2);
        msgUpdate(self,i,j,3,2);
    end
end
%% Updates all of the inter layer messages
for i = 1:self.N
    for j = 1:self.N
        msgUpdate(self,i,j,4,1);
        msgUpdate(self,i,j,4,2);
    end
end
end




function [msg] = getLastMsg(self,x,y,d,p)
%#codegen
%% Gets the last message for (x,y)->(x+d,y+d) on the plane p
if 0>=x||x>self.N || 0>=y||y>self.N
    msg = ones(self.M,1);
    return
end
%Messages are stored in a format such that the direction can directly index
%the messages
if p == 1
    msg = self.Umsg(y,x,d*self.M+1:(1+d)*self.M);
else
    msg = self.Vmsg(y,x,d*self.M+1:(1+d)*self.M);
end
msg = msg(:);
end



function [Ueng] = Unary(self,x0,y0,p,l_prime)
%#codegen
% The Unary energy term, constrains the flow vectors to be small given no
% other information
varTerm = norm((l_prime - self.win -1),1);
if p == 1
    constTerm = self.V(y0);
else
    constTerm = self.U(x0);
end
Ueng = varTerm + norm(constTerm,1);
end



function [Beng] = Binary(self,x0,y0,d,p,l_prime)
%#codegen
%Binary energy, constrains the data to match and the flow vectors to be
%smooth in a neighborhood around (x,y)
[xn,yn,pn] = Coord(self,x0,y0,p,d);
data = 0;
smoothness = 0;
if pn == p
    if p == 1
        v_p = self.V(y0);
        if 0<yn && yn<= self.N
            v_q = self.V(yn);
        else
            v_q = 0;
        end
        u_p = l_prime - self.win -1;
        if 0 < xn && xn <= self.N
            u_q = self.U(xn);
        else
            u_q = 0;
        end
    else
        v_p =  l_prime - self.win -1;
        if 0<yn && yn<= self.N
            v_q = self.V(yn);
        else
            v_q = 0;
        end
        u_p = self.U(x0);
        if 0 < xn && xn <= self.N
            u_q = self.U(xn);
        else
            u_q = 0;
        end
    end
    smoothness = min(norm(u_p - u_q,1),self.d)...
        +min(norm(v_p - v_q,1),self.d);
else
    if p == 1
        x = x0 + (l_prime - self.win - 1);
        y = y0;
    else
        x = x0;
        y = y0 + (l_prime - self.win - 1);
    end
    if 1>x || x>self.N || 1>y||y>self.N
        sift_im2 = zeros(size(self.im1,3),1);
    else
        sift_im2 = self.im2(y,x,:);
    end
    sift_im1 = self.im1(y0,x0,:);
    sift_im1 = sift_im1(:);
    sift_im2 = sift_im2(:);
    data = min(norm(sift_im1- sift_im2,2),self.t);
end
Beng = data+smoothness;
end


function [msg] = GetMsgProd(self,x0,y0,d,p0)
%#codegen
% Gets the message product for all messages from k->i where k exists in the
% neighborhood of i and k ~= j
% j = (x,y)
% i = (x+d,y+d)
[x,y,p] = Coord(self,x0,y0,p0,d);
msg = ones(self.M,1);
for i = 0:4
    [xn,yn,pn] = Coord(self,x,y,p,i);
    if xn~=x0||yn~=y0||pn~=p0
        newD = getOppositeDirection(self,i);
        msg = msg.*getLastMsg(self,xn,yn,newD,pn);
    end
end
end

function [opDir] = getOppositeDirection(self,d) %#ok<INUSL>
%#codegen
% Returns the opposite direction
% The enumeration is as follows
% 0 - Left
% 1 - Up
% 2 - Right
% 3 - Down
% 4 - Across
if d == 0
    opDir = 2;
elseif d == 1
    opDir = 3;
elseif d == 2
    opDir = 0;
elseif d == 3
    opDir = 1;
else
    opDir = 4;
end
end



function [x,y,p] = Coord(self,x0,y0,p0,d) %#ok<INUSL>
%#codegen
% calculates (x+d,y+d,p+d)
% The plane enumemration is 
% 1 - U
% 2 - V
x =x0;
y = y0;
p = p0;
if d == 0
    x = x0-1;
elseif d == 1
    y = y0 -1;
elseif d == 2
    x = x0+1;
elseif d == 3
    y = y0 -1;
elseif d == 4
    if p0 == 1
        p = 2;
    else
        p = 1;
    end
end
end

function [] = msgUpdate(self, x0,y0,d,p)
%#codegen
%Updating message from x0,y0 to (x0,y0) + d
%directions
% 0 = left
% 1 = up
% 2 = right
% 3 = down
% 4 = To the other plane

% plane
% 1 = U optimizes X
% 2 = v optimizes Y
%Checks to ensure that mesage direction is valid
[x,y,~] = Coord(self,x0,y0,d,p);
if x>0 && x <= self.N && y>0 && y <= self.N
    % scaling factor ensures that the energy terms don't underflow
    scaling = 0.1;
    % msg(0) corresponds to state -self.win
    msgProd = GetMsgProd(self,x0,y0,d,p);
    msg = zeros(self.M,1);
    for l = (self.M):-1:1
        for l_prime = (self.M):-1:1
            msg(l) = msg(l) + exp(-Unary(self,x0,y0,p,l_prime)*scaling)*exp(-Binary(self,x0,y0,d,p,l_prime)*scaling)*msgProd(l_prime);
        end
    end
    msg = msg/sum(msg);
    [xn,yn,pn] = Coord(self,x0,y0,d,p);
    dn = getOppositeDirection(self,d);
    if pn == 1
        self.Umsg(yn,xn,(dn*self.M)+1:(1+dn)*self.M) = msg(:);
    else
        self.Vmsg(yn,xn,dn*self.M+1:(1+dn)*self.M) = msg(:);
    end
end
end



function OptimalSolution(self)
%#codegen
%finding the optimal settings for V
Vhist = zeros(self.M,1);
belief = zeros(self.M,1);
for i = 1:self.N
    for j = 1:self.N
        belief = zeros(self.M,1);
        msgProd = GetMsgProd(self,i,j,4,2).*getLastMsg(self,i,j,4,1);
        for l = self.M:-1:1
            belief(l) = exp(-Binary(self,i,j,4,2,l))*msgProd(l);
        end
        [~,idx] = max(belief);
        Vhist(idx) = Vhist(idx) + 1;
    end
    [~,idx] = max(belief);
    self.V(i) = idx;
end
Uhist = zeros(self.M,1);
for j = 1:self.N
    for i = 1:self.N
        belief = zeros(self.M,1);
        msgProd = GetMsgProd(self,i,j,4,1).*getLastMsg(self,i,j,4,2);
        for l = self.M:-1:1
            belief(l) = exp(-Binary(self,i,j,4,1,l))*msgProd(l);
        end
        [~,idx] = max(belief);
        Uhist(idx) = Uhist(idx) + 1;
    end
    [~,idx] = max(belief);
    self.U(j) = idx;
end
end





