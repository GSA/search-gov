import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { Header } from '../components/Header';

describe('Header', () => {
  const page = {
    title: 'Search.gov',
    logo: {
      url: 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg',
      text: 'search.gov'
    }
  };

  const primaryHeaderLinks = [
    { title: 'first primary header link', url: 'https://first.gov' },
    { title: 'second primary header link', url: 'https://second.gov' }
  ];

  const secondaryHeaderLinks = [
    { title: 'first secondary header link', url: 'https://first.gov' },
    { title: 'second secondary header link', url: 'https://second.gov' }
  ];

  it('shows agency title and links in the basic header', () => {
    render(<Header page={page} isBasic={true} primaryHeaderLinks={primaryHeaderLinks} secondaryHeaderLinks={secondaryHeaderLinks} />);
    const title = screen.getByText(/Search.gov/i);
    expect(title).toBeInTheDocument();

    const [firstPrimaryHeaderLink, secondPrimaryHeaderLink] = Array.from(document.getElementsByClassName('usa-nav__link'));
    expect(firstPrimaryHeaderLink).toHaveAttribute('href', 'https://first.gov');
    expect(firstPrimaryHeaderLink).toHaveTextContent('first primary header link');

    expect(secondPrimaryHeaderLink).toHaveAttribute('href', 'https://second.gov');
    expect(secondPrimaryHeaderLink).toHaveTextContent('second primary header link');

    const [firstSecondaryHeaderLink, secondSecondaryHeaderLink] = Array.from(document.getElementsByClassName('usa-nav__secondary-item'));
    expect(firstSecondaryHeaderLink.childNodes[0]).toHaveAttribute('href', 'https://first.gov');
    expect(firstSecondaryHeaderLink.childNodes[0]).toHaveTextContent('first secondary header link');

    expect(secondSecondaryHeaderLink.childNodes[0]).toHaveAttribute('href', 'https://second.gov');
    expect(secondSecondaryHeaderLink.childNodes[0]).toHaveTextContent('second secondary header link');

    // To Do - investigate test cases for responsive
    const btn = screen.getByTestId('usa-menu-mob-btn'); // Menu button for mobile
    fireEvent.click(btn);
    expect(firstPrimaryHeaderLink).toBeInTheDocument();
  });

  it('shows agency title and links in the extended header', () => {
    render(<Header page={page} isBasic={false} primaryHeaderLinks={primaryHeaderLinks} secondaryHeaderLinks={secondaryHeaderLinks} />);

    const title = screen.getByText(/Search.gov/i);
    expect(title).toBeInTheDocument();

    const [firstPrimaryHeaderLink, secondPrimaryHeaderLink] = Array.from(document.getElementsByClassName('usa-nav__link'));
    expect(firstPrimaryHeaderLink).toHaveAttribute('href', 'https://first.gov');
    expect(firstPrimaryHeaderLink).toHaveTextContent('first primary header link');

    expect(secondPrimaryHeaderLink).toHaveAttribute('href', 'https://second.gov');
    expect(secondPrimaryHeaderLink).toHaveTextContent('second primary header link');

    const [firstSecondaryHeaderLink, secondSecondaryHeaderLink] = Array.from(document.getElementsByClassName('usa-nav__secondary-item'));
    expect(firstSecondaryHeaderLink.childNodes[0]).toHaveAttribute('href', 'https://first.gov');
    expect(firstSecondaryHeaderLink.childNodes[0]).toHaveTextContent('first secondary header link');

    expect(secondSecondaryHeaderLink.childNodes[0]).toHaveAttribute('href', 'https://second.gov');
    expect(secondSecondaryHeaderLink.childNodes[0]).toHaveTextContent('second secondary header link');
  });
});
