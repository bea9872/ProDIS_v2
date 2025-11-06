% ==============================================================
% plot_growth_map.m
% ==============================================================
function plot_growth_map(results, title_str)
figure('Color','w');
imagesc(results.kz_vec, results.vA_vec, results.gamma_map);
set(gca, 'YDir','normal');
xlabel('k_z'); ylabel('v_A');
title(title_str);
colorbar; ylabel(colorbar, 'Growth rate \gamma / \Omega');
end