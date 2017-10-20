#include"stdafx.h"
#include <mex.h>
#include<matrix.h>

#include "components.h"

using namespace std;

enum State { PRIMARY, SECONDARY, FAIL };


void mexFunction(
	int          nlhs,
	mxArray      *plhs[],
	int          nrhs,
	const mxArray *prhs[]
	)
{

	/* Check for proper number of arguments */

	if (nrhs != 7) {
		mexErrMsgIdAndTxt("MATLAB:netfailsimex:nargin",
			"MEXCPP requires 6 input arguments.");
	}
	else if (nlhs > 1) {
		mexErrMsgIdAndTxt("MATLAB:mexcpp:nargout",
			"MEXCPP requires <2 output argument.");
	}

//	uint64_t tmptmp = 1i64 << 2;
	//mexPrintf("test %d\n", tmptmp);

	const mwSize* dims_st= 	mxGetDimensions(prhs[0]);
	const mwSize* dims_sla = mxGetDimensions(prhs[2]);
	const uint8_t nsla = *(dims_sla+1);
	const mwSize* dims_comp = mxGetDimensions(prhs[5]);
	const uint8_t ncomp = *(dims_comp + 1);

	double* traffic = new double[ncomp];
	double* failtime = new double[nsla];
	double* tmpTime = new double[nsla];

	State* st = new State[nsla];
	State* prevst = new State[nsla];

	const uint64_t* primaries= (uint64_t *)mxGetPr(prhs[2]);
	const uint64_t* secondaries = (uint64_t *)mxGetPr(prhs[3]);
	double *demands = (double *)mxGetPr(prhs[4]);
	double *limit = (double *)mxGetPr(prhs[5]);
	char* policy = mxArrayToString(prhs[6]);
	bool linearPolicy = !strcmp(policy, "linear");

	/*if (linearPolicy)
		mexPrintf("Using linear policy\n");
	else
		mexPrintf("Using snowball policy\n");
	*/

	mwSize sbpp_dims[] = { dims_st[0],nsla };
	mxArray *pol = mxCreateNumericArray(2, sbpp_dims, mxDOUBLE_CLASS, mxREAL);
	double *pt = (double *)mxGetPr(pol);
	for (int i=0; i < *dims_st; i++)//po iteracja
	{
		for (int ii = 0; ii < ncomp; ii++)
		{
			traffic[ii] = 0.0;

		}

		for (int ii = 0; ii < nsla; ii++)
		{
			failtime[ii] = 0.0;
			st[ii] = PRIMARY;
			prevst[ii] = PRIMARY;
		}

		mxArray* ms= mxGetCell(prhs[0], i);
		mxArray* mt = mxGetCell(prhs[1], i);

		const double *time = (double *)mxGetPr(mt);
		const uint64_t* states = (uint64_t *)mxGetPr(ms);

		const mwSize* dims_st = mxGetDimensions(ms);
		const uint32_t nstates = *dims_st;

		double suma = 0.0;


		for (uint32_t index = 0; index < nstates; index++) //po stanach
		{
			register uint64_t s = states[index];

			for (int j = 0; j < nsla; j++)//po sla
			{
				bool primary = (s & primaries[j]) > 0;
				bool secondary = (s & secondaries[j]) > 0;

				
				bool cap = false;
				bool capcache = false;
				/*for (int ii = 0; ii < ncomp; ii++)
				{
					if ((traffic[ii] + demands[j])> limit[ii] && (1 << ii & secondaries[j]))
					{
						cap = true;
						break;
					}
						
				}*/

				
				switch (st[j])
				{
				case PRIMARY:
					if (primary) // pada 1
					{
						if (secondary) //pada zapas
						{
							st[j] = FAIL;
						}
						else
						{
							for (int ii = 0; ii < ncomp; ii++)
							{
								if ((traffic[ii] + demands[j])> limit[ii] && (1 << ii & secondaries[j]))
								{
									cap = true;
									break;
								}
							}
							capcache = true;


							if (cap)// braz pasma
							{
								st[j] = FAIL;
							}
							else //jest pasmo
							{
								//for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP += demand;});
								for (int ii = 0; ii < ncomp; ii++)
								{
									if (((1 << ii) & secondaries[j]))
									{
										traffic[ii] += demands[j];
									}
								}

								st[j] = SECONDARY;
							}
						}
					}
					break;
				case SECONDARY:
					//mexPrintf("sbpp: %d, %f\n", (int)st[j],time[index]);
					if (!primary) //wracamy
					{
						st[j] = PRIMARY;
						for (int ii = 0; ii < ncomp; ii++)
						{
							if ((1 << ii  & secondaries[j]))
							{
								traffic[ii] -= demands[j];
							}
						}

						break;
					}
					if (secondary) //awaria na zapasie
					{
						st[j] = FAIL;
						for (int ii = 0; ii < ncomp; ii++)
						{
							if ((1 << ii  & secondaries[j]))
							{
								traffic[ii] -= demands[j];
							}
						}

						break;
					}
					break;
				case FAIL:
					if (!primary)//wracamy
					{
						st[j] = PRIMARY;
						break;
					}

					if (!capcache)
					{
						for (int ii = 0; ii < ncomp; ii++)
						{
							if ((traffic[ii] + demands[j])> limit[ii] && (1 << ii & secondaries[j]))
							{
								cap = true;
								break;
							}
						}

					}

					if (!secondary && !cap)
					{
						//for_each(backupPath.begin(), backupPath.end(),[&](shared_ptr<Component>& c){c->currentSBPP += demand;});
						for (int ii = 0; ii < ncomp; ii++)
						{
							if ((1 <<ii  & secondaries[j]))
							{
								traffic[ii] += demands[j];
							}
						}

						st[j] = SECONDARY;
						break;
					}

				}//switch


				if (st[j] != prevst[j])//zmiana
				{
					//mexPrintf("zmiana z%d na %d\n", (int)prevst[j], (int)st[j]);
					if (st[j] == FAIL)
					{
						tmpTime[j] = time[index]; //zaczynamy zliczanie
					}
					else
					{
						if (prevst[j] == FAIL)//z awarii
						{
							if(linearPolicy)
								failtime[j] += (time[index]- tmpTime[j]); //czas awarii
							else
								failtime[j] += (time[index] - tmpTime[j])*(time[index] - tmpTime[j]); //kwadrat czasu awarii
						}

					}
					
				}
				prevst[j] = st[j];

			}


		}
		
		for (int indeks = 0; indeks < nsla; indeks++)
		{
			//pt[i] += demands[indeks]* failtime[indeks];//suma czasow awarii w roku
			if (demands[indeks] > 0)
			{
				int wpis = i + indeks*sbpp_dims[0];
				//mexPrintf("wpis: %d, %d, %d, i %d\n", wpis, sbpp_dims[0], indeks,i);
				//pt[wpis] = 3;
				pt[wpis] =  failtime[indeks];
				//if (linearPolicy)
				//	pt[wpis] += demands[indeks] * failtime[indeks];//suma czasow awarii w roku
				//else
				//	pt[wpis] += demands[indeks] * (failtime[indeks] * failtime[indeks]); //snowball
			}
			//mexPrintf("failtime %f\n", failtime[indeks]);
		}

		
	}

	plhs[0] = pol;
	delete[] traffic;
	delete[] st;
	delete[] prevst;
	delete[] failtime;
	delete[] tmpTime;

	return;
}

