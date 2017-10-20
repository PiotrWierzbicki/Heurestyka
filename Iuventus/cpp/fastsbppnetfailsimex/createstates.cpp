#include"stdafx.h"
#include <mex.h>
#include<matrix.h>

#include "components.h"

using namespace std;
namespace{
	//double lambda = 3.18e-7;
	//double alpha=2.3;
	//double alpha_i = 1.0/alpha;
	//double beta=60;

	double tmax = 12*30*24*3600;//rok
	//double tmax =  30*24 * 3600;//rok
}

std::vector<unsigned int> mxArray2vector(const mxArray * array)
{
	size_t cols =  mxGetN(array);
	cout << cols <<endl;
	double* data = mxGetPr(array);
	vector<unsigned int> ret;
	for(int i=0; i< cols; i++)
	{
		//cout<<data[i] <<endl;
	    ret.push_back((unsigned int)data[i]);
	}
	
	
	
	return ret;
}

void mexFunction(
                 int          nlhs,
                 mxArray      *plhs[],
                 int          nrhs,
                 const mxArray *prhs[]
                 )
{
 
  /* Check for proper number of arguments */

  if (nrhs != 6) {
    mexErrMsgIdAndTxt("MATLAB:netfailsimex:nargin",
            "MEXCPP requires 6 input arguments.");
  } else if (nlhs > 2) {
    mexErrMsgIdAndTxt("MATLAB:mexcpp:nargout",
            "MEXCPP requires <2 output argument.");
  }
  

  
  char* tmp = mxArrayToString(prhs[0]);
  string json(tmp);
  mxFree(tmp);
  
  std::vector<shared_ptr<Component>> network;
  std::random_device rd;
  std::mt19937 gen(rd());
 // mexPrintf("test");
  picojson::value v;
  
  istringstream is(json);
  is >> v;

  
  /*if (config.fail()) 
  {
	  std::cerr << picojson::get_last_error() << std::endl;
	  mexErrMsgIdAndTxt("MATLAB:netfailsimex",
            picojson::get_last_error().c_str());
  }*/

	picojson::object& net = v.get<picojson::object>();
	auto comps = net["components"].get<picojson::array>();
	std::transform(comps.begin(),comps.end(),std::back_inserter(network),[&](picojson::value& val)->shared_ptr<Component>{
		picojson::object& tmp = val.get<picojson::object>();
 
		//int udtype = tmp["udtype"].get<double>();
		//int ddtype = tmp["ddtype"].get<double>();

		int udtype = (int)mxGetScalar(prhs[2]);
		int ddtype = (int)mxGetScalar(prhs[3]);

		shared_ptr<Component> pointer;

		switch (udtype)
		{
		case 1://Expo
			switch (ddtype)
			{
			case 1://Exp
			{
				std::exponential_distribution<double> ud(tmp["ulambda"].get<double>());
				std::exponential_distribution<double> dd(tmp["dlambda"].get<double>());
				pointer = make_component(gen, ud, dd);
			}
				break;
			case 2:// Weib
			{
				std::exponential_distribution<double> ud(tmp["ulambda"].get<double>());
				std::weibull_distribution<double> dd(tmp["dwa"].get<double>(), tmp["dwb"].get<double>());
				pointer = make_component(gen, ud, dd);
			}
				break;
			case 3: //Pareto,
			{
				std::exponential_distribution<double> ud(tmp["ulambda"].get<double>());
				pareto_distribution dd(tmp["dpa"].get<double>(), tmp["dpb"].get<double>());
				pointer = make_component(gen, ud, dd);
			}
				break;
			case 4: //LogNorm
			{
				std::exponential_distribution<double> ud(tmp["ulambda"].get<double>());
				std::lognormal_distribution<double> dd(tmp["dlm"].get<double>(), tmp["dls"].get<double>());
				pointer = make_component(gen, ud, dd);

			}
				break;
			default:
				break;
			};
			break;
		case 2://weib
			switch (ddtype)
			{
			case 1://Exp
			{
				std::weibull_distribution<double> ud(tmp["uwa"].get<double>(), tmp["uwb"].get<double>());
				std::exponential_distribution<double> dd(tmp["dlambda"].get<double>());
				pointer = make_component(gen, ud, dd);

			}
				break;
			case 2:// Weib
			{
				std::weibull_distribution<double> ud(tmp["uwa"].get<double>(), tmp["uwb"].get<double>());
				std::weibull_distribution<double> dd(tmp["dwa"].get<double>(), tmp["dwb"].get<double>());
				pointer = make_component(gen, ud, dd);

			}
				break;
			case 3: //Pareto,
			{
				std::weibull_distribution<double> ud(tmp["uwa"].get<double>(), tmp["uwb"].get<double>());
				pareto_distribution dd(tmp["dpa"].get<double>(), tmp["dpb"].get<double>());
				pointer = make_component(gen, ud, dd);

			}
				break;
			case 4: //LogNorm
			{
				std::weibull_distribution<double> ud(tmp["uwa"].get<double>(), tmp["uwb"].get<double>());
				std::lognormal_distribution<double> dd(tmp["dlm"].get<double>(), tmp["dls"].get<double>());
				pointer = make_component(gen, ud, dd);

			}
				break;
			default:
				break;
			};

			break;
		default:
			break;
		};
		
		return pointer;
	});
	

	std::vector<double> mdowntimes;
	std::transform(comps.begin(), comps.end(), std::back_inserter(mdowntimes), [&](picojson::value& val)->double{
		picojson::object& tmp = val.get<picojson::object>();
		return 1.0 / tmp["dlambda"].get<double>();
	});

	double thr = *min_element(mdowntimes.begin(), mdowntimes.end())*mxGetScalar(prhs[5]);

	std::vector<Sla> slas;
	vector<shared_ptr<StatsColector>> stats;

	auto json_slas = net["slas"].get<picojson::array>();
	int ii=0;
	std::transform(json_slas.begin(), json_slas.end(),back_inserter(slas), [&](picojson::value& val)->Sla{
		picojson::object& tmp = val.get<picojson::object>();
		Sla ret;
		auto apath = tmp["path"].get<picojson::array>();
		for(auto i=apath.begin(); i != apath.end(); ++i)
		{
			int index = (*i).get<double>();
			ret.path.push_back(network[index-1]);
		}
		auto bpath = tmp["backupPath"].get<picojson::array>();
		for(auto i=bpath.begin(); i != bpath.end(); ++i)
		{
			int index = (*i).get<double>();
			ret.backupPath.push_back(network[index-1]);
		}
		
		auto lpaths = tmp["linkBackup"].get<picojson::array>();
		for(auto i=lpaths.begin(); i != lpaths.end(); ++i)
		{
			auto lpath = (*i).get<picojson::array>();
			std::vector<shared_ptr<Component>> tmp;
			for(auto j=lpath.begin(); j!= lpath.end(); ++j)
			{
				int index = (*j).get<double>();
				tmp.push_back(network[index-1]);
			}
			ret.linkBackup.push_back(tmp);
		}
		int ii2=0;
		ret.demand = tmp["demand"].get<double>();
		bool useSBPP=tmp["useSBPP"].get<double>()>0;
		bool useSBLP=tmp["useSBLP"].get<double>()>0;

		shared_ptr<StatsColector> tmptr;

		int p =(int)mxGetScalar(prhs[4]);
		//p = 1;
		switch(p)
		{
		case 1:
		{
			auto p1 = make_policy(Avail(), "Avail");
			createColectors(ret, p1,tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
				break;
		case 2:
		{
			auto p2 = make_policy(Cont(), "Cont");
			createColectors(ret, p2, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
				break;
		case 3:
		{
			//double thr = tmp["Pthr"].get<double>();
			auto p3 = make_policy(Thre(thr), "Thre");

			createColectors(ret, p3, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
				break;
		case 4:
		{
			auto p4 = make_policy(NonLinear(0.0, ret.demand, 0.0), "LinearCost");
			createColectors(ret, p4, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
				break;
		case 5:
		{
			auto p = make_policy(NonLinear(0.0, ret.demand, ret.demand*thr), "FixedRestartCost");
			createColectors(ret, p, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
			break;
		case 6:
		{
			auto p = make_policy(NonLinear(ret.demand/thr, 0.0, 0.0), "Snowball");
			createColectors(ret, p, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
			break;

		}


		return ret;
	});

 
	double t=0.0;
	int N=(int)mxGetScalar(prhs[1]);
	
	//plhs[0]=mxCreateDoubleMatrix(stats.size(), N, mxREAL);
	//double* outData=mxGetPr(plhs[0]);

	/*if(nlhs>1)
	{
		mwSize dims[]={stats.size(),1};
		plhs[1]=mxCreateCellArray(2, dims );
		int index =0;

		auto iter = stats.begin();
		for (;;) 
		{
			ostringstream tmp;
			(*iter)->writeName(tmp);
			mxSetCell(plhs[1],index++, mxCreateString(tmp.str().c_str()));
			if (++iter == stats.end())
			{
				break;
			}
		}
	}*/

	mwSize dims[]={N,1};
	plhs[0]=mxCreateCellArray(2, dims );
	plhs[1]=mxCreateCellArray(2, dims );
	
	auto postEvent = [&](double tt){
		for_each(slas.begin(), slas.end(),
		[&](Sla& rsla){
			rsla.onEvent(tt);
		});
	};
	int magic =0;
	for(int iteration=0; iteration<N; ++iteration)
	{
		t=0.0;
		for_each(stats.begin(), stats.end(),[](shared_ptr<StatsColector>& a){a->reset();});
		for_each(network.begin(), network.end(),[&](shared_ptr<Component>& a){a->reset(gen);});
		
		vector<uint64_t> states;
		vector<double> times;
		
		auto updateStatesTimes = [&](double tt){
			/// TODO stan na uint64
			//http://stackoverflow.com/questions/47981/how-do-you-set-clear-and-toggle-a-single-bit-in-c-c
			uint64_t currentState=0;
			int n =0;
			for(auto i=network.begin(); i != network.end(); ++i)
			{
				if((*i)->state)
					currentState |= 1 << n;
				n++;
			}
			//mexPrintf("%d\n", currentState);
			states.push_back(currentState);
			times.push_back(tt);

		};

		while(t < tmax)
		{
			//print();
			//for_each(slas.begin(), slas.end(),
			//[&](Sla& rsla){
			//	rsla.onEvent(t);
			//});
			//postEvent(t);
			updateStatesTimes(t);
			
			auto it = min_element(network.begin(), network.end(),[&](const shared_ptr<Component>& a, const shared_ptr<Component>& b)-> bool{return a->time2switch < b->time2switch;});
			auto t2s = (*it)->time2switch;
			t += t2s;
			for(auto i=network.begin(); i != network.end(); ++i)
			{
				if(i == it)
					(*i)->change(gen);
				else
					(*i)->time2switch -= t2s;
			}

		}
		t=tmax;

		//postEvent(t);
		updateStatesTimes(t);
		//display

		/*auto iter = stats.begin();
		for (;;) 
		{
			(*iter)->writeStats(outData++);
			//*(outData++)=(double)(magic++);
			if (++iter == stats.end())
			{
				break;
			}
		}*/
		
		/// TODO dopisanie
		
		
		mwSize dims[]={states.size(),1};
		mxArray *mxstates = mxCreateNumericArray(2, dims, mxUINT64_CLASS, mxREAL);
		mxArray *mxtimes = mxCreateNumericArray(2, dims, mxDOUBLE_CLASS, mxREAL);
		uint64_t *ps = (uint64_t *)mxGetPr(mxstates);
		double *pt = (double *)mxGetPr(mxtimes);
		copy(states.begin(),states.end(),ps);
		copy(times.begin(),times.end(),pt);
		mxSetCell(plhs[0],iteration, mxstates);
		mxSetCell(plhs[1],iteration, mxtimes);
	}


  return;
}

