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

//Konstruktor przyjmuj�cy: wska�nik do sieci, ilo�� w�z��w oraz mr�wek. 
//Parametry alfa i beta u�ywane przy wybieraniu nast�pnego w�z�a na podstawie feromon�w
// Q oraz OF potrzebne do aktualizowania grafu feromon�w
//ponadto tworzony jest graf wewn�trz klasy(dok�adnie taki sam sam jak przekazywany z zewn�trz)
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


//inicjalizacja wszystkich potrzebnych danych takich jak macierz feromon�w,
//�cie�ek dla danej mr�wki, tablica najlepszych dr�g(koszta), flagi
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


//ustawienie pocz�tkowe feromon�w - wsz�dzie taka sama warto��(1.0), przez co
//pierwsze przej�cie mr�wek jest ca�kowicie losowe(tak jak w rzeczywisto�ci)
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


//drukowanie macierzy feromon�w
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


//Wypisanie d�ugo�ci
void AntColony::prtLength() {
	smallestValueOfRoute = 0;
	for (int i = 0; i < numberOfNodes - 1; i++) {
		if (bestRoute[i] == stopCity) break;
		smallestValueOfRoute += GRAPH[bestRoute[i]][bestRoute[i + 1]];
	}

	cout << endl << smallestValueOfRoute << endl;
}


//M�zg ca�ego algorytmu:
//P�tla iteracyjna pierwsza, m�wi jak wiele razy wypuszczane s� mr�wki
//Nast�pnie dla ka�dej iteracji, wypuszczana jest odpowiednia ilo�� mr�wek, nst�pnie p�tla while sprawdza czy ca�a utworzona trasa
//jest poprawna(�lepe zau�ki, brak po��cze� mi�dzy miastami, powt�rzenia itp) dopiero gdy z metody 'path()' wyliczona zostanie 
//poprawna �cie�ka, kt�ra ko�czy si� w mie�cie docelowym funkcja while jest przerywana.
//P�niej sprawdzany jest koszt po��czenia, aktualizowana macierz feromon�w oraz resetowanie zmiennych na potrzeby nastepnych iteracji
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

//Metoda sprwadzaj�ca poprawno�� �cie�ki dla danej mr�wki, gdy zwr�ci 0 wszystko jest ok
//-1 - trasa nie posiada 'obecnego' (i) lub nast�pnego miasta w tablicy paths
//-2 - nie istnieje po��czenie mi�dzy kolejnymi miastami w tablicy paths
//-3 - w tablicy paths powtarza si� przynajmniej jedno miasto 
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

//Metoda do wyznaczenia �cie�ki dla konkretnej mr�wki(antNumberK) 
//Je�li dane miasto/w�ze� nie jest odwiedzone dodane jest do listy miast dost�pnych oraz warto�� feromonu
//Nast�pnie wywo�ywana jest metoda kt�ra wybiera miasto na podstawie feromon�w, oraz je�li dotarli�my do miasta docelowego(stopCity)
//To ca�a metoda jest przerywana(poniewa� dostali�my to co chcieli�my) i ustawiana jest flaga, kt�ra jest sprawdzana w antRelease
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

//Czy zosta�o odwiedzone dane miasto
bool AntColony::vizited(int antNumberK, int c) {
	for (int i = 0; i < numberOfNodes; i++) {
		if (paths[antNumberK][i] == -1) break;
		if (paths[antNumberK][i] == c) return true;
	}
	return false;
}

//Obliczanie feromon�w dla danych w�z��w oraz mr�wki
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

//Wybieranie miasta z dost�pnych wez��w(np nie odwiedzonych, tych do kt�rych mo�emy si� bezpo�rednio itp) na podstawie si�y feromon�w
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

//Koszt ca�ej �cie�ki dla danej mr�wki
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


//Ustawianie poziomu nowych feromon�w po przej�ciu danej iteracji - prywatna metoda
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
