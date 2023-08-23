function plot_brain(subj_id,subj_dir,native,transparency)

fig = figure;

if native
    % load pial files
    pial_r = ft_read_headshape(fullfile(subj_dir, subj_id,'freesurfer','surf','rh.pial'));
    pial_l = ft_read_headshape(fullfile(subj_dir, subj_id,'freesurfer','surf','lh.pial'));
    
    % plot
    ft_plot_mesh(pial_l);
    ft_plot_mesh(pial_r);
   
    title(sprintf('subj %s',subj_id))
    
    
else

% adding MNI brain plot
    load(fullfile(pwd,'fieldtrip','template','anatomy','surface_pial_left.mat'),'mesh');
    ft_plot_mesh(mesh,'facecolor', [0.8,0.8,0.8]);
    load(fullfile(pwd,'fieldtrip','template','anatomy','surface_pial_right.mat'),'mesh');
    ft_plot_mesh(mesh,'facecolor', [0.8,0.8,0.8]);

    title(sprintf('subj %s electrodes on colin27 MNI brain',subj_id))

end

view_angle = [180 270];
alpha(transparency)
view(view_angle);
material dull;
lighting gouraud;
camlight;
rotate3d on
hold on

end