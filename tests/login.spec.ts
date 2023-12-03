import { test, expect, type Page } from '@playwright/test';

test.beforeEach(async ({ page }) => {
  await page.goto('http://nextcloud.local');
});


test.describe('New Todo', () => {
  test('see the nextcloud login page', async ({ page }) => {
    await expect(page).toHaveTitle('Login – Nextcloud');    
  });

  test('login to nextcloud as admin', async ({ page }) => {
    await page.fill('#user', 'admin');
    await page.fill('#password', 'admin');
    await page.getByRole('button', { name: 'Log in' }).click();
    await page.goto('http://nextcloud.local/index.php/apps/files');
  });
});