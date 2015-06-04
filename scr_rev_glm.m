function fig = scr_rev_glm(modelfile, glm, plotNr)
% scr_rev_glm is a tool for reviewing a first level GLM designs. It is
% meant to be called by scr_review only
%
% FORMAT:
% fig = scr_rev_glm(modelfile, glm, plotNr, fig)
%
% modelfile: filename and path of modelfile
% glm:       loaded model
% plotNr:    defines which figure shall be plotted
%            (several plots can be defined by a vector)
%            1 - design matrix, SPM style
%            2 - design orthogonality, SPM style
%            3 - predicted & observed
%            4 - print regressor names
%            5 - reconstructed responses
% fig:       returns the figure handles
%
%__________________________________________________________________________
% PsPM 3.0
% (C) 2008-2015 Dominik R Bach (Wellcome Trust Centre for Neuroimaging)

% $Id: scr_rev_glm.m 714 2015-02-05 15:10:44Z tmoser $
% $Rev: 714 $

% initialise
% ------------------------------------------------------------------------
global settings;
if isempty(settings), scr_init; end;

% check input
% ------------------------------------------------------------------------
if nargin < 2, return; end;

[sts, glm] = scr_glm_recon(modelfile);
if sts == -1, return; end;

% prepare
% ------------------------------------------------------------------------

tmp.X = ones(size(glm.X));
for c=1:size(glm.X,2)
    tmp.X(glm.M==0,c)=glm.XM(:,c)/std(glm.XM(:,c));
end;
[~, filename, ~]=fileparts(modelfile);
filename=[filename, '.mat'];
XTick=1:1:size(glm.X,2);
YTickStep=glm.infos.sr*round(size(glm.X,1)/20/glm.infos.sr);
YTick=YTickStep:YTickStep:size(glm.X,1);
YTickLabel=round(YTick/glm.infos.sr);

pos0 = get(0,'screenSize');

for i=1:length(plotNr)
    if plotNr(i) <= 5 || plotNr(i) >= 1
        switch plotNr(i)
            case 1
                % --- plot design matrix in SPM style
                pos = [0.51*pos0(3),0.1*pos0(4),0.45*pos0(3),0.8*pos0(4)];
                fig(1).h = figure('Position', pos, 'PaperPositionMode', 'auto', 'PaperOrientation', 'Portrait', 'InvertHardCopy', 'off', 'Color', 'w', 'Name', 'Design Matrix');%,'NumberTitle','off');
                colormap('gray');
                fig(1).ax(1).h=axes('Position', [0.1 0.05 0.85 0.9]);
                fig(1).p(1)=imagesc(tmp.X);
                set(fig(1).ax(1).h, 'XTick', XTick, 'TickDir', 'out', 'YTick',YTick, 'YTickLabel', YTickLabel, 'FontWeight', 'Bold', 'FontSize', 10,  'TickLength', [0.005 0.025]);
                fig(1).ylabel=get(fig(1).ax(1).h, 'YLabel');
                fig(1).title=get(fig(1).ax(1).h, 'Title');
                set(fig(1).ylabel, 'String', 'Time (s)', 'FontWeight', 'Bold', 'FontSize', 14);
                set(fig(1).title, 'String', sprintf('Design Matrix: %s', filename), 'FontWeight', 'Bold', 'FontSize', 14, 'Interpreter', 'none');
                
            case 2
                % --- plot orthogonality in SPM style
                pos = [0.21*pos0(3),0.1*pos0(4),0.5*pos0(3),0.7*pos0(4)];
                % prepare
                cormat=abs(corrcoef(glm.XM));
                cormat(isnan(cormat))=0;
                cormat=1-cormat;
                % plot
                fig(2).h = figure('Position', pos,'PaperPositionMode', 'auto', 'PaperOrientation', 'Portrait', 'InvertHardCopy', 'off', 'Color', 'w', 'Name', 'Design Orthogonality');%,'NumberTitle','off');
                colormap('gray');
                fig(2).ax(1).h=axes('Position', [0.1 0.05 0.85 0.85]);
                fig(2).p(1)=imagesc(cormat);
                set(fig(2).ax(1).h, 'XTick', XTick, 'TickDir', 'out', 'YTick',XTick, 'FontWeight', 'Bold', 'FontSize', 10,  'TickLength', [0.005 0.025]);
                fig(2).title=get(fig(2).ax(1).h, 'Title');
                set(fig(2).title, 'String', sprintf('Design Orthogonality: %s', filename), 'FontWeight', 'Bold', 'FontSize', 14, 'Interpreter', 'none');
                
                % first approach of displaying regressors in orthogonality 
                % plot -> disabled because not finished yet
                % calculate width of a square
                ns = numel(glm.names);
                YLim = get(fig(2).ax(1).h, 'YLim');
                sy = diff(YLim) / ns;
                XLim = get(fig(2).ax(1).h, 'XLim');
                sx = diff(XLim) / ns;
                
                % iterate through regressors and colors
                corder = get(groot, 'defaultAxesColorOrder');
                cl = length(corder);
                for j=1:ns
                   if j > cl
                       m = floor(j/cl);
                       color = corder(j - m*cl, :);
                   else
                       color = corder(j,:);
                   end
                   
                   % draw lines around
                   space = -0.5;
                   x = [space, sx*j];
                   x = XLim(1) + x;
                   y = [(j)*sy, (j)*sy];
                   y = YLim(1) + y;
                   
                   fig(3).ax(1).p(j+1) = patch(x,y, 'none');
                   set(fig(3).ax(1).p(j+1), 'EdgeColor', color, ...
                       'FaceColor', 'none', ...
                       'Clipping', 'off', ...
                       'LineWidth', 1.5);
                   
                   % draw text
                   fig(3).ax(1).t(j) = text(0, j*sy+0.4, glm.names(j));
                   set(fig(3).ax(1).t(j), ...
                        'Color', color, ...
                        'Clipping', 'off');
                end

                
            case 3
                % --- plot predicted & observed
                pos = [0.2*pos0(3),0.1*pos0(4),0.7*pos0(3),0.7*pos0(4)];
                % prepare
                predicted=glm.Yhat; observed=glm.Y; res=glm.e; timing=glm.timing;
                fig(3).h = figure('Position', pos,'PaperPositionMode', 'auto', 'PaperOrientation', 'Portrait', 'InvertHardCopy', 'off', 'Color', 'w', 'Name', 'Model fit');%,'NumberTitle','off');
                fig(3).ax(1).h=axes('Position', [0.05 0.1 0.9 0.8]);
                hold on;
                fig(3).ax(1).p(1)=plot(observed, 'k-');
                fig(3).ax(1).p(2)=plot(predicted, 'r-');
                fig(3).ax(1).p(3)=plot(res, 'k:');
                legend_text = {'Observed', 'Predicted', 'Residual'};
                set(fig(3).ax(1).h, 'XTick', YTick, 'XTickLabel', YTickLabel, 'TickDir', 'out', 'YTick',[],  'FontWeight', 'Bold', 'FontSize', 10,  'TickLength', [0.005 0.025], 'XLim', [0 size(glm.Y,1)]);
                YLim = get(fig(3).ax(1).h, 'YLim');
                corder = get(groot, 'defaultAxesColorOrder');
                cl = length(corder);
                k = 1;
                for j=1:length(timing.onsets)
                   if j > cl
                       m = floor(j/cl);
                       color = corder(j - m*cl, :);
                   else
                       color = corder(j,:);
                   end
                   fig(3).ax(1).p(k+3)=stem(timing.onsets{j}, zeros(numel(timing.onsets{j}),1) + YLim(2)); 
                   set(fig(3).ax(1).p(k+3), 'BaseValue', YLim(1), 'Color', color);
                   legend_text(end+1) = timing.names(j);
                   if sum(timing.durations{j}) > 0 
                       % plot area with patch
                       y_pos_base = [YLim(1); YLim(1); YLim(2); YLim(2)];
                       y_pos = repmat(y_pos_base, 1,length(timing.onsets{j}));
                       offsets = timing.onsets{j}' + timing.durations{j}';
                       x_pos = [timing.onsets{j}'; offsets; offsets; timing.onsets{j}'];
                       k = k + 1;
                       fig(3).ax(1).p(k+3) = patch(x_pos, y_pos, color, ... 
                            'EdgeColor', 'none', 'FaceAlpha', 0.1);
                       % do not show in legend
                       annotation = get(fig(3).ax(1).p(k+3), 'Annotation');
                       legend_info = get(annotation, 'LegendInformation');
                       set(legend_info, 'IconDisplayStyle', 'off');
                   end
                   k = k + 1;
                end
                fig(3).xlabel=get(fig(3).ax(1).h, 'XLabel');
                fig(3).title=get(fig(3).ax(1).h, 'Title');
                fig(3).leg=legend(legend_text, 'Location', 'Best', 'FontSize', 14);
                set(fig(3).xlabel, 'String', 'Time (s)', 'FontWeight', 'Bold', 'FontSize', 14);
                set(fig(3).title, 'String', sprintf('Model fit: %s', filename), 'FontWeight', 'Bold', 'FontSize', 14, 'Interpreter', 'none');
                set(gca, 'LineWidth', 1.2);
                hold off;
            case 4
                fprintf('Regressors for %s:\n---------------------------------------\n', glm.glmfile);
                for n=1:numel(glm.names)
                    fprintf('Regressor %d: %s\n',n,glm.names{n});
                end;
                fprintf('---------------------------------------\n');
                fig(4).h = [];
                
            case 5
                % --- do plot of reconstructed responses
                pos = [0.21*pos0(3),0.1*pos0(4),0.5*pos0(3),0.7*pos0(4)];
                fig(5).h = figure('Position', pos,'PaperPositionMode', 'auto', 'PaperOrientation', 'Portrait', 'InvertHardCopy', 'off', 'Color', 'w', 'Name', 'Estimated responses');%,'NumberTitle','off');
                fig(5).ax(1).h=axes('Position', [0.05 0.1 0.9 0.8]);
                fig(5).p = plot(glm.resp);
                legend(glm.reconnames); legend boxoff;
                fig(5).title=get(fig(5).ax(1).h, 'Title');
                set(fig(5).ax(1).h, 'TickDir', 'out', 'YTick',[],  'FontWeight', 'Bold', 'FontSize', 10,  'TickLength', [0.005 0.025]);
                set(fig(5).title, 'String', sprintf('Estimated responses per condition: %s', filename), 'FontWeight', 'Bold', 'FontSize', 14, 'Interpreter', 'none');
                
        end
    end
end