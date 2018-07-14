#include "stdafx.h"
#include "Gens.h"

#include <cstdio>
#include <iostream>

#include <cstdint>
#include <stdlib.h>
#include <time.h>


using namespace std;

//Konstruktor
Gens::Gens(int *network, int NODES, int CHILDS, int MUT) {
	numberOfNodes = NODES;
	numberOfChilds = CHILDS;
	startCity = 0;
	stopCity = 7;
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

//Inicjalizacja zmiennych: rodzice, tablica nowych potmok�w, najlepsza sciezka, pojedynczy potomek i jego kopia
void Gens::initialize() {
	parent1 = new int[numberOfNodes];
	parent2 = new int[numberOfNodes];
	for (int i = 0; i < numberOfNodes; i++) parent1[i] = parent2[i] = -1;

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
}

//ustawianie paremetrow rodzic�w oraz najlepszej sciezki i jej koszt
void Gens::setParents() {
	parent1[0] = 0; parent1[1] = 1; parent1[2] = 3;
	parent1[3] = 4; parent1[4] = 2; parent1[5] = 6; parent1[6] = 7;

	parent2[0] = 0; parent2[1] = 3; parent2[2] = 4;
	parent2[3] = 5; parent2[4] = 2; parent2[5] = 6; parent2[6] = 7;
	
	//parent2[0] = 0; parent2[1] = 2; parent2[2] = 6; parent2[3] = 7;

	costOfParent1 = 0, costOfParent2 = 0;
	int par1=1, par2 = 1;
	while (parent1[par1] != -1) {
		costOfParent1 += GRAPH[parent1[par1 - 1]][parent1[par1]];
		par1++;
	}
	while (parent2[par2] != -1) {
		costOfParent2 += GRAPH[parent2[par2 -1]][parent2[par2]];
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

//Glowna czesc algorytmu - nChild: ilo�� poprawnych potomk�w, w ka�dej iteracji wypisywani s� akutalni rodzice oraz najlepsza �cie�ka
//Kt�ra jednoczesnie musi by� jednym z rodzic�w!
void Gens::makeNewPaths(int iterations) {
	srand(time(NULL));
	for (int i = 0; i < iterations; i++) {
		int nChild = 0;
		cout <<endl << "Iteracja numer " << i + 1 << endl;
		printParents();
		printBestRoute();

		//Offspring - pojedynczy potomek dla potrzeby tej p�tli, p�niej je�li jest poprawny wpisywany jest do tablicy potomk�w(newChilds)
		for (int j = 0; j < numberOfChilds; j++) {
			offspring[0] = cpyOffspring[0] = startCity;
			
			for (int k = 1; k < numberOfNodes; k++) {
				offspring[k] = -1;
				cpyOffspring[k] = -1;
			}

			//Losowane s� pseudolosowe liczby - choose(je�li jest 0 - gen pobierany od pierwszego rodzica, 1 - gen od drugiego rodzica)
			//Mutate - liczba od 1 do 100, je�li jest mniejsza od mutateLvl(MUT) - to gen mutuje, na jeden z dowolnych w�z��w.
			for (int k = 1; k < numberOfNodes; k++) {
				int choose, mutate;

				choose = rand() % 2;
				mutate = rand() % 100 + 1;

				if (choose == 0 || parent2[k]==-1) offspring[k] = parent1[k];
				else if (choose == 1 || parent1[k] == -1) offspring[k] = parent2[k];

				if (mutate < mutateLvl) offspring[k] = rand() % numberOfNodes;

				if (offspring[k] == stopCity) break;
			}

			//Je�li potomek jest np. 0 3 3 4 5 7, to ta cz�� kodu zmienia to na 0 3 4 5 7. 
			//Daje to wi�ksze prawdopodobie�stwo poprawnego potomka
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
			if(needCpy == true) for (int k = 1; k < numberOfNodes; k++) offspring[k] = cpyOffspring[k];

			//Czy istnieje po��czenie mi�dzy kolejnymi w�z�ami
			bool properOffspring = true;
			for (int k = 1; k < numberOfNodes; k++) {
				if (offspring[k-1] != -1 && offspring[k] != -1) {
					if (GRAPH[offspring[k - 1]][offspring[k]] <= 0) {
						properOffspring = false;
					}
				}
			}

			//Czy powtarzaj� si� w�z�y, je�li tak to b��d.
			for (int k = 0; k < numberOfNodes; k++) {
				for (int k2 = 0; k2 < numberOfNodes; k2++) {
					if (offspring[k] == offspring[k2] && k!=k2 && offspring[k]!=-1) {
						properOffspring = false;
						break;
					}
				}
			}

			//Czy �cie�ka posiada w�ze� docelowy
			bool isStopCity = false;
			for (int k = 1; k < numberOfNodes; k++) {
				if (offspring[k] == stopCity) {
					isStopCity = true;
					break;
				}
			}
			if (isStopCity == false) properOffspring = false;

			//Je�li wszystko jest ok, to offspring(czyli konkretny potomek) dopisywany jest do tablicy potomk�w z konkretnej iteracji
			if (properOffspring == true) {
				for (int k = 0; k < numberOfNodes; k++) {
					newChilds[nChild][k] = offspring[k];
				}
				nChild++;
			}
		}
		printChilds(nChild);
		//Sprawdzenie kosztu ka�dego potomka i ewentualna zamiana z rodzicem kt�ry ma wi�kszy koszt
		for (int j = 0; j < nChild; j++) {
			if (newChilds[j][0] == 0) {
				int sum = 0, diff=0;
				for (int k = 1; k < numberOfNodes; k++) {
					if (newChilds[j][k]==-1) break;

					sum += GRAPH[newChilds[j][k - 1]][newChilds[j][k]];
				}			

				diff = costOfParent1 - costOfParent2;
				if (diff >= 0 && sum<=costOfParent1) {
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
		cout << endl << "KONIEC ITERACJI" <<endl;
		for (int p = 0; p < 40; p++) {
			cout << "-";
		}
		cout << endl;
	}
}

//Wypisanie rodzic�w(�cie�ek) i ich koszt�w
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
			cout<< newChilds[i][j]<<" ";
			if (newChilds[i][j] == stopCity) break;
		}
		cout << endl;
	}
}

//Wypisanie najlepszej �cie�ki
void Gens::printBestRoute() {
	cout << endl << "Najlepsza akutalnie trasa: ";
	for (int i = 0; i < numberOfNodes; i++) {
		if (bestRoute[i] != -1) {
			cout << bestRoute[i] << " ";
		}
	}
	cout << " Koszt: " << costOfBestRoute<<endl;
}