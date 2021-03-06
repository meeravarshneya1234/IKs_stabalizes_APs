function X_Heijman = FigureS5Heijman()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- "Slow delayed rectifier current protects ventricular myocytes from
% arrhythmic dynamics across multiple species: a computational study" ---%

% By: Varshneya,Devenyi,Sobie 
% For questions, please contact Dr.Eric A Sobie -> eric.sobie@mssm.edu 
% or put in a pull request or open an issue on the github repository:
% https://github.com/meeravarshneya1234/IKs_stabilizes_APs.git. 

%--- Note:
% Results displayed in manuscript were run using MATLAB 2016a on a 64bit
% Intel Processor. For exact replication of figures it is best to use these
% settings.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
                            %% -- FigureS5Heijman.m -- %%
% Description: Runs the Heijman model simulation. 

% Outputs:
% --> X_Heijman - outputs the APDs, time, voltage, and state variables 

%---: Functions required to run this script :---%
% mainHRdBA.m - runs Heijman model simulation (downloaded code online)
%--------------------------------------------------------------------------
%% 
%---- Set up settings ----%
settings.PCL = 1000;
settings.freq =2;
settings.storeLast = 2; % save both beats 99 and 100
settings.stimdur = 2;
settings.Istim = -36.7;
settings.showProgress = 0;

iso_concs = 0;
settings.SS = 1;

% blocking PKA targets - 1 = no block; 0 = block 
flags.ICaL = 1; flags.IKs = 1; flags.PLB = 1; flags.TnI = 1; flags.INa = 1;
flags.INaK = 1; flags.RyR = 1; flags.IKur = 1;

for ii = 1:length(iso_concs)
    settings.ISO = iso_concs(ii);
    
    [currents,State,Ti,APDs,settings]=mainHRdBA(settings,flags);
    
    str = ['ISO_' num2str(iso_concs(ii))];
    
    X_Heijman.(str).APDs = APDs;
    X_Heijman.(str).times = Ti;
    X_Heijman.(str).V =  State(:,1);
    X_Heijman.(str).statevars =  State;
    X_Heijman.(str).currents = currents;       
   
    % plot figure 
    V = State(:,1);
    IKs = currents.iks; 
    IKr = currents.ikr; 
    
    figure
    subplot(1,2,1)
    plot(Ti,V,'linewidth',2)
    xlim([900,2000]) % adding the "time delay" in each plot
    xlabel('Time (ms)','FontSize',12,'FontWeight','bold')
    ylabel('Voltage (mV)','FontSize',12,'FontWeight','bold')
    set(gcf,'Position',[20,20,600,300])
    
    
    subplot(1,2,2)
    plot(Ti,IKs,'linewidth',2,'color','b')
    hold on
    plot(Ti,IKr,'linewidth',2,'color','r')
    xlabel('Time (ms)','FontSize',12,'FontWeight','bold')
    xlim([900,2000])% adding the "time delay" in each plot
    set(gcf,'Position',[20,20,600,300])
    mtit('Heijman','fontsize',14);

    
    % get information about the last AP (beat 100)
    stop = length(Ti); %beginning of AP
    start = find(Ti(end)-settings.bcl==Ti,1,'last'); % end of AP
    
    Tlast = Ti(start:stop); 
    Vlast = State(start:stop,1);
    ICaL_last = currents.ical(start:stop,1);
    IKs_last = currents.iks(start:stop,1);
    IKr_last = currents.ikr(start:stop,1);
    [~,indV] = max(Vlast);
    x2 = find(floor(Vlast)==floor(Vlast(1)) & Tlast > Tlast(indV),1); % and ends
    
    X_Heijman.(str).Area_Ca = trapz(Tlast(1:x2),ICaL_last(1:x2));
    X_Heijman.(str).Area_Ks = trapz(Tlast(1:x2),IKs_last(1:x2));
    X_Heijman.(str).Area_Kr = trapz(Tlast(1:x2),IKr_last(1:x2));
    X_Heijman.(str).IKs_Fraction = X_Heijman.(str).Area_Ks/(X_Heijman.(str).Area_Kr+X_Heijman.(str).Area_Ks);   

end
