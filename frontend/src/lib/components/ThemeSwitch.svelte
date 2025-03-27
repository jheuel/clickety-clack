<script lang="ts">
	import { onMount } from 'svelte';

	// Function to toggle the 'dark' class based on preference
	function updateDarkMode(): void {
		const prefersDarkMode: boolean = window.matchMedia('(prefers-color-scheme: dark)').matches;
		if (prefersDarkMode) {
			document.documentElement.classList.add('dark');
		} else {
			document.documentElement.classList.remove('dark');
		}
	}

	onMount(() => {
		// Set initial state
		updateDarkMode();

		// Listen for changes in the preference
		const mediaQuery: MediaQueryList = window.matchMedia('(prefers-color-scheme: dark)');
		mediaQuery.addEventListener('change', updateDarkMode);

		// Cleanup event listener on component destroy
		return () => {
			mediaQuery.removeEventListener('change', updateDarkMode);
		};
	});
</script>
