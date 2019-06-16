class Gens {
private:
	int startCity, stopCity, mutateLvl;
	int numberOfNodes, numberOfChilds, costOfBestRoute;
	int costOfParent1, costOfParent2;
	int *parent1, *parent2, *offspring, *cpyOffspring;
	int **GRAPH, **fullNet, **newChilds;

	bool *visited;

public:
	Gens(int *network, int NODES, int CHILDS, int MUT, int start, int stop);
	~Gens();

	int *PATH, *bestRoute;

	void initialize();
	void setParents();
	void randPath(int *parent);

	void makeNewPaths(int iterations);

	void printParents();
	void drawGRAPH();
	void printChilds(int childs);
	void printBestRoute();

	int* abcd(int *network);
	void parentsFromPreviousIteration(int *firstParent, int *secondParent);
};
