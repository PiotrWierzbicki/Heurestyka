#include "stdafx.h"
#include "components.h"

void Sla::onEvent(double time )
{
	for_each(colectors.begin(),colectors.end(),
		[&](shared_ptr<StatsColector>& colector){
			colector->update(path,backupPath,linkBackup,time);
	});
}

//const char* ThrePolicy::name="Thre";
//const char* ContPolicy::name="Cont";
//const char* AvailPolicy::name="Avail";
//const char* Loss<Linear>::name = "Linear";
//const char* Loss<FizedRestart>::name = "FizedRestart";
//const char* Loss<Snowball>::name = "Snowball";