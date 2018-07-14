#include "Rands.cpp"

class AntColony {
private:
	int numberOfNodes, numberOfANTS;
	int startCity, stopCity;
	double smallestValueOfRoute;
	int *bestRoute, *nodesForAnt;
	
	int **GRAPH, **paths;
	double **pheromones, **modifiedPheromones, **nextCity;
	double ALPHA, BETA, Q, OF;

	bool breakFlag;

	Randoms *randoms;

	void newPheromones();

public:
	AntColony(int *network, int NODES, int ANTS, double alpha, double beta,
				double q, double ro);
	~AntColony();

	void getInformation();
	void initialize();
	void setPheromones();

	void drawGRAPH();
	void printInformation();
	void printPheromones();
	void prtResults();
	void prtLength();

	void antRelease(int iterator);
	int valid(int antNumberK, int iteration);
	void path(int antNumberK);
	bool vizited(int antNumberK, int c);
	double cityPheromones(int cityi, int cityj, int antNumberK);
	int newCity();
	double computePathCost(int antNumberK);
};