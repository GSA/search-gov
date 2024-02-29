import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import React from 'react';
import { ResultGrid } from '../components/Results/ResultGrid/ResultGrid';

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
    const [firstResult] = Array.from(document.getElementsByClassName('result-title-link'));
    const clickDataJson = JSON.parse(firstResult.getAttribute('data-click') || '{}');

    expect(clickDataJson.affiliate).toBe('bing_affiliate');
    expect(clickDataJson.url).toBe('https://www.search.gov');
    expect(clickDataJson.module_code).toBe('BWEB');
    expect(clickDataJson.position).toBe(1);
    expect(clickDataJson.query).toBe('query');
    expect(clickDataJson.vertical).toBe('web');
  });

  it('sets correct Searchgov click data', () => {
    render(<ResultGrid result={result} affiliate='searchgov_affiliate' query='query' position={2} vertical='i14y' />);
    const [firstResult] = Array.from(document.getElementsByClassName('result-title-link'));
    const clickDataJson = JSON.parse(firstResult.getAttribute('data-click') || '{}');

    expect(clickDataJson.affiliate).toBe('searchgov_affiliate');
    expect(clickDataJson.url).toBe('https://www.search.gov');
    expect(clickDataJson.module_code).toBe('I14Y');
    expect(clickDataJson.position).toBe(2);
    expect(clickDataJson.query).toBe('query');
    expect(clickDataJson.vertical).toBe('i14y');
  });

  it('sets correct Blended click data', () => {
    render(<ResultGrid result={blendedresult} affiliate='blended_affiliate' query='query' position={3} vertical='blended' />);
    const [firstResult] = Array.from(document.getElementsByClassName('result-title-link'));
    const clickDataJson = JSON.parse(firstResult.getAttribute('data-click') || '{}');

    expect(clickDataJson.affiliate).toBe('blended_affiliate');
    expect(clickDataJson.url).toBe('https://www.search.gov');
    expect(clickDataJson.module_code).toBe('AIDOC');
    expect(clickDataJson.position).toBe(3);
    expect(clickDataJson.query).toBe('query');
    expect(clickDataJson.vertical).toBe('blended');
  });
});
