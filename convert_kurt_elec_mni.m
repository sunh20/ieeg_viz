%% convert kurt's recons to elec MNI format
% requires subject trodes mat file
% converts it to an MNI elec file 
% created 20230823 | SS
clear all; close all; clc

addpath('fieldtrip/')
ft_defaults

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% user specified variables
subj_id = '0992c2';
subj_dir = '/Users/sunh20/School/Research/subjects/'; 
fn_kurt_imaging = '0992c2_Montage.mat';
e_type = 's';   % s - seeg or depth, c - cortical


%% kurt imaging conversion
kurt_img = load(fullfile(subj_dir,subj_id,fn_kurt_imaging));
fieldname = fieldnames(kurt_img);

% turn into fieldtrip-like electrode file - only need elecpos for plotting
% but wouldn't hurt to add some other useful things
elec_mni = struct;
elec_mni.cfg = [];
elec_mni.elecpos = kurt_img.(fieldname{1}).MNI;
elec_mni.label = kurt_img.(fieldname{1}).MontageTable.Contact;

% save mni
save(fullfile(subj_dir,subj_id,[subj_id, '_elec_mni.mat']),"elec_mni")
disp('finished')
