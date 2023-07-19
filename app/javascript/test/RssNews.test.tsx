import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';

import { RssNews } from '../components/Results/RssNews/RssNews';

describe('Rss News component', () => {
  it('renders rss news component', () => {
    render(
      <RssNews />
    );
  });

  it('shows title', () => {
    render(
      <RssNews />
    );
    expect(screen.getAllByText('News about Benefits')).toHaveLength(1);
  });
});
