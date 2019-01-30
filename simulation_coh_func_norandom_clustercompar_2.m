function [tag, FREQ, fs] = simulation_coh_func_norandom_clustercompar_2(sim_dir,label_names,label1,noiseLevelr,specific_tag,SNR,labeldir_tag,issptial_var)

addpath /autofs/cluster/transcend/scripts/MEG/Matlab_scripts/freesurfer/
addpath /autofs/cluster/transcend/scripts/MEG/Matlab_scripts/core_scripts/

%%
if ~exist('labeldir_tag','var')
    labeldir_tag='';
end

flagSignal=2;

subjects={'042201','AC022','AC070','AC054','AC056','048102','AC058','AC064','038301'};

gradReject=1000e-13;
magReject=3e-12;

grad=1:306;
mag=3:3:306;
grad(mag)=[];

jitter=0;
noiseLevel=0;
jitter_noise(1,:)=[0 0];
jitter_noise(2,:)=[0 0];
freq=15:20;
varAcrossFreq=rand(length(freq),1);

alllabel=label_names;

for isubj=1:8
    
    
     if nargin<8
        issptial_var.do = 0;
    end
    
    
    
    if issptial_var.do==1
        
        clear label_names;               
        
%         tt= load([sim_dir 'subIndex_subj_' num2str(isubj) '_discR_randLstg.mat']);
%         
%         label_names = tt.label_names;

label_names = alllabel;
        
        if issptial_var.random == 1
            indsub1=randperm(issptial_var.parts(issptial_var.iparts));
            indsub1 = indsub1(1:issptial_var.sub_num);
            
            indsub2=randperm(issptial_var.parts(issptial_var.iparts));
            indsub2 = indsub2(1:issptial_var.sub_num)+issptial_var.parts(issptial_var.iparts);
            
            indsub = [indsub1 indsub2];
        end
        
        if issptial_var.discont == 1
            
            % left STG random sub-ROI
            indsub1=randperm(issptial_var.parts(issptial_var.iparts));
            indsub1 = indsub1(1:issptial_var.sub_num);
            % right STG: discontinous sub-ROI
            var_subj = [1 2;2 2;3 2;4 2;5 2;1 3;2 3;3 3];
            
            indsub2=var_subj(isubj,1):var_subj(isubj,2):issptial_var.parts(issptial_var.iparts);
            indsub2 = indsub2(1:issptial_var.sub_num)+issptial_var.parts(issptial_var.iparts);
            
            indsub = [indsub1 indsub2];
            
            
            
        end
        
        label_names = label_names(indsub);
        
    end
    
    save([sim_dir 'sub_inds_subj' num2str(isubj) specific_tag '.mat'],'label_names','indsub')
    
    subj=subjects{isubj};
    
    label_dir=['/autofs/cluster/transcend/fahimeh/fmm/resources/Simulations2/labels/' labeldir_tag subj '/fsmorphedto_' subj '-'];
    
    fname_inv=['/autofs/cluster/transcend/MEG/fix/' subj '/1/' subj '_fix_0.1_144_calc-inverse_loose_ico4_weight_new_erm_megreg_0_new_MNE_proj-inv.fif'];
    inv = mne_read_inverse_operator(fname_inv);
    
    fwd=mne_read_forward_solution(['/autofs/cluster/transcend/MEG/fix/' subj '/1/' subj '_fix_1_ico4-fwd.fif'],1);
    
    for iLabel=1:length(label_names)
        
        label=[label_dir label_names{iLabel}];
        
        %addpath /autofs/cluster/transcend/sheraz/scripts/freesurfer/matlab
        labverts = read_label('',label);
        % Getting only the vertex numbers. Read the help for read_label.
        % Vertex numbers are zero based.
        labverts = 1+squeeze(labverts(:,1));
        
        [~,~,lsrcind] = intersect(labverts,inv.src(1).vertno);
        [~,~,rsrcind] = intersect(labverts,inv.src(2).vertno);
        
        if(strfind(label,'lh.'))
            srcind{iLabel} = lsrcind;
            
        elseif(strfind(label,'rh.'))
            srcind{iLabel} = inv.src(1).nuse + int32(rsrcind);
            
        end
        
        clear lsrcind rsrcind
        
        
    end
    
    
    
    filename1=['/autofs/cluster/transcend/MEG/fix/' subj '/1/' subj '_fix_1_144fil_raw.fif'];
    filename2=['/autofs/cluster/transcend/MEG/fix/' subj '/1/' subj '_fix_1_0.1_144fil_raw.fif'];
    
    if exist(filename1,'file')
        filen=filename1;
    elseif exist(filename2,'file')
        filen=filename2;
    else
        continue;
    end
    
    raw=fiff_setup_read_raw(filen);
    
    
    
    
    nEpochs=50;
    fs=raw.info.sfreq;
    time=-0.25:1/fs:.75;
    nTime=length(time);
    
    nEpochsR=150;
    ranStart=randperm(6000,1);
    [rest,T] = fiff_read_raw_segment(raw,ranStart+raw.first_samp,ranStart+raw.first_samp+nTime*nEpochsR-1,1:306);
    rest=rest-repmat(mean(rest,2),1,size(rest,2));
    rest=reshape(rest,306,nTime,nEpochsR);
    
    indgrej=find(squeeze(sum((sum(abs(rest(grad,:,:))>gradReject)),2)));
    indmrej=find(squeeze(sum((sum(abs(rest(mag,:,:))>magReject)),2)));
    
    indrej=[indgrej;indmrej];
    
    if ~isempty(indrej)
        rest(:,:,indrej)=[];
    end
    
    if size(rest,3)<nEpochs*2
        continue;
    else
        rest=rest(:,:,1:nEpochs*2);
    end
    
%     indperm=randperm(100);
%     
%     for icond=1:2
%         
%         indp=indperm((icond-1)*nEpochs+1:nEpochs*icond);
%         
%         restd=rest(:,:,indp);
        
         indperm=randperm(100);
    indperm2=randperm(100);
    
    
    for icond=1:2
        
        indp=indperm((icond-1)*nEpochs+1:nEpochs*icond);
        
        restd=rest(:,:,indp);
        
        indp2=indperm2((icond-1)*nEpochs+1:nEpochs*icond);
        
        restd2=rest(:,:,indp2);
        
        
        if icond==1
            
            cortex=zeros(inv.nsource,nTime,nEpochs,'single');
            
            tt=cell(1);
            for iLabel=1:length(label1)
                iLabel
                tt{iLabel}=genLabelData(freq,length(srcind{iLabel}),nEpochs,jitter,time,noiseLevel,varAcrossFreq,flagSignal);
                
            end
            for iLabel=1:length(label1)
                cortex(srcind{iLabel},:,:)=tt{iLabel};
            end
            
            
            
            tt=cell(1);
            tic
            for iLabel=length(label1)+1:length(srcind)
                
                tt{iLabel}=genLabelData(freq,length(srcind{iLabel}),nEpochs,jitter,time,noiseLevel,varAcrossFreq,flagSignal);
                
            end
            for iLabel=length(label1)+1:length(srcind)
                cortex(srcind{iLabel},:,:)=tt{iLabel};
            end
            toc
            
            
            cortex=(cortex./max(cortex(:))).*1e-8;
            
            cortex1=reshape(cortex,size(cortex,1),size(cortex,2)*size(cortex,3));
            data_cortex=fwd.sol.data*cortex1;
            data_cortex=reshape(data_cortex,306,nTime,nEpochs);
            
          %  d1=abs(SNR*data_cortex);
            
           d1=abs(SNR*data_cortex+noiseLevelr*restd2);
            d2=abs(restd); 
          %  d2=abs(restd/noiseLevelr);
            snr=median(d1(d1~=0))/median(median(median(d2)));
            
            
            
        else
            
            data_cortex=zeros(306,nTime,nEpochs);
            snr=0;
            
        end
        
        fprintf('no rest added')
        
      %  epoch_data=SNR*data_cortex+restd/noiseLevelr;
        
        epoch_data=SNR*data_cortex+noiseLevelr*restd2+restd;
        
        FREQ=round(logspace(0.79,1.7,15));
        
        timefreq=do_time_freq_sensor(epoch_data,fs,FREQ);
        
        tag=[num2str(jitter_noise(1,1)) '_' num2str(jitter_noise(1,2)) '_' num2str(jitter_noise(2,1)) '_' num2str(jitter_noise(2,2)) '_nr_' num2str(noiseLevelr) ...
            '_snr_' num2str(SNR) '_' specific_tag];
        
        
        filename=[sim_dir 'wholecortex_' tag '_cond' num2str(icond) '_subj' num2str(isubj)];
        
        do_source_coh(timefreq,FREQ,fname_inv,label_dir,label1,filename,icond,isubj,time,fs)
        
        
        clear epoch_data
        
        
    end
    
end



