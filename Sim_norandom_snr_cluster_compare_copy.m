clear all
clc
close all

addpath /autofs/cluster/transcend/fahimeh/fm_functions/Mines/

% parts=[5 7 9 11 13];
% subs=[1 2 3 4 5];

parts=[5 7 9 11 13];
subs=[1 2 3 4 5];


%snr=[0.1 0.06 .03];
%snr=[1 0.1 0.09 .08 .07 0.06 .05 .04 0.03];
%snr=[1 0.1 .08 0.06 .04 0.03];
snr=0.05;


sim_dir='/autofs/cluster/transcend/fahimeh/fmm/resources/Simulations2/labelsize_var/';
sim_doc='/autofs/cluster/transcend/fahimeh/fmm/doc/method_paper/Simulation/Simulation2/SNR_var/';

noiseLevelr=1;

X{1} =[0     0;0    0];
X{2} =[0     0;0    0];

flagrest=2;

% POOL=parpool('local',12);


for iparts=3:3
    
    k=1;
    all_label=cell(1);
    for ipart=1:parts(iparts)
        all_label{k,1}=['superiortemporal_' num2str(ipart) '-lh.label'];
        k=k+1;
    end
    for ipart=1:parts(iparts)
        all_label{k,1}=['superiortemporal_' num2str(ipart) '-rh.label'];
        k=k+1;
    end
    
    
    sub_num=subs(iparts);
    
    label_names=all_label([1:sub_num,(1:sub_num)+parts(iparts)]);
    
    label1=all_label(1:sub_num);
    
    all_label1=all_label(1:parts(iparts));
    all_label2=all_label(parts(iparts)+1:parts(iparts)*2);
    
    specific_tag=['templ_tempr_' num2str(sub_num) 'sub_norand_15to20f_8subj_stg' num2str(parts(iparts)) 'parts'];
    
    %%
    
    labeldir_tag=['stg' num2str(parts(iparts)) 'part/'];
    
    
    for isnr=1:length(snr)
        
        SNR=snr(isnr);
        
         [tag, FREQ, fs] = simulation_coh_func_norandom_clustercompar(sim_dir,label_names,label1,noiseLevelr,specific_tag,SNR,labeldir_tag);
        
        
        %% statistics
        
%         tag='0_0_0_0_nr_1_snr_0.06_templ_tempr_3sub_norand_15to20f_8subj_stg9parts';
%         FREQ=round(logspace(0.79,1.7,20));
         nperm=200;
%         fs = 600;
        
        stats=  do_sim_stats_clustercompar(sim_dir,tag,label_names,FREQ,nperm,fs);
        
        
        
        %   cluster_coh_eval(all_label1,all_label2,X,sim_dir,noiseLevelr,specific_tag,sim_doc,flagrest,SNR)
        
        
        
        
        
        
    end
    
end
