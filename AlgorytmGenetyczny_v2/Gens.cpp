#include "stdafx.h"
#include "Gens.h"
#include "components.h"

#include <cstdio>
#include <stdio.h>
#include <conio.h>
#include <iostream>

#include <cstdint>
#include <stdlib.h>
#include <time.h>

using namespace std;

//Konstruktor
Gens::Gens(int *network, int NODES, int CHILDS, int MUT, int start, int stop) {
	numberOfNodes = NODES;
	numberOfChilds = CHILDS;
	startCity = start;
	stopCity = stop;
	costOfBestRoute = INFINITY;
	mutateLvl = MUT;

	GRAPH = new int*[numberOfNodes];
	for (int i = 0; i < numberOfNodes; i++) {
		GRAPH[i] = new int[numberOfNodes];
		for (int j = 0; j < numberOfNodes; j++) {
			GRAPH[i][j] = *((network + i * numberOfNodes) + j);
		}
	}
}

//Destruktor
Gens::~Gens() {

}

//Inicjalizacja zmiennych: rodzice, tablica nowych potmoków, najlepsza sciezka, pojedynczy potomek i jego kopia
void Gens::initialize() {
	visited = new bool[numberOfNodes];
	parent1 = new int[numberOfNodes + 1];
	parent2 = new int[numberOfNodes + 1];
	for (int i = 0; i < numberOfNodes + 1; i++) parent1[i] = parent2[i] = -1;

	newChilds = new int *[numberOfChilds];
	for (int i = 0; i < numberOfChilds; i++) newChilds[i] = new int[numberOfNodes];

	for (int i = 0; i < numberOfChilds; i++) {
		for (int j = 0; j < numberOfNodes; j++) {
			newChilds[i][j] = -1;
		}
	}
	bestRoute = new int[numberOfNodes];
	offspring = new int[numberOfNodes];
	cpyOffspring = new int[numberOfNodes];
	for (int i = 0; i < numberOfNodes; i++) {
		bestRoute[i] = -1;
		offspring[i] = -1;
		cpyOffspring[i] = -1;
	}

	PATH = new int[numberOfNodes];
	for (int i = 0; i < numberOfNodes; i++) PATH[i] = -1;
}

void Gens::randPath(int *parent) {
	int i = 0;
	int r;
	for (int j = 1; j < numberOfNodes; j++) visited[j] = false;
	visited[startCity] = true;
	parent[0] = startCity;
	while (parent[i] != stopCity) {
		bool nextStep = false;
		int counter = 0;
		while (nextStep != true) {
			r = rand() % numberOfNodes;
			if ((GRAPH[parent[i]][r] > 0) && (visited[r] == false)) {
				nextStep = true;
				i++;
				parent[i] = r;
				visited[r] = true;
			}
			else counter++;
			if (counter > numberOfNodes*numberOfNodes*numberOfNodes) {
				for (int j = 1; j < numberOfNodes; j++) {
					visited[j] = false;
					parent[j] = -1;
				}
				i = 0;
				bool nextStep = false;
				break;
			}
		}
	}
}

//ustawianie paremetrow rodziców oraz najlepszej sciezki i jej koszt
void Gens::setParents() {
	randPath(parent1);
	randPath(parent2);

	costOfParent1 = 0, costOfParent2 = 0;
	int par1 = 1, par2 = 1;

	while (parent1[par1] != -1) {
		costOfParent1 += GRAPH[parent1[par1 - 1]][parent1[par1]];
		par1++;
	}
	while (parent2[par2] != -1) {
		costOfParent2 += GRAPH[parent2[par2 - 1]][parent2[par2]];
		par2++;
	}

	if (costOfParent1 > costOfParent2) {
		costOfBestRoute = costOfParent2;
		for (int i = 0; i < numberOfNodes; i++) {
			if (parent2[i] != -1) bestRoute[i] = parent2[i];
		}
	}
	else {
		costOfBestRoute = costOfParent1;
		for (int i = 0; i < numberOfNodes; i++) {
			if (parent1[i] != -1) bestRoute[i] = parent1[i];
		}
	}
}

//Glowna czesc algorytmu - nChild: iloœæ poprawnych potomków, w ka¿dej iteracji wypisywani s¹ akutalni rodzice oraz najlepsza œcie¿ka
//Która jednoczesnie musi byæ jednym z rodziców!
void Gens::makeNewPaths(int iterations) {
	srand(time(NULL));
	for (int i = 0; i < iterations; i++) {
		int nChild = 0;
		//cout <<endl << "Iteracja numer " << i + 1 << endl;
		//printParents();
		//printBestRoute();

		//Offspring - pojedynczy potomek dla potrzeby tej pêtli, póŸniej jeœli jest poprawny wpisywany jest do tablicy potomków(newChilds)
		for (int j = 0; j < numberOfChilds; j++) {
			offspring[0] = cpyOffspring[0] = startCity;

			for (int k = 1; k < numberOfNodes; k++) {
				offspring[k] = -1;
				cpyOffspring[k] = -1;
			}

			//Losowane s¹ pseudolosowe liczby - choose(jeœli jest 0 - gen pobierany od pierwszego rodzica, 1 - gen od drugiego rodzica)
			//Mutate - liczba od 1 do 100, jeœli jest mniejsza od mutateLvl(MUT) - to gen mutuje, na jeden z dowolnych wêz³ów.
			bool chooseRand0 = false;
			bool chooseRand1 = false;
			for (int k = 1; k < numberOfNodes; k++) {
				int choose, mutate;

				choose = rand() % 2;
				if (chooseRand0 == true) choose = 0;
				if (chooseRand1 == true) choose = 1;
				mutate = rand() % 100 + 1;

				if (choose == 0 || parent2[k] == -1) {
					offspring[k] = parent1[k];
					chooseRand0 = true;
				}
				else if (choose == 1 || parent1[k] == -1) {
					offspring[k] = parent2[k];
					chooseRand1 = true;
				}

				if (mutate < mutateLvl) offspring[k] = rand() % numberOfNodes;

				if (offspring[k] == stopCity) break;
			}

			//Jeœli potomek jest np. 0 3 3 4 5 7, to ta czêœæ kodu zmienia to na 0 3 4 5 7. 
			//Daje to wiêksze prawdopodobieñstwo poprawnego potomka
			int ii = 1;
			bool needCpy = false;
			for (int k = 1; k < numberOfNodes; k++) {
				if (offspring[k - 1] == offspring[k]) {
					needCpy = true;
				}
				else {
					cpyOffspring[ii] = offspring[k];
					ii++;
				}
			}
			if (needCpy == true) for (int k = 1; k < numberOfNodes; k++) offspring[k] = cpyOffspring[k];

			//Czy istnieje po³¹czenie miêdzy kolejnymi wêz³ami
			bool properOffspring = true;
			for (int k = 1; k < numberOfNodes; k++) {
				if (offspring[k - 1] != -1 && offspring[k] != -1) {
					if (GRAPH[offspring[k - 1]][offspring[k]] <= 0) {
						properOffspring = false;
					}
				}
			}

			//Czy powtarzaj¹ siê wêz³y, jeœli tak to b³¹d.
			for (int k = 0; k < numberOfNodes; k++) {
				for (int k2 = 0; k2 < numberOfNodes; k2++) {
					if (offspring[k] == offspring[k2] && k != k2 && offspring[k] != -1) {
						properOffspring = false;
						break;
					}
				}
			}

			//Czy œcie¿ka posiada wêze³ docelowy
			bool isStopCity = false;
			for (int k = 1; k < numberOfNodes; k++) {
				if (offspring[k] == stopCity) {
					isStopCity = true;
					break;
				}
			}
			if (isStopCity == false) properOffspring = false;

			//Jeœli wszystko jest ok, to offspring(czyli konkretny potomek) dopisywany jest do tablicy potomków z konkretnej iteracji
			if (properOffspring == true) {
				for (int k = 0; k < numberOfNodes; k++) {
					newChilds[nChild][k] = offspring[k];
				}
				nChild++;
			}
		}
		//printChilds(nChild);
		//Sprawdzenie kosztu ka¿dego potomka i ewentualna zamiana z rodzicem który ma wiêkszy koszt
		for (int j = 0; j < nChild; j++) {
			if (newChilds[j][0] == startCity) {
				int sum = 0, diff = 0;
				for (int k = 1; k < numberOfNodes; k++) {
					if (newChilds[j][k] == -1) break;

					sum += GRAPH[newChilds[j][k - 1]][newChilds[j][k]];
				}

				diff = costOfParent1 - costOfParent2;
				if (diff >= 0 && sum <= costOfParent1) {
					for (int p = 0; p < numberOfNodes + 1; p++) parent1[p] = -1;
					for (int c = 0; c < numberOfNodes; c++) {
						parent1[c] = newChilds[j][c];
						costOfParent1 = sum;
						if (sum <= costOfBestRoute) {
							bestRoute[c] = newChilds[j][c];
							costOfBestRoute = sum;
						}
					}
				}
				if (diff < 0 && sum <= costOfParent2) {
					for (int p = 0; p < numberOfNodes + 1; p++) parent2[p] = -1;
					for (int c = 0; c < numberOfNodes; c++) {
						parent2[c] = newChilds[j][c];
						costOfParent2 = sum;
						if (sum <= costOfBestRoute) {
							bestRoute[c] = newChilds[j][c];
							costOfBestRoute = sum;
						}
					}
				}
			}
		}
		/*cout << endl << "KONIEC ITERACJI" <<endl;
		for (int p = 0; p < 40; p++) {
		cout << "-";
		}
		cout << endl;*/
	}

	//printBestRoute();
}

//Wypisanie rodziców(œcie¿ek) i ich kosztów
void Gens::printParents() {
	cout << "Rodzic 1: ";
	for (int i = 0; i < numberOfNodes; i++) {
		if (parent1[i] != -1) cout << parent1[i] << " ";
	}
	cout << "Koszt: " << costOfParent1;
	cout << endl << "Rodzic 2: ";
	for (int i = 0; i < numberOfNodes; i++) {
		if (parent2[i] != -1) cout << parent2[i] << " ";
	}
	cout << "Koszt: " << costOfParent2 << endl;
}

//Rysowanie grafu
void Gens::drawGRAPH() {
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

//Wypisywanie dzieci
void Gens::printChilds(int childsNum) {
	cout << endl << "Poprawni potomkowie powstali w iteracji: " << endl;
	for (int i = 0; i < childsNum; i++) {
		for (int j = 0; j < numberOfNodes; j++) {
			cout << newChilds[i][j] << " ";
			if (newChilds[i][j] == stopCity) break;
		}
		cout << endl;
	}
}

//Wypisanie najlepszej œcie¿ki
void Gens::printBestRoute() {
	cout << endl << "Najlepsza akutalnie trasa: ";
	for (int i = 0; i < numberOfNodes; i++) {
		if (bestRoute[i] != -1) {
			cout << bestRoute[i] << " ";
		}
	}
	cout << " Koszt: " << costOfBestRoute << endl;
}

int* Gens::abcd(int *network) {
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

void Gens::parentsFromPreviousIteration(int *firstParent, int *secondParent) {
	for (int i = 0; i < numberOfNodes; i++) {
		parent1[i] = firstParent[i];
		parent2[i] = secondParent[i];
	}

	costOfParent1 = 0, costOfParent2 = 0;
	int par1 = 1, par2 = 1;

	while (parent1[par1] != -1) {
		costOfParent1 += GRAPH[parent1[par1 - 1]][parent1[par1]];
		par1++;
	}
	while (parent2[par2] != -1) {
		costOfParent2 += GRAPH[parent2[par2 - 1]][parent2[par2]];
		par2++;
	}

	if (costOfParent1 > costOfParent2) {
		costOfBestRoute = costOfParent2;
		for (int i = 0; i < numberOfNodes; i++) {
			if (parent2[i] != -1) bestRoute[i] = parent2[i];
		}
	}
	else {
		costOfBestRoute = costOfParent1;
		for (int i = 0; i < numberOfNodes; i++) {
			if (parent1[i] != -1) bestRoute[i] = parent1[i];
		}
	}
}