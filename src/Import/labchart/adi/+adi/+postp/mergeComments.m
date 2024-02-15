function mergeComments(final_file_path,source_file_paths)
%x Takes comments from files and merges them in to an older file
%
%   adi.postp.mergeComments(*final_file_path,*source_file_paths)
%
%   Optional Inputs:
%   ----------------
%   final_file_path : string (default, selection)
%       Path to the file to which comments are added
%   source_file_paths : string or cellstr
%       
%
%   Examples:
%   ---------
%   1)
%   final_path = 'D:\adi_comment_merging\140903_C_01_pelvic _and hypogastric_PGE2.adicht';
%   file_with_comments = 'D:\adi_comment_merging\140903_C_01_pelvic _and hypogastric_PGE2_CMG NVC Analysis.adicht';
%   adi.postp.mergeComments(final_path,file_with_comments)
%
%   To Handle
%   ---------
%   1) 
%
%   Improvements:
%   -------------
%   1) We need to verify that the final_file_path is indeed an original
%   that contains the various sources.




% in.final_file_path = '';
% in.source_file_paths = {};
% in = sl.in.processVarargin(in,varargin);

if nargin < 1
    final_file_path = '';
elseif nargin < 2
    source_file_paths = '';
end

if isempty(final_file_path)
    final_file_path = adi.uiGetChartFile('prompt','select file to add comments to');
elseif ~exist(final_file_path,'file')
   %TODO: Build in call to the file missing error, requires moving from the
   %sl to this package
   error('Final file path does not point to a file that exists') 
end

if ischar(source_file_paths) && ~isempty(source_file_paths)
   source_file_paths = {source_file_paths}; 
end

%commented_files
if isempty(source_file_paths)
source_file_paths = adi.uiGetChartFile('multi_select',true,'prompt',...
    'Select files that contain new comments to move');
else
    for iFile = 1:length(source_file_paths)
       if ~exist(source_file_paths{iFile},'file')
          error('Specified file does not exist') 
       end
    end
end

if ischar(source_file_paths)
   source_file_paths = {source_file_paths}; 
end

final_h = adi.editFile(final_file_path); 

for iFile = 1:length(source_file_paths)
   cur_file_h = adi.readFile(source_file_paths{iFile}); 
   
   cur_comments = cur_file_h.getAllComments();
   
   h__getCommentInstructions(final_h.comments,cur_comments)
   
   keyboard
end
%final_file = adi.readFile(final_file_path);

keyboard

end

function h__getCommentInstructions(old_comments,new_comments)
%Comment Merging Rules
%{

The ID should not change for a comment. Adding new comments
will create a new ID. This can cause a problem however if we take multiple
new files since they are not in sync.

i.e. 
    - original_file
        - subset1
        - subset2
    The files subset1 & subset2 don't know about each other, so presumably
    they have ids which overlap.

How do we want to handle 

String content change
---------------------

Channel change
--------------

Time difference
---------------
- use the new one
- 

Approach
--------
Find the best match for any comment in the source in the original. This may
or may not exist. If it exists, the do nothing for now. Eventually we need
to figure out how to handle any discrepancies.
If it doesn't exist, add it.

%}
   %TODO: Implement this
   %I'd like a set of instructions
   %- create
   %- delete
   %- edit
   %as well as a comment by comment analysis 
   %- keeping
   %- deleting
   %- merging with new
   %- same as old
   %- creating
   %- merging with old
end