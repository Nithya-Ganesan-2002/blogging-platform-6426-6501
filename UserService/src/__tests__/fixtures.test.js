const fixtures = require('../mock/fixtures.json');
test('fixtures has users array', () => {
  expect(Array.isArray(fixtures.users)).toBe(true);
  expect(fixtures.users.length).toBeGreaterThan(0);
});
