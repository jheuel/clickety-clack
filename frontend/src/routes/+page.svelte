<script lang="ts">
	import TypeBox from '$lib/components/TypeBox.svelte';

	const { data } = $props();
	const { start_text } = $derived(data);
</script>

<TypeBox {start_text} />
