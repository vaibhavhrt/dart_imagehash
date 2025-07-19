<script lang="ts">
	import '../app.css';
	import { page } from '$app/state';
	import { onMount } from 'svelte';

	let { children } = $props();
	let mobileMenuOpen = $state(false);

	const navigation = [
		{ name: 'Home', href: '/' },
		{ name: 'Features', href: '/features' },
		{ name: 'Demo', href: '/demo' },
		{
			name: 'Documentation',
			href: 'https://pub.dev/documentation/dart_imagehash/latest/',
			external: true
		},
		{ name: 'pub.dev', href: 'https://pub.dev/packages/dart_imagehash', external: true },
		{ name: 'GitHub', href: 'https://github.com/vaibhavhrt/dart_imagehash', external: true }
	];

	// Smooth curve generation functions
	function generateSmoothCurve(
		baseY: number,
		amplitude: number,
		phase: number,
		frequency: number
	): { x: number; y: number }[] {
		const points = [];
		const numPoints = 15;

		for (let i = 0; i <= numPoints; i++) {
			const x = (i / numPoints) * 1920 - 100;

			// Create deeper, more complex waves by combining multiple sine waves
			const primaryWave = Math.sin((i / numPoints) * Math.PI * frequency + phase);
			const secondaryWave =
				Math.sin((i / numPoints) * Math.PI * frequency * 2.5 + phase * 1.3) * 0.4;
			const tertiaryWave =
				Math.sin((i / numPoints) * Math.PI * frequency * 0.7 + phase * 0.8) * 0.6;

			// Combine waves for more organic, deeper curves
			const combinedWave = primaryWave + secondaryWave + tertiaryWave;

			// Increase amplitude significantly for deeper curves
			const y = baseY + combinedWave * amplitude * 1.8;

			points.push({ x, y });
		}

		return points;
	}
	function pointsToPath(points: { x: number; y: number }[]) {
		if (points.length < 2) return '';

		let path = `M${points[0].x},${points[0].y}`;

		// Use smooth curves between all points
		for (let i = 1; i < points.length; i++) {
			const prev = points[i - 1];
			const curr = points[i];

			// Calculate control points for smooth curves
			const cpx1 = prev.x + (curr.x - prev.x) * 0.3;
			const cpy1 = prev.y;
			const cpx2 = curr.x - (curr.x - prev.x) * 0.3;
			const cpy2 = curr.y;

			path += ` C${cpx1},${cpy1} ${cpx2},${cpy2} ${curr.x},${curr.y}`;
		}

		return path;
	}

	let animationTime = $state(0);
	let animationId: number;
	let scrollY = $state(0);
	let ticking = false;

	// Generate dynamic curves
	const curve1 = $derived(pointsToPath(generateSmoothCurve(480, 120, animationTime * 0.5, 2)));
	const curve2 = $derived(
		pointsToPath(generateSmoothCurve(420, 140, animationTime * 0.7 + Math.PI / 4, 1.5))
	);
	const curve3 = $derived(
		pointsToPath(generateSmoothCurve(520, 100, animationTime * 0.6 + Math.PI / 2, 2.5))
	);
	const curve4 = $derived(
		pointsToPath(generateSmoothCurve(580, 160, animationTime * 0.4 + Math.PI, 1.2))
	);

	// Parallax transforms for different layers - gentle floating effect based on time + scroll
	const parallax1 = $derived(
		`translateY(${Math.sin(animationTime * 0.3 + scrollY * 0.0002) * 10}px)`
	);
	const parallax2 = $derived(
		`translateY(${Math.sin(animationTime * 0.4 + scrollY * 0.0003) * 15}px)`
	);
	const parallax3 = $derived(
		`translateY(${Math.sin(animationTime * 0.5 + scrollY * 0.0004) * 12}px)`
	);
	const parallax4 = $derived(
		`translateY(${Math.sin(animationTime * 0.6 + scrollY * 0.0005) * 8}px)`
	);
	const parallax5 = $derived(
		`translateY(${Math.sin(animationTime * 0.7 + scrollY * 0.0006) * 20}px)`
	);

	function updateCurves() {
		animationTime += 0.01;
		animationId = requestAnimationFrame(updateCurves);
	}

	function updateScrollPosition() {
		scrollY = window.scrollY;
		ticking = false;
	}

	function handleScroll() {
		if (!ticking) {
			requestAnimationFrame(updateScrollPosition);
			ticking = true;
		}
	}

	onMount(() => {
		// Start curve animation
		updateCurves();

		// Add scroll listener for parallax effect
		window.addEventListener('scroll', handleScroll, { passive: true });

		return () => {
			if (animationId) {
				cancelAnimationFrame(animationId);
			}
			window.removeEventListener('scroll', handleScroll);
		};
	});

	// Close mobile menu when navigating - reactive effect
	$effect(() => {
		// This will run whenever page changes
		page.url.pathname;
		mobileMenuOpen = false;
	});
</script>

<div
	class="relative min-h-screen overflow-hidden bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900"
>
	<!-- Fixed Top Background Elements (viewport-based) -->
	<div
		class="parallax-layer pointer-events-none fixed inset-0 z-0 overflow-hidden opacity-30"
		style="transform: {parallax1}; height: 120vh; top: -10vh;"
	>
		<!-- Beautiful Curved Flowing Intersecting Lines -->
		<svg
			class="parallax-element absolute inset-0 h-full w-full"
			viewBox="0 0 1920 1080"
			preserveAspectRatio="xMidYMid slice"
		>
			<!-- Primary flowing curve -->
			<path d={curve1} stroke="url(#gradient1)" stroke-width="3" fill="none" opacity="0.6"></path>

			<!-- Secondary intersecting curve -->
			<path d={curve2} stroke="url(#gradient2)" stroke-width="2.5" fill="none" opacity="0.5"></path>

			<!-- Third delicate curve -->
			<path d={curve3} stroke="url(#gradient3)" stroke-width="2" fill="none" opacity="0.4"></path>

			<!-- Fourth wave-like curve -->
			<path d={curve4} stroke="url(#gradient4)" stroke-width="1.5" fill="none" opacity="0.3"></path>

			<!-- Gradient definitions -->
			<defs>
				<linearGradient id="gradient1" x1="0%" y1="0%" x2="100%" y2="0%">
					<stop offset="0%" style="stop-color:#8b5cf6;stop-opacity:0.8" />
					<stop offset="50%" style="stop-color:#06b6d4;stop-opacity:0.6" />
					<stop offset="100%" style="stop-color:#10b981;stop-opacity:0.4" />
				</linearGradient>
				<linearGradient id="gradient2" x1="0%" y1="0%" x2="100%" y2="0%">
					<stop offset="0%" style="stop-color:#ec4899;stop-opacity:0.7" />
					<stop offset="50%" style="stop-color:#f59e0b;stop-opacity:0.5" />
					<stop offset="100%" style="stop-color:#3b82f6;stop-opacity:0.3" />
				</linearGradient>
				<linearGradient id="gradient3" x1="0%" y1="0%" x2="100%" y2="0%">
					<stop offset="0%" style="stop-color:#06b6d4;stop-opacity:0.6" />
					<stop offset="50%" style="stop-color:#8b5cf6;stop-opacity:0.4" />
					<stop offset="100%" style="stop-color:#f59e0b;stop-opacity:0.2" />
				</linearGradient>
				<linearGradient id="gradient4" x1="0%" y1="0%" x2="100%" y2="0%">
					<stop offset="0%" style="stop-color:#10b981;stop-opacity:0.5" />
					<stop offset="50%" style="stop-color:#ec4899;stop-opacity:0.3" />
					<stop offset="100%" style="stop-color:#8b5cf6;stop-opacity:0.1" />
				</linearGradient>
			</defs>
		</svg>

		<!-- Multiple Grid Patterns representing pixelated images -->
		<div
			class="absolute left-10 top-10 hidden h-40 w-40 animate-pulse grid-cols-8 gap-1 md:grid"
			style="transform: {parallax2}"
		>
			{#each Array(64) as _, i}
				<div
					class="rounded-sm bg-gradient-to-br from-purple-400 to-blue-400 opacity-80"
					style="animation-delay: {i * 0.05}s"
				></div>
			{/each}
		</div>

		<!-- Second grid pattern -->
		<div
			class="absolute bottom-32 right-16 grid h-36 w-36 animate-pulse grid-cols-8 gap-1"
			style="transform: {parallax3}"
		>
			{#each Array(64) as _, i}
				<div
					class="rounded-sm bg-gradient-to-br from-emerald-400 to-cyan-400 opacity-70"
					style="animation-delay: {i * 0.03}s"
				></div>
			{/each}
		</div>

		<!-- Third smaller grid -->
		<div
			class="absolute left-1/3 top-1/2 hidden h-24 w-24 animate-pulse grid-cols-6 gap-1 lg:grid"
			style="transform: {parallax2}"
		>
			{#each Array(36) as _, i}
				<div
					class="rounded-sm bg-gradient-to-br from-pink-400 to-purple-400 opacity-60"
					style="animation-delay: {i * 0.08}s"
				></div>
			{/each}
		</div>

		<!-- DCT Frequency Domain representation -->
		<div
			class="absolute right-10 top-1/2 hidden h-28 w-28 grid-cols-4 gap-1 md:grid"
			style="transform: {parallax4}"
		>
			{#each [0.9, 0.7, 0.4, 0.2, 0.6, 0.5, 0.3, 0.1, 0.3, 0.2, 0.1, 0.05, 0.1, 0.05, 0.02, 0.01] as intensity, i}
				<div
					class="animate-pulse rounded-sm bg-gradient-to-br from-yellow-400 to-orange-500"
					style="opacity: {intensity}; animation-delay: {i * 0.1}s"
				></div>
			{/each}
		</div>

		<!-- Additional DCT pattern -->
		<div
			class="absolute bottom-1/2 left-16 hidden h-20 w-20 grid-cols-3 gap-1 lg:grid"
			style="transform: {parallax3}"
		>
			{#each [0.8, 0.6, 0.3, 0.5, 0.4, 0.2, 0.2, 0.1, 0.05] as intensity, i}
				<div
					class="animate-pulse rounded-sm bg-gradient-to-br from-purple-400 to-pink-500"
					style="opacity: {intensity}; animation-delay: {i * 0.15}s"
				></div>
			{/each}
		</div>

		<!-- Hash comparison visualization -->
		<div class="absolute bottom-1/4 right-1/4 hidden md:block" style="transform: {parallax2}">
			<div class="flex items-center space-x-2 opacity-60">
				<div class="h-10 w-10 rounded bg-gradient-to-br from-green-400 to-emerald-500"></div>
				<div class="text-sm text-white">≈</div>
				<div class="h-10 w-10 rounded bg-gradient-to-br from-green-300 to-emerald-400"></div>
			</div>
		</div>

		<!-- Additional comparison -->
		<div class="top-1/5 absolute left-2/3 hidden lg:block" style="transform: {parallax3}">
			<div class="flex flex-col items-center space-y-1 opacity-50">
				<div class="h-8 w-8 rounded bg-gradient-to-br from-blue-400 to-cyan-500"></div>
				<div class="text-xs text-white">vs</div>
				<div class="h-8 w-8 rounded bg-gradient-to-br from-red-400 to-pink-500"></div>
			</div>
		</div>

		<!-- Image Icons -->
		<div
			class="absolute left-10 top-3/4 animate-pulse text-5xl opacity-30"
			style="transform: {parallax4}"
		>
			🖼️
		</div>
		<div
			class="absolute right-1/3 top-20 hidden animate-pulse text-4xl opacity-25 md:block"
			style="animation-delay: 2s; transform: {parallax5}"
		>
			📷
		</div>
		<div
			class="absolute bottom-40 left-1/3 animate-pulse text-3xl opacity-30"
			style="animation-delay: 1s; transform: {parallax3}"
		>
			🎨
		</div>
		<div
			class="absolute left-3/4 top-1/2 hidden animate-pulse text-3xl opacity-20 lg:block"
			style="animation-delay: 3s; transform: {parallax2}"
		>
			📊
		</div>
		<div
			class="bottom-1/5 absolute right-10 hidden animate-pulse text-4xl opacity-25 md:block"
			style="animation-delay: 1.5s; transform: {parallax4}"
		>
			🔍
		</div>

		<!-- Algorithm symbols -->
		<div
			class="absolute left-1/2 top-1/3 hidden animate-pulse font-mono text-2xl text-purple-400 opacity-50 md:block"
			style="animation-delay: 1.5s; transform: {parallax3}"
		>
			Σ
		</div>
		<div
			class="absolute bottom-1/2 left-1/4 hidden animate-pulse font-mono text-2xl text-blue-400 opacity-50 lg:block"
			style="animation-delay: 3s; transform: {parallax5}"
		>
			∇
		</div>
		<div
			class="top-1/5 left-1/5 absolute hidden animate-pulse font-mono text-xl text-emerald-400 opacity-45 md:block"
			style="animation-delay: 2.5s; transform: {parallax2}"
		>
			∞
		</div>
		<div
			class="absolute bottom-1/4 left-2/3 hidden animate-pulse font-mono text-xl text-pink-400 opacity-45 lg:block"
			style="animation-delay: 4s; transform: {parallax4}"
		>
			ƒ
		</div>

		<!-- Floating Hash Blocks -->
		<div
			class="animate-float absolute left-1/4 top-1/3 h-20 w-20 rotate-12 transform rounded-lg bg-gradient-to-br from-cyan-400 to-blue-500 opacity-50"
			style="transform: {parallax3} rotate(12deg)"
		></div>
		<div
			class="animate-float-delayed absolute bottom-1/3 right-1/3 hidden h-16 w-16 -rotate-12 transform rounded-lg bg-gradient-to-br from-purple-400 to-pink-500 opacity-50 md:block"
			style="transform: {parallax5} rotate(-12deg)"
		></div>
		<div
			class="animate-float absolute left-1/2 top-1/4 h-12 w-12 rotate-45 transform rounded-full bg-gradient-to-br from-yellow-400 to-orange-500 opacity-45"
			style="animation-delay: 1s; transform: {parallax2} rotate(45deg)"
		></div>
		<div
			class="left-1/5 animate-float-delayed absolute bottom-1/4 hidden h-14 w-14 -rotate-6 transform rounded-lg bg-gradient-to-br from-emerald-400 to-teal-500 opacity-45 lg:block"
			style="transform: {parallax4} rotate(-6deg)"
		></div>
		<div
			class="right-1/5 w-18 h-18 rotate-30 animate-float absolute top-3/4 hidden transform rounded-lg bg-gradient-to-br from-indigo-400 to-purple-500 opacity-40 md:block"
			style="animation-delay: 3s; transform: {parallax3} rotate(30deg)"
		></div>
	</div>

	<!-- Repeating Pattern Background -->
	<div
		class="parallax-layer pointer-events-none absolute inset-0 z-0 opacity-10 md:opacity-25"
		style="transform: {parallax2}"
	>
		<!-- Grid patterns scattered throughout -->
		<div class="bg-pattern-grids"></div>
		<!-- Binary code patterns -->
		<div class="bg-pattern-binary" style="transform: {parallax3}"></div>
		<!-- DCT frequency grids -->
		<div class="bg-pattern-dct" style="transform: {parallax4}"></div>
		<!-- Wavelet curves -->
		<div class="bg-pattern-wavelets" style="transform: {parallax2}"></div>
		<!-- Curved line patterns -->
		<div class="bg-pattern-curves" style="transform: {parallax5}"></div>
		<!-- Hash comparisons -->
		<div class="bg-pattern-comparisons" style="transform: {parallax3}"></div>
		<!-- Image icons -->
		<div class="bg-pattern-icons" style="transform: {parallax4}"></div>
		<!-- Math symbols -->
		<div class="bg-pattern-symbols" style="transform: {parallax2}"></div>

		<!-- SVG Curved Lines that scroll with content -->
	</div>
	<nav class="sticky top-0 z-50 border-b border-white/10 bg-black/20 backdrop-blur-md">
		<div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
			<div class="flex h-16 items-center justify-between">
				<div class="flex items-center">
					<a href="/" class="gradient-text text-2xl font-bold"> dart_imagehash </a>
				</div>

				<!-- Desktop Navigation -->
				<div class="hidden md:block">
					<div class="ml-10 flex items-baseline space-x-4">
						{#each navigation as item}
							{#if item.external}
								<a
									href={item.href}
									target="_blank"
									rel="noopener noreferrer"
									class="flex items-center gap-1 rounded-md px-3 py-2 text-sm font-medium text-gray-300 transition-colors hover:text-white"
								>
									{item.name}
									<svg class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
										<path
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="2"
											d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
										/>
									</svg>
								</a>
							{:else}
								<a
									href={item.href}
									class="rounded-md px-3 py-2 text-sm font-medium text-gray-300 transition-colors hover:text-white"
									class:text-white={page.url.pathname === item.href}
								>
									{item.name}
								</a>
							{/if}
						{/each}
					</div>
				</div>

				<!-- Mobile menu button -->
				<div class="md:hidden">
					<button
						onclick={() => (mobileMenuOpen = !mobileMenuOpen)}
						class="inline-flex items-center justify-center rounded-md p-2 text-gray-300 hover:text-white focus:outline-none focus:ring-2 focus:ring-white focus:ring-offset-2 focus:ring-offset-gray-800"
						aria-label="Toggle mobile navigation menu"
					>
						<svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M4 6h16M4 12h16M4 18h16"
							></path>
						</svg>
					</button>
				</div>
			</div>
		</div>

		<!-- Mobile Navigation -->
		{#if mobileMenuOpen}
			<div class="md:hidden">
				<div class="space-y-1 bg-black/30 px-2 pb-3 pt-2 backdrop-blur-md sm:px-3">
					{#each navigation as item}
						{#if item.external}
							<a
								href={item.href}
								target="_blank"
								rel="noopener noreferrer"
								class="flex items-center gap-2 rounded-md px-3 py-2 text-base font-medium text-gray-300 transition-colors hover:text-white"
							>
								{item.name}
								<svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"
									/>
								</svg>
							</a>
						{:else}
							<a
								href={item.href}
								class="block rounded-md px-3 py-2 text-base font-medium text-gray-300 transition-colors hover:text-white"
								class:text-white={page.url.pathname === item.href}
							>
								{item.name}
							</a>
						{/if}
					{/each}
				</div>
			</div>
		{/if}
	</nav>

	<main class="flex-1">
		{@render children()}
	</main>

	<footer class="mt-20 border-t border-white/10 bg-black/20 backdrop-blur-md">
		<div class="mx-auto max-w-7xl px-4 py-8 sm:px-6 lg:px-8">
			<div class="text-center">
				<p class="text-gray-400">
					© 2025 dart_imagehash. Built with ❤️ using Svelte and Tailwind CSS.
				</p>
				<div class="mt-4">
					<a
						href="https://github.com/vaibhavhrt/dart_imagehash"
						target="_blank"
						rel="noopener noreferrer"
						class="text-gray-400 transition-colors hover:text-white"
					>
						View on GitHub
					</a>
				</div>
			</div>
		</div>
	</footer>
</div>
