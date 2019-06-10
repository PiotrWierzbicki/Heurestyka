#include "Rands.cpp"

class AntColony {
private:
	int numberOfNodes, numberOfANTS;
	int startCity, stopCity;
	double smallestValueOfRoute;
	int *nodesForAnt;

	int **GRAPH, **paths, **fullNet;
	double **pheromones, **modifiedPheromones, **nextCity;
	double ALPHA, BETA, Q, OF;

	bool breakFlag;

	Randoms *randoms;

	void newPheromones();

public:
	AntColony(int *network, int NODES, int ANTS, double alpha, double beta,
		double q, double ro, int start, int stop);
	~AntColony();

	void initialize(double pheromones[4][4], int dim);
	void setPheromones();

	void drawGRAPH();
	void printInformation();
	void printPheromones();
	void prtResults();
	void prtLength();

	void antRelease();
	int valid(int antNumberK);
	void path(int antNumberK);
	bool vizited(int antNumberK, int c);
	double cityPheromones(int cityi, int cityj, int antNumberK);
	int newCity();
	double computePathCost(int antNumberK);

	int *bestRoute, *PATH;
	int* abcd(int *network);
};