function [s, range, select] = srf(this, time, varargin)
% srf  First-order shock response functions
%
% __Syntax__
%
%     S = srf(M, NPer, ...)
%     S = srf(M, Range, ...)
%
%
% __Input Arguments__
%
% * `M` [ model ] - Model object whose shock responses will be simulated.
%
% * `Range` [ numeric | char ] - Simulation date range with the first date
% being the shock date.
%
% * `NPer` [ numeric ] - Number of simulation periods.
%
%
% __Output Arguments__
%
% * `S` [ struct ] - Databank with shock response time series.
%
%
% __Options__
%
% * `Delog=true` [ `true` | `false` ] - Delogarithmize shock responses for
% log variables.
%
% * `Select=@all` [ cellstr | `@all` ] - Run the shock response function
% for a selection of shocks only; `@all` means all shocks are simulated.
%
% * `Size=@auto` [ `@auto` | numeric ] - Size of the shocks that will be
% simulated; `@auto` means that each shock will be set to its std dev
% currently assigned in the model object `M`.
%
%
% __Description__
% 
%
% __Example__
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

opt = passvalopt('model.srf', varargin{:});

if ischar(opt.select)
    opt.select = regexp(opt.select, '\w+', 'match');
end

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32); 
ne = sum(ixe);
nv = length(this);
listShocks = this.Quantity.Name(ixe);

% Select shocks.
if isequal(opt.select, @all)
    posSelected = 1 : ne;
else
    numSelected = length(opt.select);
    posSelected = nan(1, numSelected);
    for i = 1 : length(opt.select)
        x = find( strcmp(opt.select{i}, listShocks) );
        if length(x)==1
            posSelected(i) = x;
        end
    end
    if any(isnan(posSelected))
        throw( exception.Base('Model:InvalidName', 'error'), ...
               'shock', opt.select{isnan(posSelected)} );
    end
end
select = listShocks(posSelected);
numSelected = length(select);

% Set size of shocks.
if strcmpi(opt.size, 'std') ...
        || isequal(opt.size, @auto) ...
        || isequal(opt.size, @std)
    sizeShocks = this.Variant.StdCorr(:, posSelected, :);
else
    sizeShocks = opt.size*ones(1, numSelected, nv);
end

func = @(T, R, K, Z, H, D, U, Omg, variantRequested, numPeriods) ...
    timedom.srf(T, R(:, posSelected), [ ], Z, H(:, posSelected), [ ], U, [ ], ...
    numPeriods, sizeShocks(1, :, variantRequested));

[s, range, select] = responseFunction(this, time, func, select, opt);
for i = 1 : length(select)
    s.(select{i}).data(1, i, :) = sizeShocks(1, i, :);
    s.(select{i}) = trim(s.(select{i}));
end

s = addToDatabank({'Parameters', 'Std', 'NonzeroCorr'}, this, s);

end%

