function [fig, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap)

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

fig = scatter3(e(:,1), e(:,2), e(:,3), ...
'o', 'filled', ...
'SizeData', e_size, ...
'MarkerEdgeColor','k');

fig.CData = cmap;
  
end

