import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import React from 'react';
import { RelatedSearches } from '../components/Results/RelatedSearches/RelatedSearches';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('Related Searches component', () => {
  const relatedSearchesProps = [{
    label: 'jupiter',
    link: '/search?affiliate=rss&query=jupiter+planet'
  }];

  it('renders Related Searches component', () => {
    render(
      <RelatedSearches relatedSearches={...relatedSearchesProps} />
    );
  });

  it('shows Related Searches title and its link', () => {
    render(
      <RelatedSearches relatedSearches={...relatedSearchesProps} />
    );
    const link = Array.from(document.getElementsByClassName('result-title-link')).pop() as HTMLParagraphElement;
    expect(link).toHaveAttribute('href', '/search?affiliate=rss&query=jupiter+planet');
  });
});
