%% erik reed
% set(gcf,'Position', [100 100 350 300]);
% set(gcf,'PaperPosition', [100 100 350 300]);
% set(gcf,'Position', [1500 100 350 275]);
set(gcf,'PaperPositionMode','auto')
print(gcf,'-dpng','-r300','C:\Users\Erik\Desktop\phd_stuff\papers\cool_figures\unstable')

%% plot parameter interactions
clear all
close all
hold all
for i=1:15
    filenum=ceil(rand()*50-1);
    fprintf('file %i\n',filenum)
    trial = importdata(num2str(filenum));
    lhood = trial.data(:,2);
    err = trial.data(:,3);
    iter = trial.data(:,1);
    plot(lhood,err,'-*')
end
xlabel('log-likelihood')
ylabel('error')
set(gcf,'position', [100 100 350 300]);
% snazzyFig(gcf)

%% plot histograms
clear all
close all
fprintf('dir: %s\n',pwd);
err = zeros(1,49)';
lhood = zeros(1,49)';
iter = zeros(1,49)';
parfor i=1:49
%     fprintf('file %i\n',i)
   trial = importdata(num2str(i)); 
   lhood(i) = trial.data(end,2);
   err(i) = trial.data(end,3);
   iter(i) = trial.data(end,1);
end
fprintf('iter mean: %f\n',mean(iter))
fprintf('iter std: %f\n',std(iter))
fprintf('lhood mean: %f\n',mean(lhood))
fprintf('lhood std: %f\n',std(lhood))
fprintf('err mean: %f\n',mean(err))
fprintf('err std: %f\n',std(err))
hist(err,20)
xlabel('error')
ylabel('frequency')
xlim([10 60])
% set(gcf,'position', [100 100 466 317]);
set(gcf,'position', [100 100 350 300]);
% use in the results folder
%% run
close all
clear all

MARKER_TYPE = ['+','o','*','.','x','s','d','^','v','>','<'];

ONLY_PLOT_SOME_BNETS = true;
BNETS_TO_PLOT = [{'alarm'}];

ONLY_PLOT_SOME_SAMPLES = false;
MIN_SAMPLES = -1;
MAX_SAMPLES = intmax;

ONLY_PLOT_SOME_HIDDEN = false;
MIN_HIDDEN = -1;
MAX_HIDDEN = intmax;

CPT_PLOT_SAMPLES = log2(800);

listing1 = dir;

for i=3:length(listing1)
    if listing1(i).isdir
        bn_name = listing1(i).name;
        if strcmp(bn_name,'cpt_counts') || listing1(i).name(1) == '.'
            continue;
        end
        if ONLY_PLOT_SOME_BNETS
            for bnet_i=1:length(BNETS_TO_PLOT)
                if sum(strcmp({listing1.name}',...
                        BNETS_TO_PLOT(bnet_i)))>=1
                    break
                end
                   continue
            end
        end
        bn_name = strrep(bn_name, '_', '\_');
        listing2 = dir(listing1(i).name);
        currentdir = listing1(i).name;
        
        %         figure
        figure((i-1)*3)
        subplot(3,1,1)
        hold all
        %         xlabel('Number of samples');
        ylabel('Number of iterations');
        title(strcat('Net: ',bn_name));
        
        subplot(3,1,2)
        hold all
        %         xlabel('Number of samples');
        ylabel('Log-likelihood');
        
        subplot(3,1,3)
        hold all
        xlabel('Log_2 Number of samples');
        ylabel('Error (L2 norm)');
        
        figure((i-1)*3+1)
        subplot(3,1,1)
        hold all
        %         xlabel('Number of samples');
        ylabel('Number of iterations');
        title(strcat('Net: ',bn_name));
        
        subplot(3,1,2)
        hold all
        %         xlabel('Number of samples');
        ylabel('Log-likelihood');
        
        subplot(3,1,3)
        hold all
        xlabel('Number of hidden nodes');
        ylabel('Error (L2 norm)');
        
        figure((i-1)*3+2)
        subplot(3,1,1)
        hold all
        %         xlabel('Number of samples');
        ylabel('Number of iterations');
        title(strcat('Net: ',bn_name, ', samples: ', round(2^CPT_PLOT_SAMPLES)));
        
        subplot(3,1,2)
        hold all
        %         xlabel('Number of samples');
        ylabel('Log-likelihood');
        
        subplot(3,1,3)
        hold all
        xlabel('CPT parameters (num\_parents or CPT entries)');
        ylabel('Error (L2 norm)');
        
        %         subplot(4,1,4)
        %         hold all
        %         xlabel('Log-likelihood');
        %         ylabel('Error (L2 norm)');
        
        legendNames = cell(length(listing2)-2,1);
        legendNames2 = [];
        
        %shared
        num_hidden_s = [];
        num_hidden_s_data = [];
        %hidden
        num_hidden_h = [];
        num_hidden_h_data = [];
        
        for j=3:length(listing2)
            if listing2(j).isdir
                currentdir2 = strcat(currentdir, '\', listing2(j).name);
                fprintf(strcat(strrep(currentdir2,'\','\\'),'\n'))
                shared_num = listing2(j).name(2:end);
                if (listing2(j).name(1)) == 's'
                    currentType = 's';
                    num_hidden_s = [num_hidden_s str2double(shared_num)];
                    legendNames(j-2) = cellstr(strcat(shared_num,', sharing'));
                elseif (listing2(j).name(1)) == 'h'
                    currentType = 'h';
                    num_hidden_h = [num_hidden_h str2double(shared_num)];
                    legendNames(j-2) = cellstr(strcat(shared_num,', no\_sharing'));
                else
                    currentType = 'unknown';
                    legendNames(j-2) = cellstr(strcat('unknown, ',shared_num));
                    fprintf 'unfamiliar prefix\n'
                    continue
                end
                listing3 = dir(strcat(currentdir2, '\', 'rand_trials'));
                % stores mean, std
                num_iters = zeros(length(listing3)-2,2);
                num_samples = zeros(length(listing3)-2,1);
                num_likelihood  = zeros(length(listing3)-2,2);
                num_error = zeros(length(listing3)-2,2);
                
                for k=3:length(listing3)
                    if listing3(k).isdir
                        currentdir3 = strcat(currentdir2, '\rand_trials\', listing3(k).name);
                        sample_num = listing3(k).name(2:end);
                        
                        num_samples(k-2) = str2double(sample_num);
                        runs_listing = dir(strcat(currentdir3));
                        num_iters_run = zeros(length(runs_listing)-2,1);
                        num_iters_err = zeros(length(runs_listing)-2,1);
                        num_iters_l = zeros(length(runs_listing)-2,1);
                        for runfile=3:length(runs_listing)
                            filepath = strcat(currentdir3,'\',runs_listing(runfile).name);
                            tmp = importdata(filepath);
                            data = tmp.data;
                            num_iters_run(runfile-2) = data(end,1);
                            num_iters_l(runfile-2) = data(end,2);
                            num_iters_err(runfile-2) = data(end,3);
                        end
                        asd = num_iters_l

                        num_iters(k-2,1) = mean(num_iters_run);
                        num_iters(k-2,2) = std(num_iters_run);
                        num_likelihood(k-2,1) = mean(num_iters_l);
                        num_likelihood(k-2,2) = std(num_iters_l);
                        num_error(k-2,1) = mean(num_iters_err);
                        num_error(k-2,2) = std(num_iters_err);
                    end
                end
                num_samples = log2(num_samples);
                [num_samples,i2]=sort(num_samples);
                if currentType=='h'
                    num_hidden_h_data = [num_hidden_h_data,
                        [{num_samples},{num_iters(i2,1)},{num_iters(i2,2),...
                        num_likelihood(i2,1),num_likelihood(i2,2),...
                        num_error(i2,1),num_error(i2,2)}]];
                end
                if currentType=='s'
                    num_hidden_s_data = [num_hidden_s_data,
                        [{num_samples},{num_iters(i2,1)},{num_iters(i2,2),...
                        num_likelihood(i2,1),num_likelihood(i2,2),...
                        num_error(i2,1),num_error(i2,2)}]];
                end
                % figure w/ num_samples x-axis
                marker_index = mod(j+1,length(MARKER_TYPE))+1;
                lineStyle = strcat(':', MARKER_TYPE(marker_index));
                if currentType == 'h'
                    lineStyle = strcat('--', MARKER_TYPE(marker_index));
                end
                figure((i-1)*3)
                
                subplot(3,1,1)
                hold all
                errorbar(num_samples,num_iters(i2,1),num_iters(i2,2), lineStyle);
                hold all
                subplot(3,1,2)
                errorbar(num_samples,num_likelihood(i2,1),num_likelihood(i2,2), lineStyle);
                hold all
                subplot(3,1,3)
                errorbar(num_samples,num_error(i2,1),num_error(i2,2), lineStyle);
                %
                %                 subplot(4,1,4)
                %                 errorbar(num_likelihood(:,1),num_error(:,1),num_error(:,2), '*');
            end
        end
        figure((i-1)*3+1)
        allData = cell2mat(num_hidden_s_data);
        allDataH = cell2mat(num_hidden_h_data);
%         cpt_data = importdata(strcat('cpt_counts\',listing1(i).name,'.csv'));
        % num_hidden,cpt_size,num_parents
%         cpt_data = cpt_data.data;
cpt_data = 1:4;
        [tmp,i4]=sort(cpt_data(:,1));
        cpt_data = cpt_data(i4,:); % sort in ascending order
        % total CPT size / number of parents
        %         cpt_data_ratio = cpt_data(end-length(num_hidden_h)+1:end,2) ...
        %             ./cpt_data(end-length(num_hidden_h)+1:end,3);
%         cpt_data_ratio = cpt_data(end-length(num_hidden_h)+1:end,2);
cpt_data_ratio = 1;        

        % for each number of samples (of shared)
        for ij = 1:length(num_samples)
            % collect data
            % note this value numXpoints should divide evenly
            numXpoints = length(num_hidden_s_data)/length(num_samples);
            numSamplesStr = num2str(round(2^num_samples(ij)));
            
            samplesIndicies = cell2mat(num_hidden_s_data(:,1)) == num_samples(ij);
            nSamplesData = allData(samplesIndicies,:);
            
            marker_index = mod(ij,length(MARKER_TYPE));
            
            figure((i-1)*3+1)
            % shared
            [tmp_numHidden,i3]=sort(num_hidden_s);
            legendNames2 = [legendNames2; cellstr(strcat(numSamplesStr,'s'))];
            
            [tmp_numHidden' nSamplesData(i3,2) nSamplesData(i3,4)]
            
            % print stats
            itrmean = corr(tmp_numHidden',nSamplesData(i3,2));
            itrstd = corr(tmp_numHidden',nSamplesData(i3,3));
            lrmean = corr(tmp_numHidden',nSamplesData(i3,4));
            lrstd = corr(tmp_numHidden',nSamplesData(i3,5));
            errmean = corr(tmp_numHidden',nSamplesData(i3,6));
            errstd = corr(tmp_numHidden',nSamplesData(i3,7));
            
%             fprintf('r-values (%s samples)\n',numSamplesStr)
%             fprintf('iters mean,std, lhood mean,std, error mean,std\n');
%             fprintf('%s,%f,%f,%f,%f,%f,%f\n', numSamplesStr,...
%                 itrmean,itrstd, lrmean,lrstd,errmean,errstd)
            
            
            subplot(3,1,1)
            hold all
            ebl = errorbar(tmp_numHidden,nSamplesData(i3,2),nSamplesData(i3,3),...
                strcat(':',MARKER_TYPE(marker_index)));
            
            subplot(3,1,2)
            hold all
            errorbar(tmp_numHidden,nSamplesData(i3,4),nSamplesData(i3,5),...
                strcat(':',MARKER_TYPE(marker_index)));
            
            subplot(3,1,3)
            hold all
            errorbar(tmp_numHidden,nSamplesData(i3,6),nSamplesData(i3,7),...
                strcat(':',MARKER_TYPE(marker_index)));
            
            % CPT figure
            if num_samples(ij) == CPT_PLOT_SAMPLES
                [tmp_numHidden,i3]=sort(num_hidden_h);
                if ~isequal(cpt_data(end-length(num_hidden_h)+1:end,1),num_hidden_h(i3)')
%                     error('CPT file does not match!')
                        fprintf('WARNING: CPT figure will be broken \n')
                end
                figure((i-1)*3+2)
                subplot(3,1,1)
                hold all
                errorbar(cpt_data_ratio,nSamplesData(i3,2),nSamplesData(i3,3), '*');
                subplot(3,1,2)
                hold all
                errorbar(cpt_data_ratio,nSamplesData(i3,4),nSamplesData(i3,5), '*');
                subplot(3,1,3)
                hold all
                errorbar(cpt_data_ratio,nSamplesData(i3,6),nSamplesData(i3,7), '*');
            end
            % End of CPT figure
            ebl_color = get(ebl, 'Color');
            
            
            % non-shared
            samplesIndicies = cell2mat(num_hidden_h_data(:,1)) == num_samples(ij);
            nSamplesData = allDataH(samplesIndicies,:);
            
            % plot num_parents vs. iter
            %             errorbar(cpt_data(1:length(num_hidden_h),3), ...
            %                nSamplesData(i3,2),nSamplesData(i3,3), '*');
            
            figure((i-1)*3+1)
            legendNames2 = [legendNames2; cellstr(strcat(numSamplesStr,'h'))];
            subplot(3,1,1)
            hold all
            errorbar(tmp_numHidden,nSamplesData(i3,2),nSamplesData(i3,3), ...
                strcat('--',MARKER_TYPE(marker_index)), ...
                'color',ebl_color);
            
            subplot(3,1,2)
            hold all
            errorbar(tmp_numHidden,nSamplesData(i3,4),nSamplesData(i3,5), ...
                strcat('--',MARKER_TYPE(marker_index)), ...
                'color',ebl_color);
            
            subplot(3,1,3)
            hold all
            errorbar(tmp_numHidden,nSamplesData(i3,6),nSamplesData(i3,7), ...
                strcat('--',MARKER_TYPE(marker_index)), ...
                'color',ebl_color);
            
            % CPT begin
            if num_samples(ij) == CPT_PLOT_SAMPLES
                figure((i-1)*3+2)
                subplot(3,1,1)
                hold all
                errorbar(cpt_data_ratio,nSamplesData(i3,2),nSamplesData(i3,3), '*', ...
                    'color',ebl_color);
                
                subplot(3,1,2)
                hold all
                errorbar(cpt_data_ratio,nSamplesData(i3,4),nSamplesData(i3,5), '*', ...
                    'color',ebl_color);
                
                subplot(3,1,3)
                hold all
                errorbar(cpt_data_ratio,nSamplesData(i3,6),nSamplesData(i3,7), '*', ...
                    'color',ebl_color);
            end
            % CPT end
        end
        
        
        %         subplot(3,1,1)
        %         hold all
        %         plot(cpt_data(:,1),cpt_data(:,3),':')
        %         plot(cpt_data(:,1),cpt_data(:,2),':')
        
        
        figure((i-1)*3)
        subplot(3,1,1)
        if min(num_samples) ~= max(num_samples)
            xlim([min(num_samples),max(num_samples)])
        end
        snazzyFig(gcf);
        
        subplot(3,1,2)
        legend(legendNames);
        if min(num_samples) ~= max(num_samples)
            xlim([min(num_samples),max(num_samples)])
        end
        snazzyFig(gcf);
        
        subplot(3,1,3)
        if min(num_samples) ~= max(num_samples)
            xlim([min(num_samples),max(num_samples)])
        end
        snazzyFig(gcf);
        
        %         subplot(4,1,4)
        %         xlim([min(num_likelihood(:,1)),max(num_likelihood(:,1))])
        %         subplot(3,1,2)
        %         legend(legendNames);
        %         subplot(3,1,3)
        %         legend(legendNames);
        print('-dpng', listing1(i).name)
        saveas(gcf, listing1(i).name, 'fig')
        
        figure((i-1)*3+1)
        subplot(3,1,1)
        if min(num_hidden_s) ~= max(num_hidden_s)
            xlim([min(num_hidden_s),max(num_hidden_s)])
        end
        snazzyFig(gcf);
        
        subplot(3,1,2)
        legend(legendNames2);
        if min(num_hidden_s) ~= max(num_hidden_s)
            xlim([min(num_hidden_s),max(num_hidden_s)])
        end
        snazzyFig(gcf);
        
        subplot(3,1,3)
        if min(num_hidden_s) ~= max(num_hidden_s)
            xlim([min(num_hidden_s),max(num_hidden_s)])
        end
        snazzyFig(gcf);
        
        print('-dpng', strcat(listing1(i).name,'2'))
        saveas(gcf, strcat(listing1(i).name,'2'), 'fig')
        
        figure((i-1)*3+2)
        subplot(3,1,2)
        legend('shared','hidden');
        snazzyFig(gcf);
        print('-dpng', strcat(listing1(i).name,'3'))
        saveas(gcf, strcat(listing1(i).name,'3'), 'fig')
        
        close all
    end
end

%%