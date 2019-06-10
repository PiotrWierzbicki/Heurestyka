#include "stdafx.h"
#include "AntColony.h"
#include "components.h"

#include <cstdio>
#include <iostream>
#include <cstdlib>
#include <conio.h>

#include <cmath>
#include <limits>
#include <climits>

using namespace std;

//Konstruktor przyjmuj¹cy: wskaŸnik do sieci, iloœæ wêz³ów oraz mrówek. 
//Parametry alfa i beta u¿ywane przy wybieraniu nastêpnego wêz³a na podstawie feromonów
// Q oraz OF potrzebne do aktualizowania grafu feromonów
//ponadto tworzony jest graf wewn¹trz klasy(dok³adnie taki sam sam jak przekazywany z zewn¹trz)
AntColony::AntColony(int *network, int NODES, int ANTS, double alpha, double beta,
	double q, double of, int start, int stop) {
	startCity = start;
	stopCity = stop;
	numberOfNodes = NODES;
	numberOfANTS = ANTS;
	ALPHA = alpha;
	BETA = beta;
	Q = q;
	OF = of;

	randoms = new Randoms(1);

	GRAPH = new int*[numberOfNodes];
	for (int i = 0; i < numberOfNodes; i++) {
		GRAPH[i] = new int[numberOfNodes];
		for (int j = 0; j < numberOfNodes; j++) {
			GRAPH[i][j] = *((network + i * numberOfNodes) + j);
		}
	}
}


AntColony::~AntColony() {

}


//inicjalizacja wszystkich potrzebnych danych takich jak macierz feromonów,
//œcie¿ek dla danej mrówki, tablica najlepszych dróg(koszta), flagi
void AntColony::initialize(double AllPheromones[4][4], int dim) {
	pheromones = new double*[numberOfNodes];
	modifiedPheromones = new double*[numberOfNodes];
	nextCity = new double*[numberOfNodes - 1];

	for (int i = 0; i < numberOfNodes; i++) {
		pheromones[i] = new double[numberOfNodes];
		modifiedPheromones[i] = new double[numberOfNodes];
		nextCity[i] = new double[2];

		for (int j = 0; j < 2; j++) nextCity[i][j] = -1.0;

		for (int j = 0; j < numberOfNodes; j++) {
			pheromones[i][j] = AllPheromones[i][j];
			modifiedPheromones[i][j] = AllPheromones[i][j];
		}
	}

	paths = new int *[numberOfANTS];
	for (int i = 0; i < numberOfANTS; i++) {
		paths[i] = new int[numberOfNodes];
		for (int j = 0; j < numberOfNodes; j++) {
			paths[i][j] = -1;
		}
	}

	smallestValueOfRoute = (double)INT_MAX;
	bestRoute = new int[numberOfNodes];
	for (int i = 0; i < numberOfNodes; i++) bestRoute[i] = -1;

	breakFlag = false;
	nodesForAnt = new int[numberOfANTS];
	for (int i = 0; i < numberOfANTS; i++) nodesForAnt[i] = 1;

	PATH = new int[numberOfNodes];
	for (int i = 0; i < numberOfNodes; i++) PATH[i] = -1;
}


//ustawienie pocz¹tkowe feromonów - wszêdzie taka sama wartoœæ(1.0), przez co
//pierwsze przejœcie mrówek jest ca³kowicie losowe(tak jak w rzeczywistoœci)
void AntColony::setPheromones() {
	for (int i = 0; i < numberOfNodes; i++) {
		for (int j = 0; j < numberOfNodes; j++) {
			if (GRAPH[i][j] > 0) {
				pheromones[i][j] = 1.0;
				pheromones[j][i] = 1.0;
			}
			else pheromones[i][i] = 0.0;
		}
	}
}


//rysowanie grafu 
void AntColony::drawGRAPH() {
	cout << "GRAPH: " << endl;
	cout << "  | ";
	for (int i = 0; i < numberOfNodes; i++) printf("%2d  ", i);
	cout << endl << "- | ";
	for (int i = 0; i < numberOfNodes; i++) cout << "----";
	cout << endl;

	for (int i = 0; i < numberOfNodes; i++) {
		cout << i << " | ";
		for (int j = 0; j < numberOfNodes; j++) {
			if (i == j)		printf("%2s  ", "x");
			else			printf("%2d  ", GRAPH[i][j]);
		}
		cout << endl;
	}
	cout << endl;
}


void AntColony::printInformation() {
	cout << "Szukanie trasy z " << startCity << " do " << stopCity << endl;
}


//drukowanie macierzy feromonów
void AntColony::printPheromones() {
	cout << "Feromony:" << endl;
	cout << "  | ";
	for (int i = 0; i < numberOfNodes; i++) printf("%5d   ", i);
	cout << endl << "- | ";

	for (int i = 0; i < numberOfNodes; i++) cout << "--------";
	cout << endl;

	for (int i = 0; i < numberOfNodes; i++) {
		cout << i << " | ";
		for (int j = 0; j < numberOfNodes; j++) {
			if (i == j) {
				printf("%5s   ", "x");
				continue;
			}
			if (GRAPH[i][j] > 0) printf("%7.3f ", pheromones[i][j]);
			else {
				if (pheromones[i][j] == 0.0)	printf("%5.0f   ", pheromones[i][j]);
				else							printf("%7.3f ", pheromones[i][j]);
			}
		}
		cout << endl;
	}
	cout << endl;
}


//Wyniki
void AntColony::prtResults() {
	cout << "Wynik: " << endl;
	for (int i = 0; i < numberOfNodes; i++) {
		cout << bestRoute[i] << " ";
		if (bestRoute[i] == stopCity) break;
	}
}


//Wypisanie d³ugoœci
void AntColony::prtLength() {
	smallestValueOfRoute = 0;
	for (int i = 0; i < numberOfNodes - 1; i++) {
		if (bestRoute[i] == stopCity) break;
		smallestValueOfRoute += GRAPH[bestRoute[i]][bestRoute[i + 1]];
	}

	cout << endl << smallestValueOfRoute << endl;
}


//Mózg ca³ego algorytmu:
//Pêtla iteracyjna pierwsza, mówi jak wiele razy wypuszczane s¹ mrówki
//Nastêpnie dla ka¿dej iteracji, wypuszczana jest odpowiednia iloœæ mrówek, nstêpnie pêtla while sprawdza czy ca³a utworzona trasa
//jest poprawna(œlepe zau³ki, brak po³¹czeñ miêdzy miastami, powtórzenia itp) dopiero gdy z metody 'path()' wyliczona zostanie 
//poprawna œcie¿ka, która koñczy siê w mieœcie docelowym funkcja while jest przerywana.
//PóŸniej sprawdzany jest koszt po³¹czenia, aktualizowana macierz feromonów oraz resetowanie zmiennych na potrzeby nastepnych iteracji
void AntColony::antRelease() {
	for (int j = 0; j < numberOfANTS; j++) {
		//cout << "Mrowka numer: " << j+1 << " zostala wypuszczona" << endl;
		breakFlag = false;
		nodesForAnt[j] = 1;
		while (0 != valid(j)) {
			for (int c = 0; c < numberOfNodes; c++) {
				paths[j][c] = -1;
			}
			path(j);
			if (breakFlag == true) break;
		}

		//for (int k = 0; k < nodesForAnt[j]; k++) cout << paths[j][k]<<" ";
		//cout << " - trasa zostala znaleziona" << endl;
		double rlentgh = computePathCost(j);
		//cout << rlentgh << endl;

		if (rlentgh < smallestValueOfRoute) {
			smallestValueOfRoute = rlentgh;
			for (int r = 0; r < numberOfNodes; r++) bestRoute[r] = paths[j][r];
		}
		//cout << "Mrowka numer " << j + 1 << " zakonczyla przemarsz" << endl<< endl;
		//cout << nodesForAnt[j] << endl;
	}

	//cout << endl << "Aktualizowanie feromonow . . .";
	newPheromones();
	//cout << " zrobione" << endl << endl;
	//printPheromones();

	for (int i = 0; i < numberOfANTS; i++) {
		for (int j = 0; j < numberOfNodes; j++) paths[i][j] = -1;
	}
	prtResults();
	//prtLength();
}

//Metoda sprwadzaj¹ca poprawnoœæ œcie¿ki dla danej mrówki, gdy zwróci 0 wszystko jest ok
//-1 - trasa nie posiada 'obecnego' (i) lub nastêpnego miasta w tablicy paths
//-2 - nie istnieje po³¹czenie miêdzy kolejnymi miastami w tablicy paths
//-3 - w tablicy paths powtarza siê przynajmniej jedno miasto 
int AntColony::valid(int antNumberK) {
	for (int i = 0; i < numberOfNodes - 1; i++) {
		int cityi = paths[antNumberK][i];
		int cityj = paths[antNumberK][i + 1];

		if (cityi < 0 || cityj < 0) {
			nodesForAnt[antNumberK] = 1;
			return -1;
		}

		if (GRAPH[cityi][cityj] < 1) {
			nodesForAnt[antNumberK] = 1;
			return -2;
		}
		for (int j = 0; j < i - 1; j++) {
			if (paths[antNumberK][i] == paths[antNumberK][j]) {
				nodesForAnt[antNumberK] = 1;
				return -3;
			}
		}
	}
	return 0;
}

//Metoda do wyznaczenia œcie¿ki dla konkretnej mrówki(antNumberK) 
//Jeœli dane miasto/wêze³ nie jest odwiedzone dodane jest do listy miast dostêpnych oraz wartoœæ feromonu
//Nastêpnie wywo³ywana jest metoda która wybiera miasto na podstawie feromonów, oraz jeœli dotarliœmy do miasta docelowego(stopCity)
//To ca³a metoda jest przerywana(poniewa¿ dostaliœmy to co chcieliœmy) i ustawiana jest flaga, która jest sprawdzana w antRelease
void AntColony::path(int antNumberK) {
	paths[antNumberK][0] = startCity;
	for (int i = 0; i < numberOfNodes - 1; i++) {
		int cityi = paths[antNumberK][i];
		int count = 0;
		for (int c = 0; c < numberOfNodes; c++) {
			if (cityi == c) continue;
			if (GRAPH[cityi][c] > 0) {
				if (!vizited(antNumberK, c)) {
					nextCity[count][0] = cityPheromones(cityi, c, antNumberK);
					nextCity[count][1] = (double)c;
					count++;
				}
			}
		}

		if (0 == count) return;

		paths[antNumberK][i + 1] = newCity();
		nodesForAnt[antNumberK]++;
		if (paths[antNumberK][i + 1] == stopCity) {
			breakFlag = true;
			break;
		}
	}
}

//Czy zosta³o odwiedzone dane miasto
bool AntColony::vizited(int antNumberK, int c) {
	for (int i = 0; i < numberOfNodes; i++) {
		if (paths[antNumberK][i] == -1) break;
		if (paths[antNumberK][i] == c) return true;
	}
	return false;
}

//Obliczanie feromonów dla danych wêz³ów oraz mrówki
double AntColony::cityPheromones(int cityi, int cityj, int antNumberK) {
	double ETAij = (double)pow(1 / (double)GRAPH[cityi][cityj], BETA);
	double TAUij = (double)pow(pheromones[cityi][cityj], ALPHA);

	double sum = 0.0;
	for (int c = 0; c < numberOfNodes; c++) {
		if (GRAPH[cityi][c]>0) {
			if (!vizited(antNumberK, c)) {
				double ETA = (double)pow(1 / (double)GRAPH[cityi][c], BETA);
				double TAU = (double)pow(pheromones[cityi][c], ALPHA);
				sum += (ETA*TAU);
			}
		}
	}
	return (ETAij * TAUij) / sum;
}

//Wybieranie miasta z dostêpnych wez³ów(np nie odwiedzonych, tych do których mo¿emy siê bezpoœrednio itp) na podstawie si³y feromonów
int AntColony::newCity() {
	double xi = randoms->Uniforme();
	int i = 0;
	double sum = nextCity[i][0];
	while (sum < xi) {
		i++;
		sum += nextCity[i][0];
	}
	return (int)nextCity[i][1];
}

//Koszt ca³ej œcie¿ki dla danej mrówki
double AntColony::computePathCost(int antNumberK) {
	double sum = 0.0;
	for (int i = 0; i < nodesForAnt[antNumberK] - 1; i++) {
		if (GRAPH[paths[antNumberK][i]][paths[antNumberK][i + 1]]>0) {
			sum = sum + (double)GRAPH[paths[antNumberK][i]][paths[antNumberK][i + 1]];
		}
		else break;
	}
	return sum;
}


//Ustawianie poziomu nowych feromonów po przejœciu danej iteracji - prywatna metoda
void AntColony::newPheromones() {
	for (int i = 0; i < numberOfANTS; i++) {
		double rlength = computePathCost(i);
		for (int j = 0; j < nodesForAnt[i] - 1; j++) {
			int cityi = paths[i][j];
			int cityj = paths[i][j + 1];
			modifiedPheromones[cityi][cityj] += Q / rlength;
			modifiedPheromones[cityj][cityi] += Q / rlength;
		}
	}

	for (int i = 0; i < numberOfNodes; i++) {
		for (int j = 0; j < numberOfNodes; j++) {
			pheromones[i][j] = (1 - OF) * pheromones[i][j] + modifiedPheromones[i][j];
			modifiedPheromones[i][j] = 0.0;
		}
	}
}

int* AntColony::abcd(int *network) {
	fullNet = new int*[numberOfNodes];
	for (int i = 0; i < numberOfNodes; i++) {
		fullNet[i] = new int[numberOfNodes];
		for (int j = 0; j < numberOfNodes; j++) {
			fullNet[i][j] = *((network + i * numberOfNodes) + j);
		}
	}

	for (int k = 0; k < numberOfNodes; k++) {
		if (bestRoute[k + 1] != -1) {
			int counter = 1;
			for (int i = 0; i < numberOfNodes; i++) {
				for (int j = i; j < numberOfNodes; j++) {
					if (fullNet[i][j] > 0) {
						if (bestRoute[k] < bestRoute[k + 1]) {
							if (i == bestRoute[k] && j == bestRoute[k + 1]) PATH[k] = counter;
						}
						else {
							if (j == bestRoute[k] && i == bestRoute[k + 1]) PATH[k] = counter;
						}
						counter++;
					}
				}
			}
		}
		else {
			break;
		}
	}
	return PATH;
}
