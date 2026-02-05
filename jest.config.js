module.exports = {
  transform: {
    '^.+\\.(ts|tsx)$': 'ts-jest'
  },
  collectCoverage: true,
  collectCoverageFrom: ['app/javascript/components/**/*.{ts,tsx}'],
  coverageDirectory: 'coverage',
  clearMocks: true,
  testEnvironment: 'jsdom',
  moduleNameMapper: {
    '\\.(css|less|scss)$': 'identity-obj-proxy',
    '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$': '<rootDir>app/javascript/test/__mocks__/fileMock.js'
  },
  testMatch: [
    '<rootDir>/app/javascript/test/**/*test.{ts,tsx}'
  ],
  setupFiles: ['jest-canvas-mock']
};
