function ff = outputFactorData(this, x, Px, range, ixy, opt)
% outputFactorData  Prepare output factor data from FAVAR.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TEMPLATE_SERIES = Series( );

%--------------------------------------------------------------------------

nx = size(this.C, 2);
nPer = length(range);
nAlt = size(x, 3);

mean_ = replace( ...
    TEMPLATE_SERIES, ...
    permute(x(1:nx, :, :), [2, 1, 3]), ...
    range(1) ...
    );
if opt.meanonly
    ff = mean_;
else
    std_ = nan(nx, nPer, nAlt);
    for i = 1 : nx
        temp = Px(nx, nx, :, :);
        temp = sqrt(temp);
        temp = permute(temp, [1, 3, 4, 2]);
        std_(i, :, :) = temp;
    end
    std_ = replace( ...
        TEMPLATE_SERIES, ...
        permute(std_, [2, 1, 3]), ...
        range(1) ...
        );
    % Means and MSEs that can be used as initial condition.
    lastObs = find(any(ixy~=0, 1), 1, 'last');
    if isempty(lastObs)
        posRange = 1 : nPer;
    else
        posRange = lastObs : nPer;
    end
    init = { ...
        x(:, posRange, :), ...
        Px(:, :, posRange, :), ...
        range(posRange), ...
        };
    ff = struct( );
    ff.mean = mean_;
    ff.std = std_;
    ff.init = init;
end

end
