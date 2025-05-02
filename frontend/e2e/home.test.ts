import { expect, test } from '@playwright/test';

test('home page has expected span with content "Typing speed"', async ({ page }) => {
	await page.goto('/');
	await expect(page.locator('span:has-text("Typing speed")')).toBeVisible();
});

test('take screenshot of the main content', async ({ page }) => {
	const test_text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.';
	await page.goto(`/?start_text=${test_text}`);
	const element = await page.locator('body > div > main > div');
	await element.screenshot({
		path: 'playwright-report/main_content.jpeg',
	});
});
