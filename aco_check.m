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


%Tie_open= [15 21 26];   %tie list
Tie_open= [19 17 26];

[order_loop,continuous] = order_voltage(Bus,Line,Loop,Parent,Tie_open,3);
[Total_powerloss_system,voltage_system] = powerloss_voltage(Bus,Line,order_loop,3);

Voltage=voltage_system(:,2)     %'.*23000;
% [15 21 26]-----[0.9951 0.9951 0.9951 0.9912 0.9888 0.9861 0.9850 0.9777 0.9710 0.9770 0.9710 0.9690 0.9944 0.9950 0.9915 0.9910]
 %[19 17 26]-----[0.9912 0.9912 0.9912 0.9824 0.9710 0.9861 0.9850 0.9777 0.9708 0.9770 0.9710 0.9690 0.9868 0.9778 0.9915 0.9910]  