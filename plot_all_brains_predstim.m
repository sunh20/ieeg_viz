% plot all plots
% make sure fieldtrip is added to path
addpath('fieldtrip')
addpath(genpath('../subjects'))
addpath(genpath('../predstim/results'))
ft_defaults
clear all; close all; clc


%% user settings 

marker_black = 1; % 0 if you want white
save_on = 1; % save plots to file
run_name = 'run2'; % name the save file

% types of plots
plot_stim_trodes = 0; % plot stim trodes only 
plot_run1 = 0; 
plot_run2 = 1; 

%% auto settings

flatui = ["#417CA7", "#D93A46", "#4C956C", "#F18F01", "#3C153B", "#f075e6","#94D1BE"];
subj_dir = '/Users/sunh20/School/Research/subjects/'; 
e_type = 's';   % s - seeg or depth, c - cortical

% brain settings
native = false;      % true - plot native brain (if false plots MNI)
transparency = 0.1; % [0,1] - best to use for depths

% electrode settings
e_size = 50;          
cmap = [0,0,0];     % color/colormap for elecs, (3,n_electrodes)

%% plot all subject brains, can customize which plot type i guess

subj_ids = {'7b2ac8','2a67ba','3fb8ca','120d23','14b3d8','ab2418','bdc872','a87316','ab82a9'};
exps = [1,1,1,1,1,1,1,1,2];
e_stims = {[7,8] ,[9,10] ,[15,16] ,[19,20],[4,5],[27,28],[13,14],[3,4],[26,27]};

for j = 1:length(subj_ids)

subj_id = subj_ids{j};
exp = exps(j); 
e_stim = e_stims{j};

%% plots - change cmap after first plot + rerun this block again

% plot brain
plot_brain(subj_id,subj_dir,native,transparency)

% plot electrodes
if marker_black
    [fig, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap,'k'); % with black marker
else
    [fig, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap); % with white marker
end

%% kurt to TDT electrode conversion
% load table
fn_table = [subj_id '_kurt_to_tdt.csv_amps_' num2str(exp) '.csv'];
T = readtable(fn_table);

% change stim electrodes - convert TDT to kurt
e_stim_corrected = e_stim;
e_stim_corrected(1) = T(T.TDT == e_stim(1),:).kurt;
e_stim_corrected(2) = T(T.TDT == e_stim(2),:).kurt;

%% plot stim trodes

if plot_stim_trodes
% highlight stim electrodes
n_elecs = length(elecs.elecpos);

% default color: blue
map = validatecolor(flatui(1), 'multiple');
cmap = repmat(map, [n_elecs,1]);

% highlight stim electrodes
fprintf('confirming stim electrodes %i-%i (%s-%s)\n',e_stim(1),e_stim(2),elecs.label{e_stim_corrected(1)},elecs.label{e_stim_corrected(2)})
map = validatecolor(flatui(2), 'multiple');
cmap(e_stim_corrected,:) = repmat(map, [length(e_stim_corrected),1]);

%% plot svm acc (run1) 
elseif plot_run1

%% camp from 1vAll SVM results
% need to have T loaded

% set colormap 
c_lookup = sky;

fn = [subj_id '_cont_stim_train-' num2str(exp) '_1vAllSVM_2Hz_log_bs.csv'];
T_svm = readtable(fn);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% fill TDT table with SVM acc vals
ch_list = unique(T_svm.ch);
% svm_acc_for_T = zeros(height(T),1);
T.svm1vA = zeros(height(T),1);
T.svm1vA_sig = zeros(height(T),1); % keep track of significance
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

    % add to table T by matching to TDT channel value
    T(T.TDT == ch,'svm1vA') = {test_avg_acc};

    % mark if pass permutation test
    null_dist = T_svm.acc(T_svm.ch == ch & (matches(T_svm.label,'null')));

    if sum(test_avg_acc < null_dist)/length(null_dist) < 0.05
        T(T.TDT == ch,'svm1vA_sig') = {1};
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

% dont plot non sig channels
n_ch = length(cmap(T.svm1vA_sig == 0,:));
cmap(T.svm1vA_sig == 0,:) = repmat([1,1,1],n_ch,1);

% mark channels that shouldn't be considered in grey
n_ch_outliers = length(cmap(acc == 0,:));
cmap(acc == 0,:) = repmat([0.5,0.5,0.5],n_ch_outliers,1);

% stim - red
map = validatecolor(flatui(2), 'multiple');
cmap(e_stim_corrected,:) = repmat(map, [length(e_stim_corrected),1]);

elseif plot_run2

%% camp from 1vAll SVM results
% need to have T loaded

% set colormap 
c_lookup = sky;

fn = [subj_id '_cont_stim_train-' num2str(exp) '_1vAllSVM_2Hz_log_bs_kfold.csv'];
T_svm = readtable(fn);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% fill TDT table with SVM acc vals
ch_list = unique(T_svm.ch);
% svm_acc_for_T = zeros(height(T),1);
T.svm1vA = zeros(height(T),1);
T.svm1vA_sig = zeros(height(T),1); % keep track of significance
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

    % add to table T by matching to TDT channel value
    T(T.TDT == ch,'svm1vA') = {test_avg_acc};

    % mark if pass permutation test
    null_dist = T_svm.acc(T_svm.ch == ch & (matches(T_svm.label,'null')));

    if sum(test_avg_acc < null_dist)/length(null_dist) < 0.05
        T(T.TDT == ch,'svm1vA_sig') = {1};
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

% dont plot non sig channels
n_ch = length(cmap(T.svm1vA_sig == 0,:));
cmap(T.svm1vA_sig == 0,:) = repmat([1,1,1],n_ch,1);

% mark channels that shouldn't be considered in grey
n_ch_outliers = length(cmap(acc == 0,:));
cmap(acc == 0,:) = repmat([0.5,0.5,0.5],n_ch_outliers,1);

% stim - red
map = validatecolor(flatui(2), 'multiple');
cmap(e_stim_corrected,:) = repmat(map, [length(e_stim_corrected),1]);

end


%% plot again with right labels + 128 TDT electrodes

% plot brain
plot_brain(subj_id,subj_dir,native,transparency)

% plot electrodes
if marker_black
    [fig, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap,'k'); % with black marker
else
    [fig, elecs] = plot_elecs(subj_id,subj_dir,e_type,native,e_size,cmap); % with white marker
end

%% save
if save_on
f = gcf;
exportgraphics(f,[subj_id '_' run_name '_' mat2str(exp) '.png'],'Resolution',300)
end


    

end

