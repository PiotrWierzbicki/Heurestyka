// fastsbpp.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
// states 0001000 1 awaria komponentu
// czas dopisywany (0, tmax1,0,tmax2,0,tmax3...)
enum State {PRIMARY, SECONDARY, FAIL};

double sim(
	const double* time, 
	const uint64_t* states, 
	const uint32_t nstates, 
	const double* sbppLimit, 
	const uint8_t ncomp, 
	const uint64_t primaryPath, 
	const uint64_t protectionPath, 
	double* traffic[],
	const double demand,
	State* state
	)
{
	for(uint32_t index=0;index < nstates; index++)
	{
		register uint64_t s = states[index];
		bool primary = (s & primaryPath) > 0;
		bool secondary = (s & protectionPath) > 0;
		bool cap = false;
		bool capcache=false;
		//for(int i=0; i < ncomp; i++)
		//{
		//	if((*traffic)[i]+demand > sbppLimit[i] && (1i64<<i & protectionPath)) //sprawdzam, czy gdzies przekroczy這 limit
		//	{
		//		cap = true;
		//		break;
		//	}
		//}
		//szybciej
		//const double* pl=sbppLimit;
		//uint64_t mask=1i64;
		//for(double* pt=*traffic;pt !=*traffic +ncomp; pt++,pl++)
		//{
		//	if(*pt > *pl && mask) //sprawdzam, czy gdzies przekroczy這 limit
		//	{
		//		cap = true;
		//		break;
		//	}
		//	mask << 1;
		//}

		switch (*state)
		{
		case PRIMARY:
			if (primary ) // pada 1
			{
				if(secondary ) //pada zapas
				{
					*state=FAIL;
				}
				else
				{
					const double* pl=sbppLimit;
					uint64_t mask=1i64;
					for(double* pt=*traffic;pt !=*traffic +ncomp; pt++,pl++)
					{
						if(*pt > *pl && mask) //sprawdzam, czy gdzies przekroczy這 limit
						{
							cap = true;
							break;
						}
						mask << 1;
					}
					capcache=true;

					if(cap)// braz pasma
					{
						*state=FAIL;
					}
					else //jest pasmo
					{
						//for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP += demand;});
						for(int i=0; i < ncomp; i++)
						{
							if( (1i64<<i & protectionPath)) 
							{
								(*traffic)[i]+=demand;
							}
						}

						*state = SECONDARY;
					}
				}
			}
			break;
		case SECONDARY:
			if(!primary) //wracamy
			{
				*state=PRIMARY;
				//for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP -= demand;});
				for(int i=0; i < ncomp; i++)
				{
					if( (1i64<<i & protectionPath)) 
					{
						(*traffic)[i]-=demand;
					}
				}

				break;
			}
			if(secondary) //awaria na zapasie
			{
				*state= FAIL;
				//for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP -= demand;});
				for(int i=0; i < ncomp; i++)
				{
					if( (1i64<<i & protectionPath)) 
					{
						(*traffic)[i]-=demand;
					}
				}

				break;
			}
			break;
		case FAIL:
			if(!primary)//wracamy
			{
				*state=PRIMARY;
				break;
			}

			if(!capcache)
			{
				const double* pl=sbppLimit;
				uint64_t mask=1i64;
				for(double* pt=*traffic;pt !=*traffic +ncomp; pt++,pl++)
				{
					if(*pt > *pl && mask) //sprawdzam, czy gdzies przekroczy這 limit
					{
						cap = true;
						break;
					}
					mask << 1;
				}
			}

			if(!secondary && !cap)
			{
				//for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP += demand;});
				for(int i=0; i < ncomp; i++)
				{
					if( (1i64<<i & protectionPath)) 
					{
						(*traffic)[i]+=demand;
					}
				}

				*state = SECONDARY;
				break;
			}
			
		}//switch


	}//for
	return 0.0;
}

int _tmain(int argc, _TCHAR* argv[])
{
	const uint32_t nstates=3000;
	const uint64_t* states =  new uint64_t[nstates];
	const uint8_t ncomp=26;
	const uint64_t primaryPath=82554i64;
	const uint64_t protectionPath=36031133481173514i64;
	double* traffic =  new double[ncomp];
	const double demand = 20;
	double* sbppLimit =  new double[ncomp];
	State st=PRIMARY;
	for(int i=0;i<ncomp;i++)
	{
		sbppLimit[i]=100;
	}
	for(int i=0;i <10000; i++)
	{
		sim(nullptr,states,nstates,sbppLimit,ncomp,primaryPath,protectionPath,&traffic,demand,&st);
	}
	return 0;
}

