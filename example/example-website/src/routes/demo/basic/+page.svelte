<script lang="ts">
	import dartData from '$lib/data/basic-demo-dart.json';
	import pythonData from '$lib/data/basic-demo-python.json';
	import type { Algorithms } from '$lib/types';
	import { base } from '$app/paths';

	let selectedAlgorithm = $state<Algorithms>('ahash');
	let selectedImage1 = $state('');
	let selectedImage2 = $state('');
	let comparisonResult = $state<{
		dartHash1: string;
		dartHash2: string;
		pythonHash1: string;
		pythonHash2: string;
		dartDistance: number;
		pythonDistance: number;
		dartSimilarity: number;
		pythonSimilarity: number;
	} | null>(null);

	const algorithms: { value: Algorithms; label: string; description: string }[] = [
		{ value: 'ahash', label: 'Average Hash (aHash)', description: 'Fast and simple hashing' },
		{
			value: 'phash',
			label: 'Perceptual Hash (pHash)',
			description: 'Most robust for modifications'
		},
		{
			value: 'dhash',
			label: 'Difference Hash (dHash)',
			description: 'Good for crops and rotations'
		},
		{ value: 'whash', label: 'Wavelet Hash (wHash)', description: 'Balanced approach' }
	];

	const sampleImages = dartData.images;

	function calculateHammingDistance(hash1: string, hash2: string): number {
		if (hash1.length !== hash2.length) return -1;

		let distance = 0;
		for (let i = 0; i < hash1.length; i++) {
			if (hash1[i] !== hash2[i]) {
				distance++;
			}
		}
		return distance;
	}

	function calculateSimilarity(distance: number, hashLength: number): number {
		return 100.0 * (1.0 - distance / hashLength);
	}

	function compareImages() {
		if (!selectedImage1 || !selectedImage2 || !selectedAlgorithm) {
			comparisonResult = null;
			return;
		}

		const dartImage1 = dartData.images.find((img) => img.name === selectedImage1);
		const dartImage2 = dartData.images.find((img) => img.name === selectedImage2);
		const pythonImage1 = pythonData.images.find((img) => img.name === selectedImage1);
		const pythonImage2 = pythonData.images.find((img) => img.name === selectedImage2);

		if (!dartImage1 || !dartImage2 || !pythonImage1 || !pythonImage2) {
			comparisonResult = null;
			return;
		}

		const dartHash1 = dartImage1.hashes[selectedAlgorithm];
		const dartHash2 = dartImage2.hashes[selectedAlgorithm];
		const pythonHash1 = pythonImage1.hashes[selectedAlgorithm];
		const pythonHash2 = pythonImage2.hashes[selectedAlgorithm];

		const dartDistance = calculateHammingDistance(dartHash1, dartHash2);
		const pythonDistance = calculateHammingDistance(pythonHash1, pythonHash2);
		const dartSimilarity = calculateSimilarity(dartDistance, dartHash1.length);
		const pythonSimilarity = calculateSimilarity(pythonDistance, pythonHash1.length);

		comparisonResult = {
			dartHash1,
			dartHash2,
			pythonHash1,
			pythonHash2,
			dartDistance,
			pythonDistance,
			dartSimilarity,
			pythonSimilarity
		};
	}

	// Reactive comparison when selections change
	$effect(() => {
		compareImages();
	});

	function getAlgorithmDescription(algorithm: string) {
		const algo = algorithms.find((a) => a.value === algorithm);
		return algo ? algo.description : '';
	}

	function getSimilarityColor(similarity: number) {
		if (similarity >= 90) return 'text-green-400';
		if (similarity >= 70) return 'text-yellow-400';
		if (similarity >= 50) return 'text-orange-400';
		return 'text-red-400';
	}

	function getSimilarityLabel(similarity: number) {
		if (similarity >= 90) return 'Very Similar';
		if (similarity >= 70) return 'Similar';
		if (similarity >= 50) return 'Somewhat Similar';
		return 'Different';
	}

	function getImageDescription(imageName: string) {
		if (imageName.includes('modified')) return 'Modified version';
		if (imageName.includes('cat1')) return 'Original image';
		return 'Different image';
	}
</script>

<svelte:head>
	<title>Basic Demo - dart_imagehash</title>
	<meta
		name="description"
		content="Interactive demo comparing image hashes using different algorithms with sample images."
	/>
</svelte:head>

<div class="py-20">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<!-- Header -->
		<div class="mb-16">
			<div class="relative mb-6">
				<div class="absolute -top-12 right-0 sm:-top-8 md:-top-6">
					<a
						href="{base}/demo"
						class="rounded-lg border border-white/20 bg-white/10 px-3 py-1.5 text-xs text-white transition-all hover:bg-white/20 sm:px-4 sm:py-2 sm:text-sm"
					>
						← Back to Demo Selection
					</a>
				</div>
				<div class="text-center">
					<h1 class="mb-6 text-4xl font-bold text-white sm:text-5xl">
						<span class="gradient-text">Basic Image Comparison</span>
					</h1>
					<p class="mx-auto max-w-3xl text-xl text-gray-300">
						Compare sample images using different perceptual hashing algorithms. Select images and
						an algorithm to see how similar they are.
					</p>
				</div>
			</div>
		</div>

		<!-- Algorithm Selection -->
		<div class="mb-12 rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
			<h2 class="mb-6 text-2xl font-semibold text-white">Choose Algorithm</h2>
			<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
				{#each algorithms as algorithm}
					<button
						onclick={() => (selectedAlgorithm = algorithm.value)}
						class="rounded-lg border-2 p-4 text-left transition-all duration-200 {selectedAlgorithm ===
						algorithm.value
							? 'border-purple-500 bg-purple-500/20'
							: 'border-white/20 bg-white/5'}"
					>
						<div class="font-medium text-white">{algorithm.label}</div>
						<div class="mt-1 text-sm text-gray-300">{algorithm.description}</div>
					</button>
				{/each}
			</div>
		</div>

		<!-- Image Selection -->
		<div class="mb-12 grid grid-cols-1 gap-8 lg:grid-cols-2">
			<!-- First Image -->
			<div class="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
				<h3 class="mb-6 text-xl font-semibold text-white">First Image</h3>
				<div class="grid grid-cols-1 gap-4">
					{#each sampleImages as image}
						<button
							onclick={() => (selectedImage1 = image.name)}
							class="flex items-center rounded-lg border-2 p-4 transition-all duration-200 {selectedImage1 ===
							image.name
								? 'border-blue-500 bg-blue-500/20'
								: 'border-white/20 bg-white/5'}"
						>
							<img
								src={image.url}
								alt={image.name}
								class="mr-4 h-16 w-16 rounded-lg object-cover"
								loading="lazy"
							/>
							<div class="text-left">
								<div class="font-medium text-white">{image.name}</div>
								<div class="text-sm text-gray-300">{getImageDescription(image.name)}</div>
							</div>
						</button>
					{/each}
				</div>
			</div>

			<!-- Second Image -->
			<div class="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
				<h3 class="mb-6 text-xl font-semibold text-white">Second Image</h3>
				<div class="grid grid-cols-1 gap-4">
					{#each sampleImages as image}
						<button
							onclick={() => (selectedImage2 = image.name)}
							class="flex items-center rounded-lg border-2 p-4 transition-all duration-200 {selectedImage2 ===
							image.name
								? 'border-green-500 bg-green-500/20'
								: 'border-white/20 bg-white/5'}"
						>
							<img
								src={image.url}
								alt={image.name}
								class="mr-4 h-16 w-16 rounded-lg object-cover"
								loading="lazy"
							/>
							<div class="text-left">
								<div class="font-medium text-white">{image.name}</div>
								<div class="text-sm text-gray-300">{getImageDescription(image.name)}</div>
							</div>
						</button>
					{/each}
				</div>
			</div>
		</div>

		<!-- Comparison Result -->
		{#if comparisonResult}
			<div class="mb-12 rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
				<h2 class="mb-6 text-2xl font-semibold text-white">Comparison Result</h2>
				<div class="grid grid-cols-1 gap-8 lg:grid-cols-2">
					<!-- Dart Results -->
					<div class="space-y-6">
						<div class="rounded-lg border border-blue-500/20 bg-blue-500/10 p-6">
							<h3 class="mb-3 text-lg font-medium text-blue-300">🎯 Dart Implementation</h3>
							<div class="space-y-3">
								<div>
									<div class="text-sm text-gray-300">First Image ({selectedImage1})</div>
									<div class="font-mono text-blue-300">{comparisonResult.dartHash1}</div>
								</div>
								<div>
									<div class="text-sm text-gray-300">Second Image ({selectedImage2})</div>
									<div class="font-mono text-blue-300">{comparisonResult.dartHash2}</div>
								</div>
								<hr class="border-blue-500/30" />
								<div class="flex justify-between">
									<span class="text-gray-300">Distance:</span>
									<span class="font-mono text-white">{comparisonResult.dartDistance}</span>
								</div>
								<div class="flex justify-between">
									<span class="text-gray-300">Similarity:</span>
									<span class="font-mono {getSimilarityColor(comparisonResult.dartSimilarity)}">
										{comparisonResult.dartSimilarity.toFixed(2)}%
									</span>
								</div>
								<div class="flex justify-between">
									<span class="text-gray-300">Assessment:</span>
									<span class="font-medium {getSimilarityColor(comparisonResult.dartSimilarity)}">
										{getSimilarityLabel(comparisonResult.dartSimilarity)}
									</span>
								</div>
							</div>
						</div>
					</div>

					<!-- Python Results -->
					<div class="space-y-6">
						<div class="rounded-lg border border-green-500/20 bg-green-500/10 p-6">
							<h3 class="mb-3 text-lg font-medium text-green-300">🐍 Python Implementation</h3>
							<div class="space-y-3">
								<div>
									<div class="text-sm text-gray-300">First Image ({selectedImage1})</div>
									<div class="font-mono text-green-300">{comparisonResult.pythonHash1}</div>
								</div>
								<div>
									<div class="text-sm text-gray-300">Second Image ({selectedImage2})</div>
									<div class="font-mono text-green-300">{comparisonResult.pythonHash2}</div>
								</div>
								<hr class="border-green-500/30" />
								<div class="flex justify-between">
									<span class="text-gray-300">Distance:</span>
									<span class="font-mono text-white">{comparisonResult.pythonDistance}</span>
								</div>
								<div class="flex justify-between">
									<span class="text-gray-300">Similarity:</span>
									<span class="font-mono {getSimilarityColor(comparisonResult.pythonSimilarity)}">
										{comparisonResult.pythonSimilarity.toFixed(2)}%
									</span>
								</div>
								<div class="flex justify-between">
									<span class="text-gray-300">Assessment:</span>
									<span class="font-medium {getSimilarityColor(comparisonResult.pythonSimilarity)}">
										{getSimilarityLabel(comparisonResult.pythonSimilarity)}
									</span>
								</div>
							</div>
						</div>
					</div>
				</div>

				<!-- Algorithm Info -->
				<div class="mt-6 rounded-lg border border-purple-500/20 bg-purple-500/10 p-6">
					<h3 class="mb-3 text-lg font-medium text-purple-300">
						Algorithm: {algorithms.find((a) => a.value === selectedAlgorithm)?.label}
					</h3>
					<div class="text-white">{getAlgorithmDescription(selectedAlgorithm)}</div>
					<div class="mt-2 text-sm text-gray-400">
						Hash Length: {comparisonResult.dartHash1.length} bits
					</div>
				</div>
			</div>
		{:else}
			<div class="mb-12 rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
				<div class="text-center">
					<div class="mb-4 text-4xl">🔍</div>
					<h2 class="mb-4 text-2xl font-semibold text-white">Select Images to Compare</h2>
					<p class="text-gray-300">
						Choose two images and an algorithm to see their similarity comparison.
					</p>
				</div>
			</div>
		{/if}

		<!-- Code Example -->
		<div class="mb-12 rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
			<h2 class="mb-6 text-2xl font-semibold text-white">Code Example</h2>
			<div class="rounded-lg border border-gray-500/20 bg-gray-900/50 p-6">
				<pre class="text-sm text-gray-300"><code
						>{`import 'package:dart_imagehash/dart_imagehash.dart';

// Load images
final image1 = decodeImage(File('${selectedImage1 || 'image1.jpg'}').readAsBytesSync())!;
final image2 = decodeImage(File('${selectedImage2 || 'image2.jpg'}').readAsBytesSync())!;

// Calculate ${selectedAlgorithm} hash
final hash1 = ImageHasher.${
							selectedAlgorithm === 'ahash'
								? 'averageHash'
								: selectedAlgorithm === 'phash'
									? 'perceptualHash'
									: selectedAlgorithm === 'dhash'
										? 'differenceHash'
										: 'waveletHash'
						}(image1);
final hash2 = ImageHasher.${
							selectedAlgorithm === 'ahash'
								? 'averageHash'
								: selectedAlgorithm === 'phash'
									? 'perceptualHash'
									: selectedAlgorithm === 'dhash'
										? 'differenceHash'
										: 'waveletHash'
						}(image2);

// Compare hashes
final distance = hash1 - hash2;
final similarity = 100.0 * (1.0 - (distance / hash1.bits.length));

print('Hash 1: \$hash1');
print('Hash 2: \$hash2');
print('Distance: \$distance');
print('Similarity: \${similarity.toStringAsFixed(2)}%');`}</code
					></pre>
			</div>
		</div>

		<!-- Information Section -->
		<div class="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
			<h2 class="mb-6 text-2xl font-semibold text-white">About the Sample Images</h2>
			<div class="grid grid-cols-1 gap-8 md:grid-cols-3">
				<div class="text-center">
					<div class="mx-auto mb-4 h-24 w-24 overflow-hidden rounded-full bg-blue-500/20">
						<img
							src={sampleImages.find((img) => img.name === 'cat1.JPG')?.url || ''}
							alt="cat1.JPG"
							class="h-full w-full object-cover"
							loading="lazy"
						/>
					</div>
					<h3 class="mb-2 text-lg font-medium text-white">cat1.JPG</h3>
					<p class="text-sm text-gray-300">Original image used as the baseline for comparison.</p>
				</div>
				<div class="text-center">
					<div class="mx-auto mb-4 h-24 w-24 overflow-hidden rounded-full bg-green-500/20">
						<img
							src={sampleImages.find((img) => img.name === 'cat1-modified.JPG')?.url || ''}
							alt="cat1-modified.JPG"
							class="h-full w-full object-cover"
							loading="lazy"
						/>
					</div>
					<h3 class="mb-2 text-lg font-medium text-white">cat1-modified.JPG</h3>
					<p class="text-sm text-gray-300">
						Modified version of cat1.JPG with cropping and added drawings.
					</p>
				</div>
				<div class="text-center">
					<div class="mx-auto mb-4 h-24 w-24 overflow-hidden rounded-full bg-purple-500/20">
						<img
							src={sampleImages.find((img) => img.name === 'cat2.JPG')?.url || ''}
							alt="cat2.JPG"
							class="h-full w-full object-cover"
							loading="lazy"
						/>
					</div>
					<h3 class="mb-2 text-lg font-medium text-white">cat2.JPG</h3>
					<p class="text-sm text-gray-300">Completely different image for comparison.</p>
				</div>
			</div>
		</div>
	</div>
</div>
