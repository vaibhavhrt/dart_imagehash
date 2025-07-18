<script lang="ts">
	const algorithms = [
		{
			name: 'Average Hash (aHash)',
			description:
				'The simplest and fastest hashing algorithm that works by reducing the image to a grayscale 8x8 thumbnail, calculating the average color value, and then setting each bit based on whether each pixel is above or below the average.',
			pros: [
				'Very fast computation',
				'Low memory usage',
				'Good for basic duplicate detection',
				'Works well with resize operations'
			],
			cons: [
				'Sensitive to color changes',
				'May not detect rotations well',
				'Less robust to transformations'
			],
			bestFor: 'Quick duplicate detection and basic similarity matching',
			complexity: 'O(1)',
			icon: '📊'
		},
		{
			name: 'Perceptual Hash (pHash)',
			description:
				'A more sophisticated algorithm that uses the Discrete Cosine Transform (DCT) to identify the most important visual features of an image, making it more robust to various transformations.',
			pros: [
				'Robust to scaling and rotation',
				'Good compression resistance',
				'Handles lighting changes well',
				'More reliable than aHash'
			],
			cons: [
				'More computationally expensive',
				'Slightly higher memory usage',
				'May be overkill for simple tasks'
			],
			bestFor: 'Professional image matching and content-based retrieval',
			complexity: 'O(n log n)',
			icon: '🔍'
		},
		{
			name: 'Difference Hash (dHash)',
			description:
				'Calculates the hash based on the relative gradient between adjacent pixels, making it particularly good at detecting structural changes in images.',
			pros: [
				'Good for structural similarity',
				'Efficient computation',
				'Handles cropping well',
				'Two variants: horizontal and vertical'
			],
			cons: [
				'Sensitive to significant transformations',
				'May not work well with very noisy images',
				'Less robust than pHash'
			],
			bestFor: 'Detecting crops, minor edits, and structural similarities',
			complexity: 'O(1)',
			icon: '📈'
		},
		{
			name: 'Wavelet Hash (wHash)',
			description:
				'Uses the Haar wavelet transform to capture both spatial and frequency information, providing a good balance between robustness and computational efficiency.',
			pros: [
				'Balanced robustness',
				'Good for multi-scale analysis',
				'Handles various transformations',
				'Efficient frequency domain analysis'
			],
			cons: [
				'More complex implementation',
				'Moderate computational cost',
				'May be sensitive to extreme transformations'
			],
			bestFor: 'General-purpose image matching with good robustness',
			complexity: 'O(n log n)',
			icon: '🌊'
		}
	];

	const comparisonMetrics = [
		{
			metric: 'Speed',
			ahash: 95,
			phash: 70,
			dhash: 90,
			whash: 75
		},
		{
			metric: 'Accuracy',
			ahash: 70,
			phash: 95,
			dhash: 80,
			whash: 85
		},
		{
			metric: 'Memory Usage',
			ahash: 95,
			phash: 80,
			dhash: 90,
			whash: 85
		},
		{
			metric: 'Robustness',
			ahash: 60,
			phash: 95,
			dhash: 75,
			whash: 85
		}
	];
</script>

<svelte:head>
	<title>Features - dart_imagehash</title>
	<meta
		name="description"
		content="Explore the different image hashing algorithms available in dart_imagehash: aHash, pHash, dHash, and wHash."
	/>
</svelte:head>

<div class="py-20">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<!-- Header -->
		<div class="mb-16 text-center">
			<h1 class="mb-6 text-4xl font-bold text-white sm:text-5xl">
				<span class="gradient-text">Algorithm Features</span>
			</h1>
			<p class="mx-auto max-w-3xl text-xl text-gray-300">
				Choose the right image hashing algorithm for your specific needs. Each algorithm has its
				strengths and optimal use cases.
			</p>
		</div>

		<!-- Algorithm Cards -->
		<div class="space-y-16">
			{#each algorithms as algorithm, index}
				<div class="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
					<div class="flex flex-col lg:flex-row lg:items-start lg:space-x-8">
						<div class="mb-6 flex-shrink-0 text-center lg:mb-0 lg:text-left">
							<div class="mb-4 text-6xl">{algorithm.icon}</div>
							<div
								class="inline-flex items-center rounded-full bg-purple-600/20 px-3 py-1 text-sm font-medium text-purple-300"
							>
								{algorithm.complexity}
							</div>
						</div>

						<div class="flex-grow">
							<h3 class="mb-4 text-2xl font-bold text-white">{algorithm.name}</h3>
							<p class="mb-6 leading-relaxed text-gray-300">{algorithm.description}</p>

							<div class="mb-6 grid grid-cols-1 gap-6 md:grid-cols-2">
								<div>
									<h4 class="mb-3 flex items-center font-semibold text-green-400">
										<svg class="mr-2 h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
											<path
												fill-rule="evenodd"
												d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
												clip-rule="evenodd"
											></path>
										</svg>
										Advantages
									</h4>
									<ul class="space-y-2">
										{#each algorithm.pros as pro}
											<li class="flex items-start text-gray-300">
												<span class="mr-2 text-green-400">•</span>
												{pro}
											</li>
										{/each}
									</ul>
								</div>

								<div>
									<h4 class="mb-3 flex items-center font-semibold text-red-400">
										<svg class="mr-2 h-5 w-5" fill="currentColor" viewBox="0 0 20 20">
											<path
												fill-rule="evenodd"
												d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
												clip-rule="evenodd"
											></path>
										</svg>
										Limitations
									</h4>
									<ul class="space-y-2">
										{#each algorithm.cons as con}
											<li class="flex items-start text-gray-300">
												<span class="mr-2 text-red-400">•</span>
												{con}
											</li>
										{/each}
									</ul>
								</div>
							</div>

							<div class="rounded-lg border border-blue-600/20 bg-blue-600/10 p-4">
								<h4 class="mb-2 font-semibold text-blue-400">Best For:</h4>
								<p class="text-gray-300">{algorithm.bestFor}</p>
							</div>
						</div>
					</div>
				</div>
			{/each}
		</div>

		<!-- Comparison Chart -->
		<div class="mt-20">
			<div class="mb-12 text-center">
				<h2 class="mb-4 text-3xl font-bold text-white sm:text-4xl">Performance Comparison</h2>
				<p class="mx-auto max-w-2xl text-lg text-gray-300">
					Compare different algorithms across key performance metrics
				</p>
			</div>

			<div class="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
				<div class="overflow-x-auto">
					<table class="w-full">
						<thead>
							<tr class="border-b border-white/10">
								<th class="px-6 py-4 text-left font-semibold text-white">Metric</th>
								<th class="px-6 py-4 text-center font-semibold text-white">aHash</th>
								<th class="px-6 py-4 text-center font-semibold text-white">pHash</th>
								<th class="px-6 py-4 text-center font-semibold text-white">dHash</th>
								<th class="px-6 py-4 text-center font-semibold text-white">wHash</th>
							</tr>
						</thead>
						<tbody>
							{#each comparisonMetrics as metric}
								<tr class="border-b border-white/5">
									<td class="px-6 py-4 font-medium text-gray-300">{metric.metric}</td>
									<td class="px-6 py-4 text-center">
										<div class="flex items-center justify-center">
											<div class="h-2 w-20 overflow-hidden rounded-full bg-gray-700">
												<div
													class="h-full rounded-full bg-gradient-to-r from-purple-500 to-blue-500 transition-all duration-500"
													style="width: {metric.ahash}%"
												></div>
											</div>
											<span class="ml-2 text-sm text-gray-400">{metric.ahash}%</span>
										</div>
									</td>
									<td class="px-6 py-4 text-center">
										<div class="flex items-center justify-center">
											<div class="h-2 w-20 overflow-hidden rounded-full bg-gray-700">
												<div
													class="h-full rounded-full bg-gradient-to-r from-purple-500 to-blue-500 transition-all duration-500"
													style="width: {metric.phash}%"
												></div>
											</div>
											<span class="ml-2 text-sm text-gray-400">{metric.phash}%</span>
										</div>
									</td>
									<td class="px-6 py-4 text-center">
										<div class="flex items-center justify-center">
											<div class="h-2 w-20 overflow-hidden rounded-full bg-gray-700">
												<div
													class="h-full rounded-full bg-gradient-to-r from-purple-500 to-blue-500 transition-all duration-500"
													style="width: {metric.dhash}%"
												></div>
											</div>
											<span class="ml-2 text-sm text-gray-400">{metric.dhash}%</span>
										</div>
									</td>
									<td class="px-6 py-4 text-center">
										<div class="flex items-center justify-center">
											<div class="h-2 w-20 overflow-hidden rounded-full bg-gray-700">
												<div
													class="h-full rounded-full bg-gradient-to-r from-purple-500 to-blue-500 transition-all duration-500"
													style="width: {metric.whash}%"
												></div>
											</div>
											<span class="ml-2 text-sm text-gray-400">{metric.whash}%</span>
										</div>
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			</div>
		</div>

		<!-- Usage Recommendations -->
		<div class="mt-20">
			<div class="mb-12 text-center">
				<h2 class="mb-4 text-3xl font-bold text-white sm:text-4xl">Usage Recommendations</h2>
			</div>

			<div class="grid grid-cols-1 gap-8 md:grid-cols-2">
				<div class="rounded-xl border border-white/10 bg-white/5 p-6 backdrop-blur-sm">
					<h3 class="mb-4 text-xl font-semibold text-white">🚀 For Speed</h3>
					<p class="mb-4 text-gray-300">
						When performance is critical and you need to process thousands of images quickly.
					</p>
					<div class="rounded-lg border border-purple-600/20 bg-purple-600/10 p-3">
						<code class="text-purple-300">ImageHasher.averageHash(image)</code>
					</div>
				</div>

				<div class="rounded-xl border border-white/10 bg-white/5 p-6 backdrop-blur-sm">
					<h3 class="mb-4 text-xl font-semibold text-white">🎯 For Accuracy</h3>
					<p class="mb-4 text-gray-300">
						When you need the most reliable results and can afford slightly slower computation.
					</p>
					<div class="rounded-lg border border-purple-600/20 bg-purple-600/10 p-3">
						<code class="text-purple-300">ImageHasher.perceptualHash(image)</code>
					</div>
				</div>

				<div class="rounded-xl border border-white/10 bg-white/5 p-6 backdrop-blur-sm">
					<h3 class="mb-4 text-xl font-semibold text-white">✂️ For Crops</h3>
					<p class="mb-4 text-gray-300">
						When you need to detect cropped or edited versions of images.
					</p>
					<div class="rounded-lg border border-purple-600/20 bg-purple-600/10 p-3">
						<code class="text-purple-300">ImageHasher.differenceHash(image)</code>
					</div>
				</div>

				<div class="rounded-xl border border-white/10 bg-white/5 p-6 backdrop-blur-sm">
					<h3 class="mb-4 text-xl font-semibold text-white">⚖️ For Balance</h3>
					<p class="mb-4 text-gray-300">
						When you need a good balance of speed, accuracy, and robustness.
					</p>
					<div class="rounded-lg border border-purple-600/20 bg-purple-600/10 p-3">
						<code class="text-purple-300">ImageHasher.waveletHash(image)</code>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
