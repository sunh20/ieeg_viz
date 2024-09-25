function [splot, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap,markercolor,remove_non_TDT,notnan_idx)

if ~exist('markercolor','var')
    markercolor = 'w';
end

if native
    
    % get electrodes
    switch e_type
        case 's'
            load(fullfile(subj_dir, subj_id,[subj_id '_elec_acpc_f.mat']), 'elec_acpc_f');
            elecs = elec_acpc_f;
        case 'c'
            load(fullfile(subj_dir, subj_id,[subj_id '_elec_acpc_fr.mat']), 'elec_acpc_fr');
            elecs = elec_acpc_fr;
    end
    
else
    
    % get MNI electrodes
    load(fullfile(subj_dir, subj_id,[subj_id '_elec_mni.mat']), 'elec_mni');
    elecs = elec_mni;
    
end

e = elecs.elecpos;

% use cmap to figure out inactive electrodes 
cmap_flat = sum(cmap,2);
e_inactive = cmap_flat == 0;

% use notnan to remove non TDT electrodes from plot and cmap
if remove_non_TDT
    e = e(notnan_idx,:);
    cmap_plot = cmap(notnan_idx,:);
    e_inactive = e_inactive(notnan_idx);

else
    cmap_plot = cmap;
end

% plot channels - inactive 
scatter3(e(e_inactive,1), e(e_inactive,2), e(e_inactive,3), [], e(e_inactive,3), ...
'o', 'filled', ...
'SizeData', e_size, ...
'MarkerEdgeColor',markercolor, ...
'MarkerEdgeAlpha',0.5,...
'MarkerFaceAlpha',0);

% plot channels - active 
splot = scatter3(e(~e_inactive,1), e(~e_inactive,2), e(~e_inactive,3), [], e(~e_inactive,3), ...
'o', 'filled', ...
'SizeData', e_size, ...
'MarkerEdgeColor',markercolor, ...
'MarkerFaceAlpha',1);

splot.CData = cmap_plot(~e_inactive,:);

% plot transparent channels 
  
end

