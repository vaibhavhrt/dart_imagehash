<script lang="ts">
	import { onMount } from 'svelte';
	import { base } from '$app/paths';

	let isVisible = $state(false);

	onMount(() => {
		isVisible = true;
	});

	const features = [
		{
			title: 'Average Hash (aHash)',
			description: 'Fast and simple hashing comparing pixels against image average',
			icon: '📊'
		},
		{
			title: 'Perceptual Hash (pHash)',
			description: 'Robust hashing using discrete cosine transform',
			icon: '🔍'
		},
		{
			title: 'Difference Hash (dHash)',
			description: 'Efficient hashing based on adjacent pixel comparisons',
			icon: '📈'
		},
		{
			title: 'Wavelet Hash (wHash)',
			description: 'Advanced hashing using Haar wavelet transform',
			icon: '🌊'
		}
	];

	const useCases = [
		{
			title: 'Duplicate Detection',
			description: 'Find and remove duplicate images from your collection',
			icon: '🔍'
		},
		{
			title: 'Similar Image Search',
			description: 'Locate visually similar images even with modifications',
			icon: '🎯'
		},
		{
			title: 'Content Moderation',
			description: 'Detect inappropriate content variations automatically',
			icon: '🛡️'
		}
	];
</script>

<svelte:head>
	<title>dart_imagehash - Perceptual Image Hashing for Dart</title>
	<meta
		name="description"
		content="A comprehensive Dart package for perceptual image hashing with multiple algorithms including aHash, pHash, dHash, and wHash."
	/>
</svelte:head>

<div class="relative overflow-hidden">
	<!-- Hero Section -->
	<section class="relative py-20 sm:py-32">
		<div class="absolute inset-0 bg-gradient-to-r from-purple-600/20 to-blue-600/20 blur-3xl"></div>
		<div class="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="text-center" class:opacity-0={!isVisible} class:animate-fade-in-up={isVisible}>
				<h1 class="mb-6 text-4xl font-bold text-white sm:text-6xl">
					<span class="gradient-text">Perceptual Image Hashing</span>
					<br />
					<span class="text-gray-300">for Dart</span>
				</h1>
				<p class="mx-auto mb-8 max-w-3xl text-xl text-gray-300">
					Generate compact, fixed-length fingerprints from images to find duplicates, detect similar
					images, and perform content-based image retrieval with ease.
				</p>
				<div class="flex flex-col justify-center gap-4 sm:flex-row">
					<a
						href="https://pub.dev/packages/dart_imagehash"
						target="_blank"
						rel="noopener noreferrer"
						class="rounded-lg bg-gradient-to-r from-purple-600 to-blue-600 px-8 py-3 font-semibold text-white shadow-lg transition-all duration-300 hover:from-purple-700 hover:to-blue-700 hover:shadow-xl"
					>
						Get Started
					</a>
					<a
						href="{base}/demo"
						class="rounded-lg border border-white/20 bg-white/10 px-8 py-3 font-semibold text-white backdrop-blur-sm transition-all duration-300 hover:bg-white/20"
					>
						Try Demo
					</a>
				</div>
			</div>
		</div>
	</section>

	<!-- Features Section -->
	<section class="relative py-20">
		<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="mb-16 text-center">
				<h2 class="mb-4 text-3xl font-bold text-white sm:text-4xl">Multiple Hashing Algorithms</h2>
				<p class="mx-auto max-w-2xl text-lg text-gray-300">
					Choose from four different perceptual hashing algorithms, each optimized for different use
					cases
				</p>
			</div>

			<div class="grid grid-cols-1 gap-8 md:grid-cols-2 lg:grid-cols-4">
				{#each features as feature, index}
					<div class="feature-card text-center" style="animation-delay: {index * 0.1}s">
						<div class="mb-4 text-4xl">{feature.icon}</div>
						<h3 class="mb-3 text-xl font-semibold text-white">{feature.title}</h3>
						<p class="text-gray-300">{feature.description}</p>
					</div>
				{/each}
			</div>
		</div>
	</section>

	<!-- Code Example Section -->
	<section class="relative py-20">
		<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="mb-16 text-center">
				<h2 class="mb-4 text-3xl font-bold text-white sm:text-4xl">Simple to Use</h2>
				<p class="mx-auto max-w-2xl text-lg text-gray-300">
					Get started with just a few lines of code
				</p>
			</div>

			<div class="mx-auto max-w-4xl">
				<div class="rounded-lg border border-white/10 bg-gray-900/50 p-6 backdrop-blur-sm">
					<div class="mb-4 flex items-center justify-between">
						<span class="font-mono text-sm text-gray-400">example.dart</span>
						<button
							class="text-gray-400 transition-colors hover:text-white"
							onclick={() =>
								navigator.clipboard.writeText(
									document.querySelector('.code-content')?.textContent || ''
								)}
							aria-label="Copy code to clipboard"
						>
							<svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"
								></path>
							</svg>
						</button>
					</div>
					<pre class="code-content overflow-x-auto text-sm text-gray-100"><code
							>{`import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:dart_imagehash/dart_imagehash.dart';

void main() {
  // Load images
  final image1 = img.decodeImage(File('image1.jpg').readAsBytesSync())!;
  final image2 = img.decodeImage(File('image2.jpg').readAsBytesSync())!;

  // Calculate hashes
  final hash1 = ImageHasher.averageHash(image1);
  final hash2 = ImageHasher.averageHash(image2);

  // Compare similarity
  final distance = hash1 - hash2;
  final similarity = 1.0 - (distance / hash1.length);
  
  print('Similarity: \${(similarity * 100).toStringAsFixed(2)}%');
}`}</code
						></pre>
				</div>
			</div>
		</div>
	</section>

	<!-- Use Cases Section -->
	<section class="relative py-20">
		<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="mb-16 text-center">
				<h2 class="mb-4 text-3xl font-bold text-white sm:text-4xl">Perfect for Many Use Cases</h2>
				<p class="mx-auto max-w-2xl text-lg text-gray-300">
					From content moderation to duplicate detection, image hashing has countless applications
				</p>
			</div>

			<div class="grid grid-cols-1 gap-8 md:grid-cols-3">
				{#each useCases as useCase, index}
					<div class="feature-card text-center" style="animation-delay: {index * 0.1}s">
						<div class="mb-4 text-4xl">{useCase.icon}</div>
						<h3 class="mb-3 text-xl font-semibold text-white">{useCase.title}</h3>
						<p class="text-gray-300">{useCase.description}</p>
					</div>
				{/each}
			</div>
		</div>
	</section>

	<!-- Installation Section -->
	<section class="relative py-20">
		<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="mb-16 text-center">
				<h2 class="mb-4 text-3xl font-bold text-white sm:text-4xl">Quick Installation</h2>
				<p class="mx-auto max-w-2xl text-lg text-gray-300">
					Add dart_imagehash to your project in seconds
				</p>
			</div>

			<div class="mx-auto max-w-2xl">
				<div class="rounded-lg border border-white/10 bg-gray-900/50 p-6 backdrop-blur-sm">
					<div class="mb-4 flex items-center justify-between">
						<span class="font-mono text-sm text-gray-400">terminal</span>
					</div>
					<pre class="text-sm text-gray-100"><code>{`dart pub add dart_imagehash`}</code></pre>
				</div>
				<div class="mt-6 text-center">
					<span class="text-gray-400"
						>This will automatically add the latest version to your pubspec.yaml</span
					>
				</div>
			</div>
		</div>
	</section>
</div>

<style>
	.animate-fade-in-up {
		animation: fadeInUp 0.8s ease-out;
	}

	@keyframes fadeInUp {
		from {
			opacity: 0;
			transform: translateY(30px);
		}
		to {
			opacity: 1;
			transform: translateY(0);
		}
	}

	.feature-card {
		animation: fadeInUp 0.6s ease-out both;
	}
</style>
