clear all; clc; close all;
global_setup

data_split = 'Dev';

% Window sizes to test
Win_len = 2.^(9:13);
Nwin = length(Win_len);

% Initial kappa array
J = 4;
Nsongs = get_nsongs(data_split);
kappa = zeros(J,Nwin, Nsongs);

% Loop over songs and window sizes
for ind=1:Nsongs
    for n=1:Nwin
      clc; fprintf('song %d / %d \n win length %d / %d \n',ind,Nsongs,n,Nwin);
      Nw = Win_len(n);
      Nfft = Nw;
      hop = Nfft/4;
    
      % Load the data
      [~,~,Sm] = get_data_DSD(dataset_path,data_split,ind,Fs,Nfft,Nw,hop);
      
      % Estimate kappa
      for j=1:J
          kappa(j,n,ind) = estim_kappa_vm(Sm(:,:,j),Nfft,hop);
      end
      
    end
end

% Record results
save(strcat(out_path, 'vm_kappa_dev.mat','kappa','Win_len'));
