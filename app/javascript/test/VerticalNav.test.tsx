import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { VerticalNav } from '../components/VerticalNav/VerticalNav';

describe('VerticalNav', () => {
  it('shows the vertical nav links', () => {
    const relatedSites = [{ label: 'Related Site 1', link: 'example.com' }];

    render(<VerticalNav relatedSites={relatedSites}/>);
    
    const moreLink = screen.getByText(/More/i);
    const relatedSitesLink = screen.getByText(/Related Sites/i);
    expect(moreLink).toBeInTheDocument();
    expect(relatedSitesLink).toBeInTheDocument();

    const moreLinkBtn = screen.getByTestId('moreBtn');
    const [moreLinkChild] = screen.getAllByText(/Link 1/i);
    fireEvent.click(moreLinkBtn);
    expect(moreLinkChild).toBeInTheDocument();

    const relatesSitesBtn = screen.getByTestId('relatedSitesBtn');
    const [relatedSitesChild] = screen.getAllByText(/Related Site 1/i);
    fireEvent.click(relatesSitesBtn);
    expect(relatedSitesChild).toBeInTheDocument();
  });
});
