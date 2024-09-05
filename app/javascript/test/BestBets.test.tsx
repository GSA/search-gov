/* eslint-disable camelcase */

import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import { BestBets } from '../components/Results/BestBets/index';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();
jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('Best Bets', () => {
  const additionalResults = { recommendedBy: 'USA.gov', 
    textBestBets: [{
      title: 'A best bet',
      description: 'This is the best bet',
      url: 'http://www.example.com'
    }],
    graphicsBestBet: {
      title: 'Search support',
      titleUrl: 'https://search.gov/support.html',
      imageUrl: 'https://search.gov/support.jpg',
      imageAltText: 'support alt text',
      links: [{ 
        title: 'Learning', 
        url: 'https://search.gov/learn' }] 
    } 
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

  it('calls fetch with correct Text Best Bet click data', () => {
    render(<BestBets {...additionalResults} affiliate='boos_affiliate' query='query' vertical='web' />);
    
    const link = screen.getByText(/A best bet/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'http://www.example.com',
      module_code: 'BOOS',
      position: 1,
      query: 'query',
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

  it('calls fetch with correct Graphics Best Bet click data on image and links', () => {
    render(<BestBets {...additionalResults} affiliate='bbg_affiliate' query='query' vertical='web' />);
    const imageClickBody = {
      affiliate: 'bbg_affiliate',
      url: 'https://search.gov/support.html',
      module_code: 'BBG',
      position: 1,
      query: 'query',
      vertical: 'web'
    };
    const linkClickBody = {
      affiliate: 'bbg_affiliate',
      url: 'https://search.gov/learn',
      module_code: 'BBG',
      position: 2,
      query: 'query',
      vertical: 'web'
    };
    
    const image = screen.getByText(/Search support/i);
    fireEvent.click(image);

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(imageClickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });

    const link = screen.getByText(/Learning/i);
    fireEvent.click(link);

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(linkClickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(2);
  });
});

describe('Mobile view: Best Bets', () => {
  beforeAll(() => {
    window.innerWidth = 450;
  });

  const additionalResults = { recommendedBy: 'USA.gov', 
    textBestBets: [{
      title: 'A best bet',
      description: 'This is the best bet',
      url: 'http://www.example.com'
    }],
    graphicsBestBet: {
      title: 'Search support',
      titleUrl: 'https://search.gov/support.html',
      imageUrl: 'https://search.gov/support.jpg',
      imageAltText: 'support alt text',
      links: [{ 
        title: 'Learning', 
        url: 'https://search.gov/learn' }] 
    } 
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

  it('calls fetch with correct Text Best Bet click data', () => {
    render(<BestBets {...additionalResults} affiliate='boos_affiliate' query='query' vertical='web' />);
    
    const link = screen.getByText(/This is the best bet/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'boos_affiliate',
      url: 'http://www.example.com',
      module_code: 'BOOS',
      position: 1,
      query: 'query',
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


