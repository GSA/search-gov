import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

import { RssNews } from '../components/Results/RssNews/RssNews';

describe('Rss News component', () => {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  const newsProps = {
    affiliate: 'test_affiliate',
    news: [
      {
        title: '<strong>GSA</strong> title',
        description: 'test description',
        link: 'https://test.com',
        publishedAt: '2023-08-17'
      }
    ],
    newsLabel: 'News about gsa',
    query: 'news',
    vertical: 'web'
  };

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

  it('calls fetch with correct rss news click data', () => {
    render(<RssNews {...newsProps}/>);

    const link = screen.getByText(/title/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'test_affiliate',
      url: 'https://test.com',
      module_code: 'NEWS',
      position: 1,
      query: 'news',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});

describe('Mobile view: RSS news clicking the content div', () => {
  beforeAll(() => {
    window.innerWidth = 450;
  });

  const newsProps = {
    affiliate: 'test_affiliate',
    news: [
      {
        title: '<strong>GSA</strong> title',
        description: 'test description',
        link: 'https://test.com',
        publishedAt: '2023-08-17'
      }
    ],
    newsLabel: 'News about gsa',
    query: 'news',
    vertical: 'web'
  };

  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  it('calls fetch with correct federal reg document click data', () => {
    render(<RssNews {...newsProps}/>);

    const desc = screen.getByText(/test description/i);
    fireEvent.click(desc);
    const clickBody = {
      affiliate: 'test_affiliate',
      url: 'https://test.com',
      module_code: 'NEWS',
      position: 1,
      query: 'news',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});
