class Gens {
private:
	int startCity, stopCity, mutateLvl;
	int numberOfNodes, numberOfChilds, costOfBestRoute;
	int costOfParent1, costOfParent2;
	int *parent1, *parent2, *offspring, *cpyOffspring, *bestRoute;
	int **GRAPH, **newChilds;

public:
	Gens(int *network, int NODES, int CHILDS, int MUT);
	~Gens();

	void initialize();
	void setParents();

	void makeNewPaths(int iterations);

	void printParents();
	void drawGRAPH();
	void printChilds(int childs);
	void printBestRoute();
};
