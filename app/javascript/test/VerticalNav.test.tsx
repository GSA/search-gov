import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { VerticalNav } from '../components/VerticalNav/VerticalNav';

describe('VerticalNav', () => {
  it('shows the vertical nav links', () => {
    render(<VerticalNav />);
    
    const moreLink = screen.getByText(/More/i);
    const relatedSitesLink = screen.getByText(/Related Sites/i);
    expect(moreLink).toBeInTheDocument();
    expect(relatedSitesLink).toBeInTheDocument();

    const moreLinkBtn = screen.getByTestId('moreBtn');
    const moreLinkChild = screen.getAllByText(/Link 1/i)[0];
    fireEvent.click(moreLinkBtn);
    expect(moreLinkChild).toBeInTheDocument();

    const relatesSitesBtn = screen.getByTestId('relatedSitesBtn');
    const relatedSitesChild = screen.getAllByText(/Related Site 1/i)[0];
    fireEvent.click(relatesSitesBtn);
    expect(relatedSitesChild).toBeInTheDocument();
  });
});
