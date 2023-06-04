clear;
clc;
%count = 0;
% INPUT parameters
% Bus data
% Bus No		P,MW		Q,MVAR		V_mag,PU	V_phase		
Bus1=   [1		 0.0		0.0			1.0			 0.0	;
         0          0       0           0               0;
         0          0       0           0               0;         
	 	 4       2.0     	1.6 		0.991		-0.370  ;
	 	 5       3.0     	0.4 		0.9888		-0.544  ;
	 	 6       2.0     	-0.4 		0.986		-0.697  ;
	 	 7       1.5     	1.2 		0.985		-0.704  ;
	 	 8       4.0     	2.7 		0.979		-0.763  ;
	 	 9       5.0     	0.8 		0.971		-1.451  ;
	 	 10      1.0     	0.9 		0.977		-0.770  ;
	 	 11      0.6     	-0.5		0.971		-1.525  ;
	 	 12      4.5     	-1.7 		0.969		-1.836  ;
	 	 13      1.0     	0.9 		0.994		-0.332  ;
	 	 14      1.0     	-1.1 		0.995		-0.459  ;
	 	 15      1.0     	0.9 		0.992		-0.527  ;
	 	 16      2.1     	-0.8		0.991		-0.596  ];
		   
% Branch data
%		Line	Bus		Bus	PU Branch 	PU Branch	
%		no:		1	    2	resistance	reactance	

Line=    [ 1      0      1       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
           0      0     0       0       0           ;
          11	 1		4 	 0.075   	0.1     	;
          12     4   	5 	 0.08    	0.11    	;
          13     4   	6 	 0.09    	0.18    	;
          14     6   	7 	 0.04    	0.04    	;
          15     5   	11 	 0.04    	0.04    	;
          16     1   	8 	 0.11    	0.11    	;
          17     8   	10	 0.11    	0.11    	;
          18     8   	9 	 0.08    	0.11    	;          
          19     9   	11	 0.11    	0.11    	;
          20     9   	12	 0.08    	0.11    	;
          21     10  	14	 0.04    	0.04    	;
          22     1   	13	 0.11    	0.11    	;
          23     13  	15	 0.08    	0.11    	;
          24     13  	14	 0.09    	0.12    	;          
          25     15  	16	 0.04    	0.04    	;     
	      26     7   	16 	 0.09    	0.12    	];
      
%    Loop data
%Loop  = [11 12 15	19	18	16 0 0 0 0 0 0; 16	17	21	24	22 0 0 0 0 0 0 0;   13 14 26 25 23 24 21 17 18 19 15 12];
Loop        = [11 12 15	19	18	16 0 0 0 0 0 0 0; 16	17	21	24	22 0 0 0 0 0 0 0 0;   13 14 26 25 23 24 21 17 18 19 15 12 20];
%Branch & possible parents
Parent =   [1   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            0   0   0   0   0   0;
            11  1   12  16  13  22;
            12  11  13  15  0   0 ;
            13  11  12  14  0   0;
            14  13  26  0   0   0;
            15  12  19  0   0   0;
            16  1   11  17  18  22;
            17  16  18  21  0   0;
            18  16  17  19  20  0;
            19  15  18  20  0   0;
            20  18  19  0   0   0;
            21  17  24  0   0   0;
            22  1   11  16  23  24;
            23  22  24  25  0   0;
            24  21  22  23  0   0;
            25  23  26   0  0   0;
            26  14  25  0   0   0];
        
% Capacitor bank data
Capacitor_bank=  [4 5 11 13 16 ];   %buses with capacitor banks
cap_list=[0.3 0.6 0.9 1.2 1.5 1.8];    % capacitor bank values
%cap_list=[900 1200 1500 1800];

root_branch = 1;                 %root branch

% Initializations
Bus1(:,2:3)   = Bus1(:,2:3)/100;
Bus=Bus1;
cap_list=cap_list./100;
sizeof_bus=size(Bus);
sizeof_line = size(Line);
sizeof_loop = size(Loop);
sizeof_parent = size(Parent);
sizeof_capacitor_bank=size(Capacitor_bank);
sizeof_cap_list=size(cap_list); 
n_node=sizeof_capacitor_bank(2);

c = max(Bus(:,1));
d = sort(c);
n_bus = d(end);   % maximum bus number


n_ant = 6;     % no. of ants 
n_stage = 3;    %Number of loops
Iter_max = 10;	% Maximum number of iterations
alpha =4; %5   %5          %1;	% Parameter representing the importance of trail
beta = 8 ;%10  %8         %5;	% Parameter representing the importance of visibility
rho = .5; %1   %1        %0.5;	% Evaporation
Q = 10 ; %10       %10;	% A constant

%Tie_open= [15 21 26];    %tie list
Tie_open=[19 17 26];

best_cap = zeros(Iter_max,n_node);  %best path of each iteration
pheromone_cap = ones(sizeof_cap_list(2)*n_node,sizeof_cap_list(2)*n_node,n_stage);    %pheromone content of paths from one stage to next
eta_cap = zeros(sizeof_cap_list(2)*n_node,sizeof_cap_list(2)*n_node,n_stage);   %inverse of power loss corresponding to the above

%*********************Iterations***************************
for iter_iter=0:Iter_max-1
%iter_iter
t=cputime;
req_node_old=[];
    %*********************Loops********************************
    for iter_stage=1:n_stage
%iter_stage         
        % nodes to which capacitors are to be connected
        req_node=[];
        Loop2=Loop(iter_stage,:);
        Loop1=[];
        for x=1:sizeof_loop(2)
            if Loop2(x)~=0
                Loop1=[Loop1,Loop2(x)];
            end
        end
        sizeof_loop1=size(Loop1);
%Loop1
        for x=1:sizeof_loop1(2)        %nodes having capacitor bank for each loop
            cap=find(Loop1(x)==Line(:,1));
            cap1=find(Line(cap,2)==Capacitor_bank);
            if cap1>0
                pos1=find(Line(cap,2)==req_node);
                if pos1>0
                    req_node=[req_node];
                else
                    req_node=[req_node,Line(cap,2)];
                end
            end
            cap2=find(Line(cap,3)==Capacitor_bank);
            if cap2>0
                pos2=find(Line(cap,3)==req_node);
                if pos2>0
                    req_node=[req_node];
                else
                    req_node=[req_node,Line(cap,3)];
                end
            end
        end
        sizeof_req_node=size(req_node);
%req_node
        % positions of required nodes in capacitor bank
        position=[];
        for i1=1:sizeof_req_node(2)
            pos=find(req_node(i1)==Capacitor_bank);
            position=[position,pos];
        end
        %all previous loop compensated nodes
        if iter_stage>1            
            for i=1:sizeof_req_node(2)                
                if req_node(i)~=req_node_old                    
                    req_node_old=[req_node_old,req_node(i)];                
                end
            end
        else           
            req_node_old=req_node;
        end
        req_node=[];
        req_node=req_node_old; 
         sizeof_req_node=size(req_node);
%req_node
        tabu_cap=zeros(n_ant,sizeof_capacitor_bank(2));
        % at required node 1 ants are placed randomly at each capacitor value
        rand_order1=[];
        for i2=1:ceil(n_ant/sizeof_cap_list(2))  %randomly positioning each ant at the first node of a loop
            rand_order1=[rand_order1,randperm(sizeof_cap_list(2))];
        end
        rand_order=rand_order1(1:n_ant);
        for i2=1:length(rand_order)
            rand_position(i2)=cap_list(rand_order(i2));
        end
        %pos_1=find(req_node(1)==Capacitor_bank);
        tabu_cap(:,1)=(rand_position(1:n_ant))';
        Bus2=Bus;
        %**********************Nodes*******************************
        for iter_node=2:sizeof_req_node(2)
            pos_node=find(req_node(iter_node)==Capacitor_bank);
            %***********************Ants*******************************
            for iter_ant=1:n_ant
%iter_ant 
                pos_node_old=find(req_node(iter_node-1)==Capacitor_bank);
                cap_opened=tabu_cap(iter_ant,1:iter_node-1); %already opened capacitor values of previous nodes             
                probability=zeros(1,sizeof_cap_list(2));
                pos_cap_old=find(cap_opened(end)==cap_list);
                eta_pos1=pos_node_old*sizeof_cap_list(2)-(sizeof_cap_list(2)-pos_cap_old);
                %***********************Capacitor switches*****************
                for iter_cap=1:sizeof_cap_list(2)
                    cap_opened(iter_node)=cap_list(iter_cap); 
                    for i=1:iter_node
                        node=find(req_node(i)==Bus(:,1));
                        Bus2(node,3)=Bus(node,3)-cap_opened(iter_node);
                    end
                    pos_cap=find(cap_list(iter_cap)==cap_list);
                    %[order_loop,continuous] = order(Bus2,Line,Loop,Parent,Tie_open,iter_stage);
                    [order_loop,continuous] = order_voltage(Bus2,Line,Loop,Parent,Tie_open,iter_stage);
                    %[Total_powerloss_system] = powerloss(Bus2,Line,order_loop,iter_stage);
                    [Total_powerloss_system,voltage_system] = powerloss_voltage(Bus2,Line,order_loop,iter_stage);
                    eta_pos2=pos_node*sizeof_cap_list(2)-(sizeof_cap_list(2)-pos_cap);
                    eta_cap(eta_pos1,eta_pos2,iter_stage)=1.0/Total_powerloss_system;
                    probability(iter_cap)=(pheromone_cap(eta_pos1,eta_pos2,iter_stage))^alpha*(eta_cap(eta_pos1,eta_pos2,iter_stage))^beta;
                end %iter_cap
                probability=probability/sum(probability);% normalized probability of each capacitor in the bus capacitor bank
                pcum=cumsum(probability);
                select=find(pcum>=rand);
                to_add=cap_list(select(1));
                tabu_cap(iter_ant,iter_node)=to_add;
%tabu_cap
            end %iter_ant
        end %iter_node
        Bus2=Bus;        
        for i2=1:n_ant  %calculating powerloss with the selected capacitor values at every nodes
            Bus3=Bus;
            for j2=1:sizeof_req_node(2)
                node_1=find(req_node(j2)==Bus(:,1));
                pos_2=find(req_node(j2)==Capacitor_bank);
                Bus3(node_1,3)=Bus(node_1,3)-tabu_cap(i2,pos_2);
            end            
            [order_loop,continuous] = order_voltage(Bus3,Line,Loop,Parent,Tie_open,iter_stage);
            [Total_powerloss_system,voltage_system] = powerloss_voltage(Bus3,Line,order_loop,iter_stage);
            total_loss(i2)=Total_powerloss_system;            
        end
        loss_min(iter_iter+1)=min(total_loss); 
    cap_placement(:,:)=tabu_cap(:,:);
    best_position=find(total_loss==loss_min(iter_iter+1));
    best(iter_iter+1,:)=cap_placement(best_position(end),:);
    loss_average(iter_iter+1)=mean(total_loss);
    
    delta_pheromone=zeros(sizeof_cap_list(2)*n_node,sizeof_cap_list(2)*n_node,n_stage);
    for i_1=1:n_ant
        for j_1=1:(sizeof_req_node(2)-1)
            x1=find(req_node(j_1)==Capacitor_bank);
            x2=find(cap_placement(i_1,x1)==cap_list);
            x3=find(req_node(j_1+1)==Capacitor_bank);
            x4=find(cap_placement(i_1,x3)==cap_list);
            delta_pheromone(x1*sizeof_cap_list(2)-(sizeof_cap_list(2)-x2),x3*sizeof_cap_list(2)-(sizeof_cap_list(2)-x4),iter_stage)=delta_pheromone(x1*sizeof_cap_list(2)-(sizeof_cap_list(2)-x2),x3*sizeof_cap_list(2)-(sizeof_cap_list(2)-x4),iter_stage)+Q/total_loss(i_1);
        end
    end
    pheromone_cap=(1-rho).*pheromone_cap+delta_pheromone;
    tabu_list=zeros(n_ant,n_node);    
    end %iter_stage 
    time= cputime-t;
end %iter_iter
Bus4=Bus;
for j=1:sizeof_capacitor_bank(2)
    node_final=find(Capacitor_bank(j)==Bus(:,1));                
    Bus4(node_final,3)=Bus(node_final,3)-best(Iter_max,j);
end
[order_loop,continuous] = order_voltage(Bus4,Line,Loop,Parent,Tie_open,iter_stage);
[Total_powerloss_system,voltage_system] = powerloss_voltage(Bus4,Line,order_loop,iter_stage);
best
loss_min
best_solution=best(Iter_max,:)
total_loss_system=Total_powerloss_system
%total_loss
time

figure(1)
set(gcf,'Name','Ant Colony Optimization！！Figure of loss_min','Color','w')
plot(loss_min,'r','LineWidth',2)
set(gca,'Color','w')
%hold on
%plot(loss_average,'k')
xlabel('Iterations')
ylabel('Min powerloss')
title('Powerloss')


%Original=[0.9951;0.9951;0.9951;0.9912;0.9888;0.9861;0.9850;0.9777;0.9710;0.9770;0.9710;0.9690;0.9944;0.9950;0.9915;0.9910];
Original= [0.9912; 0.9912; 0.9912; 0.9824; 0.9710; 0.9861; 0.9850; 0.9777; 0.9708; 0.9770; 0.9710; 0.9690; 0.9868; 0.9778; 0.9915; 0.9910];
%Original=Original.*23000;
New=voltage_system(:,2)     %'.*23000;
%Total_powerloss_system;
figure(3)
set(gcf,'Name','Voltage_Profile！！Original ang New Voltages','Color','w')
plot(Original,'k','LineWidth',2)
set(gca,'Color','w')
hold on
plot(New,'r','LineWidth',2)
axis([1 16 0.9 1.1])
xlabel('Nodes')
ylabel('Voltage')
title('Voltage_Profile')


   