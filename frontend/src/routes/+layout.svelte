<script lang="ts">
	import '../app.css';
	import ThemeSwitch from '$lib/components/ThemeSwitch.svelte';

	let { children } = $props();
</script>

<ThemeSwitch />
<header></header>

<nav>
	<!-- <a href="/">Home</a>
    <a href="/about">About</a> -->
</nav>

<main class="min-h-screen p-4 sm:p-8">
	{@render children()}
</main>

<footer></footer>
