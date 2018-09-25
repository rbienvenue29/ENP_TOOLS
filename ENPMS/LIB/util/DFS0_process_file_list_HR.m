function DFS0_process_file_list_HR(INI)

FILE_FILTER = '*.dfs0'; % list only files with extension .dfs0
FLOW_DFS0_FILES = [INI.DIR_FLOW_DFS0 FILE_FILTER];
LISTING  = dir(char(FLOW_DFS0_FILES));
FIG_DIR = INI.DIR_FLOW_PNGSHR;

n = length(LISTING);
for i = 1:n
   try
      s = LISTING(i);
      NAME = s.name;
   FILE_NAME = [INI.DIR_FLOW_DFS0 NAME];
   fprintf('  Processing: %d/%d: %s \n', i, n, char(NAME));
      
      % read database file
      DFS0 = read_file_DFS0(FILE_NAME);
%      DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME);            % Line
%      commented out as it has been found to be unnecessary in current
%      iteration. Possible use may be found for re-assignment of DFS0.UNIT
%      based on a datatype/(summation or average) combinations where units
%      need to be ammended.
      DFS0.NAME = NAME;
      
      fprintf('... reducing: %d/%d: %s \n', i, n, char(FILE_NAME))
      DFS0 = DFS0_data_reduce_HR(DFS0);
      
      % create a hourly file dfs0 file.
      [~,B,~] = fileparts(char(FILE_NAME));
   FILE_NAME = [INI.DIR_FLOW_DFS0HR,B,'.dfs0'];     
      DFS0.STATION = B;
      % save the file in a new directory
      create_DFS0_GENERIC_HR_Q(INI,DFS0,FILE_NAME);
      
      % read the new hourly file
      fprintf('... reading: %d/%d: %s \n', i, n, char(FILE_NAME));
      DFS0 = read_file_DFS0(FILE_NAME);
%      DFS0 = DFS0_assign_DTYPE_UNIT(DFS0,NAME);
      DFS0.NAME = NAME;
      
      DFS0 = DFS0_cumulative_flow(DFS0);
   %INI.DIR_DFS0_FILES = strrep(INI.DIR_DFS0_FILES,'DFS0','DFS0HR');
      % generate Timeseries
      plot_fig_TS_1(DFS0,FIG_DIR);
      
      % generate Cumulative
      plot_fig_CUMULATIVE_1(DFS0,FIG_DIR);

      % generate CDF
      plot_fig_CDF_1(DFS0,FIG_DIR)

      % generate PE
      plot_fig_PE_1(DFS0,FIG_DIR)
      
      % plot Monthly
      plot_fig_MM_1(DFS0,FIG_DIR)
      
      % plot Annual
      plot_fig_YY_1(DFS0,FIG_DIR)

   catch
      fprintf('... exception (C) in: %d/%d: %s \n', i, n, char(FILE_NAME));
      fclose('all');
   end
% Process the DFS0 and *.png files for inclusion on PDFs.
format compact
DIRPNG = INI.DIR_FLOW_PNGSHR;
PNGFILES = [DIRPNG '*.png'];
VECPNG = ls(PNGFILES);                                      % list all files in DIRPNG with extension *.png
[num_pngs,~] = size(VECPNG);
noFIG = 3;                                                  % Set the number of image rows per latex page. Value can either be 2 or 3.
FID = fopen(INI.FLOWHR_LATEX_FILENAME,'w');
latex_print_begin(FID,INI.FLOWHR_LATEX_HEADER);
for i = 1:num_pngs
    m = mod(i,2);                                       % This variable has no usage within this or any other function/script. Consider revising, removing this variable completely.
    n = mod(i,3);
%    if m == 0; noFIG = 3; else; noFIG = 2; end  % This is not the correct
%    way to determine NoFIG. Need to deteremine a better method else just
%    default to a 2 column 3 row image layout
    if mod(i,6) == 1; latex_begin_new_page(FID); end                        % If this is the first image to be processed, begin the latex page design.
    [~,NAME,EXT] = fileparts(VECPNG(i,:));
    latex_print_pages_figures(m,n,FID,INI.FLOWHR_LATEX_RELATIVE_PNG_PATH,NAME,strtrim(EXT),noFIG);
    if ~mod(i,6) || i == length(VECPNG), latex_end_page(FID); end           % If the page has 6 total figures, or i is the last image in the list, end the latex page.
end
latex_print_end(FID)
fclose(FID);
fclose('all');
end