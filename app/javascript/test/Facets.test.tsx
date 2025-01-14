import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';

import { Facets } from '../components/Facets/Facets';

describe('Facets component', () => {
  it('renders Facets component', () => {
    render(
      <Facets aggregations={[]} />
    );
  });

  it('shows Filter search label', () => {
    render(
      <Facets aggregations={[]} />
    );
    expect(screen.getByText('Filter search')).toBeInTheDocument();
  });

  it('shows aggegations', () => {
    render(
      <Facets aggregations={[]} />
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

    const checkbox1 = screen.getByRole('checkbox', { name: /small business/i });
    expect(checkbox1).not.toBeChecked();

    fireEvent.click(checkbox1);
    expect(checkbox1).toBeChecked();

    fireEvent.click(checkbox1);
    expect(checkbox1).not.toBeChecked();

    const checkbox2 = screen.getByRole('checkbox', { name: /real estate/i });
    const checkbox3 = screen.getByRole('checkbox', { name: /technologists/i });

    // Initially, selectedIds should be empty
    expect(checkbox2).not.toBeChecked();
    expect(checkbox3).not.toBeChecked();

    fireEvent.click(checkbox2);
    expect(checkbox2).toBeChecked();

    fireEvent.click(checkbox2);
    expect(checkbox2).not.toBeChecked();
  });

  it('shows Clear and See Results button', () => {
    render(
      <Facets aggregations={[]} />
    );
    expect(screen.getByText('Clear')).toBeInTheDocument();
    expect(screen.getByText('See Results')).toBeInTheDocument();

    const seeResultsBtnLabel = screen.getByText(/See Results/i);
    fireEvent.click(seeResultsBtnLabel);

    const clearBtnLabel = screen.getByText(/Clear/i);
    fireEvent.click(clearBtnLabel);
  });
});
