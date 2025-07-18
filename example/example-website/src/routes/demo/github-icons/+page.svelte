<script lang="ts">
	import dartHashes from '$lib/data/github-icons-dart.json';
	import pythonHashes from '$lib/data/github-icons-python.json';
	import type { AlgorithmsWithZ } from '$lib/types';

	let selectedAlgorithm: AlgorithmsWithZ = $state('ahash');
	let isLoading = $state(false);

	const algorithms = [
		{
			value: 'ahash' as AlgorithmsWithZ,
			label: 'Average Hash (aHash)',
			description: 'Fast and simple hashing'
		},
		{
			value: 'phash' as AlgorithmsWithZ,
			label: 'Perceptual Hash (pHash)',
			description: 'Most robust for modifications'
		},
		{
			value: 'dhash' as AlgorithmsWithZ,
			label: 'Difference Hash (dHash)',
			description: 'Good for crops and rotations'
		},
		{
			value: 'whash' as AlgorithmsWithZ,
			label: 'Wavelet Hash (wHash)',
			description: 'Balanced approach'
		},
		{
			value: 'ahash-z' as AlgorithmsWithZ,
			label: 'Average Hash with Z-Transform',
			description: 'aHash with z-transform preprocessing'
		},
		{
			value: 'phash-z' as AlgorithmsWithZ,
			label: 'Perceptual Hash with Z-Transform',
			description: 'pHash with z-transform preprocessing'
		},
		{
			value: 'dhash-z' as AlgorithmsWithZ,
			label: 'Difference Hash with Z-Transform',
			description: 'dHash with z-transform preprocessing'
		},
		{
			value: 'whash-z' as AlgorithmsWithZ,
			label: 'Wavelet Hash with Z-Transform',
			description: 'wHash with z-transform preprocessing'
		}
	];

	function getDartClusters() {
		return dartHashes.clusters[selectedAlgorithm] || [];
	}

	function getPythonClusters() {
		return pythonHashes.clusters[selectedAlgorithm] || [];
	}

	function findCorrespondingPythonCluster(dartCluster: any) {
		if (!dartCluster.images || dartCluster.images.length === 0) {
			return null;
		}

		const firstImageUrl = dartCluster.images[0].url;
		const pythonClusters = getPythonClusters();

		// Find the Python cluster that contains the same first image
		for (const pythonCluster of pythonClusters) {
			if (
				pythonCluster.images &&
				pythonCluster.images.some((img: any) => img.url === firstImageUrl)
			) {
				return pythonCluster;
			}
		}

		return null;
	}

	function handleAlgorithmChange(algorithm: AlgorithmsWithZ) {
		isLoading = true;
		selectedAlgorithm = algorithm;
		// Simulate loading delay
		setTimeout(() => {
			isLoading = false;
		}, 300);
	}

	function getAlgorithmDescription(algorithm: AlgorithmsWithZ) {
		const algo = algorithms.find((a) => a.value === algorithm);
		return algo ? algo.description : '';
	}
</script>

<svelte:head>
	<title>GitHub Icons Demo - dart_imagehash</title>
	<meta
		name="description"
		content="Compare image hashing results between Dart and Python implementations using GitHub icon datasets."
	/>
</svelte:head>

<div class="py-20">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<!-- Header -->
		<div class="mb-16">
			<div class="relative mb-6">
				<div class="absolute right-0 top-0">
					<a
						href="/demo"
						class="rounded-lg border border-white/20 bg-white/10 px-4 py-2 text-sm text-white transition-all hover:bg-white/20"
					>
						← Back to Demo Selection
					</a>
				</div>
				<div class="text-center">
					<h1 class="mb-6 text-4xl font-bold text-white sm:text-5xl">
						<span class="gradient-text">GitHub Icons Demo</span>
					</h1>
					<p class="mx-auto max-w-3xl text-xl text-gray-300">
						Compare image hashing results between Dart and Python implementations using real GitHub
						icon datasets. Icons are clustered by their perceptual hash similarity.
					</p>
				</div>
			</div>
		</div>

		<!-- Algorithm Selection -->
		<div class="mb-12 rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
			<h2 class="mb-6 text-2xl font-semibold text-white">Select Hashing Algorithm</h2>
			<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4 xl:grid-cols-4">
				{#each algorithms as algorithm}
					<button
						onclick={() => handleAlgorithmChange(algorithm.value)}
						class="rounded-lg border-2 p-4 text-left transition-all duration-200 {selectedAlgorithm ===
						algorithm.value
							? 'border-purple-500 bg-purple-500/20'
							: 'border-white/20 bg-white/5'} {algorithm.value.endsWith('-z')
							? 'border-l-4 border-l-orange-500'
							: ''}"
					>
						<div class="font-medium text-white">{algorithm.label}</div>
						<div class="mt-1 text-sm text-gray-300">{algorithm.description}</div>
					</button>
				{/each}
			</div>
		</div>

		<!-- Results Container -->
		{#if isLoading}
			<div class="flex justify-center py-20">
				<div class="flex items-center">
					<svg
						class="mr-3 h-8 w-8 animate-spin text-purple-500"
						xmlns="http://www.w3.org/2000/svg"
						fill="none"
						viewBox="0 0 24 24"
					>
						<circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"
						></circle>
						<path
							class="opacity-75"
							fill="currentColor"
							d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
						></path>
					</svg>
					<span class="text-white">Loading clusters...</span>
				</div>
			</div>
		{:else}
			<div class="space-y-8">
				<!-- Header for comparison -->
				<div class="grid grid-cols-1 gap-8 lg:grid-cols-2">
					<div class="rounded-2xl border border-blue-500/20 bg-blue-500/10 p-6 text-center">
						<div class="flex items-center justify-center">
							<div
								class="mr-3 flex h-10 w-10 items-center justify-center rounded-lg bg-blue-500/20"
							>
								<span class="text-xl">🎯</span>
							</div>
							<div>
								<h2 class="text-xl font-semibold text-white">Dart Implementation</h2>
								<p class="text-sm text-gray-300">
									{getAlgorithmDescription(selectedAlgorithm)}
								</p>
							</div>
						</div>
					</div>
					<div class="rounded-2xl border border-green-500/20 bg-green-500/10 p-6 text-center">
						<div class="flex items-center justify-center">
							<div
								class="mr-3 flex h-10 w-10 items-center justify-center rounded-lg bg-green-500/20"
							>
								<span class="text-xl">🐍</span>
							</div>
							<div>
								<h2 class="text-xl font-semibold text-white">Python Implementation</h2>
								<p class="text-sm text-gray-300">
									{getAlgorithmDescription(selectedAlgorithm)}
								</p>
							</div>
						</div>
					</div>
				</div>

				<!-- Side-by-side comparison -->
				<div class="space-y-6">
					{#each getDartClusters() as dartCluster}
						{@const pythonCluster = findCorrespondingPythonCluster(dartCluster)}
						<div class="grid grid-cols-1 gap-8 lg:grid-cols-2">
							<!-- Dart Result -->
							<div class="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
								<div class="rounded-lg border border-blue-500/20 bg-blue-500/10 p-6">
									<div class="mb-4 flex items-center justify-between">
										<h3 class="font-mono text-sm font-medium text-blue-300">
											Hash: {dartCluster.hash}
										</h3>
										<span class="rounded-full bg-blue-500/20 px-3 py-1 text-xs text-blue-300">
											{dartCluster.count} similar icons
										</span>
									</div>
									<div class="grid grid-cols-4 gap-4 sm:grid-cols-6 lg:grid-cols-4 xl:grid-cols-6">
										{#each dartCluster.images as image}
											<div class="group relative">
												<a
													href={image.repoUrl}
													target="_blank"
													rel="noopener noreferrer"
													class="block rounded-lg border border-white/10 bg-white/5 p-3 transition-all duration-200 hover:border-blue-400/50 hover:bg-blue-500/10"
												>
													<img
														src={image.url}
														alt={image.name}
														class="h-8 w-8 object-contain"
														loading="lazy"
													/>
												</a>
												<div
													class="absolute bottom-full left-1/2 mb-2 hidden -translate-x-1/2 transform rounded-md bg-gray-900 px-2 py-1 text-xs text-white group-hover:block"
												>
													{image.name}
												</div>
											</div>
										{/each}
									</div>
								</div>
							</div>

							<!-- Python Result -->
							<div class="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
								{#if pythonCluster}
									<div class="rounded-lg border border-green-500/20 bg-green-500/10 p-6">
										<div class="mb-4 flex items-center justify-between">
											<h3 class="font-mono text-sm font-medium text-green-300">
												Hash: {pythonCluster.hash}
											</h3>
											<span class="rounded-full bg-green-500/20 px-3 py-1 text-xs text-green-300">
												{pythonCluster.count} similar icons
											</span>
										</div>
										<div
											class="grid grid-cols-4 gap-4 sm:grid-cols-6 lg:grid-cols-4 xl:grid-cols-6"
										>
											{#each pythonCluster.images as image}
												<div class="group relative">
													<a
														href={image.repoUrl}
														target="_blank"
														rel="noopener noreferrer"
														class="block rounded-lg border border-white/10 bg-white/5 p-3 transition-all duration-200 hover:border-green-400/50 hover:bg-green-500/10"
													>
														<img
															src={image.url}
															alt={image.name}
															class="h-8 w-8 object-contain"
															loading="lazy"
														/>
													</a>
													<div
														class="absolute bottom-full left-1/2 mb-2 hidden -translate-x-1/2 transform rounded-md bg-gray-900 px-2 py-1 text-xs text-white group-hover:block"
													>
														{image.name}
													</div>
												</div>
											{/each}
										</div>
									</div>
								{:else}
									<div class="rounded-lg border border-gray-500/20 bg-gray-500/10 p-6">
										<div class="text-center">
											<div class="mb-2 text-gray-400">
												<span class="text-2xl">🔍</span>
											</div>
											<h3 class="text-sm font-medium text-gray-400">
												No corresponding cluster found
											</h3>
											<p class="mt-2 text-xs text-gray-500">
												The Python implementation did not group these icons in the same way
											</p>
										</div>
									</div>
								{/if}
							</div>
						</div>
					{/each}
				</div>
			</div>
		{/if}

		<!-- Information Section -->
		<div class="mt-16 rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
			<h2 class="mb-6 text-2xl font-semibold text-white">How It Works</h2>
			<div class="grid grid-cols-1 gap-8 md:grid-cols-3">
				<div class="text-center">
					<div
						class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-purple-500/20"
					>
						<span class="text-xl">📥</span>
					</div>
					<h3 class="mb-2 text-lg font-medium text-white">Collect Icons</h3>
					<p class="text-sm text-gray-300">
						Icons are collected from popular GitHub repositories like Eva Icons and Feather Icons.
					</p>
				</div>
				<div class="text-center">
					<div
						class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-purple-500/20"
					>
						<span class="text-xl">🔢</span>
					</div>
					<h3 class="mb-2 text-lg font-medium text-white">Generate Hashes</h3>
					<p class="text-sm text-gray-300">
						Each icon is converted to PNG and processed through both Dart and Python
						implementations. Regular and z-transform variants are available.
					</p>
				</div>
				<div class="text-center">
					<div
						class="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-purple-500/20"
					>
						<span class="text-xl">🎯</span>
					</div>
					<h3 class="mb-2 text-lg font-medium text-white">Cluster Similar</h3>
					<p class="text-sm text-gray-300">
						Icons with identical hashes are grouped together, showing visually similar icons.
					</p>
				</div>
			</div>
		</div>

		<!-- Z-Transform Information -->
		<div class="mt-8 rounded-lg border border-orange-600/20 bg-orange-600/10 p-6">
			<div class="mb-4 text-lg font-semibold text-orange-400">🔄 Z-Transform Variants</div>
			<p class="mb-4 text-gray-300">
				Z-transform variants (marked with orange border) apply histogram equalization preprocessing
				to normalize image brightness and contrast before hashing. This can improve clustering
				accuracy for images with varying lighting conditions.
			</p>
			<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
				<div>
					<h4 class="mb-2 font-medium text-orange-300">Regular Algorithms</h4>
					<p class="text-sm text-gray-400">
						Process images directly with their original pixel values and lighting.
					</p>
				</div>
				<div>
					<h4 class="mb-2 font-medium text-orange-300">Z-Transform Variants</h4>
					<p class="text-sm text-gray-400">
						Apply histogram equalization first, then hash the normalized image.
					</p>
				</div>
			</div>
		</div>

		<!-- Data Source Note -->
		<div class="mt-8 rounded-lg border border-yellow-600/20 bg-yellow-600/10 p-6 text-center">
			<div class="mb-2 text-lg font-semibold text-yellow-400">📊 Data Source</div>
			<p class="text-gray-300">
				This demo uses sample data showing how the icon clustering would work. The actual
				implementation processes thousands of real GitHub icons from repositories like
				<a
					href="https://github.com/akveo/eva-icons"
					target="_blank"
					rel="noopener noreferrer"
					class="text-yellow-400 hover:text-yellow-300">Eva Icons</a
				>
				and
				<a
					href="https://github.com/feathericons/feather"
					target="_blank"
					rel="noopener noreferrer"
					class="text-yellow-400 hover:text-yellow-300">Feather Icons</a
				>.
			</p>
		</div>
	</div>
</div>
