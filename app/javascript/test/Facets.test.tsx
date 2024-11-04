import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';

import { Facets } from '../components/Facets/Facets';

describe('Facets component', () => {
  it('renders Facets component', () => {
    render(
      <Facets facetsEnabled={true} />
    );
  });

  it('shows Filter search label', () => {
    render(
      <Facets facetsEnabled={true} />
    );
    expect(screen.getByText('Filter search')).toBeInTheDocument();
  });

  it('shows aggegations', () => {
    render(
      <Facets facetsEnabled={true} />
    );
    expect(screen.getByText('Audience')).toBeInTheDocument();
    expect(screen.getByText('Small business')).toBeInTheDocument();

    expect(screen.getByText('Content Type')).toBeInTheDocument();
    expect(screen.getByText('Press release')).toBeInTheDocument();

    expect(screen.getByText('File Type')).toBeInTheDocument();
    expect(screen.getByText('CSV')).toBeInTheDocument();

    expect(screen.getByText('Tags')).toBeInTheDocument();
    expect(screen.getByText('Contracts')).toBeInTheDocument();

    expect(screen.getByText('Date Range')).toBeInTheDocument();
    expect(screen.getByText('Last year')).toBeInTheDocument();
    
    const checkboxElement = screen.getByRole('checkbox', { name: /small business/i });
    expect(checkboxElement).not.toBeChecked();

    fireEvent.click(checkboxElement);
    expect(checkboxElement).toBeChecked();
    
    fireEvent.click(checkboxElement);
    expect(checkboxElement).not.toBeChecked();
  });

  it('shows Clear and See Results button', () => {
    render(
      <Facets facetsEnabled={true} />
    );
    expect(screen.getByText('Clear')).toBeInTheDocument();
    expect(screen.getByText('See Results')).toBeInTheDocument();

    const seeResultsBtnLabel = screen.getByText(/See Results/i);
    fireEvent.click(seeResultsBtnLabel);
  });
});
