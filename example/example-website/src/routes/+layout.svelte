<script lang="ts">
	import '../app.css';
	import { page } from '$app/stores';
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

	onMount(() => {
		// Close mobile menu when navigating
		return page.subscribe(() => {
			mobileMenuOpen = false;
		});
	});
</script>

<div class="min-h-screen bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900">
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
									class="rounded-md px-3 py-2 text-sm font-medium text-gray-300 transition-colors hover:text-white"
								>
									{item.name}
								</a>
							{:else}
								<a
									href={item.href}
									class="rounded-md px-3 py-2 text-sm font-medium text-gray-300 transition-colors hover:text-white"
									class:text-white={$page.url.pathname === item.href}
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
								class="block rounded-md px-3 py-2 text-base font-medium text-gray-300 transition-colors hover:text-white"
							>
								{item.name}
							</a>
						{:else}
							<a
								href={item.href}
								class="block rounded-md px-3 py-2 text-base font-medium text-gray-300 transition-colors hover:text-white"
								class:text-white={$page.url.pathname === item.href}
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
