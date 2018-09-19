function D02_analysis_DFS0_Q()
% Script reads dfs0 files and provides analysis and figures along with CDF
% PE, monthly and annual summaries
% this is to save matlab database files which can be extremely slow

% -------------------------------------------------------------------------
% path string of ROOT Directory = DRIVE:/GIT/ENP_TOOLS MAIN Directory = PRE_PROCESSING
% -------------------------------------------------------------------------
[ROOT,MAIN,~] = fileparts(pwd());
TEMP = strsplit(ROOT,'\');

INI.ROOT = [TEMP{1} '/' TEMP{2} '/'];

% -------------------------------------------------------------------------
% Add path(s) to ENP_TOOLS and all other 1st level sub-directories
% -------------------------------------------------------------------------
INI.TOOLS_DIR = [INI.ROOT TEMP{3} '/'];
INI.SAMPLE_INPUT_DIR = [INI.ROOT 'ENP_TOOLS_Sample_Input/'];

clear TEMP ROOT MAIN
% -------------------------------------------------------------------------
% Add sub--directory path(s) for ENP_TOOLS directory
% -------------------------------------------------------------------------
INI.PRE_PROCESSING_DIR = [INI.TOOLS_DIR MAIN '/'];
    % Input directories:
INI.input = [INI.PRE_PROCESSING_DIR '_input/'];
    % DFS0 file creation from DFE input file directories
INI.STATION_DIR = [INI.PRE_PROCESSING_DIR 'D00_STATIONS/'];
INI.FLOW_DIR = [INI.PRE_PROCESSING_DIR 'D01_FLOW/'];
INI.STAGE_DIR = [INI.PRE_PROCESSING_DIR 'D02_STAGE/'];
    % BC2D generation directories:
INI.BC2D_DIR = [INI.PRE_PROCESSING_DIR 'G01_BC2D/'];

% -------------------------------------------------------------------------
% SETUP Location of ENPMS Scripts and Initialize
% -------------------------------------------------------------------------
INI.MATLAB_SCRIPTS = '../ENPMS/';

try
    addpath(genpath(INI.MATLAB_SCRIPTS));
catch
    addpath(genpath(INI.MATLAB_SCRIPTS,0));
end

% Delete existing DFS0 files? (0 = FALSE, 1 = TRUE)
INI.DELETE_EXISTING_DFS0 = 1;

% directory with *.DFS0 files:

INI.DIR_DFS0_FILES = [INI.FLOW_DIR 'DFS0/'];
FILE_FILTER = '*.dfs0'; % list only files with extension .out
FLOW_DFS0_FILES = [INI.DIR_DFS0_FILES FILE_FILTER];
LISTING  = dir(char(FLOW_DFS0_FILES));

% iterate over all DFS0 files
DFS0_process_file_list(INI,LISTING);

DFS0_process_file_list_DD(INI,LISTING);

DFS0_process_file_list_HR(INI,LISTING);

% Process the DFS0 and *.png files for inclusion on PDFs. User can set
% which *.png series to process: full, DD, or HR. Process only one at a
% time currently.

format compact
DPATH = INI.FLOW_DIR;                                       % set DPATH to directory location with necessary *.dfs0 and *.png files
% Set *.dfs0 DIRECTORY for the user defined pdf creation.
DIRPNG = [DPATH 'DFS0/'];                                   % location of DFS0 *.png files
%DIRPNG = [DPATH 'DFS0DD/'];                                % location of DFS0DD *.png files
%DIRPNG = [DPATH 'DFS0HR/'];                                % location of DFS0HR *.png files
PNGFILES = [DIRPNG '*.png'];
VECPNG = ls(PNGFILES);                                      % list all files in DIRPNG with extension *.png
% Set output FILENAME for the user defined pdf creation.
FILENAME = [DPATH 'FLOW.tex'];                              % Destination STAGE LaTex file ( *.tex )
%FILENAME = [DPATH 'FLOW_DD.tex'];                          % Destination STAGE_DD LaTex file ( *.tex )
%FILENAME = [DPATH 'FLOW_HR.tex'];                          % Destination STAGE_HR LaTex file ( *.tex )
HEADER = 'FLOW Analysis *New';
noFIG = 3;                                                  % Set the number of image rows per latex page. Value can either be 2 or 3.

FID = fopen(FILENAME,'w');

latex_print_begin(FID,HEADER);


for i = 1:length(VECPNG)
    m = mod(i,3);                                       % This variable has no usage within this or any other function/script. Consider revising, removing this variable completely.
    n = mod(i,2);
    
%    if m == 0; noFIG = 3; else; noFIG = 2; end  % This is not the correct
%    way to determine NoFIG. Need to deteremine a better method else just
%    default to a 2 column 3 row image layout
    
    if mod(i,6) == 1; latex_begin_new_page(FID); end                        % If this is the first image to be processed, begin the latex page design.
    
    [~,NAME,EXT] = fileparts(VECPNG(i,:));
    latex_print_pages_figures(m,n,FID,DIRPNG,NAME,strtrim(EXT),noFIG);
    
    if ~mod(i,6) || i == length(VECPNG), latex_end_page(FID); end           % If the page has 6 total figures, or i is the last image in the list, end the latex page.

end

latex_print_end(FID)

fclose(FID);

end
% -------------------------------------------------------------------------