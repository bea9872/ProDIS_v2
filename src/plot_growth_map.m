function plot_growth_map(results, varargin)
% plot_growth_map: simple plotting helper
% Usage:
% plot_growth_map(results, 'xlabel', 'kz', 'ylabel', 'vA', 'title', '...')
p = inputParser;
addRequired(p,'results');
addParameter(p,'xlabel','k_z');
addParameter(p,'ylabel','sweep_var');
addParameter(p,'title','Growth rate map');
parse(p, results, varargin{:});

gamma_map = results.gamma_map;
kz = results.kz_list;

if isfield(results,'sweep_vals')
    sweep_vals = results.sweep_vals;
    imagesc(kz, sweep_vals, gamma_map);
    set(gca,'YDir','normal');
    xlabel(p.Results.xlabel); ylabel(p.Results.ylabel);
else
    plot(kz, gamma_map, 'LineWidth', 1.5);
    xlabel(p.Results.xlabel); ylabel('growth rate');
end
colorbar;
title(p.Results.title);
end