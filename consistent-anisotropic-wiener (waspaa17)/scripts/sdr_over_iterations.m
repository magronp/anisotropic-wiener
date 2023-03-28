% Get the SDR over iterations for CW and CAW

clc; clear all; close all;
test_or_dev = 'Test';
scenario = 'oracle';
set_settings_caw;

% Score
SDR = zeros(max_iter+1,2,Nsongs);

% loop over the songs
for ind=1:Nsongs
    clc; fprintf('Iteration %d / %d \n',ind,Nsongs)
    
    % Load data
    num_piece = datavec(ind);
    [sm_aux,x,Sm_aux,X] = get_data_DSD(dataset_path,test_or_dev,num_piece,Fs,Nfft,Nw,hop);
    [F,T] = size(X);
    
    % Reshape the data so its music accompaniment + singing voice
    J=2;
    sm = [sm_aux(1,:)+sm_aux(2,:)+sm_aux(3,:) ; sm_aux(4,:)];
    Sm(:,:,1) = Sm_aux(:,:,1)+  Sm_aux(:,:,2)+ Sm_aux(:,:,3);
    Sm(:,:,2) = Sm_aux(:,:,4);
    clear sm_aux; clear Sm_aux;
    

    % Variances (oracle or informed scenario)
    V=abs(Sm);
    switch scenario
        case 'oracle'
            variances = V.^2;
        case 'informed'
            variances = zeros(F,T,J);
            for j=1:J
                [waux,haux] = NMF(V(:,:,j),rand(F,K),rand(K,T),iter_nmf,1,0);
                variances(:,:,j) = (waux*haux).^2;
            end
    end
    
    % Separation
    
    % Initial filters
    X_w = variances ./ (sum(variances,3)+eps) .* repmat(X,[1 1 J]);
    X_aw = anisotropic_wiener(X,variances,kappa_caw*ones(F,T,J),hop);
    
    % Consistent Wiener filtering
    [~,~,aux] = caw(X_w,variances,0,delta_caw,Nw,hop,wtype,0,max_iter,sm);
    aux = mean(aux{1},1);
    SDR(:,1,ind) = squeeze(aux(1,1,:));
   
     % Consistent anisotropic Wiener filtering
    [~,~,aux] = caw(X_aw,variances,kappa_caw,delta_caw,Nw,hop,wtype,0,max_iter,sm);
    aux = mean(aux{1},1);
    SDR(:,2,ind) = squeeze(aux(1,1,:));
    
end

% Record scores
save(strcat(metrics_path,'sdr_over_iter_',scenario,'.mat'),'SDR');

% Plot results
sdr = mean(SDR,3);
figure;
plot(0:max_iter,sdr(1,1)*ones(1,max_iter+1),'b--',0:max_iter,sdr(:,1),'b-*',0:max_iter,sdr(1,2)*ones(1,max_iter+1),'r-.',0:max_iter,sdr(:,2),'r-o'); hold on;
plot(0:max_iter,sdr(1,end)*ones(1,max_iter+1),'k-');
xlabel('Iterations','fontsize',16); ylabel('SDR (dB)','fontsize',16);
ha=legend('Wiener','CW','AW','CAW'); set(ha,'fontsize',14);
