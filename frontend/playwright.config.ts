import { defineConfig } from '@playwright/test';

export default defineConfig({
	webServer: {
		// command: 'npm run build && npm run preview',
		command: 'npm run dev',
		port: 5173
	},
	reporter: 'html',
	testDir: 'e2e'
});
