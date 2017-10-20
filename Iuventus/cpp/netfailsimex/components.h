#ifndef COMPONENTS_H
#define COMPONENTS_H

class pareto_distribution
{
public:
	
	pareto_distribution(const double& alpha_, const double& beta_):alpha(alpha_),beta(beta_),uni(0, 1)
	{
		alpha_i = 1.0/alpha;
	}
	template<class Engine>
	double operator()(Engine& Eng)
	{	// return next value
		return beta/pow(1.0 - uni(Eng), alpha_i);
	}
private:
	uniform_real_distribution<> uni;
	double alpha;
	double alpha_i;
	double beta;

};



//struct Component
//{
//	bool state; // 1 awaria, 0 dzialanie
//	double time2switch;
//	double currentSBPP;
//	double currentSBLP;
//	Component(std::mt19937& gen,double lambda_,	double alpha_,	double beta_, double wa_, double wb_, bool exp_up_,double sbppLimit_, double sbplLimit_):state(false),
//		dexp(lambda_),
//		weib(wa_,wb_),
//		exp_up(exp_up_),
//		duni(0, 1),
//		alpha(alpha_),
//		beta(beta_),
//		sbppLimit(sbppLimit_),
//		sbplLimit(sbppLimit_),
//		currentSBPP(0.0),
//		currentSBLP(0.0)
//	{
//		alpha_i = 1.0/alpha;
//		time2switch = dexp(gen);// losoujemy kiedy bedzie awaria
//	}
//	void change(std::mt19937& gen)
//	{
//		if(state) //konczy sie awaria, losujemy czas do nastepnej
//		{
//			time2switch = exp_up?dexp(gen):weib(gen);
//		}
//		else//zaczyna sie awaria losujemy czas naprawy
//		{
//			double l = beta/pow(1.0 - duni(gen), alpha_i);
//			time2switch = l;			
//		}
//		state = !state; // zmiana stanu
//	}
//	void reset(std::mt19937& gen){
//		state=false;
//		currentSBPP=0.0;
//		currentSBLP=0.0;
//		time2switch = dexp(gen);// losoujemy kiedy bedzie awaria
//	}
//	double getSBPPlimit(){return sbppLimit;}
//	double getSBLPlimit(){return sbplLimit;}
//private:
//	std::exponential_distribution<> dexp;
//	std::uniform_real_distribution<> duni;
//	std::weibull_distribution<> weib;
//	//double lambda;
//	double alpha;
//	double alpha_i;
//	double beta;
//	const bool exp_up;
//	double sbppLimit;
//	double sbplLimit;
//
//
//};


struct Component
{
	bool state; // 1 awaria, 0 dzialanie
	double time2switch;
	double currentSBPP;
	double currentSBLP;
	Component():state(false), sbppLimit(20)
	{
	}
	virtual void change(std::mt19937& gen)=0;
	virtual ~Component(){}
	virtual void reset(std::mt19937& gen)=0;
	double getSBPPlimit(){return sbppLimit;}
	double getSBLPlimit(){return sbplLimit;}
private:
	double sbppLimit;
	double sbplLimit;
};

template <typename U,typename D>
struct TypedComponent: public Component
{
	TypedComponent(std::mt19937& gen, U& u, D& d):Component(),uptimeDist(u),downtimeDist(d)
	{
		Component::time2switch = uptimeDist(gen);// losoujemy kiedy bedzie awaria
	}
	void change(std::mt19937& gen)
	{
		if(Component::state) //konczy sie awaria, losujemy czas do nastepnej
		{
			Component::time2switch = uptimeDist(gen);
		}
		else//zaczyna sie awaria losujemy czas naprawy
		{
			//double l = beta/pow(1.0 - duni(gen), alpha_i);
			Component::time2switch = downtimeDist(gen);
		}
		Component::state = !Component::state; // zmiana stanu

	}
	void reset(std::mt19937& gen)
	{
		Component::state = false;
		Component::currentSBPP = 0.0;
		Component::currentSBLP = 0.0;
		Component::time2switch = uptimeDist(gen);// losoujemy kiedy bedzie awaria

	}
private:
	U uptimeDist;
	D downtimeDist;
};

template <typename U, typename D>
std::shared_ptr<Component> make_component(std::mt19937& gen, U& u, D& d)
{
	shared_ptr<Component> pointer(new TypedComponent<U, D >(gen, u, d));
	return pointer;
}

template <typename T>
struct TotalHolder
{
public:
	TotalHolder():total(0){}
	const T& getTotal(){return total;}
protected:
	T total;
};

//struct AvailPolicy: public TotalHolder<double>
//{
//	static const char* name;
//
//	AvailPolicy():oldState(false),oldTime(0.0){}
//	void update(bool state, double t)
//	{
//		if(oldState && !state) //1->0 koniec awarii
//		{
//			total += (t-oldTime);
//		}
//		if(!oldState && state) //0->1 poczatek awari
//		{
//			oldTime = t;
//		}
//		oldState = state;
//	}
//	void reset(){
//		oldState=false;
//		oldTime=0.0;
//		total =0;
//	}
//
//private:
//	bool oldState;
//	double oldTime;
//};

template <typename Fun, typename T>
struct Policy : public TotalHolder<T>
{
	const char* name; //TODO przeniesc do klasy
	Policy() :oldState(false), oldTime(0.0){}
	Policy(const Fun& af, const char* aname) :oldState(false), oldTime(0.0), f(af), name(aname){}
	void update(bool state, double t)
	{
		if (oldState && !state) //1->0 koniec awarii
		{
			TotalHolder<T>::total += f(t - oldTime);
		}
		if (!oldState && state) //0->1 poczatek awari
		{
			oldTime = t;
		}
		oldState = state;
	}
	void reset(){
		oldState = false;
		oldTime = 0.0;
		TotalHolder<T>::total = 0;
	}

private:
	bool oldState;
	double oldTime;
	Fun f;
};

struct NonLinear
{
	NonLinear() :a(1.0), b(1.0), c(1.0){}
	NonLinear(double aA, double aB, double aC) :a(aA), b(aB), c(aC){}
	double operator()(double x)
	{
		return a*x*x + b*x + c;
	}
private:
	double a;
	double b;
	double c;
};

struct Thre
{
	Thre() :thr(120){}
	Thre(double aThr) :thr(aThr){}
	auto operator()(double x) ->double
	{
		return x>thr ? x : 0.0;
	}
private:
	double thr;
};

template <typename Fun>
auto make_policy(const Fun& f, const char* name)->Policy<Fun, typename result_of<Fun(double)>::type>
{
	Policy<Fun, typename result_of<Fun(double)>::type> tmp(f, name);
	return tmp;
}


struct Avail
{
	double operator()(double x)
	{
		return x;
	}
};

struct Cont
{
	int operator()(double x)
	{
		return 1;
	}
};
//struct FixedRestart: public Linear
//{
//	FixedRestart() :gamma(1.0){}
//	FixedRestart(double aBeta, double aGamma) :Linear(aBeta),gamma(aGamma){}
//	double operator()(double x)
//	{
//		return Linear::operator()(x)+gamma;
//	}
//private:
//	double gamma;
//};
//
//struct Snowball
//{
//	Snowball() :delta(1.0){}
//	Snowball(double aDelta) :delta(aDelta){}
//	double operator()(double x)
//	{
//		return delta*x*x;
//	}
//private:
//	double delta;
//};
//
//struct MixSnowFix : public Snowball, FixedRestart
//{
//	MixSnowFix() {}
//	MixSnowFix(double) {}
//	double operator()(double x)
//	{
//		return Snowball::operator()(x)+FixedRestart::operator()(x);
//	}
//};

//struct ContPolicy: public TotalHolder<unsigned int>
//{
//	static const char* name;
//	ContPolicy():oldState(false){}
//	void update(bool state, double t)
//	{
//
//		if(!oldState && state) //0->1 poczatek awari
//		{
//			total++;
//		}
//		oldState = state;
//	}
//	void reset(){
//		oldState=false;
//		total =0;
//	}
//private:
//	bool oldState;
//};





class StatsColector
{
public:
	virtual void update(vector<shared_ptr<Component>>& path,vector<shared_ptr<Component>>& backupPath,vector<std::vector<shared_ptr<Component>>>& linkBackup, double t)=0;
	virtual void reset()=0;
	virtual void writeStats(double*)=0;
	virtual ~StatsColector(){}
	int getSecondComparator(){return secondComparator;}
	void setSecondComparator(int c){secondComparator=c;}
	int getFirstComparator(){return firstComparator;}
	void setFirstComparator(int c){firstComparator=c;}
	virtual void writeName(ostream& out)=0;

private:
	int secondComparator;
	int firstComparator;
};

template <class T>
class PolicyHolder: public StatsColector
{
	void writeStats(double* out)
	{
		*out= policy.getTotal();
	}
	virtual void reset(){
		policy.reset();
	}
public:
	void setPolicy(const T& aPolicy){ policy = aPolicy; }
protected:
	T policy;

};

template <typename T>
class UnprotectedStatsColector: public PolicyHolder<T>
{
public:
	virtual void update(vector<shared_ptr<Component>>& path,vector<shared_ptr<Component>>& backupPath,vector<std::vector<shared_ptr<Component>>>& linkBackup, double t)
	{
		PolicyHolder<T>::policy.update(any_of(path.begin(), path.end(),[](shared_ptr<Component>& c)->bool{return c->state;}), t);
	}
	void writeName(ostream& out){out << "Unprotected"<< PolicyHolder<T>::policy.name ;}
};

template <typename T>
class DedicatedProtectionColector: public PolicyHolder<T>
{
public:
	virtual void update(vector<shared_ptr<Component>>& path,vector<shared_ptr<Component>>& backupPath,vector<std::vector<shared_ptr<Component>>>& linkBackup, double t)
	{
		bool primary = any_of(path.begin(), path.end(),[](shared_ptr<Component>& c)->bool{return c->state;});
		bool secondary = any_of(backupPath.begin(), backupPath.end(),[](shared_ptr<Component>& c)->bool{return c->state;});
		PolicyHolder<T>::policy.update(primary && secondary, t);
	}
	void writeName(ostream& out){out << "Dedicated"<< PolicyHolder<T>::policy.name;}
	
};

template <typename T>
class LinkDedicatedProtectionColector: public PolicyHolder<T>
{
public:
	virtual void update(vector<shared_ptr<Component>>& path,vector<shared_ptr<Component>>& backupPath,vector<std::vector<shared_ptr<Component>>>& linkBackup, double t)
	{
		bool all=false;
		for(int i=0; i < path.size(); ++i)
		{
			auto& segmentbackup = linkBackup[i];
			bool segment = path[i]->state && any_of(segmentbackup.begin(), segmentbackup.end(),[](shared_ptr<Component>& c)->bool{return c->state;});
			all = all || segment;
		}
		PolicyHolder<T>::policy.update(all, t);
	}
	void writeName(ostream& out){out << "LinkDedicated"<< PolicyHolder<T>::policy.name;}
};


template <typename T>
class SBPPColector: public PolicyHolder<T>
{
	enum State {PRIMARY, SECONDARY, FAIL};
public:
	SBPPColector(double demand_):demand(demand_),state(PRIMARY){}
	virtual void update(vector<shared_ptr<Component>>& path,vector<shared_ptr<Component>>& backupPath,vector<std::vector<shared_ptr<Component>>>& linkBackup, double t)
	{
		bool primary = any_of(path.begin(), path.end(),[&](shared_ptr<Component>& c)->bool{return c->state;});
		bool secondary = any_of(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c)->bool{return c->state;});
		bool cap = any_of(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c)->bool{return c->currentSBPP+demand > c->getSBPPlimit();});
		//if (cap)
			//mexPrintf("cap %d,%f\n", this, t);

		switch (state)
		{
		case PRIMARY:
			if (primary ) // pada 1
			{
				if(secondary ) //pada zapas
				{
					state=FAIL;
				}
				else
				{
					if(cap)// braz pasma
					{
						state=FAIL;
					}
					else //jest pasmo
					{
						for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP += demand;});
						state = SECONDARY;
					}
				}
			}
			break;
		case SECONDARY:
			//mexPrintf("sbpp: %d, %f\n", (int)state, t);
			if(!primary) //wracamy
			{
				state=PRIMARY;
				for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP -= demand;});
				break;
			}
			if(secondary) //awaria na zapasie
			{
				state= FAIL;
				for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP -= demand;});
				break;
			}
			break;
		case FAIL:
			if(!primary)//wracamy
			{
				state=PRIMARY;
				break;
			}
			if(!secondary && !cap)
			{
				for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP += demand;});
				state = SECONDARY;
				break;
			}
			
		}
		
		PolicyHolder<T>::policy.update(state == FAIL, t);
	}
	void writeName(ostream& out){out << "SBPP"<< PolicyHolder<T>::policy.name;}
	void reset(){
		PolicyHolder<T>::policy.reset();
		state=PRIMARY;
	}

private:
	double demand;
	State state;
};

template <typename T>
class SBLPColector: public PolicyHolder<T>
{
	enum State {FAIL=-2, PRIMARY=-1};
public:
	SBLPColector(double demand_):demand(demand_){reset();}
	virtual void update(vector<shared_ptr<Component>>& path,vector<shared_ptr<Component>>& backupPath,vector<std::vector<shared_ptr<Component>>>& linkBackup, double t)
	{
		if(currentBackup >=0)//na zapasie
		{
			auto& segmentbackup = linkBackup[currentBackup];
			//wracamy z zapasu
			if(!any_of(path.begin(), path.end(),[&](shared_ptr<Component>& c)->bool{return c->state;}))
			{				
				for_each(segmentbackup.begin(), segmentbackup.end(),[&](shared_ptr<Component>& c){c->currentSBLP -= demand;});
				currentBackup=PRIMARY;
			}
			if(any_of(segmentbackup.begin(), segmentbackup.end(),[&](shared_ptr<Component>& c)->bool{return c->state;}))
			{
				//awaria na backupie
				//sprzatamy
				for_each(segmentbackup.begin(), segmentbackup.end(),[&](shared_ptr<Component>& c){c->currentSBLP -= demand;});
				currentBackup=FAIL;
			}
		}
		else if(currentBackup == PRIMARY)
		{
			//sprawdzamy czy jest awaria i czy dziala zapas
			bool switc2backup=false;
			bool pathstate=false;
			for(int i=0; i < path.size() && !switc2backup; ++i)
			{
				if(path[i]->state) //mamy awarie
				{
					pathstate=true; //cos nam pada
					auto& segmentbackup = linkBackup[i];
					bool segment = any_of(segmentbackup.begin(), segmentbackup.end(),[](shared_ptr<Component>& c)->bool{return c->state;});
					bool cap = any_of(segmentbackup.begin(), segmentbackup.end(),[&](shared_ptr<Component>& c)->bool{return c->currentSBLP+demand > c->getSBLPlimit();});
					if(!segment && !cap) //przechodzimy na protkcje
					{
						for_each(segmentbackup.begin(), segmentbackup.end(),[&](shared_ptr<Component>& c){c->currentSBLP += demand;});
						currentBackup=i;
						switc2backup=true;
					}//else sprawdzamy dalej
				}
			}
			if(pathstate && !switc2backup) //jest awaria i nie znaleziono zapasu
			{
				currentBackup=FAIL;
			}

		}
		else //FAIL
		{
			bool pathstate=false;
			int stateCandidate=FAIL;
			for(int i=0; i < path.size() ; ++i)
			{
				if(path[i]->state) //mamy awarie
				{
					pathstate=true; 
					auto& segmentbackup = linkBackup[i];
					bool segment = any_of(segmentbackup.begin(), segmentbackup.end(),[](shared_ptr<Component>& c)->bool{return c->state;});
					bool cap = any_of(segmentbackup.begin(), segmentbackup.end(),[&](shared_ptr<Component>& c)->bool{return c->currentSBLP+demand > c->getSBLPlimit();});
					if(!segment && !cap) //przechodzimy na protkcje
					{
						stateCandidate=i; // wybieramy ostatnia mozliwa konfguracje
					}
				}
			}
			if(!pathstate) //waracamy
			{
				currentBackup=PRIMARY;
			}
			else if(stateCandidate != FAIL) //waracamy na protekcje
			{
				auto& segmentbackup = linkBackup[stateCandidate];
				for_each(segmentbackup.begin(), segmentbackup.end(),[&](shared_ptr<Component>& c){c->currentSBLP += demand;});
				currentBackup=stateCandidate;
			}

		}

		PolicyHolder<T>::policy.update(currentBackup == FAIL, t);

	}
	void writeName(ostream& out){out << "SBLP"<< PolicyHolder<T>::policy.name;}
	void reset(){
		currentBackup=PRIMARY;//podstawowa
		PolicyHolder<T>::policy.reset();
		//state=PRIMARY;
	}

private:
	double demand;
	int currentBackup; //numer zapasu, -1 podstawowa, -2 awaria calosci
};
struct Sla
{
	Sla()
	{}
	std::vector<shared_ptr<Component>> path;
	std::vector<shared_ptr<Component>> backupPath;
	std::vector<std::vector<shared_ptr<Component>>> linkBackup;
	double demand;

	void onEvent(double time );
	void addColector(shared_ptr<StatsColector> c){colectors.push_back(c);}
private:
	vector<shared_ptr<StatsColector>> colectors;

};


template< template<class > class C>
struct ArgType
{};
//helper C typ protekcji, P polityka utworzona z make_policy
template< template<class > class C ,typename P>
shared_ptr<StatsColector> make_colector( ArgType<C> h, P& p)
{
	shared_ptr<StatsColector> tmptr;
	C<P>* xx = new  C<P>();
	xx->setPolicy(p);
	tmptr = shared_ptr<StatsColector>(xx);
	return tmptr;
}

//TODO perfect forwarding
template< template<class > class C, typename P, typename A>
shared_ptr<StatsColector> make_colectorA(ArgType<C> h, P& p, const A& a)
{
	shared_ptr<StatsColector> tmptr;
	C<P>* xx = new  C<P>(a);
	xx->setPolicy(p);
	tmptr = shared_ptr<StatsColector>(xx);
	return tmptr;
}


template <typename A, typename B,typename C>
void createColectors(A& ret, B& p, shared_ptr<StatsColector>& tmptr, int& ii, int& ii2, bool useSBPP, bool useSBLP, C& stats)
{
	tmptr = make_colector(ArgType<UnprotectedStatsColector>(), p);
	ret.addColector(tmptr);
	stats.push_back(tmptr);
	tmptr->setSecondComparator(ii++);
	tmptr->setFirstComparator(ii2++);

	tmptr = make_colector(ArgType<DedicatedProtectionColector>(), p);
	ret.addColector(tmptr);
	stats.push_back(tmptr);
	tmptr->setSecondComparator(ii++);
	tmptr->setFirstComparator(ii2++);
//#if 0
	tmptr = make_colector(ArgType<LinkDedicatedProtectionColector>(), p);
	ret.addColector(tmptr);
	stats.push_back(tmptr);
	tmptr->setSecondComparator(ii++);
	tmptr->setFirstComparator(ii2++);
	/*
	if (useSBPP)
	{
		tmptr = make_colectorA(ArgType<SBPPColector>(), p, ret.demand);
		ret.addColector(tmptr);
		stats.push_back(tmptr);
		tmptr->setSecondComparator(ii++);
		tmptr->setFirstComparator(ii2++);
	}
	if (useSBLP)
	{
		tmptr = make_colectorA(ArgType<SBLPColector>(), p, ret.demand);
		ret.addColector(tmptr);
		stats.push_back(tmptr);
		tmptr->setSecondComparator(ii++);
		tmptr->setFirstComparator(ii2++);
	}
	*/
//#endif
}

#endif
