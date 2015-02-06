function [hres] = displayResults(posterior,out,y,x,x0,theta,phi,alpha,sigma)
% compares VB posteriors with simulated parameters and hidden states

if isempty(posterior)
    return
end

hres = figure;
pos = get(hres,'position');
set(hres,'name','Simulation results','position',[pos(1),pos(2)-pos(4),pos(3),2*pos(4)],'color',ones(1,3),'menubar','none');

% parameters
if ~isempty(theta)
    hs = subplot(4,2,1,'parent',hres);
    xtick = 1:out.dim.n_theta;
    set(hs,'xtick',xtick,'nextplot','add','xlim',[.2,out.dim.n_theta+.8])
    if ~out.options.OnLine
        V = VBA_getVar(posterior.SigmaTheta);
        muTheta = posterior.muTheta;
    else
        V = VBA_getVar(posterior.SigmaTheta{end});
        muTheta = posterior.muTheta(:,end);
    end
    plotUncertainTimeSeries(muTheta,V,[],hs);
    title(hs,'theta')
    plot(hs,theta,'go')
end
if ~isempty(phi)
    hs = subplot(4,2,2,'parent',hres);
    xtick = 1:out.dim.n_phi;
    set(hs,'xtick',xtick,'nextplot','add','xlim',[.2,out.dim.n_phi+.8])
    if ~out.options.OnLine
        V = VBA_getVar(posterior.SigmaPhi);
        muPhi = posterior.muPhi;
    else
        V = VBA_getVar(posterior.SigmaPhi{end});
        muPhi = posterior.muPhi(:,end);
    end
    plotUncertainTimeSeries(muPhi,V,[],hs);
    title(hs,'phi')
    plot(hs,phi,'go')
end

% hyperparameters
if ~out.options.binomial
    sigmaHat = posterior.a_sigma(end)./posterior.b_sigma(end);
    vs = posterior.a_sigma(end)./(posterior.b_sigma(end).^2);
    lvs = log(sigmaHat+sqrt(vs)) - log(sigmaHat);
    try
        alphaHat = posterior.a_alpha(end)./posterior.b_alpha(end);
        va = posterior.a_alpha(end)./(posterior.b_alpha(end).^2);
        lva = log(alphaHat+sqrt(va)) - log(alphaHat);
        lm = log([alphaHat;sigmaHat]);
        lv = [lva;lvs];
        xtick = [1,2];
        lab = {'alpha','sigma'};
    catch
        lm = log(sigmaHat);
        lv = lvs;
        xtick = 1;
        lab = 'sigma';
    end
    hs = subplot(4,2,3,'parent',hres);
    set(hs,'nextplot','add')
    plotUncertainTimeSeries(lm,lv.^2,[],hs);
    plot(hs,log([alpha;sigma]),'go')
    set(hs,'xtick',xtick,'xticklabel',lab)
    ylabel(hs,'log-precisions')
    title(hs,'precision hyperparameters')
end

if out.dim.n_t > 1
    dTime = [1:out.dim.n_t];
else
    dTime = [1:out.dim.p];
end
if out.dim.n > 0
    try
        % initial conditions
        hs = subplot(4,2,4,'parent',hres);
        xtick = 1:out.dim.n;
        set(hs,'xtick',xtick,'nextplot','add','xlim',[.2,out.dim.n+.8])
        V = VBA_getVar(posterior.SigmaX0);
        plotUncertainTimeSeries(posterior.muX0,V,[],hs);
        title(hs,'initial conditions')
        plot(x0,'go')
        % Hidden states
        hs = subplot(4,2,5,'parent',hres);
        set(hs,'nextplot','add')
        plot(hs,x','--')
        if isempty(posterior.SigmaX)
            plot(hs,posterior.muX')
        else
            V = VBA_getVar(posterior.SigmaX.current);
            plotUncertainTimeSeries(posterior.muX,V,dTime,hs);
        end
        grid(hs,'on')
        title(hs,'estimated hidden-states time series')
    end
end

hs = subplot(4,2,6,'parent',hres);
set(hs,'nextplot','add')
plot(hs,y','--')
if out.dim.n_t > 1
    plotUncertainTimeSeries(out.suffStat.gx,out.suffStat.vy,dTime,hs);
else
    plotUncertainTimeSeries(out.suffStat.gx',out.suffStat.vy',dTime,hs);
end
grid(hs,'on')
title(hs,'predicted y')

if out.dim.n > 0
    miX = min([posterior.muX(:);x(:)]);
    maX = max([posterior.muX(:);x(:)]);
    hs = subplot(4,2,7,'parent',hres);
    set(hs,'nextplot','add')
    plot(hs,posterior.muX(:),x(:),'.')
    plot(hs,[miX,maX],[miX,maX],'r')
    title(hs,'x(t) vs <x(t)>')
    grid(hs,'on')
    axis(hs,'tight')
end
miy = min([out.suffStat.gx(:);y(:)]);
may = max([out.suffStat.gx(:);y(:)]);
hs = subplot(4,2,8,'parent',hres);
set(hs,'nextplot','add')
plot(hs,[miy,may],[miy,may],'r')
if ~out.options.binomial
    plot(hs,out.suffStat.gx(:),y(:),'.')
else
    [stacky,stdy,gridg] = VBA_Bin2Cont(out.suffStat.gx,y);
    errorbar(gridg,stacky,stdy,'k.','parent',hs)
end

title(hs,'y(t) vs <y(t)>')
grid(hs,'on')
axis(hs,'tight')

try getSubplots,end

