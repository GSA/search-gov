/* eslint-disable camelcase */

import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import { ResultGrid } from '../components/Results/ResultGrid/ResultGrid';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

describe('Result Grid: Desktop view, clicking the title link', () => {
  const result = {
    title: 'test result 1',
    url: 'https://www.search.gov',
    description: 'A description'
  };
  const blendedresult = {
    title: 'test result 1',
    url: 'https://www.search.gov',
    description: 'A description',
    blendedModule: 'AIDOC'
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

  it('calls fetch with correct Bing click data', () => {
    render(<ResultGrid result={result} affiliate='bing_affiliate' query='query' position={1} vertical='web' />);

    const title = screen.getByText(/test result 1/i);
    fireEvent.click(title);
    const clickBody = {
      affiliate: 'bing_affiliate',
      url: 'https://www.search.gov',
      module_code: 'BWEB',
      position: 1,
      query: 'query',
      vertical: 'web',
      type: 'click'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('calls fetch with correct Searchgov click data', () => {
    render(<ResultGrid result={result} affiliate='searchgov_affiliate' query='query' position={2} vertical='i14y' />);

    const title = screen.getByText(/test result 1/i);
    fireEvent.click(title);
    const clickBody = {
      affiliate: 'searchgov_affiliate',
      url: 'https://www.search.gov',
      module_code: 'I14Y',
      position: 2,
      query: 'query',
      vertical: 'i14y',
      type: 'click'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('calls fetch with correct Blended click data', () => {
    render(<ResultGrid result={blendedresult} affiliate='blended_affiliate' query='query' position={3} vertical='blended' />);

    const title = screen.getByText(/test result 1/i);
    fireEvent.click(title);
    const clickBody = {
      affiliate: 'blended_affiliate',
      url: 'https://www.search.gov',
      module_code: 'AIDOC',
      position: 3,
      query: 'query',
      vertical: 'blended',
      type: 'click'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('no mobile outline is present when div is clicked', () => {
    render(<ResultGrid result={result} affiliate='bing_affiliate' query='query' position={1} vertical='web' />);

    const desc = screen.getByText(/A description/i);
    fireEvent.click(desc);

    const resultGrid = Array.from(document.getElementsByClassName('mobile-outline'));
    expect(resultGrid.length).toBe(0);
  });
});

describe('Result Grid: Mobile view, clicking the result div', () => {
  beforeAll(() => {
    window.innerWidth = 450;
  });

  const result = {
    title: 'test result 1',
    url: 'https://www.search.gov',
    description: 'A description'
  };
  const blendedresult = {
    title: 'test result 1',
    url: 'https://www.search.gov',
    description: 'A description',
    blendedModule: 'AIDOC'
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

  it('when the result div is clicked, calls fetch with correct Bing click data', () => {
    render(<ResultGrid result={result} affiliate='bing_affiliate' query='query' position={1} vertical='web' />);

    const desc = screen.getByText(/A description/i);
    fireEvent.click(desc);
    const clickBody = {
      affiliate: 'bing_affiliate',
      url: 'https://www.search.gov',
      module_code: 'BWEB',
      position: 1,
      query: 'query',
      vertical: 'web',
      type: 'click'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('when the result div is clicked, calls fetch with correct Searchgov click data', () => {
    render(<ResultGrid result={result} affiliate='searchgov_affiliate' query='query' position={2} vertical='i14y' />);

    const desc = screen.getByText(/A description/i);
    fireEvent.click(desc);
    const clickBody = {
      affiliate: 'searchgov_affiliate',
      url: 'https://www.search.gov',
      module_code: 'I14Y',
      position: 2,
      query: 'query',
      vertical: 'i14y',
      type: 'click'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('when the result div is clicked, calls fetch with correct Blended click data', () => {
    render(<ResultGrid result={blendedresult} affiliate='blended_affiliate' query='query' position={3} vertical='blended' />);

    const desc = screen.getByText(/A description/i);
    fireEvent.click(desc);
    const clickBody = {
      affiliate: 'blended_affiliate',
      url: 'https://www.search.gov',
      module_code: 'AIDOC',
      position: 3,
      query: 'query',
      vertical: 'blended',
      type: 'click'
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
