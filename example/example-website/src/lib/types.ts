export interface ImageData {
	name: string;
	url: string;
	repoUrl: string;
}

export interface ClusterData {
	hash: string;
	count: number;
	images: ImageData[];
}

export type Algorithms = 'ahash' | 'phash' | 'dhash' | 'whash';
export type AlgorithmsWithZ = Algorithms | 'ahash-z' | 'phash-z' | 'dhash-z' | 'whash-z';
export type AlgorithmClusters = {
	[key in AlgorithmsWithZ]: ClusterData[];
};

export interface HashData {
	algorithm: string;
	clusters: AlgorithmClusters;
}
