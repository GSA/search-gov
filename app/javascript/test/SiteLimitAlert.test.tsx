import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import React from 'react';
import { SiteLimitAlert } from '../components/Results/SiteLimitAlert/SiteLimitAlert';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('Site limit Alert component', () => {
  it('renders SpellingSuggestion component', () => {
    render(
      <SiteLimitAlert 
        sitelimit='www.nps.gov/shen'
        url='/search?affiliate=nps&amp;query=trail+maps' 
        query='government' />
    );
  });
});
