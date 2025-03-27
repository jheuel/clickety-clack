<script lang="ts">
	import { onMount, tick } from 'svelte';

	let text: string | undefined = $state();

	let cursorPosition = $state(-1);

	type TypeEvent = {
		position: number;
		expected: string;
		typed: string;
		timestamp: number;
	};

	let type_events: TypeEvent[] = $state([]);
	let finished_word: number[] = $state([]);
	let char_interval: number[] = $state([]);
	let word_interval: number[] = $state([]);
	let errors: TypeEvent[] = $state([]);
	let inputElement: HTMLInputElement;
	let charElements: HTMLSpanElement[] = $state([]);
	let underlineElement: HTMLDivElement | null = $state(null);
	let containerElement: HTMLButtonElement;

	let chars_per_minute = $derived.by(() => {
		if (char_interval.length < 1) return 0.0;
		const average_duration_per_char =
			char_interval.reduce((acc, curr) => acc + curr, 0) / char_interval.length;
		return 60000 / average_duration_per_char;
	});

	let words_per_minute = $derived.by(() => {
		if (word_interval.length < 1) return 0.0;
		const average_duration_per_word =
			word_interval.reduce((acc, curr) => acc + curr, 0) / word_interval.length;
		return 60000 / average_duration_per_word;
	});

	let char_threshold: number = 1000;
	let word_threshold: number = 5000;

	function splitIntoWords(text: string) {
		const words = text.split(/(\s+)/);
		let currentIndex = 0;
		return words.map((word) => {
			const wordObj = {
				content: word,
				isSpace: word.trim() === '',
				startIndex: currentIndex
			};
			currentIndex += word.length;
			return wordObj;
		});
	}

	function updateUnderline() {
		if (!charElements[cursorPosition]) {
			return;
		}
		if (!underlineElement || !containerElement) {
			return;
		}

		const charRect = charElements[cursorPosition].getBoundingClientRect();
		const containerRect = containerElement.getBoundingClientRect();
		const left = charRect.left - containerRect.left;
		const width = charRect.width || 10;
		const top = charRect.bottom - containerRect.top - 2;

		underlineElement.style.left = `${left}px`;
		underlineElement.style.width = `${width}px`;
		underlineElement.style.top = `${top}px`;
	}

	async function handleKeypress(event: KeyboardEvent) {
		if (text === undefined) return;

		const typedChar = event.key;
		const expectedChar = text[cursorPosition];

		if (typedChar === expectedChar) {
			cursorPosition += 1;
			if (typedChar === ' ') {
				finished_word = [...finished_word, Date.now()];
				if (finished_word.length > 1) {
					const word_delta =
						finished_word[finished_word.length - 1] - finished_word[finished_word.length - 2];
					if (word_delta < word_threshold) {
						word_interval = [...word_interval, word_delta];
					}
				}
			}
			type_events = [
				...type_events,
				{
					position: cursorPosition,
					expected: expectedChar,
					typed: typedChar,
					timestamp: Date.now()
				}
			];
			if (type_events.length > 1) {
				const char_delta =
					type_events[type_events.length - 1].timestamp -
					type_events[type_events.length - 2].timestamp;
				if (char_delta < char_threshold) {
					char_interval = [...char_interval, char_delta];
				}
			}
			await tick();
			updateUnderline();
		} else if (typedChar.length === 1) {
			errors = [
				...errors,
				{
					position: cursorPosition,
					expected: expectedChar,
					typed: typedChar,
					timestamp: Date.now()
				}
			];
		}
	}

	async function fetch_text() {
		try {
			const response = await fetch('/api/text');
			if (!response.ok) {
				throw new Error('Network response was not ok');
			}
			const data = await response.json();
			text = data.text;
			cursorPosition = 0;
			errors = [];
			await tick();
			inputElement.focus();
			updateUnderline();
		} catch (error) {
			console.error('Error fetching text:', error);
		}
	}

	$effect(() => {
		if (text === undefined) return;
		if (cursorPosition >= text.length) {
			fetch_text();
		}
	});

	onMount(() => {
		inputElement.focus();
		updateUnderline();
		window.addEventListener('resize', updateUnderline);
		return () => window.removeEventListener('resize', updateUnderline);
	});

	onMount(fetch_text);
</script>

<div class="relative mx-auto w-full max-w-2xl p-4">
	{#if text === undefined}
		<p>Loading...</p>
	{/if}
	<button
		bind:this={containerElement}
		class="relative w-full rounded-lg border-2 border-gray-300 bg-gray-100 px-4 py-8
           font-mono text-lg break-words dark:border-gray-700 dark:bg-gray-800"
		onclick={() => inputElement.focus()}
	>
		{#if text !== undefined}
			{#each splitIntoWords(text) as word, wordIndex}
				<span class="inline-block whitespace-nowrap">
					{#each word.content as char, charOffset}
						{@const charIndex = word.startIndex + charOffset}
						<span
							bind:this={charElements[charIndex]}
							class={`
                                relative inline-block
                                ${char === ' ' ? 'whitespace-nowrap' : ''}
                                ${errors.some((e) => e.position === charIndex) ? 'text-red-500' : ''}
                            `}
						>
							{#if char === ' '}
								&nbsp;
							{:else}
								{char}
							{/if}
						</span>
					{/each}
				</span>
			{/each}
			<div
				bind:this={underlineElement}
				class="animate-slow-pulse absolute h-[2px] bg-blue-500 transition-[left,width] duration-100 ease-out"
				class:hidden={cursorPosition >= text.length}
			></div>
		{/if}
	</button>

	<input
		id="type-box-input"
		bind:this={inputElement}
		type="text"
		class="absolute h-0 w-0 opacity-0"
		onkeypress={handleKeypress}
		autocomplete="off"
	/>
	{#if errors.length > 0}
		<div class="mt-4 rounded bg-red-50 p-2">
			<h3 class="text-sm font-bold text-red-700 dark:text-red-400">Errors: {errors.length}</h3>
			<ul class="text-sm text-red-600 dark:text-red-400">
				{#each errors as error}
					<li>
						Pos {error.position}: Expected '{error.expected}' but got '{error.typed}'
					</li>
				{/each}
			</ul>
		</div>
	{/if}

	<div class="mt-2 text-sm font-light">
		<div class="flex space-x-4">
			<div class="flex flex-row space-x-4">
				<span class="text-gray-600 dark:text-gray-400"> Typing speed: </span>
				<span class="text-right font-medium text-gray-800 dark:text-gray-200">
					{words_per_minute.toFixed(1)} words/min
				</span>
				<span class="text-right text-gray-600 dark:text-gray-400">
					({chars_per_minute.toFixed(1)} chars/min)
				</span>
			</div>
		</div>
	</div>
</div>

<style>
	@keyframes slow-pulse {
		0% {
			opacity: 1;
		}
		50% {
			opacity: 0.3;
		}
		100% {
			opacity: 1;
		}
	}

	.animate-slow-pulse {
		animation: slow-pulse 2s infinite;
	}
</style>
