function [u,dudx,dudp] = u_Fourier(x,P,t,in)
% input function for free-form (Fourier decomposition) deterministic DCM
% function [u,dudx,dudp] = u_Fourier(x,P,t,in)
% IN:
%   - x: [useless]
%   - P: nW*nuX1 vector of Fourier projection parameters, where nW is the
%   number of Fourier basis functions and nu is the dimensionality of the
%   output
%   - t: time at which the Fourier basis set is evaluated
%   - in: user-defined structure containing the set of Fourier frequencies
% OUT:
%   - u: the nuXnt matrix of outputs, where nt is the length of the
%   argument t.
%   - dudx: [useless]
%   - dudp: gradient wrt the parameters

% construct Fourier basis at time t
X = zeros(length(in.W),length(t));
for i = 1:length(t)
    X(:,i) = cos(in.W(:).*pi.*t(i)./in.T);
end

% project basis onto input space
P = reshape(P,length(in.W),[]);
u = (X'*P)';

% get gradients
dudx = [];
dudp = kron(eye(size(P,2)),X);