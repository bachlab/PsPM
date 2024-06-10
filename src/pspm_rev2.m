function sts = pspm_rev2(modelfile, con)
% ● Description
%   pspm_rev2 is a tool for reviewing & reporting a second level design.
% ● Format
%   pspm_rev2(MODELFILE, {CON})
% ● Arguments
%   optional argument: con indicates the contrasts that you wish to be
%   reported
% ● History
%   Introduced in PsPM 3.0
%   Written in 2008-2015 by Dominik R Bach (Wellcome Trust Centre for Neuroimaging)
%   Maintained in 2022 by Teddy

% initialise
global settings
if isempty(settings)
  pspm_init;
end
sts = -1;

% check input arguments
if nargin<1
  errmsg=sprintf('No model file specified'); warning(errmsg); return;
end;

% check model file
if exist(modelfile)~=2
  errmsg=sprintf('Model file (%s) doesn''t exist', modelfile); warning(errmsg); return;
else
  load (modelfile);
end;

if isempty(find(ismember(who, 't'), 1))
  errmsg=sprintf('Model file (%s) doesn''t contain a second level design', modelfile); warning(errmsg); return;
end;

% plot contrasts
if nargin<2
  con=1:numel(t.t);
elseif ischar(con)
  if strcmpi(con, 'all')
    con=1:numel(t.t);
  else
    errmsg=sprintf('No valid contrast option'); warning(errmsg); return;
  end;
end;

if t.type==1
  YMax=max(mean(t.beta(:,con)) + std(t.beta(:,con))/sqrt(size(t.beta,1)));
  YMax=YMax+0.2*YMax;
  YMin=min(mean(t.beta(:,con)) - std(t.beta(:,con))/sqrt(size(t.beta,1)));
  YMin=YMin+0.2*YMin;
  if YMin>0, YMin=0; end;
  if YMax<0, YMax=-0.2*YMin; end;
  fig(1).h=figure('Position', [50 50 max([600, numel(con)*200]) 600],...
    'PaperPositionMode', 'auto', 'PaperOrientation', 'Portrait', ...
    'InvertHardCopy', 'off', 'Color', 'w', 'Name', 'Parameter estimates');
  fig(1).ax(1).h=axes('Position', [0.1 0.1 0.8 0.8]);
  m=mean(t.beta(:,con)); s=std(t.beta(:,con))/sqrt(size(t.beta,1));
  for c=1:numel(con)
    if t.p(con(c))<0.05, color=[0.5 0 0]; else color=[0.5 0.5 0.5]; end;
    fig(1).plot(c)=bar(c, m(c), 'FaceColor', color, 'EdgeColor', [0 0 0], 'LineWidth', 3, 'BarWidth', 0.7);
    hold on;
    fig(1).err(c)=errorbar(c, m(c), s(c), 'LineStyle', 'none', 'Color', [0 0 0], 'LineWidth', 3);
  end;
  set(fig(1).ax(1).h, 'XTick', [1:numel(con)], ...
    'XTickLabel', t.names(con), 'YLim',[YMin, YMax], ...
    'YTick', [], 'TickLabelInterpreter', 'none', ...
    'XTickLabelRotation', 25, ...
    'FontWeight', 'Bold', 'FontSize', 14);
  set(get(fig(1).ax(1).h, 'YLabel'), ...
    'String', 'Parameter mean (arbitrary units)', ...
    'FontSize', 18, 'FontWeight', 'Bold');
end;

% display files and tables
disp(' ');
disp(sprintf('Reporting %d contrasts for %s', numel(con), modelfile));
if t.type==1, numfiles=numel(t.files); else numfiles=sum([numel(t.files{1}), numel(t.files{2})]); end;
disp(sprintf('%d files used for %d-sample t-test:', numfiles, t.type));
disp(' ');
for g=1:t.type
  if t.type==2, disp(sprintf('Group %d:', g)); gsize=numel(t.files{g}); else gsize=numel(t.files); end;
  disp('__________________________________________________________________________________');
  disp('Files:');
  for m=1:gsize
    if t.type==1, disp(t.files{m}); else disp(t.files{g}{m}); end;
  end;
  disp(' ');
  disp('__________________________________________________________________________________');
  disp('Parameter estimates:');
  if t.type==1, disp(t.beta(:,con)); else disp(t.beta{g}(:,con)); end;
end;
disp('__________________________________________________________________________________');
disp('Statistics:');
if t.type==1
  disp('-----------------------------------------------------------------------------------------------');
  disp(sprintf('mean\t\tsem\t\tt\t\tp\t\tdf\t\tContrast name'));
  disp('-----------------------------------------------------------------------------------------------');
  for c=con
    disp(sprintf('%.2f\t\t%.2f\t\t%.2f\t\t%.4f\t\t%d\t\t%s', mean(t.beta(:,c)), std(t.beta(:,c))/sqrt(size(t.beta,1)), t.t(c), t.p(c), t.df(c), t.names{c}));
  end;
  disp('-----------------------------------------------------------------------------------------------');
elseif t.type==2
  disp('-------------------------------------------------------------------------------');
  disp(sprintf('group 1\t\t\tgroup 2'));
  disp(sprintf('mean\tsem\t\tmean\tsem\t\tt\t\tp\t\t\tdf\t\tContrast name'));
  disp('-------------------------------------------------------------------------------');
  for c=con
    disp(sprintf('%.2f\t%.2f\t%.2f\t%.2f\t%.2f\t%.4f\t\t%d\t\t%s', ...
      mean(t.beta{1}(:,c)), std(t.beta{1}(:,c))/sqrt(size(t.beta{1}, 1)), mean(t.beta{2}(:,c)), std(t.beta{2}(:,c))/sqrt(size(t.beta{2}, 1)), ...
      t.t(c), t.p(c), t.df(c), t.names{c}));
  end;
  disp('-------------------------------------------------------------------------------');
end;
disp(' ');
disp('__________________________________________________________________________________');
disp('PsPM (c) Dominik R. Bach, Wellcome Trust Centre for Neuroimaging, UCL London UK');
sts = 1;
return
