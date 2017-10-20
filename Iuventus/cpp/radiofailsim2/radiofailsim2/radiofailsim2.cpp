// netfailsim.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <sstream>
#include "components.h"

//g++ -O2 -std=gnu++11   -o netfailsim netfailsim.cpp
//scl enable devtoolset-2 python27 bash
//g++ - O2 - std = gnu++11 - o netfailsim netfailsim.cpp components.cpp
//xargs -a params.txt  -n 5 -P 15 ./netfailsim
namespace{
	//double lambda = 3.18e-7;
	//double alpha=2.3;
	//double alpha_i = 1.0/alpha;
	//double beta=60;

	double tmax = 12*30*24*3600;//rok
}




//int _tmain(int argc, _TCHAR* argv[])
int main(int argc, char* argv[])
{

#if 0 //testy
	pareto_distribution d1(2.0, 1.2);
	pareto_distribution d2=d1;
	Linear l;
	Policy<Linear,double> ll(l,"aa");
	
	UnprotectedStatsColector<Policy<Linear, double>>* x = new  UnprotectedStatsColector<Policy<Linear, double>>();
	//UnprotectedStatsColector<ThrePolicy>* x = new  UnprotectedStatsColector<ThrePolicy>();
	x->setPolicy(ll);
	auto p = make_policy([](double dt)->double{return 4*dt+7.0; },"test");
	auto* xx = new  UnprotectedStatsColector<decltype(p)>();
	xx->setPolicy(p);
	//auto f = [](double dt)->double {return 3 * dt; };
	//auto aa = make_colector<UnprotectedStatsColector,decltype(p)>(p, nullptr);

	//auto aa = make_colector<UnprotectedStatsColector, decltype(p)>(p);
	ArgType<UnprotectedStatsColector> hh();
	auto aa = make_colectorA(ArgType<SBLPColector>(), make_policy([](double dt)->double{return 4 * dt + 7.0; }, "test2"),44);
#endif

	std::map<std::string,std::string> argsmap;
	if(argc <15)
	{
		//cout<< "netfailsim config.json out.txt N policy[1 avail, 2 cont, 3 thre(120s)] up_time_dist[1 Exp, 2 Weib]" << endl;
		cout<< "netfailsim -i config.json -o out.txt -n N -p policy[1 avail, 2 cont, 3 thre 4 snoball] -u up_time_dist[1 Exp, 2 Weib] -d down_time_dist[1 Exp, 2 Weib, 3 Par, 4LogNorm] -h [thr scale]" << endl;
		return -1;
	}
	else
	{
		for(int i=1;i < argc-1;i+=2)
			argsmap.emplace(make_pair(argv[i],argv[i+1]));

		for (auto x=argsmap.begin();x!= argsmap.end(); ++x)
			std::cout << x->first << ": " << x->second << std::endl;

	}

	picojson::value v;
	ifstream config(argsmap["-i"]);
	config >> v;
	if (config.fail()) 
	{
		std::cerr << picojson::get_last_error() << std::endl;
		return 1;
	}

	std::vector<shared_ptr<Component>> network;
	std::random_device rd;
    std::mt19937 gen(rd());

	picojson::object& net = v.get<picojson::object>();
	auto comps = net["components"].get<picojson::array>();
	std::transform(comps.begin(),comps.end(),std::back_inserter(network),[&](picojson::value& val)->shared_ptr<Component>{
		picojson::object& tmp = val.get<picojson::object>();
 
		//int udtype = tmp["udtype"].get<double>();
		//int ddtype = tmp["ddtype"].get<double>();

		int udtype = atoi(argsmap["-u"].c_str());
		int ddtype = atoi(argsmap["-d"].c_str());

		shared_ptr<Component> pointer;
				std::exponential_distribution<double> ud(tmp["ulambda"].get<double>());
				std::exponential_distribution<double> dd(tmp["dlambda"].get<double>());
				pointer = make_component(gen, ud, dd);
				pointer->X = tmp["X"].get<double>();
				pointer->Y = tmp["Y"].get<double>();


		//pointer = make_component(gen, ud, dd);




		//switch (udtype)
		//{
		//case 1://Expo
		//	switch (ddtype)
		//	{
		//	case 1://Exp
		//	{
		//		std::exponential_distribution<double> ud(tmp["ulambda"].get<double>());
		//		std::exponential_distribution<double> dd(tmp["dlambda"].get<double>());
		//		pointer = make_component(gen, ud, dd);
		//	}
		//		break;
		//	case 2:// Weib
		//	{
		//		std::exponential_distribution<double> ud(tmp["ulambda"].get<double>());
		//		std::weibull_distribution<double> dd(tmp["dwa"].get<double>(), tmp["dwb"].get<double>());
		//		pointer = make_component(gen, ud, dd);
		//	}
		//		break;
		//	case 3: //Pareto,
		//	{
		//		std::exponential_distribution<double> ud(tmp["ulambda"].get<double>());
		//		pareto_distribution dd(tmp["dpa"].get<double>(), tmp["dpb"].get<double>());
		//		pointer = make_component(gen, ud, dd);
		//	}
		//		break;
		//	case 4: //LogNorm
		//	{
		//		std::exponential_distribution<double> ud(tmp["ulambda"].get<double>());
		//		std::lognormal_distribution<double> dd(tmp["dlm"].get<double>(), tmp["dls"].get<double>());
		//		pointer = make_component(gen, ud, dd);
		//	}
		//		break;
		//	default:
		//		break;
		//	};
		//	break;
		//case 2://weib
		//	switch (ddtype)
		//	{
		//	case 1://Exp
		//	{
		//		std::weibull_distribution<double> ud(tmp["uwa"].get<double>(), tmp["uwb"].get<double>());
		//		std::exponential_distribution<double> dd(tmp["dlambda"].get<double>());
		//		pointer = make_component(gen, ud, dd);

		//	}
		//		break;
		//	case 2:// Weib
		//	{
		//		std::weibull_distribution<double> ud(tmp["uwa"].get<double>(), tmp["uwb"].get<double>());
		//		std::weibull_distribution<double> dd(tmp["dwa"].get<double>(), tmp["dwb"].get<double>());
		//		pointer = make_component(gen, ud, dd);

		//	}
		//		break;
		//	case 3: //Pareto,
		//	{
		//		std::weibull_distribution<double> ud(tmp["uwa"].get<double>(), tmp["uwb"].get<double>());
		//		pareto_distribution dd(tmp["dpa"].get<double>(), tmp["dpb"].get<double>());
		//		pointer = make_component(gen, ud, dd);

		//	}
		//		break;
		//	case 4: //LogNorm
		//	{
		//		std::weibull_distribution<double> ud(tmp["uwa"].get<double>(), tmp["uwb"].get<double>());
		//		std::lognormal_distribution<double> dd(tmp["dlm"].get<double>(), tmp["dls"].get<double>());
		//		pointer = make_component(gen, ud, dd);

		//	}
		//		break;
		//	default:
		//		break;
		//	};

		//	break;
		//default:
		//	break;
		//};
		
		return pointer;
	});

	std::vector<double> mdowntimes;
	std::transform(comps.begin(), comps.end(), std::back_inserter(mdowntimes), [&](picojson::value& val)->double{
		picojson::object& tmp = val.get<picojson::object>();
		return 1.0 / tmp["dlambda"].get<double>();
	});

	double thr = *min_element(mdowntimes.begin(), mdowntimes.end())*atof(argsmap["-h"].c_str());

	std::vector<Sla> slas;
	vector<shared_ptr<StatsColector>> stats;

	auto json_slas = net["slas"].get<picojson::array>();
	int ii=0;
	std::transform(json_slas.begin(), json_slas.end(),back_inserter(slas), [&](picojson::value& val)->Sla{
		picojson::object& tmp = val.get<picojson::object>();
		Sla ret;
		auto apath = tmp["path"].get<double>();

		//for(auto i=apath.begin(); i != apath.end(); ++i)
		//{
		//	int index = (*i).get<double>();
		//	ret.path.push_back(network[index-1]);
		//}

		auto bpath = tmp["backup_paths"].get<picojson::array>();
		for(auto i=bpath.begin(); i != bpath.end(); ++i)
		{
			int index = (*i).get<double>();
			if (index > 0)
				ret.backupPath.push_back(network[index-1]);
		}
		
	/*	auto lpaths = tmp["linkBackup"].get<picojson::array>();
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
		}*/

		int ii2=0;
		ret.demand = tmp["demand"].get<double>();
//		bool useSBPP=tmp["useSBPP"].get<double>()>0;
//		bool useSBLP=tmp["useSBLP"].get<double>()>0;

		bool useSBPP = false;
		bool useSBLP = false;

		shared_ptr<StatsColector> tmptr;

		int p =atoi(argsmap["-p"].c_str());
		p = 1;
		switch(p)
		{
		case 1:
		{
			auto p1 = make_policy(Avail(), "Avail");
			createColectors(ret, p1,tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
				//break;
		case 2:
		{
			auto p2 = make_policy(Cont(), "Cont");
			createColectors(ret, p2, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
				//break;
		case 3:
		{
			//double thr = tmp["Pthr"].get<double>();
			auto p3 = make_policy(Thre(thr), "Thre");

			createColectors(ret, p3, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
				//break;
		case 4:
		{
			auto p4 = make_policy(NonLinear(0.0, ret.demand, 0.0), "LinearCost");
			createColectors(ret, p4, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
				//break;
		case 5:
		{
			auto p = make_policy(NonLinear(0.0, ret.demand, ret.demand*thr), "FixedRestartCost");
			createColectors(ret, p, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
			//break;
		case 6:
		{
			auto p = make_policy(NonLinear(ret.demand/thr, 0.0, 0.0), "Snowball");
			createColectors(ret, p, tmptr, ii, ii2, useSBPP, useSBLP, stats);
		}
			//break;

		}


		return ret;
	});

 
	std::ofstream file(argsmap["-o"],std::ios::out | std::ios::trunc);	 

	//sort(stats.begin(), stats.end(),[](const shared_ptr<StatsColector>& a, const shared_ptr<StatsColector>& b)->bool{
	//	if(a->getFirstComparator() == b->getFirstComparator())
	//		return a->getSecondComparator() < b->getSecondComparator();
	//	return a->getFirstComparator() < b->getFirstComparator();
	//});
	
	{
		std::stringstream ss;
		ss <<argsmap["-o"] << ".lbl";
		std::ofstream lblfile(ss.str(),std::ios::out | std::ios::trunc);

		auto iter = stats.begin();
		for (;;) 
		{
			(*iter)->writeName(lblfile);
			if (++iter == stats.end())
			{
				lblfile << endl;
				break;
			}
			lblfile << endl;
		}
	}

	
	
	double t=0.0;
	int N=atoi(argsmap["-n"].c_str());

	auto print = [&](){
		auto iter = network.begin();
		file << t << ",";

		for (;;) 
		{
			//file << (*iter)->state;
			file << (*iter)->currentSBLP;
			if (++iter == network.end())
			{
				file << endl;
				break;
			}
			file << ",";
		}
	};
	auto postEvent = [&](double tt){
		for_each(slas.begin(), slas.end(),
		[&](Sla& rsla){
			rsla.onEvent(tt);
		});
	};
	for(int iteration=0; iteration<N; ++iteration)
	{
		t=0.0;
		for_each(stats.begin(), stats.end(),[](shared_ptr<StatsColector>& a){a->reset();});
		for_each(network.begin(), network.end(),[&](shared_ptr<Component>& a){a->reset(gen);});

		while(t < tmax)
		{
			//print();
			//for_each(slas.begin(), slas.end(),
			//[&](Sla& rsla){
			//	rsla.onEvent(t);
			//});
			postEvent(t);
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
		//print();
		//for_each(slas.begin(), slas.end(),
		//[&](Sla& rsla){
		//	rsla.onEvent(t);
		//});

		postEvent(t);
		//display

		auto iter = stats.begin();
		for (;;) 
		{
			(*iter)->writeStats(file);
			if (++iter == stats.end())
			{
				file << endl;
				break;
			}
			file << ",";
		}
	}

	file.close();


	return 0;
}

