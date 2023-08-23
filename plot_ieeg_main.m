%% plot ieeg main
% created 20220225 | SS
clear all; close all; clc

% make sure fieldtrip is added to path
ft_defaults

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% user specified variables
subj_id = '7b2ac8';
subj_dir = '/Users/sunh20/School/Research/subjects/'; 
e_type = 's';   % s - seeg or depth, c - cortical
e_stim = [29,30]; % stim electrodes % 7b2ac8: [29,30]

%% plot settings

% brain settings
native = false;      % true - plot native brain (if false plots MNI)
transparency = 0.1; % [0,1] - best to use for depths

% electrode settings
e_size = 50;          
cmap = [0,0,0];     % color/colormap for elecs, (3,n_electrodes)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
assert(strcmp(e_type,'c') || strcmp(e_type,'s'),'e_type input not recognized, please try again')


%% plots - change cmap after first plot

% plot brain
plot_brain(subj_id,subj_dir,native,transparency)

% plot electrodes
[fig, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap);


%% cmap: highlight stim electrodes
flatui = ["#417CA7", "#D93A46", "#4C956C", "#F18F01", "#3C153B", "#f075e6","#94D1BE"];

n_elecs = length(elecs.elecpos);

% default color: blue
map = validatecolor(flatui(1), 'multiple');
cmap = repmat(map, [n_elecs,1]);

% highlight stim electrodes
fprintf('confirming stim electrodes %i-%i (%s-%s)\n',e_stim(1),e_stim(2),elecs.label{e_stim(1)},elecs.label{e_stim(2)})
map = validatecolor(flatui(2), 'multiple');
cmap(e_stim,:) = repmat(map, [length(e_stim),1]);

%% example 2
%cmap = jet(n_elecs);

%% print
title(sprintf('subject %s, stim ch %s-%s',subj_id,elecs.label{e_stim(1)},elecs.label{e_stim(2)}))
print(gcf,sprintf('%s_mni_plot.png',subj_id),'-dpng','-r300');

