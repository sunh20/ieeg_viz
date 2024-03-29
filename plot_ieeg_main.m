%% plot ieeg main
% created 20220225 | SS
clear all; close all; clc

% make sure fieldtrip is added to path
addpath('fieldtrip')
addpath(genpath('../subjects'))
ft_defaults

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% user specified variables
subj_id = '0992c2';
exp = 2;
subj_dir = '/Users/sunh20/School/Research/subjects/'; 
e_type = 's';   % s - seeg or depth, c - cortical
e_stim = [20,21]; % stim electrodes 


% 7b2ac8: [7,8] 
% 2a67ba [9,10] 
% 3fb8ca [15,16] 
% c765c3 [10,11]
% 14b3d8 [4,5]
% ab2418 [27,28]
% 120d23 [19,20]
% 0992c2 1: [5,6], 2: [20,21]

%% plot settings

% brain settings
native = false;      % true - plot native brain (if false plots MNI)
transparency = 0.1; % [0,1] - best to use for depths

% electrode settings
e_size = 50;          
cmap = [0,0,0];     % color/colormap for elecs, (3,n_electrodes)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
assert(strcmp(e_type,'c') || strcmp(e_type,'s'),'e_type input not recognized, please try again')


%% plots - change cmap after first plot + rerun this block again

% plot brain
plot_brain(subj_id,subj_dir,native,transparency)

% plot electrodes
[fig, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap);

%% export figure + PNG
% make sure you change filenames

savefig([subj_id '_EPamp_' mat2str(exp) '.fig'])
f = gcf;
exportgraphics(f,[subj_id '_EPamp_' mat2str(exp) '.png'],'Resolution',300)

%% cmap: highlight stim electrodes

% be very careful about TDT to kurt conversion 
e_stim_corrected = e_stim;

flatui = ["#417CA7", "#D93A46", "#4C956C", "#F18F01", "#3C153B", "#f075e6","#94D1BE"];
n_elecs = length(elecs.elecpos);

% default color: blue
map = validatecolor(flatui(1), 'multiple');
cmap = repmat(map, [n_elecs,1]);

% highlight stim electrodes
fprintf('confirming stim electrodes %i-%i (%s-%s)\n',e_stim(1),e_stim(2),elecs.label{e_stim_corrected(1)},elecs.label{e_stim_corrected(2)})
map = validatecolor(flatui(2), 'multiple');
cmap(e_stim_corrected,:) = repmat(map, [length(e_stim_corrected),1]);

%% cmap: EP Measure amplitude response + save new table
% electrodes that aren't recorded on TDT will be set to 0

% set colormap 
c_lookup = sky;

% load TDT EP Measure amp data
load(['../subjects/' subj_id '/' subj_id '_EP_Measure-' num2str(exp) '_amps.mat'])

% load conversion file 
fn_table = [subj_id '_kurt_to_tdt.csv'];
T = readtable(fn_table);

% create idx transformation matrix
T2 = sortrows(T,'TDT');
T2 = T2(~any(ismissing(T2),2),:); % remove non-TDT channels
fprintf('there are %i TDT channels detected from the kurt_to_tdt csv file\n', height(T2))

% correct + set zeros to zeros
n_elecs = length(elecs.elecpos);
EP_amps_norm_transformed = zeros(n_elecs,1);
EP_amps_norm_transformed(T2.kurt) = EP_amps_norm(T2.TDT);

% convert stim electrodes
e_stim_corrected = e_stim;
e_stim_corrected(1) = T2(T2.TDT == e_stim(1),:).kurt;
e_stim_corrected(2) = T2(T2.TDT == e_stim(2),:).kurt;

% map electrode amp to colormap (256 units)
EP_amps_norm_corrected_mod = round(EP_amps_norm_transformed*256);
EP_amps_norm_corrected_mod(EP_amps_norm_corrected_mod == 0) = 1;
cmap = c_lookup(EP_amps_norm_corrected_mod,:);

% stim - red
map = validatecolor(flatui(2), 'multiple');
cmap(e_stim_corrected,:) = repmat(map, [length(e_stim_corrected),1]);

fprintf('confirming stim electrodes %i-%i (%s-%s)\n',e_stim(1),e_stim(2),elecs.label{e_stim_corrected(1)},elecs.label{e_stim_corrected(2)})

% add to table + export 
T.amp_norm = EP_amps_norm_transformed;
writetable(T,[fn_table '_amps_' mat2str(exp) '.csv'])

clear seg_average_all EP_amps EP_amps_norm c_lookup

%% cmap for EP Amps when we already made the modified CSV file 

% set colormap 
c_lookup = sky;

% load TDT EP Measure amp data
load("../3fb8ca_EP_Measure-1_amps.mat")

% load table
fn_table = [subj_id '_kurt_to_tdt.csv_amps.csv'];
T = readtable(fn_table);
EP_amps_norm_transformed = T.amp_norm;

% change stim electrodes - convert TDT to kurt
e_stim_corrected = e_stim;
e_stim_corrected(1) = T(T.TDT == e_stim(1),:).kurt;
e_stim_corrected(2) = T(T.TDT == e_stim(2),:).kurt;

% map electrode amp to colormap (256 units)
EP_amps_norm_corrected_mod = round(EP_amps_norm_transformed*256);
EP_amps_norm_corrected_mod(EP_amps_norm_corrected_mod == 0) = 1;
cmap = c_lookup(EP_amps_norm_corrected_mod,:);

% stim - red
map = validatecolor(flatui(2), 'multiple');
cmap(e_stim_corrected,:) = repmat(map, [length(e_stim_corrected),1]);

fprintf('confirming stim electrodes %i-%i (%s-%s)\n',e_stim_corrected(1),e_stim_corrected(2),elecs.label{e_stim_corrected(1)},elecs.label{e_stim_corrected(2)})

% add to table + export 
% T.amp_norm = EP_amps_norm_transformed;
% writetable(T,[fn_table '_amps.csv'])
%% example 2
%cmap = jet(n_elecs);

%% print
title(sprintf('subject %s, stim ch %s-%s',subj_id,elecs.label{e_stim_corrected(1)},elecs.label{e_stim_corrected(2)}))
print(gcf,sprintf('%s_mni_plot.png',subj_id),'-dpng','-r300');

