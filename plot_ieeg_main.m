%% plot ieeg main
% created 20220225 | SS
clear all; close all; clc

% make sure fieldtrip is added to path
ft_defaults

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% user specified variables
subj_id = '0d5e8e';
subj_dir = '/Users/sunh20/School/Research/subjects/'; 
e_type = 's';   % s - seeg or depth, c - cortical

%% plot settings

% brain settings
native = true;      % true - plot native brain (if false plots MNI)
transparency = 0.2; % [0,1] - best to use for depths

% electrode settings
e_size = 50;          
cmap = [0,0,0];     % color/colormap for elecs, (3,n_electrodes)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% don't change anything after here pls

assert(strcmp(e_type,'c') || strcmp(e_type,'s'),'e_type input not recognized, please try again')

% plot brain
plot_brain(subj_id,subj_dir,native,transparency)

% plot electrodes
fig = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap);

%% some cmap examples

n_elecs = 126;

cmap = zeros(n_elecs, 3);
cmap(:,1) = rand(n_elecs,1);

% example 2
%cmap = jet(n_elecs);