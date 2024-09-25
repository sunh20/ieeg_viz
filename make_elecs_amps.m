%%% update elecs file 
addpath(genpath('../subjects'))
ft_defaults
subj_dir = '/Users/sunh20/School/Research/subjects/'; 

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subj_ids = {'7b2ac8','2a67ba','3fb8ca','120d23','14b3d8','ab2418','bdc872','a87316','ab82a9'};
subj_names = {'S1','S2','S4','S5','S6','S7','S9','S10','S11'}; 
exps = [1,1,1,1,1,2,1,1,2];
e_stims = {[7,8],[9,10],[15,16],[19,20],[4,5],[27,28],[13,14],[3,4],[26,27]}; 


for j = 1:length(subj_ids)

subj_id = subj_ids{j};
subj_name = subj_names{j};
exp = exps(j); 
e_stim = e_stims{j};

% get elecs
load(fullfile(subj_dir, subj_id,[subj_id '_elec_mni.mat']), 'elec_mni');
elecs = elec_mni;

% load kurt file
fn_table = [subj_id '_kurt_to_tdt.csv_amps_' num2str(exp) '.csv'];
T = readtable(fn_table);

% add to table + export 
T.x = elecs.elecpos(:,1);
T.y = elecs.elecpos(:,2);
T.z = elecs.elecpos(:,3);

writetable(T,[fn_table '_elec_pos_' mat2str(exp) '.csv'])

end