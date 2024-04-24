import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import { Facets } from '../components/Facets/Facets';

describe('Facets component', () => {
  it('renders Facets component', () => {
    render(
      <Facets />
    );
  });

  it('shows Filter search label', () => {
    render(
      <Facets />
    );
    expect(screen.getByText('Filter search')).toBeInTheDocument();
  });

  it('shows aggegations', () => {
    render(
      <Facets />
    );
    expect(screen.getByText('Audience')).toBeInTheDocument();
    expect(screen.getByText('Small business')).toBeInTheDocument();

    expect(screen.getByText('Content Type')).toBeInTheDocument();
    expect(screen.getByText('Press release')).toBeInTheDocument();

    expect(screen.getByText('File Type')).toBeInTheDocument();
    expect(screen.getByText('PDF')).toBeInTheDocument();

    expect(screen.getByText('Tags')).toBeInTheDocument();
    expect(screen.getByText('Contracts')).toBeInTheDocument();

    expect(screen.getByText('Date Range')).toBeInTheDocument();
    expect(screen.getByText('Last year')).toBeInTheDocument();
  });

  it('shows Clear and See Results button', () => {
    render(
      <Facets />
    );
    expect(screen.getByText('Clear')).toBeInTheDocument();
    expect(screen.getByText('See Results')).toBeInTheDocument();
  });
});
