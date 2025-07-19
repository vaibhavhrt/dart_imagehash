<script lang="ts">
	import { base } from '$app/paths';
</script>

<svelte:head>
	<title>Demo - dart_imagehash</title>
	<meta
		name="description"
		content="Try out the dart_imagehash library with our interactive demo. Compare images using different hashing algorithms."
	/>
</svelte:head>

<div class="py-20">
	<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
		<!-- Header -->
		<div class="mb-16 text-center">
			<h1 class="mb-6 text-4xl font-bold text-white sm:text-5xl">
				<span class="gradient-text">Interactive Demo</span>
			</h1>
			<p class="mx-auto max-w-3xl text-xl text-gray-300">
				Experience the power of perceptual image hashing. Choose from our interactive demos below.
			</p>
		</div>

		<!-- Demo Options -->
		<div class="mb-12 grid grid-cols-1 gap-8 md:grid-cols-2">
			<!-- Basic Demo -->
			<div class="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
				<div class="mb-6 flex items-center">
					<div class="mr-4 flex h-12 w-12 items-center justify-center rounded-lg bg-purple-500/20">
						<span class="text-xl">🎮</span>
					</div>
					<div>
						<h2 class="text-xl font-semibold text-white">Basic Image Comparison</h2>
						<p class="text-sm text-gray-300">Compare two images using different algorithms</p>
					</div>
				</div>
				<p class="mb-6 text-gray-300">
					Select two sample images and compare their similarity using different hashing algorithms.
					Perfect for understanding how each algorithm works.
				</p>
				<a
					href="{base}/demo/basic"
					class="inline-block rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 px-6 py-3 font-semibold text-white shadow-lg transition-all duration-300 hover:from-purple-700 hover:to-blue-700"
				>
					Try Basic Demo
				</a>
			</div>

			<!-- GitHub Icons Demo -->
			<div class="rounded-2xl border border-white/10 bg-white/5 p-8 backdrop-blur-sm">
				<div class="mb-6 flex items-center">
					<div class="mr-4 flex h-12 w-12 items-center justify-center rounded-lg bg-green-500/20">
						<span class="text-xl">📊</span>
					</div>
					<div>
						<h2 class="text-xl font-semibold text-white">GitHub Icons Clustering</h2>
						<p class="text-sm text-gray-300">Compare Dart vs Python implementations</p>
					</div>
				</div>
				<p class="mb-6 text-gray-300">
					See how similar icons from GitHub repositories are clustered together using both Dart and
					Python implementations. Great for understanding real-world applications.
				</p>
				<a
					href="{base}/demo/github-icons"
					class="inline-block rounded-lg bg-gradient-to-r from-green-600 to-teal-600 px-6 py-3 font-semibold text-white shadow-lg transition-all duration-300 hover:from-green-700 hover:to-teal-700"
				>
					View GitHub Icons Demo
				</a>
			</div>
		</div>
	</div>
</div>
