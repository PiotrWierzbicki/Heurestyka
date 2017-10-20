%NEFAILSIMEX szybki symulator awarii sieci
% parametry netfailsimex(json,N,udtype,ddtype,policy,scale)
% json konfiguracja sieci w formcie json 
% 	N - liczba symulacji
% 	udtype rozklad pomiedzy awariami 1 Exp, 2 Weib
% 	ddtype rozk³ad czasu naprawy 	1 Exp, 2 Weib, 3 Par, 4 LogNorm
% 	policy polityka kompensacji 1 avail, 2 cont, 3 thre 4 LinearCost snoball 5 FixedRestartCost 6 Snowball
% 	scale parametr skali czasu
% 	
% Fukcje polityi kompensacji kara=sum(f(x)), x to czas awarii
% 	Thre x>thr ? x : 0.0;
% 	Avail x
% 	Cont 1
% 	LinearCost demand*x
% 	FixedRestartCost demand*x + thr*demand
% 	Snowball demand/thr*x^2
% 	
% przyk³ad konfiguracji:
% {
% 	"components":[
% 		{"ulambda":7.820405e-07, "dpa":4.000000e+00, "dpb":1.475548e+02,  "sbppLimit":7.600000e+01,  "sbplLimit":7.600000e+01,  "uwa":1.000000e+00,  "uwb":1.278706e+06, "dlambda":5.079627e-03, "dwa":2.511332e+00, "dwb":2.181778e+02, "dlm":5.244149e+00, "dls":2.498652e-01},
% 		{"ulambda":1.208990e-06, "dpa":4.000000e+00, "dpb":2.281114e+02,  "sbppLimit":7.600000e+01,  "sbplLimit":1.020000e+02,  "uwa":1.000000e+00,  "uwb":8.271366e+05, "dlambda":3.288938e-03, "dwa":2.524439e+00, "dwb":3.370920e+02, "dlm":5.679457e+00, "dls":2.496830e-01},
% 	],
% 	"slas":[
% 	{
% 		"path":[1],
% 		"backupPath":[3,5],
% 		"linkBackup":[[3,5]],
% 		"demand":52.000000,
% 		"useSBPP":1,
% 		"useSBLP":1
% 	},
% 	{
% 		"path":[2,8],
% 		"backupPath":[1,4,7],
% 		"linkBackup":[[1,4,7],[1,4,7]],
% 		"demand":18.000000,
% 		"useSBPP":1,
% 		"useSBLP":1
% 	}
% 	]
% }
