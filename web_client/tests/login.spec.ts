import { test, expect } from '@playwright/test';

test('should login successfully and redirect to dashboard', async ({ page }) => {
    // 1. Navigate to the login page
    await page.goto('/login');

    // 2. Verify we are on the login page
    await expect(page).toHaveTitle(/EduFlow/);
    await expect(page.locator('h3')).toContainText('Sign In to EduFlow');

    // 3. Fill in the credentials
    await page.fill('input[type="email"]', 'admin@eduflow.com');
    await page.fill('input[type="password"]', 'adminpassword');

    // 4. Click the login button
    await page.getByRole('button', { name: 'Sign In' }).click();

    // 5. Verify redirection to dashboard
    await page.waitForURL('/dashboard');
    await expect(page).toHaveURL(/.*\/dashboard/);

    // 6. Verify dashboard content loads
    await expect(page.locator('h1')).toContainText('Platform Command Center');
});
