import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import ErrorPage from '../components/ErrorPage';

describe('ErrorPage', () => {
  it('renders the shared basic header, error content, and slim footer', () => {
    render(
      <ErrorPage
        title="Search Temporarily Unavailable"
        paragraphs={['This page is unavailable.', '<strong>Contact support.</strong>']}
        page={{
          affiliate: 'searchgov',
          displayLogoOnly: true,
          title: 'Search.gov',
          logo: { url: '/errors/images/searchgov-logo.png', text: 'Search.gov' },
          homepageUrl: 'https://search.gov'
        }}
        translations={{
          en: {
            searches: { skipToMainContent: 'Skip to main content' },
            returnToTop: 'Return to top'
          }
        }}
        language={{ code: 'en', rtl: false }}
      />
    );

    expect(screen.getByTestId('header')).toHaveClass('usa-header--basic');
    expect(screen.getByRole('heading', { name: 'Search Temporarily Unavailable' })).toBeInTheDocument();
    expect(screen.getByText('This page is unavailable.')).toBeInTheDocument();
    expect(screen.getByText('Contact support.')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: 'Return to top' })).toHaveAttribute('href', '#main-content');
  });
});
