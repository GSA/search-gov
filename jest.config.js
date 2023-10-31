module.exports = {
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest'
  },
  collectCoverage: true,
  collectCoverageFrom: ['app/javascript/components/**/*.{ts,tsx}'],
  coverageDirectory: 'coverage',
  testEnvironment: 'jsdom',
  moduleNameMapper: {
    '\\.(css|less|scss)$': 'identity-obj-proxy'
  },
  testMatch: [
    '<rootDir>/app/javascript/test/**/*test.{ts,tsx}'
  ],
  setupFiles: ['jest-canvas-mock']
};
