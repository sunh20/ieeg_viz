%% plot ieeg main
% created 20220225 | SS
clear all; close all; clc

% make sure fieldtrip is added to path
addpath('fieldtrip')
addpath(genpath('../subjects'))
addpath(genpath('../predstim/results'))
ft_defaults

flatui = ["#417CA7", "#D93A46", "#4C956C", "#F18F01", "#3C153B", "#f075e6","#94D1BE"];
subj_dir = '/Users/sunh20/School/Research/subjects/'; 
e_type = 's';   % s - seeg or depth, c - cortical

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% user specified variables
subj_id = 'a87316';
exp = 1;
e_stim = [3,4]; % TDT stim electrodes 


% S1, 7b2ac8: [7,8] 
% S2, 2a67ba [9,10] 
% S4, 3fb8ca [15,16] 
% S3, c765c3 [10,11]
% S5, 120d23 [19,20]
% S6, 14b3d8 [4,5]
% S7, ab2418 [27,28]
% 0992c2 1: [5,6], 2: [20,21]
% S9, bdc872 3: [13,14], 10: [8,9]
% S10, a87316 [3,4]
% S11: ab82a9 [26,27]

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
[fig, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap,'k'); % with black marker
% [fig, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap); % with white marker
%% export figure + PNG
% make sure you change filenames

%savefig([subj_id '_EPamp_' mat2str(exp) '.fig'])
f = gcf;
%exportgraphics(f,[subj_id '_mni_trodes' mat2str(exp) '.png'],'Resolution',300)
%exportgraphics(f,[subj_id '_EPamp_' mat2str(exp) '.png'],'Resolution',300)
exportgraphics(f,[subj_id '_run1_' mat2str(exp) '.png'],'Resolution',300)

%% kurt to TDT electrode conversion + highlight stim trodes
% load table
fn_table = [subj_id '_kurt_to_tdt.csv_amps_' num2str(exp) '.csv'];
T = readtable(fn_table);

% change stim electrodes - convert TDT to kurt
e_stim_corrected = e_stim;
e_stim_corrected(1) = T(T.TDT == e_stim(1),:).kurt;
e_stim_corrected(2) = T(T.TDT == e_stim(2),:).kurt;

% highlight stim electrodes
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
%%
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
T.x = elecs.elecpos(:,1);
T.y = elecs.elecpos(:,2);
T.z = elecs.elecpos(:,3);

writetable(T,[fn_table '_amps_' mat2str(exp) '.csv'])

clear seg_average_all EP_amps EP_amps_norm c_lookup

%% cmap for EP Amps when we already made the modified CSV file 

% set colormap 
c_lookup = sky;

% load TDT EP Measure amp data
load(['../subjects/' subj_id '/' subj_id '_EP_Measure-' num2str(exp) '_amps.mat'])

% load table
fn_table = [subj_id '_kurt_to_tdt.csv_amps_' num2str(exp) '.csv'];
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
%% camp from 1vAll SVM results
% need to have T loaded

% set colormap 
c_lookup = sky;

fn = [subj_id '_cont_stim_train-' num2str(exp) '_1vAllSVM_2Hz_log_bs.csv'];
T_svm = readtable(fn);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% fill TDT table with SVM acc vals
ch_list = unique(T_svm.ch);
svm_acc_for_T = zeros(height(T),1);
T.svm1vA = svm_acc_for_T;
n_sig_chans = 0;

% for channel present in table svm
for i = 1:length(ch_list)

    ch = ch_list(i);

    % CHECK if channel 0 is present, means data is zero-indexed and needs
    % to be fixed in python 
    if ch == 0
        disp('ch = 0 is present, data is zero indexed and needs to be fixed in python')
    end

    test_avg_acc = mean(T_svm.acc(T_svm.ch == ch & (matches(T_svm.label,'test'))));

    % if pass permutation test, add to table T by matching to TDT channel value
    null_dist = T_svm.acc(T_svm.ch == ch & (matches(T_svm.label,'null')));

    if sum(test_avg_acc < null_dist)/length(null_dist) < 0.05
        % add to table T 
        T(T.TDT == ch,'svm1vA') = {test_avg_acc};
        n_sig_chans = n_sig_chans + 1;
    end

end
fprintf('n sig chans = %i\n', n_sig_chans)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create cmap for accuracy vals

acc = T.svm1vA;

% % set all sig channels to 256
% acc(acc > 0) = 256;
% acc(acc == 0) = 1;
% acc_plot = acc;

% normalize to 0-1
acc_norm = acc/max(acc);

% map electrode amp to colormap (256 units)
acc_plot = round(acc_norm*256);
acc_plot(acc_plot == 0) = 1;
cmap = c_lookup(acc_plot,:);

% stim - red
map = validatecolor(flatui(2), 'multiple');
cmap(e_stim_corrected,:) = repmat(map, [length(e_stim_corrected),1]);


%% example 2
%cmap = jet(n_elecs);

%% print
title(sprintf('subject %s, stim ch %s-%s',subj_id,elecs.label{e_stim_corrected(1)},elecs.label{e_stim_corrected(2)}))
print(gcf,sprintf('%s_mni_plot.png',subj_id),'-dpng','-r300');

