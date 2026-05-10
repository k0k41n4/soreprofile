<script lang="ts">
	import '../routes/layout.css';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700&display=swap" rel="stylesheet">
	<style>
		:global(body) {
			font-family: 'Outfit', sans-serif;
		}
	</style>
</svelte:head>

<div class="min-h-screen selection:bg-brand-primary/30">
	{@render children()}
</div>
