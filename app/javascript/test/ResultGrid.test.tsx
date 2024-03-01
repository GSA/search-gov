import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import { ResultGrid } from '../components/Results/ResultGrid/ResultGrid';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

describe('Result Grid', () => {
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

  it('sets correct Bing click data', () => {
    render(<ResultGrid result={result} affiliate='bing_affiliate' query='query' position={1} vertical='web' />);

    const title = screen.getByText(/test result 1/i);
    fireEvent.click(title);
  });

  it('sets correct Searchgov click data', () => {
    render(<ResultGrid result={result} affiliate='searchgov_affiliate' query='query' position={2} vertical='i14y' />);

    const title = screen.getByText(/test result 1/i);
    fireEvent.click(title);
  });

  it('sets correct Blended click data', () => {
    render(<ResultGrid result={blendedresult} affiliate='blended_affiliate' query='query' position={3} vertical='blended' />);

    const title = screen.getByText(/test result 1/i);
    fireEvent.click(title);
  });
});
