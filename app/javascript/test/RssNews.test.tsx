import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import parse from 'html-react-parser';

import { RssNews } from '../components/Results/RssNews/RssNews';

describe('Rss News component', () => {
  const newsProps = {
    'news': [
      {
        'title': '<strong>GSA</strong> title',
        'description': 'test description',
        'link': 'https://test.com',
        'publishedAt': '2023-08-17'
      }
    ],
    'recommendedBy': 'gsa',
    parse
  }

  it('renders rss news component', () => {
    render(
      <RssNews {...newsProps}/>
    );
  });

  it('shows title', () => {
    render(
      <RssNews {...newsProps}/>
    );
    expect(screen.getByText('News about gsa')).toBeInTheDocument();
  });
});
