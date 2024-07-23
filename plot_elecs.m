function [splot, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,e_alpha,cmap,markercolor,remove_non_TDT,notnan_idx)

if ~exist('markercolor','var')
    markercolor = 'w';
else
    markercolor = 'k';
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

% % turn e_active into boolean array
% e_idx_expand = zeros(1,length(e));
% e_idx_expand(e_idx) = 1;

% use notnan to remove non TDT electrodes from plot and cmap
if remove_non_TDT
    e = e(notnan_idx,:);
    cmap_plot = cmap(notnan_idx,:);

else
    cmap_plot = cmap;
end

% plot channels
splot = scatter3(e(:,1), e(:,2), e(:,3), [], e(:,3), ...
'o', 'filled', ...
'SizeData', e_size, ...
'MarkerEdgeColor',markercolor, ...
'MarkerFaceAlpha',e_alpha);

splot.CData = cmap_plot;

% plot transparent channels 
  
end

