classdef pspm_update_struct_test < pspm_testcase
% ● Description
%   Unittest class for the pspm_update_struct function
% ● History
%   Written on 05-02-2014 by Teddy
properties(Constant)
  A = struct();
  B = struct();
  Fields = {'a','b','c','d'};
  Values = {'aValue','bValue','cValue','dValue'};
end
methods(Test)
function CheckStringInput(this)
  UpdatedA.(this.Fields{1}) = this.Values{1};
  ResultB = pspm_update_struct(this.B, UpdatedA, this.Fields{1});
  this.verifyEqual(ResultB.(this.Fields{1}), UpdatedA.(this.Fields{1}));
end
function CheckCellInputSingle(this)
  UpdatedA.(this.Fields{1}) = this.Values{1};
  ResultB = pspm_update_struct(this.B, UpdatedA, this.Fields(1));
  this.verifyEqual(ResultB.(this.Fields{1}), UpdatedA.(this.Fields{1}));
end
function CheckCellInputMulti(this)
  UpdatedA.(this.Fields{1}) = this.Values{1};
  UpdatedA.(this.Fields{2}) = this.Values{2};
  UpdatedA.(this.Fields{3}) = this.Values{3};
  ResultB = pspm_update_struct(this.B, UpdatedA, this.Fields(1:3));
  this.verifyEqual(ResultB.(this.Fields{1}), UpdatedA.(this.Fields{1}));
  this.verifyEqual(ResultB.(this.Fields{2}), UpdatedA.(this.Fields{2}));
  this.verifyEqual(ResultB.(this.Fields{3}), UpdatedA.(this.Fields{3}));
end
end
end