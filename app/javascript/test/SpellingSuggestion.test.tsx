import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import React from 'react';
import { SpellingSuggestion } from '../components/Results/SpellingSuggestion/SpellingSuggestion';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('SpellingSuggestion component', () => {
  const spellingSuggestionProps = {
    suggested: '<a class=\"suggestedQuery\" href=\"/search?affiliate=logo_alignment&amp;query=medical\">medical</a>',
    original: '<a class=\"originalQuery\" href=\"/search?affiliate=logo_alignment&amp;query=%2Bmecidal\">mecidal</a>',
    originalUrl: '/search?affiliate=logo_alignment&query=%2Bmecidal',
    originalQuery: 'mecidal',
    suggestedQuery: 'medical',
    suggestedUrl: '/search?affiliate=logo_alignment&query=medical',
    affiliate: 'logo_alignment',
    vertical: 'web'
  }

  it('renders SpellingSuggestion component', () => {
    render(
      <SpellingSuggestion {...spellingSuggestionProps} />
    );
  });
});
