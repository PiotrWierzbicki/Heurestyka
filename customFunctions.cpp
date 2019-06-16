#include "stdafx.h"
#include "customFunctions.h"
#include <stdio.h>
#include <iostream>

int partition(double data[], int p, int r) {
	double x = data[p];
	double w;
	int i = p, j = r;

	while (true) {
		while (data[j] > x)
			j--;
		while (data[i] < x)
			i++;
		if (i < j) {
			w = data[i];
			data[i] = data[j];
			data[j] = w;
			i++;
			j--;
		}
		else return j;
	}
}

void quicksort(double data[], int p, int r) {
	int q;
	if (p < r) {
		q = partition(data, p, r);
		quicksort(data, p, q);
		quicksort(data, q + 1, r);
	}
}


float percentile95th(double data[], int N) {
	/*for (int i = 0; i < N; i++) {
	std::cout << data[i] << std::endl;
	}
	std::cout<<std::endl << std::endl;*/
	quicksort(data, 0, N - 1);
	/*for (int i = 0; i < N; i++) {
	std::cout << data[i] << std::endl;
	}*/

	int smallN = 9500;
	return data[smallN];
}


double *getBestNParents(double data[], int N) {
	quicksort(data, 0, N - 1);
	return data;
}