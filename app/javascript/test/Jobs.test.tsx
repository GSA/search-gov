import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import { Jobs } from '../components/Results/Jobs/Jobs';

Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: jest.fn().mockImplementation(query => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(), // deprecated
    removeListener: jest.fn(), // deprecated
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});

describe('Jobs component', () => {
  it('renders Jobs component', () => {
    render(
      <Jobs />
    );
  });

  it('shows title', () => {
    render(
      <Jobs />
    );
    expect(screen.getByText('Job Openings at SSA')).toBeInTheDocument();
  });
});
