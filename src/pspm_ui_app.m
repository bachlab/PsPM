function app = pspm_ui_app (app)
OS = ispc*1 + ismac*2 + (isunix-ismac)*3;
pspm_font_list = {'Segoe UI', 'Helvetica', 'DejaVu Sans'};
pspm_font = pspm_font_list{OS};
app.logo.FontName = pspm_font;
app.text_tools.FontName = pspm_font;
end