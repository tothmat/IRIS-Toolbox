function this = diff(this, varargin)
% diff  First difference
%{
% ## Syntax ##
%
% Input arguments marked with a `~` sign may be omitted
%
%     this = diff(this, ~shift)
%
%
% ## Input Arguments ##
%
% __`this`__ [ NumericTimeSubscriptable ] -
% Input time series.
%
% __`~shift`__ [ numeric ] - Number of periods over which the first difference
% will be computed; `y=this-this{shift}`; `shift` is a negative number
% for the usual backward differencing; if omitted, `shift=-1`.
%
%
% ## Output Arguments ##
%
% __`this`__ [ NumericTimeSubscriptable ] -
% First difference of the input time series.
%
%
% ## Description ##
%
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

[shift, rows, power] = prepareChange(this, varargin{:});

%--------------------------------------------------------------------------

if isempty(this.data)
    return
end

%**************************************************************************
this = unop(@series.change, this, 0, @minus, shift, rows);
%**************************************************************************

if power~=1
    this.Data = this.Data * power;
end

end%

